library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity axi_lite_data_verifier is
port(
  -- axi interface signals
  axi_clk       : in std_logic;
  axi_rst       : in std_logic;
  axi_awaddr    : in std_logic_vector(31 DOWNTO 0);  -- uint32
  axi_wvalid    : in std_logic;  -- ufix1
  axi_awvalid   : in std_logic;  -- ufix1
  -- 
  clk           : in std_logic;
  data          : in std_logic_vector(63 downto 0);
  dvld          : in std_logic;
  ch_sel        : in std_logic_vector(1 downto 0);
  
  -- registers
  wr_rst_reg    : in  std_logic_vector(31 downto 0);
  rd_count_reg  : out std_logic_vector(31 downto 0);
  rd_status_reg : out std_logic_vector(31 downto 0);
  wr_cntmax     : in std_logic_vector(15 downto 0);
  rd_cntmax     : out std_logic_vector(15 downto 0);

  err_irq       : out std_logic;  
  ch1_0         : out std_logic_vector(31 downto 0);  -- channel 1: 5 samples
  ch1_1         : out std_logic_vector(31 downto 0); 
  ch1_2         : out std_logic_vector(31 downto 0); 
  ch1_3         : out std_logic_vector(31 downto 0); 
  ch1_4         : out std_logic_vector(31 downto 0); 
  ch2_0         : out std_logic_vector(31 downto 0);  -- channel 2: 5 samples
  ch2_1         : out std_logic_vector(31 downto 0);
  ch2_2         : out std_logic_vector(31 downto 0);
  ch2_3         : out std_logic_vector(31 downto 0);
  ch2_4         : out std_logic_vector(31 downto 0)
  );
end entity axi_lite_data_verifier;

architecture rtl of axi_lite_data_verifier is

component dataVerifier is
port(
  clk        : in std_logic;
  rst        : in std_logic;
  data       : in std_logic_vector(63 downto 0);
  dvld       : in std_logic;
  ch_sel     : in std_logic_vector(1 downto 0);
  cntmax     : in std_logic_vector(15 downto 0);
  cnt        : out std_logic_vector(31 downto 0);
  err        : out std_logic;  
  ch1_0      : out std_logic_vector(31 downto 0);  -- channel 1: 5 samples
  ch1_1      : out std_logic_vector(31 downto 0); 
  ch1_2      : out std_logic_vector(31 downto 0); 
  ch1_3      : out std_logic_vector(31 downto 0); 
  ch1_4      : out std_logic_vector(31 downto 0); 
  ch2_0      : out std_logic_vector(31 downto 0);  -- channel 2: 5 samples
  ch2_1      : out std_logic_vector(31 downto 0);
  ch2_2      : out std_logic_vector(31 downto 0);
  ch2_3      : out std_logic_vector(31 downto 0);
  ch2_4      : out std_logic_vector(31 downto 0)
  );
end component;

signal err_int : std_logic;
-- reset signals
constant rst_reg_addr : std_logic_vector(31 downto 0) := X"43C50100";
signal rst_reg        : std_logic;
signal rst_clr        : std_logic;
signal reset_shft     : std_logic_vector(7 downto 0);
-- sync signals
signal cnt_sync1  : std_logic_vector(31 downto 0);
signal cnt_sync2  : std_logic_vector(31 downto 0);
signal stat_sync1 : std_logic_vector(31 downto 0);
signal stat_sync2 : std_logic_vector(31 downto 0);
signal ch1_0_int : std_logic_vector(31 downto 0);
signal ch1_1_int : std_logic_vector(31 downto 0);
signal ch1_2_int : std_logic_vector(31 downto 0);
signal ch1_3_int : std_logic_vector(31 downto 0);
signal ch1_4_int : std_logic_vector(31 downto 0);
signal ch2_0_int : std_logic_vector(31 downto 0);
signal ch2_1_int : std_logic_vector(31 downto 0);
signal ch2_2_int : std_logic_vector(31 downto 0);
signal ch2_3_int : std_logic_vector(31 downto 0);
signal ch2_4_int : std_logic_vector(31 downto 0);
signal ch1_0_sync1 : std_logic_vector(31 downto 0);
signal ch1_0_sync2 : std_logic_vector(31 downto 0);
signal ch1_1_sync1 : std_logic_vector(31 downto 0);
signal ch1_1_sync2 : std_logic_vector(31 downto 0);
signal ch1_2_sync1 : std_logic_vector(31 downto 0);
signal ch1_2_sync2 : std_logic_vector(31 downto 0);
signal ch1_3_sync1 : std_logic_vector(31 downto 0);
signal ch1_3_sync2 : std_logic_vector(31 downto 0);
signal ch1_4_sync1 : std_logic_vector(31 downto 0);
signal ch1_4_sync2 : std_logic_vector(31 downto 0);
signal ch2_0_sync1 : std_logic_vector(31 downto 0);
signal ch2_0_sync2 : std_logic_vector(31 downto 0);
signal ch2_1_sync1 : std_logic_vector(31 downto 0);
signal ch2_1_sync2 : std_logic_vector(31 downto 0);
signal ch2_2_sync1 : std_logic_vector(31 downto 0);
signal ch2_2_sync2 : std_logic_vector(31 downto 0);
signal ch2_3_sync1 : std_logic_vector(31 downto 0);
signal ch2_3_sync2 : std_logic_vector(31 downto 0);
signal ch2_4_sync1 : std_logic_vector(31 downto 0);
signal ch2_4_sync2 : std_logic_vector(31 downto 0);
signal data_verifier_rst : std_logic;
signal data_clk_rst_sync : std_logic;
signal cntmax_sync1 : std_logic_vector(15 downto 0);
signal cntmax_sync2 : std_logic_vector(15 downto 0);
signal cntmax_sync3 : std_logic_vector(15 downto 0);
begin

rst_enable: process(axi_clk, axi_rst)
begin
if rising_edge(axi_clk) then
  if axi_rst = '1' then
        rst_reg <= '0';
  else
        if (axi_awvalid = '1' and axi_wvalid = '1') then
            case axi_awaddr is
                when rst_reg_addr =>
                    rst_reg  <= '1';
                when others =>
                    -- do nothing
            end case;
        else
            if rst_clr = '1' then
                rst_reg <= '0';
            end if;
        end if;
  end if;
end if;
end process rst_enable;
  
rst_proc : process (clk)
begin
    if rising_edge(clk) then   
        if rst_reg = '0' then
            rst_clr    <= '0';
            reset_shft <= reset_shft (6 downto 0) & '0';
        else
            reset_shft <= (others => '1');
            rst_clr    <= '1';
        end if;
    end if;
end process rst_proc;

data_verifier_rst <= reset_shft(7);

sync_rst_process : process(clk)
begin
    if rising_edge(clk) then
        --data_clk_rst_sync <= reset_shft(15);
        --data_verifier_rst <= data_clk_rst_sync;

        cntmax_sync1 <= wr_cntmax;
        cntmax_sync2 <= cntmax_sync1;
		cntmax_sync3 <= cntmax_sync2;
    end if;
end process sync_rst_process;


sync_process: process(axi_clk)
begin
    if rising_edge(axi_clk) then
        cnt_sync2 <= cnt_sync1;
        rd_count_reg <= cnt_sync2;
        
        stat_sync1 <= (0 => err_int, 1 => ch_sel(0), 2 => ch_sel(1), others => '0'); -- set bit_0 to err_int and zero the rest!
        stat_sync2 <= stat_sync1;
        rd_status_reg <= stat_sync2;
        
        -- sync channel 1
        ch1_0_sync1 <= ch1_0_int;
        ch1_0_sync2 <= ch1_0_sync1;
        ch1_0       <= ch1_0_sync2;
        
        ch1_1_sync1 <= ch1_1_int;
        ch1_1_sync2 <= ch1_1_sync1;
        ch1_1       <= ch1_1_sync2;
        
        ch1_2_sync1 <= ch1_2_int;
        ch1_2_sync2 <= ch1_2_sync1;
        ch1_2       <= ch1_2_sync2;
        
        ch1_3_sync1 <= ch1_3_int;
        ch1_3_sync2 <= ch1_3_sync1;
        ch1_3       <= ch1_3_sync2;
        
        ch1_4_sync1 <= ch1_4_int;
        ch1_4_sync2 <= ch1_4_sync1;
        ch1_4       <= ch1_4_sync2;
        
        -- sync channel 2
        ch2_0_sync1 <= ch2_0_int;
        ch2_0_sync2 <= ch2_0_sync1;
        ch2_0       <= ch2_0_sync2;
                        
        ch2_1_sync1 <= ch2_1_int;
        ch2_1_sync2 <= ch2_1_sync1;
        ch2_1       <= ch2_1_sync2;
                        
        ch2_2_sync1 <= ch2_2_int;
        ch2_2_sync2 <= ch2_2_sync1;
        ch2_2       <= ch2_2_sync2;
                        
        ch2_3_sync1 <= ch2_3_int;
        ch2_3_sync2 <= ch2_3_sync1;
        ch2_3       <= ch2_3_sync2;
                        
        ch2_4_sync1 <= ch2_4_int;
        ch2_4_sync2 <= ch2_4_sync1;
        ch2_4       <= ch2_4_sync2;
    
    end if;
end process;

err_irq <= err_int; -- external error flag, to be used for interrupt

rd_cntmax <= wr_cntmax;

data_verifier_inst : dataVerifier
port map(
    clk    => clk,
    rst    => data_verifier_rst,
    data   => data,
    dvld   => dvld,
    ch_sel => ch_sel,
    cnt    => cnt_sync1,
    cntmax => cntmax_sync2,
    err    => err_int,
    ch1_0  => ch1_0_int,
    ch1_1  => ch1_1_int,
    ch1_2  => ch1_2_int,
    ch1_3  => ch1_3_int,
    ch1_4  => ch1_4_int,
    ch2_0  => ch2_0_int,
    ch2_1  => ch2_1_int,
    ch2_2  => ch2_2_int,
    ch2_3  => ch2_3_int,
    ch2_4  => ch2_4_int
);
end rtl;
