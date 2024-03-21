
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SDRRampSrc is
    generic (
        bit_width : integer := 64
    );
    port (
        clk       : in std_logic;
        reset     : in std_logic;
        stream_en : in std_logic;

        src_sel   : in std_logic_vector(1 downto 0);
        cnt_max   : in std_logic_vector(15 downto 0);

        data_in   : in std_logic_vector(bit_width - 1 downto 0);
        data_vld  : in std_logic;

        src_strobe : out std_logic;
        src_out    : out std_logic_vector(bit_width - 1 downto 0)   
    );
end entity;

architecture rtl of SDRRampSrc is
  -- Signals
  signal s_sin_i      : std_logic_vector(15 downto 0);
  signal s_sin_q      : std_logic_vector(15 downto 0);
  signal s_sin_strobe : std_logic;
  signal s_cnt        : unsigned(14 downto 0);
  signal s_cnt_i1     : std_logic_vector(15 downto 0);
  signal s_cnt_q1     : std_logic_vector(15 downto 0);
  signal s_cnt_i2     : std_logic_vector(15 downto 0);
  signal s_cnt_q2     : std_logic_vector(15 downto 0);
  signal s_cnt_i3     : std_logic_vector(15 downto 0);
  signal s_cnt_q3     : std_logic_vector(15 downto 0);
  signal s_cnt_i4     : std_logic_vector(15 downto 0);
  signal s_cnt_q4     : std_logic_vector(15 downto 0);
  
  signal maxcnt_offset : unsigned(14 downto 0);

  signal stream_enb_sync1 : std_logic;
  signal stream_enb_sync2 : std_logic;
  signal stream_enb_sync3 : std_logic;

  signal src_sel_sync1 : std_logic_vector(1 downto 0);
  signal src_sel_sync2 : std_logic_vector(1 downto 0);
  signal src_sel_sync3 : std_logic_vector(1 downto 0);

  signal cnt_max_sync1 : std_logic_vector(15 downto 0);
  signal cnt_max_sync2 : std_logic_vector(15 downto 0);
  signal cnt_max_sync3 : std_logic_vector(15 downto 0);
  
  signal ramp_data_out : std_logic_vector(bit_width - 1 downto 0);

begin

  ------------------------------ Sources ------------------------------  
  sync_proc : process(clk)
  begin
    if clk'event and clk = '1' then
        stream_enb_sync1 <= stream_en;
        stream_enb_sync2 <= stream_enb_sync1;
        if stream_enb_sync1 = stream_enb_sync2 then
          stream_enb_sync3 <= stream_enb_sync2;
        end if;

        src_sel_sync1 <= src_sel;
        src_sel_sync2 <= src_sel_sync1;
        if src_sel_sync2 = src_sel_sync1 then
          src_sel_sync3 <= src_sel_sync2;
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
      s_cnt     <= (others => '0');    
     elsif stream_enb_sync3 = '1' then
        if s_cnt = unsigned(cnt_max_sync3(14 downto 0)) then
          s_cnt <= to_unsigned(0, 15);
        else
          s_cnt <= s_cnt + to_unsigned(1, 15);
        end if;
      else
        s_cnt      <= (others => '0');
      end if;
    end if;
  end process p_counter;
    
  maxcnt_offset <= 32767 - unsigned(cnt_max_sync3(14 downto 0));
  
  s_cnt_i1 <= std_logic_vector('0' & s_cnt);
  s_cnt_q1 <= std_logic_vector(not(s_cnt_i1));
  
  s_cnt_i2 <= std_logic_vector('0' & (s_cnt+1+maxcnt_offset)) when ((s_cnt+1) > unsigned(cnt_max_sync3(14 downto 0))) else 
              std_logic_vector('0' & (s_cnt+1)); 
  s_cnt_q2 <= std_logic_vector(not(s_cnt_i2));
  
  s_cnt_i3 <= std_logic_vector('0' & (s_cnt+3+maxcnt_offset)) when ((s_cnt+3) > unsigned(cnt_max_sync3(14 downto 0))) else 
              std_logic_vector('0' & (s_cnt+3));
  s_cnt_q3 <= std_logic_vector(not(s_cnt_i3));
  
  s_cnt_i4 <= std_logic_vector('0' & (s_cnt+5+maxcnt_offset)) when ((s_cnt+5) > unsigned(cnt_max_sync3(14 downto 0))) else 
              std_logic_vector('0' & (s_cnt+5));
  s_cnt_q4 <= std_logic_vector(not(s_cnt_i4));
  
   gen_ramp_data_out:
   for n in 1 to (bit_width/16) generate -- n [1:8]
   assign_postive_Ch1_I_ramp: if (n = 1) generate
      ramp_data_out(((n-1)*16)+15 downto (n-1)*16) <= s_cnt_i1;
   end generate assign_postive_Ch1_I_ramp;
   
   assign_postive_Ch1_Q_ramp: if (n = 2) generate
      ramp_data_out(((n-1)*16)+15 downto (n-1)*16) <= s_cnt_q1;
   end generate assign_postive_Ch1_Q_ramp;
   
   assign_negative_Ch2_I_ramp: if (n = 3) generate
      ramp_data_out(((n-1)*16)+15 downto (n-1)*16) <= s_cnt_i2;
   end generate assign_negative_Ch2_I_ramp;
   
   assign_negative_Ch2_Q_ramp: if (n = 4)  generate
      ramp_data_out(((n-1)*16)+15 downto (n-1)*16) <= s_cnt_q2;
   end generate assign_negative_Ch2_Q_ramp;
   
   assign_postive_Ch3_I_ramp: if (n = 5) generate
      ramp_data_out(((n-1)*16)+15 downto (n-1)*16) <= s_cnt_i3;
   end generate assign_postive_Ch3_I_ramp;
   
   assign_postive_Ch3_Q_ramp: if (n = 6)  generate
      ramp_data_out(((n-1)*16)+15 downto (n-1)*16) <= s_cnt_q3;
   end generate assign_postive_Ch3_Q_ramp;
   
   assign_negative_Ch4_I_ramp: if (n = 7) generate
      ramp_data_out(((n-1)*16)+15 downto (n-1)*16) <= s_cnt_i4;
   end generate assign_negative_Ch4_I_ramp;
   
   assign_negative_Ch4_Q_ramp: if (n = 8) generate
      ramp_data_out(((n-1)*16)+15 downto (n-1)*16) <= s_cnt_q4;
   end generate assign_negative_Ch4_Q_ramp;
   
   end generate gen_ramp_data_out;
  
  src_out  <= data_in          when src_sel_sync3 = "00" else
              ramp_data_out    when src_sel_sync3 = "10";                     

  src_strobe <= (data_vld and stream_enb_sync3)  when src_sel_sync3 = "00" else
                 stream_enb_sync3                when src_sel_sync3 = "10";

end rtl;