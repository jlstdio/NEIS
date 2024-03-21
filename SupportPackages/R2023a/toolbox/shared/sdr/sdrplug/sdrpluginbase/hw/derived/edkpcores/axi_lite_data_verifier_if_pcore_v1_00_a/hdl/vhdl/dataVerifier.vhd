-- verify ramp signal
-- channel 1: increasing ramp
-- channel 2: decreasing ramp (if any) 

-- ch_sel: channel select signal; channel[i] is enabled if ch_sel[i]=1
-- err : sticky indicator if error occurs, use rst to clear
-- cnt : number of samples when error occurs
-- when error occurs, log five samples with bad sample in the middle

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity dataVerifier is
port(
  clk        : in std_logic;
  rst        : in std_logic;
  data       : in std_logic_vector(63 downto 0);
  dvld       : in std_logic;
  ch_sel     : in std_logic_vector(1 downto 0);
  cntmax    : in std_logic_vector(15 downto 0);
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
end;

architecture rtl of dataVerifier is

signal err_I0    :std_logic;
signal err_Q0    :std_logic;
signal err_I1    :std_logic;
signal err_Q1    :std_logic;
signal exp_I0    :std_logic_vector(15 downto 0);
signal exp_Q0    :std_logic_vector(15 downto 0);
signal exp_I1    :std_logic_vector(15 downto 0);
signal exp_Q1    :std_logic_vector(15 downto 0);
signal act_I0    :std_logic_vector(15 downto 0);
signal act_Q0    :std_logic_vector(15 downto 0);
signal act_I1    :std_logic_vector(15 downto 0);
signal act_Q1    :std_logic_vector(15 downto 0);
signal err_int   :std_logic;
signal cnt_int   :std_logic_vector(31 downto 0);
signal ch1_0_int :std_logic_vector(31 downto 0);
signal ch1_1_int :std_logic_vector(31 downto 0); 
signal ch1_2_int :std_logic_vector(31 downto 0); 
signal ch1_3_int :std_logic_vector(31 downto 0); 
signal ch1_4_int :std_logic_vector(31 downto 0); 
signal ch2_0_int :std_logic_vector(31 downto 0);
signal ch2_1_int :std_logic_vector(31 downto 0);
signal ch2_2_int :std_logic_vector(31 downto 0);
signal ch2_3_int :std_logic_vector(31 downto 0);
signal ch2_4_int :std_logic_vector(31 downto 0);

begin

dataLog: process(clk)
begin
  if rising_edge(clk) then
    if rst = '1' then
      cnt_int     <= (others => '0');
      ch1_0_int   <= (others => '0');
      ch1_1_int   <= (others => '0');
      ch1_2_int   <= (others => '0');
      ch1_3_int   <= (others => '0');
      ch1_4_int   <= (others => '0');
      ch2_0_int   <= (others => '0');
      ch2_1_int   <= (others => '0');
      ch2_2_int   <= (others => '0');
      ch2_3_int   <= (others => '0');
      ch2_4_int   <= (others => '0');
    elsif (dvld = '1') and (err_int = '0') then
      cnt_int     <= cnt_int +1;
      ch1_0_int   <= data(31 downto 0);
      ch1_1_int   <= ch1_0_int;
      ch1_2_int   <= ch1_1_int;
      ch1_3_int   <= ch1_2_int;
      ch1_4_int   <= ch1_3_int;
      ch2_0_int   <= data(63 downto 32);
      ch2_1_int   <= ch2_0_int;
      ch2_2_int   <= ch2_1_int;
      ch2_3_int   <= ch2_2_int;
      ch2_4_int   <= ch2_3_int;         
    end if;
  end if;
end process;

-- expected 
 --exp_I0 <= ch1_1_int(15 downto  0) +1;          
-- exp_Q0 <= ch1_1_int(31 downto 16) +1;
-- exp_I1 <= ch2_1_int(15 downto  0) -1;
-- exp_Q1 <= ch2_1_int(31 downto 16) -1;
          
exp_I0 <= ch1_1_int(15 downto  0) +1 when ((signed(ch1_1_int(15 downto  0))) < signed(cntmax)) else
          not(ch1_1_int(15 downto  0));
          
exp_Q0 <= ch1_1_int(31 downto 16) +1 when ((signed(ch1_1_int(31 downto  16))) < signed(cntmax)) else
          not(ch1_1_int(31 downto  16));

exp_I1 <= ch2_1_int(15 downto  0) -1 when (signed(ch2_1_int(15 downto  0))) > not(signed(cntmax)) else
          not(ch2_1_int(15 downto  0));

exp_Q1 <= ch2_1_int(31 downto 16) -1 when (signed(ch2_1_int(31 downto 16))) > not(signed(cntmax)) else
          not(ch2_1_int(31 downto 16));

-- actual
act_I0 <= ch1_0_int(15 downto  0);
act_Q0 <= ch1_0_int(31 downto 16);
act_I1 <= ch2_0_int(15 downto  0);
act_Q1 <= ch2_0_int(31 downto 16);

verifyData: process(clk)
begin
  if rising_edge(clk) then
    if rst = '1' then
      err_I0 <= '0';
      err_Q0 <= '0';
      err_I1 <= '0';
      err_Q1 <= '0';
    elsif (cnt_int >1) then
      if exp_I0 /= act_I0 then err_I0 <= '1'; end if;
      if exp_Q0 /= act_Q0 then err_Q0 <= '1'; end if;
      if exp_I1 /= act_I1 then err_I1 <= '1'; end if;
      if exp_Q1 /= act_Q1 then err_Q1 <= '1'; end if;
    end if;
  end if;
end process;

err_int <= (err_I0 or err_Q0 or err_I1 or err_Q1) when ch_sel = "11" else 
           (err_I0 or err_Q0) when ch_sel = "01" else
           (err_I1 or err_Q1) when ch_sel = "10" else
           '0';

err   <= err_int;
cnt   <= cnt_int;
ch1_0 <= ch1_0_int;
ch1_1 <= ch1_1_int;
ch1_2 <= ch1_2_int;
ch1_3 <= ch1_3_int;
ch1_4 <= ch1_4_int;
ch2_0 <= ch2_0_int;
ch2_1 <= ch2_1_int;
ch2_2 <= ch2_2_int;
ch2_3 <= ch2_3_int;
ch2_4 <= ch2_4_int;

end rtl;