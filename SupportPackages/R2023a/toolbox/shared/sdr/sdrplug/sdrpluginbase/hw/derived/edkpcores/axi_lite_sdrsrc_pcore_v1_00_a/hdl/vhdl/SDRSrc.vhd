
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SDRSrc is
  port (
    clk       : in std_logic;
    reset     : in std_logic;
    stream_en : in std_logic;

    srcSel    : in std_logic_vector(1 downto 0);
    cnt_max   : in std_logic_vector(15 downto 0);

    RFIn_I    : in std_logic_vector(15 downto 0);
    RFIn_Q    : in std_logic_vector(15 downto 0);
    RFIn_strb : in std_logic;

    loop_I    : in std_logic_vector(15 downto 0);
    loop_Q    : in std_logic_vector(15 downto 0);
    loop_vld :  in std_logic;

    src_strobe : out std_logic;
    src_I      : out std_logic_vector(15 downto 0);
    src_Q      : out std_logic_vector(15 downto 0));
end entity;

architecture rtl of SDRSrc is
  -- Signals
  signal s_sin_i      : std_logic_vector(15 downto 0);
  signal s_sin_q      : std_logic_vector(15 downto 0);
  signal s_sin_strobe : std_logic;

  signal s_cnt_i      : unsigned(15 downto 0);
  signal s_cnt_q      : unsigned(15 downto 0);
  signal s_cnt_strobe : std_logic;

  signal streamEnb_sync1 : std_logic;
  signal streamEnb_sync2 : std_logic;
  signal streamEnb_sync3 : std_logic;

  signal srcSel_sync1 : std_logic_vector(1 downto 0);
  signal srcSel_sync2 : std_logic_vector(1 downto 0);
  signal srcSel_sync3 : std_logic_vector(1 downto 0);

  signal cnt_max_sync1 : std_logic_vector(15 downto 0);
  signal cnt_max_sync2 : std_logic_vector(15 downto 0);
  signal cnt_max_sync3 : std_logic_vector(15 downto 0);

begin

  ------------------------------ Sources ------------------------------

  
  sync_proc : process(clk)
  begin
    if clk'event and clk = '1' then
        streamEnb_sync1 <= stream_en;
        streamEnb_sync2 <= streamEnb_sync1;
        if streamEnb_sync1 = streamEnb_sync2 then
          streamEnb_sync3 <= streamEnb_sync2;
        end if;

        srcSel_sync1 <= srcSel;
        srcSel_sync2 <= srcSel_sync1;
        if srcSel_sync2 = srcSel_sync1 then
          srcSel_sync3 <= srcSel_sync2;
        end if;

        cnt_max_sync1 <= cnt_max;
        cnt_max_sync2 <= cnt_max_sync1;
        if cnt_max_sync2 = cnt_max_sync1 then
          cnt_max_sync3 <= cnt_max_sync2;
        end if;
    end if;
  end process sync_proc;

  -- Sample sequence number generator
  p_counter : process (clk)
  begin
    if clk'event and clk = '1' then
     if reset = '1' then
      s_cnt_i      <= (others => '0');
      s_cnt_q      <= (others => '0');
      s_cnt_strobe <= '0';
      --s_cnt_q <= (7 downto 0 => '1', others => '0');
     elsif streamEnb_sync3 = '1' then
        if s_cnt_i = unsigned(cnt_max_sync3(15 downto 0)) then
          s_cnt_i <= to_unsigned(0, 16);
        else
          s_cnt_i <= s_cnt_i + to_unsigned(1, 16);
        end if;
        if s_cnt_q = unsigned(cnt_max_sync3(15 downto 0)) then
          s_cnt_q <= to_unsigned(0, 16);
        else
          s_cnt_q <= s_cnt_q + to_unsigned(1, 16);
        end if;
        s_cnt_strobe <= '1';
      else
        s_cnt_i      <= (others => '0');
        s_cnt_q      <= (others => '0');
        s_cnt_strobe <= '0';
      end if;
    end if;
  end process p_counter;

  src_I <= RFIn_I                    when srcSel_sync3 = "00" else
           std_logic_vector(s_cnt_i) when srcSel_sync3 = "10" else
           s_sin_i                   when srcSel_sync3 = "01" else
           loop_I;                      

  src_Q <= RFIn_Q                    when srcSel_sync3 = "00" else
           std_logic_vector(s_cnt_q) when srcSel_sync3 = "10" else
           s_sin_i                   when srcSel_sync3 = "01" else
           loop_Q;

  src_strobe <= (RFIn_Strb and streamEnb_sync3) when srcSel_sync3 = "00" else
                 streamEnb_sync3                when srcSel_sync3 = "10" else
                 s_sin_strobe                   when srcSel_sync3 = "01" else
                 loop_vld;


  s_sin_i      <= (others => '0');
  s_sin_q      <= (others => '0');
  s_sin_strobe <= '0';

end rtl;