LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY SDRNCOWaveformGen IS
  PORT( clk                               :   IN    std_logic;
        reset                             :   IN    std_logic;
        enb                               :   IN    std_logic;
        phaseIdx                          :   IN    std_logic_vector(19 DOWNTO 0);  -- ufix20_E7
        sine                              :   OUT   std_logic_vector(19 DOWNTO 0);  -- sfix20_En18
        cosine                            :   OUT   std_logic_vector(19 DOWNTO 0)  -- sfix20_En18
        );
END SDRNCOWaveformGen;


ARCHITECTURE rtl OF SDRNCOWaveformGen IS

  -- Component Declarations
  COMPONENT SDRNCOLookUpTableGen
    PORT( clk                             :   IN    std_logic;
          reset                           :   IN    std_logic;
          enb                             :   IN    std_logic;
          lutaddr                         :   IN    std_logic_vector(17 DOWNTO 0);  -- ufix18
          lutoutput                       :   OUT   std_logic_vector(19 DOWNTO 0)  -- sfix20_En18
          );
  END COMPONENT;

  -- Component Configuration Statements
  FOR ALL : SDRNCOLookUpTableGen
    USE ENTITY work.SDRNCOLookUpTableGen(rtl);

  -- Signals
  SIGNAL phaseIdx_unsigned                : unsigned(19 DOWNTO 0);  -- ufix20_E7
  SIGNAL selsign                          : std_logic;  -- ufix1
  SIGNAL SelsignRegister_reg              : std_logic_vector(0 TO 3);  -- ufix1 [4]
  SIGNAL selsignreg                       : std_logic;  -- ufix1
  SIGNAL lutaddrexd                       : unsigned(18 DOWNTO 0);  -- ufix19
  SIGNAL addrOverFsin                     : std_logic;  -- ufix1
  SIGNAL seladdr                          : std_logic;  -- ufix1
  SIGNAL lutaddr1                         : unsigned(17 DOWNTO 0);  -- ufix18
  SIGNAL lutaddrmax                       : unsigned(18 DOWNTO 0);  -- ufix19
  SIGNAL lutaddr2                         : unsigned(17 DOWNTO 0);  -- ufix18
  SIGNAL lutaddrsin                       : unsigned(17 DOWNTO 0);  -- ufix18
  SIGNAL AddrOverFsinRegister_reg         : std_logic_vector(0 TO 3);  -- ufix1 [4]
  SIGNAL addrOverFsinreg                  : std_logic;  -- ufix1
  SIGNAL lutoutsin                        : std_logic_vector(19 DOWNTO 0);  -- ufix20
  SIGNAL lutoutsin_signed                 : signed(19 DOWNTO 0);  -- sfix20_En18
  SIGNAL ampOne                           : signed(19 DOWNTO 0);  -- sfix20_En18
  SIGNAL lutoutsin_ampOne                 : signed(19 DOWNTO 0);  -- sfix20_En18
  SIGNAL uminus_cast                      : signed(20 DOWNTO 0);  -- sfix21_En18
  SIGNAL uminus_cast_1                    : signed(20 DOWNTO 0);  -- sfix21_En18
  SIGNAL lutoutsin_ampOne_inv             : signed(19 DOWNTO 0);  -- sfix20_En18
  SIGNAL sine_tmp                         : signed(19 DOWNTO 0);  -- sfix20_En18
  SIGNAL selsign_1                        : std_logic;  -- ufix1
  SIGNAL SelsignCosRegister_reg           : std_logic_vector(0 TO 3);  -- ufix1 [4]
  SIGNAL selsign_cosreg                   : std_logic;  -- ufix1
  SIGNAL addreqzero                       : std_logic;  -- ufix1
  SIGNAL clkenbRegister_reg               : std_logic;  -- ufix1
  SIGNAL enbreg                           : std_logic;  -- ufix1
  SIGNAL addreqzero_1                     : std_logic;  -- ufix1
  SIGNAL lutaddrcos                       : unsigned(17 DOWNTO 0);  -- ufix18
  SIGNAL AddrOverFcosRegister_reg         : std_logic_vector(0 TO 3);  -- ufix1 [4]
  SIGNAL addrOverFcosreg                  : std_logic;  -- ufix1
  SIGNAL lutoutcos                        : std_logic_vector(19 DOWNTO 0);  -- ufix20
  SIGNAL lutoutcos_signed                 : signed(19 DOWNTO 0);  -- sfix20_En18
  SIGNAL lutoutcos_ampOne                 : signed(19 DOWNTO 0);  -- sfix20_En18
  SIGNAL uminus_cast_2                    : signed(20 DOWNTO 0);  -- sfix21_En18
  SIGNAL uminus_cast_3                    : signed(20 DOWNTO 0);  -- sfix21_En18
  SIGNAL lutoutcos_ampOne_inv             : signed(19 DOWNTO 0);  -- sfix20_En18
  SIGNAL cosine_tmp                       : signed(19 DOWNTO 0);  -- sfix20_En18

BEGIN
  u_SineWave_inst : SDRNCOLookUpTableGen
    PORT MAP( clk => clk,
              reset => reset,
              enb => enb,
              lutaddr => std_logic_vector(lutaddrsin),  -- ufix18
              lutoutput => lutoutsin  -- sfix20_En18
              );

  u_CosineWave_inst : SDRNCOLookUpTableGen
    PORT MAP( clk => clk,
              reset => reset,
              enb => enb,
              lutaddr => std_logic_vector(lutaddrcos),  -- ufix18
              lutoutput => lutoutcos  -- sfix20_En18
              );

  phaseIdx_unsigned <= unsigned(phaseIdx);

  -- Sine sign selection signal
  selsign <= phaseIdx_unsigned(19);

  SelsignRegister_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        SelsignRegister_reg <= (OTHERS => '0');
      ELSIF enb = '1' THEN
        SelsignRegister_reg(0) <= selsign;
        SelsignRegister_reg(1 TO 3) <= SelsignRegister_reg(0 TO 2);
      END IF;
    END IF;
  END PROCESS SelsignRegister_process;

  selsignreg <= SelsignRegister_reg(3);

  -- Get extended LUT address for overflow handling
  lutaddrexd <= phaseIdx_unsigned(18 DOWNTO 0);

  -- Detect sine overflow
  
  addrOverFsin <= '1' WHEN lutaddrexd = 262144 ELSE
      '0';

  seladdr <= phaseIdx_unsigned(18);

  lutaddr1 <= phaseIdx_unsigned(17 DOWNTO 0);

  -- Map LUT address in correct phase
  lutaddrmax <= to_unsigned(2#1000000000000000000#, 19);

  lutaddr2 <= resize(resize(lutaddrmax, 20) - resize(lutaddr1, 20), 18);

  
  lutaddrsin <= lutaddr1 WHEN seladdr = '0' ELSE
      lutaddr2;

  AddrOverFsinRegister_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        AddrOverFsinRegister_reg <= (OTHERS => '0');
      ELSIF enb = '1' THEN
        AddrOverFsinRegister_reg(0) <= addrOverFsin;
        AddrOverFsinRegister_reg(1 TO 3) <= AddrOverFsinRegister_reg(0 TO 2);
      END IF;
    END IF;
  END PROCESS AddrOverFsinRegister_process;

  addrOverFsinreg <= AddrOverFsinRegister_reg(3);

  lutoutsin_signed <= signed(lutoutsin);

  ampOne <= to_signed(16#40000#, 20);

  -- Assign sine amplitude One
  
  lutoutsin_ampOne <= lutoutsin_signed WHEN addrOverFsinreg = '0' ELSE
      ampOne;

  uminus_cast <= resize(lutoutsin_ampOne, 21);
  uminus_cast_1 <=  - (uminus_cast);
  lutoutsin_ampOne_inv <= uminus_cast_1(19 DOWNTO 0);

  -- Select sign of Sine output
  
  sine_tmp <= lutoutsin_ampOne WHEN selsignreg = '0' ELSE
      lutoutsin_ampOne_inv;

  sine <= std_logic_vector(sine_tmp);

  -- Cosine sign selection signal
  selsign_1 <= selsign XOR seladdr;

  SelsignCosRegister_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        SelsignCosRegister_reg <= (OTHERS => '0');
      ELSIF enb = '1' THEN
        SelsignCosRegister_reg(0) <= selsign_1;
        SelsignCosRegister_reg(1 TO 3) <= SelsignCosRegister_reg(0 TO 2);
      END IF;
    END IF;
  END PROCESS SelsignCosRegister_process;

  selsign_cosreg <= SelsignCosRegister_reg(3);

  -- Detect cosine overflow
  
  addreqzero <= '1' WHEN lutaddrexd = 0 ELSE
      '0';

  clkenbRegister_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        clkenbRegister_reg <= '0';
      ELSIF enb = '1' THEN
        clkenbRegister_reg <= enb;
      END IF;
    END IF;
  END PROCESS clkenbRegister_process;

  enbreg <= clkenbRegister_reg;

  addreqzero_1 <= addreqzero AND enbreg;

  
  lutaddrcos <= lutaddr2 WHEN seladdr = '0' ELSE
      lutaddr1;

  AddrOverFcosRegister_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        AddrOverFcosRegister_reg <= (OTHERS => '0');
      ELSIF enb = '1' THEN
        AddrOverFcosRegister_reg(0) <= addreqzero_1;
        AddrOverFcosRegister_reg(1 TO 3) <= AddrOverFcosRegister_reg(0 TO 2);
      END IF;
    END IF;
  END PROCESS AddrOverFcosRegister_process;

  addrOverFcosreg <= AddrOverFcosRegister_reg(3);

  lutoutcos_signed <= signed(lutoutcos);

  -- Assign cosine amplitude One
  
  lutoutcos_ampOne <= lutoutcos_signed WHEN addrOverFcosreg = '0' ELSE
      ampOne;

  uminus_cast_2 <= resize(lutoutcos_ampOne, 21);
  uminus_cast_3 <=  - (uminus_cast_2);
  lutoutcos_ampOne_inv <= uminus_cast_3(19 DOWNTO 0);

  -- Select sign of cosine output
  
  cosine_tmp <= lutoutcos_ampOne WHEN selsign_cosreg = '0' ELSE
      lutoutcos_ampOne_inv;

  cosine <= std_logic_vector(cosine_tmp);

END rtl;

