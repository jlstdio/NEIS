----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 

----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity axi_stream_sample_counter is
    generic(
        AXIS_DATA_WIDTH : integer  := 32
    );
    Port (  ACLK                : IN STD_LOGIC;
            ARESETN             : IN STD_LOGIC;
            S_AXIS_TVALID       : IN STD_LOGIC;
            S_AXIS_TREADY       : OUT STD_LOGIC;
            S_AXIS_TDATA        : IN STD_LOGIC_VECTOR(AXIS_DATA_WIDTH-1 DOWNTO 0);
            M_AXIS_TVALID       : OUT STD_LOGIC;
            M_AXIS_TREADY       : IN STD_LOGIC;
            M_AXIS_TDATA        : OUT STD_LOGIC_VECTOR(AXIS_DATA_WIDTH-1 DOWNTO 0);
            M_AXIS_TLAST        : OUT STD_LOGIC;
            DEBUG_OUT           : OUT STD_LOGIC_VECTOR(34 downto 0)
         );
end axi_stream_sample_counter;

architecture Behavioral of axi_stream_sample_counter is

    constant SAMPLES_PER_RING   : integer := 32768;
    
    signal sample_cnt : unsigned(31 downto 0);
    signal tlast_int : std_logic;

begin

    M_AXIS_TVALID   <= S_AXIS_TVALID;       -- pass through
    M_AXIS_TDATA    <= S_AXIS_TDATA;        -- pass through
    S_AXIS_TREADY   <= M_AXIS_TREADY;       -- pass through
    
    M_AXIS_TLAST <= tlast_int;
    
    DEBUG_OUT <= S_AXIS_TVALID & M_AXIS_TREADY & tlast_int & std_logic_vector(sample_cnt); 
    
    gen_tlast : process(ACLK, ARESETN, S_AXIS_TVALID) is

    begin
        if (ARESETN = '0') then
            sample_cnt <= (others => '0');
            tlast_int <= '0';
        elsif rising_edge(ACLK) then
        
            if ((S_AXIS_TVALID = '1') and (M_AXIS_TREADY = '1') ) then
                                
                if (sample_cnt = SAMPLES_PER_RING - 2) then
                    sample_cnt  <= sample_cnt + 1;
                    tlast_int <= '1';
                elsif (sample_cnt = SAMPLES_PER_RING - 1) then
                    sample_cnt <= (others => '0');
                    tlast_int <= '0';
                elsif (sample_cnt < SAMPLES_PER_RING) then
                    sample_cnt <= sample_cnt + 1;
                    tlast_int <= '0';
                end if;                
                
            end if;
        
        
        end if;
    end process;
 
end Behavioral;

