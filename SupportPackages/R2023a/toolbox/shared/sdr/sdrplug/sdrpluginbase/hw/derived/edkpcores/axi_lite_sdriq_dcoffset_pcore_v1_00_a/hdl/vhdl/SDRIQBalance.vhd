
-------------------------------------------------------------------------------
-- Description: 
--                 x_out = x_in
--                  y_out = coeff_I* x_in + coeff_Q* y_in
-- 
--              Here, the 'x' and 'y' input and output signals should be
--              connected to the corresponding 'I' and 'Q' signals,
--              respectively.
--
--              The entire block can be bypassed with a single clock delay when
--              the bypass signal is asserted.
--
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SDRIQBalance is

port (
    rst         : in  std_logic;
    clk         : in  std_logic;
    bypass      : in  std_logic;

    -- Parameters
    coeff_I     : in  std_logic_vector(9 downto 0); -- coefficient C
    coeff_Q     : in  std_logic_vector(9 downto 0); -- coefficient D

    strobe_in   : in  std_logic; -- input valid
    x_in        : in  std_logic_vector(15 downto 0);
    y_in        : in  std_logic_vector(15 downto 0);

    strobe_out  : out std_logic; -- output valid
    x_out       : out std_logic_vector(15 downto 0);
    y_out       : out std_logic_vector(15 downto 0)
);
end entity;

architecture RTL of SDRIQBalance is

    -- Signals

   constant c_Y_MAX : signed(13 downto 0) := (13 => '0', others => '1');
   constant c_Y_MIN : signed(13 downto 0) := (13 => '1', others => '0');

    constant sat_allones  : std_logic_vector(4 DOWNTO 0) := (others => '0');
    constant sat_allzeros : std_logic_vector(4 DOWNTO 0) := (others => '0');

    signal x_top2bits     : std_logic_vector(1 downto 0); 
    signal y_top2bits     : std_logic_vector(1 downto 0); 
    signal x_in_14bits    : std_logic_vector(13 downto 0); 
    signal y_in_14bits    : std_logic_vector(13 downto 0); 
    signal x_out_tmp      : std_logic_vector(13 downto 0); 
    signal y_out_tmp      : std_logic_vector(13 downto 0); 

    signal s_xin          : signed(13 downto 0); -- 14En0
    signal s_yin          : signed(13 downto 0); -- 14En0

    signal s_c_times_x    : signed(23 downto 0);
    signal s_d_times_y    : signed(23 downto 0);

    signal s_sum_saturate : signed(13 downto 0); -- 14En0

    signal s_sum          : signed(24 downto 0); -- 25En6

    signal s_strobe_dly_1 : std_logic; 
    signal s_strobe_dly_2 : std_logic; 
    signal s_strobe_dly_3 : std_logic; 

    signal s_x_dly_1      : signed(13 downto 0);
    signal s_x_dly_2      : signed(13 downto 0);
    signal s_x_dly_3      : signed(13 downto 0);
 
    signal s_strobe_d     : std_logic;
    signal s_x_d          : signed(13 downto 0);

begin

    -- Processes
    x_top2bits  <= x_in(15 downto 14);
    y_top2bits  <= y_in(15 downto 14);
    x_in_14bits <= x_in(13 downto 0);
    y_in_14bits <= y_in(13 downto 0);

    s_xin <= signed(x_in_14bits);
    s_yin <= signed(y_in_14bits);


    p_SDRIQBalance : process (clk)
    begin
        if rising_edge(clk) then
          if rst = '1' then
            s_c_times_x <= (others => '0');
            s_d_times_y <= (others => '0');

            s_x_dly_1 <= (others => '0');
            s_strobe_dly_1 <= '0';

            s_sum <= (others => '0');
            s_x_dly_2 <= (others => '0');
            s_strobe_dly_2 <= '0';
      
            s_x_dly_3 <= (others => '0');
            s_strobe_dly_3 <= '0';
            
            s_sum_saturate <= (others => '0');
            s_x_d <= (others => '0');
            s_strobe_d <= '0';
         -- IF strobe_in = '1' THEN
          elsif bypass = '0' then
           -- First pipeline ----------------------------------------------
           -- product (+1 delay)
              s_c_times_x    <= signed(coeff_I) * s_xin;
              s_d_times_y    <= signed(coeff_Q) * s_yin;

              s_x_dly_1      <= s_xin;
              s_strobe_dly_1 <= strobe_in;
           ----------------------------------------------------------------
           -- Second pipeline ----------------------------------------------
            -- Sum (+1 delay)
              s_sum     <= resize(s_c_times_x, 25) + resize(s_d_times_y,25);

              s_x_dly_2 <= s_x_dly_1; 
              s_strobe_dly_2 <= s_strobe_dly_1;
            ----------------------------------------------------------------
           -- Third pipeline ----------------------------------------------
            -- Saturation and rounding (floor) (+1 delay)

            IF (s_sum(24) = '0') AND (s_sum(23 DOWNTO 19) /= "00000") THEN --goes over
              s_sum_saturate <= "01111111111111"; -- largest positive 
            ELSIF (s_sum(24) = '1') AND (s_sum(23 DOWNTO 19) /= "11111") THEN -- goes under 
              s_sum_saturate <="10000000000000"; -- smallest negative
            ELSE
              s_sum_saturate <= s_sum(19 DOWNTO 6);
            END IF;
  
            s_x_dly_3      <= s_x_dly_2;
            s_strobe_dly_3 <= s_strobe_dly_2;

           --   s_sum_saturate <= c_Y_MAX WHEN (s_sum(DATA_WORD_LENGTH+COEF_WORD_LENGTH) = '0') AND (s_sum(DATA_WORD_LENGTH+COEF_WORD_LENGTH -1 DOWNTO DATA_WORD_LENGTH+COEF_FRACTION_LENGTH-1) /= sat_allzeros) ELSE
           --    c_Y_MIN WHEN (s_sum(DATA_WORD_LENGTH+COEF_WORD_LENGTH) = '1') AND (s_sum(DATA_WORD_LENGTH+COEF_WORD_LENGTH -1 DOWNTO DATA_WORD_LENGTH+COEF_FRACTION_LENGTH-1) /= sat_allones) ELSE
           --        s_sum(DATA_WORD_LENGTH+COEF_FRACTION_LENGTH-1 DOWNTO COEF_FRACTION_LENGTH+1);

            -- Forth pipeline ----------------------------------------------
            -- Final assignment 
              y_out      <= std_logic_vector(resize(s_sum_saturate, 16));
              x_out     <= std_logic_vector(resize(s_x_dly_3, 16));
              strobe_out <= s_strobe_dly_3;
          else
              y_out      <= y_in;
              x_out      <= x_in;
             strobe_out  <= strobe_in;
          end if;
          --END IF;
        end if;
    end process p_SDRIQBalance;

    -- Output assignment

  --  strobe_out  <= s_strobe_d;
  --  x_out_tmp <= std_logic_vector(s_x_d);
  --  y_out_tmp <= std_logic_vector(s_sum_saturate);

  --  output_process : process (bypass,x_out_tmp,y_out_tmp, x_top2bits,y_top2bits)
--	 begin
	--	if (bypass = '0') then -- sign extension
  --      x_out <= x_out_tmp(13) & x_out_tmp(13) & x_out_tmp;
  --      y_out <= y_out_tmp(13) & y_out_tmp(13) & y_out_tmp;
	--	else -- counter case
  --      x_out <= x_top2bits & x_out_tmp;
  --      y_out <= y_top2bits & y_out_tmp;
	--	end if;
	-- end process output_process;

end RTL;
