library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SDRSimpleInt is
  port (
    clk   : in std_logic;
    reset : in std_logic;

    din_I     : in std_logic_vector(15 downto 0);
    din_Q     : in std_logic_vector(15 downto 0);
    din_vld   : in std_logic;
    intFactor : in std_logic_vector(31 downto 0);

    dout_I    : out std_logic_vector(15 downto 0);
    dout_Q    : out std_logic_vector(15 downto 0);
    dout_vld  : out std_logic
    );
end entity;

architecture rtl of SDRSimpleInt is

  signal cnt         : unsigned(31 downto 0);
  signal dout_vld_temp : std_logic;

  signal intFactor_sync1   : std_logic_vector(31 downto 0);
  signal intFactor_sync2   : std_logic_vector(31 downto 0);
  signal intFactor_sync3   : std_logic_vector(31 downto 0);

begin
  
  sync_proc: process(clk)
  begin 
    if clk'event and clk = '1' then
       intFactor_sync1     <= intFactor;
       intFactor_sync2     <= intFactor_sync1;
       if intFactor_sync1 = intFactor_sync2 then
          intFactor_sync3 <= intFactor_sync2;
       end if;
    end if;
  end process;

  cnt_proc: process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        cnt        <= to_unsigned(1, 32);
      elsif dout_vld_temp = '1' then
        if cnt = unsigned(intFactor_sync3) then
          cnt        <= to_unsigned(1, 32);
        else
          cnt        <= cnt + to_unsigned(1, 32);
        end if;
      end if;
    end if;
  end process;
  
  data_proc: process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        dout_I     <= (others => '0');
        dout_Q     <= (others => '0');
      else
        if din_vld =  '1' then
          dout_I     <= din_I;
          dout_Q     <= din_Q;    
        else       
          dout_I     <= (others => '0');
          dout_Q     <= (others => '0');
        end if;
      end if;
    end if;
  end process;
  
  dvld_proc: process(clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        dout_vld_temp <= '0';
      else      
        if (dout_vld_temp = '0' and cnt =  to_unsigned(1, 32)) or (dout_vld_temp = '1' and cnt = unsigned(intFactor_sync3)) then
            dout_vld_temp <= din_vld;
        end if;
      end if;
    end if;
  end process;
  
  dout_vld <= dout_vld_temp;
end rtl;

