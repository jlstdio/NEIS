library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SDRSimpleDec is
  port (
    clk   : in std_logic;
    reset : in std_logic;

    din_I     : in std_logic_vector(15 downto 0);
    din_Q     : in std_logic_vector(15 downto 0);
    strobe_in : in std_logic;
    decFactor : in std_logic_vector(31 downto 0);

    dout_I     : out std_logic_vector(15 downto 0);
    dout_Q     : out std_logic_vector(15 downto 0);
    strobe_out : out std_logic
    );
end entity;

architecture rtl of SDRSimpleDec is

  signal cnt         : unsigned(31 downto 0);

  signal decFactor_sync1   : std_logic_vector(31 downto 0);
  signal decFactor_sync2   : std_logic_vector(31 downto 0);
  signal decFactor_sync3   : std_logic_vector(31 downto 0);
  

begin
  
  process(clk)
  begin 
    if clk'event and clk = '1' then
       decFactor_sync1     <= decFactor;
       decFactor_sync2     <= decFactor_sync1;
       if decFactor_sync1 = decFactor_sync2 then
          decFactor_sync3 <= decFactor_sync2;
       end if;
    end if;
  end process;

  data_proc: process(clk)  -- data
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        dout_I     <= (others => '0');
        dout_Q     <= (others => '0');
      else
        dout_I <= din_I;
        dout_Q <= din_Q;
      end if;
    end if;
  end process;
  
  cnt_proc: process(clk)  -- counter
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        cnt        <= to_unsigned(1, 32);
      elsif strobe_in = '1' then -- strobe_in => counter enable
        if cnt = unsigned(decFactor_sync3) then
          cnt      <= to_unsigned(1, 32);
        else
          cnt      <= cnt + to_unsigned(1, 32);
        end if;
      end if;
    end if;
  end process;
  
  strobe_out_proc: process(clk) -- strobe out
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        strobe_out <= '0';
      elsif strobe_in = '1' and cnt = to_unsigned(1, 32) then
        strobe_out <= '1';
      else
        strobe_out <= '0';
      end if;
    end if;
  end process;  
  
end rtl;