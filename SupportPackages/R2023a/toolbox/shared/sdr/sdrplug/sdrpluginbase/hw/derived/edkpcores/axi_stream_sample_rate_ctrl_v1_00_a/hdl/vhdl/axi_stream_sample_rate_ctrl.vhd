library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_stream_sample_rate_ctrl is
   generic (C_TDATA_WIDTH : integer := 32);
    port (  clk                : in  std_logic;
            rst                : in  std_logic;
            int_factor_1       : in  std_logic_vector (31 downto 0);
            int_factor_2       : in  std_logic_vector (31 downto 0);
            int_sel            : in  std_logic; -- sel between int_factor_1 and int_factor_2
            int_bypass         : in  std_logic; -- if true, 1X rate ouput
            stream_en          : in  std_logic;
            -- input AXIS
            s_axis_tvalid      : in  std_logic;
            s_axis_tdata       : in  std_logic_vector (C_TDATA_WIDTH-1 downto 0);
            s_axis_tready      : out std_logic;
            -- output AXIS
            m_axis_tdata       : out std_logic_vector (C_TDATA_WIDTH-1 downto 0);
            m_axis_tvalid      : out std_logic
		      );
end axi_stream_sample_rate_ctrl;

architecture rtl of axi_stream_sample_rate_ctrl is

--signal decleration
signal int_factor_1_sync1 : std_logic_vector(31 downto 0);
signal int_factor_1_sync2 : std_logic_vector(31 downto 0);
signal int_factor_1_final : std_logic_vector(31 downto 0);
signal int_factor_2_sync1 : std_logic_vector(31 downto 0);
signal int_factor_2_sync2 : std_logic_vector(31 downto 0);
signal int_factor_2_final : std_logic_vector(31 downto 0);
signal clk_count_reg      : unsigned(9 downto 0);
signal s_axis_tready_int  : std_logic;
signal stream_en_sync1    : std_logic;
signal stream_en_sync2    : std_logic;
signal stream_en_final    : std_logic;
signal int_factor         : std_logic_vector(31 downto 0);

begin

 -- sync interpolation factor to DAC/data clock domain
sync_proc : process(clk)
begin
    if rising_edge(clk) then 
        int_factor_1_sync1 <= int_factor_1;
        int_factor_1_sync2 <= int_factor_1_sync1;
        if int_factor_1_sync2 = int_factor_1_sync1 then
            int_factor_1_final <= int_factor_1_sync2; 
        end if;

        int_factor_2_sync1 <= int_factor_2;
        int_factor_2_sync2 <= int_factor_2_sync1;
        if int_factor_2_sync2 = int_factor_2_sync1 then
            int_factor_2_final <= int_factor_2_sync2; 
        end if;
        
        stream_en_sync1 <= stream_en;
        stream_en_sync2 <= stream_en_sync1;
        if stream_en_sync2 = stream_en_sync1 then
            stream_en_final <= stream_en_sync2;
        end if;
    end if;
end process sync_proc;

-- select actual interpolation factor
int_factor <= X"00000001"        when int_bypass = '1' else
              int_factor_1_final when int_sel = '0' else
              int_factor_2_final;



-- generate axi stream tready signal, controls data flow into tx path 
tready_gen : process(rst,clk)
begin
    if (rst = '1') then
        clk_count_reg <= (others=>'0');
        s_axis_tready_int <= '0';
    elsif rising_edge(clk) then
        if (stream_en_final = '1') then --do we need to check s_axis_tvalid too
            if (clk_count_reg = (to_integer(unsigned(int_factor)))-1) then
                clk_count_reg <= (others => '0');
                s_axis_tready_int <= '1';
            else
                clk_count_reg <= clk_count_reg + 1;
                s_axis_tready_int <= '0';
            end if;
        end if;
    end if;    
end process;

s_axis_tready <= s_axis_tready_int;

-- clock data signals 
--not sure if I need to clock these in?
process(rst,clk)
begin
    if (rst = '1') then
        m_axis_tdata   <= (others=>'0');
        m_axis_tvalid  <= '0';
    elsif rising_edge(clk) then
        m_axis_tdata  <= s_axis_tdata;
        m_axis_tvalid <= s_axis_tvalid and s_axis_tready_int;
    end if;
end process;

end rtl;

