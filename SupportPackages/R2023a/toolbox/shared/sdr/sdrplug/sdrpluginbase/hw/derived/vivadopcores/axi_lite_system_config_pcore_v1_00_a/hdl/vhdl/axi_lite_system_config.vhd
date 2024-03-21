
-- ----------------------------------------------
-- File Name: axi_lite_system_config.vhd
-- Created:   23-Apr-2013 15:26:49
-- Copyright  2013 MathWorks, Inc.
-- ----------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use work.sdr_hwinfo_pkg.all;

entity axi_lite_system_config is
  port ( 
        clk                 :   IN    std_logic;
        reset               :   IN    std_logic;
        clk_enable          :   IN    std_logic;
        rx_clk              :   IN    std_logic;  -- ufix1
        g_reset             :   IN    std_logic;  -- ufix1 -- 
        axi_awaddr          :   IN    std_logic_vector(31 DOWNTO 0);  -- uint32
        axi_wvalid          :   IN    std_logic;  -- ufix1
        axi_awvalid         :   IN    std_logic;  -- ufix1
        axi_wdata           :   IN    std_logic_vector(31 DOWNTO 0);  -- uint32
        i2c_reset           :   OUT   std_logic;  -- ufix1
        rx_data_path_rst    :   OUT   std_logic;  -- ufix1
        stream_enable_rx    :   OUT   std_logic;  -- ufix1
        dec_select          :   OUT   std_logic;  -- ufix1
        dec_by_pass         :   OUT   std_logic;  -- ufix1
        dut_rx_by_pass      :   OUT   std_logic;  -- ufix1
  
        
        --REGISTERS
        rd_ver_reg              : OUT   std_logic_vector(31 DOWNTO 0);  -- uint32
        rd_hwinfo1_reg          : OUT   std_logic_vector(31 DOWNTO 0);  -- uint32
        rd_hwinfo2_reg          : OUT   std_logic_vector(31 DOWNTO 0);  -- uint32
        rd_hwinfo3_reg          : OUT   std_logic_vector(31 DOWNTO 0);  -- uint32
        rd_hwinfo4_reg          : OUT   std_logic_vector(31 DOWNTO 0);  -- uint32
        rd_hwinfo5_reg          : OUT   std_logic_vector(31 DOWNTO 0);  -- uint32
        rd_hwinfo6_reg          : OUT   std_logic_vector(31 DOWNTO 0);  -- uint32
        rd_hwinfo7_reg          : OUT   std_logic_vector(31 DOWNTO 0);  -- uint32
        rd_hwinfo8_reg          : OUT   std_logic_vector(31 DOWNTO 0);  -- uint32
        rd_rxstrmenb_reg        : OUT   std_logic_vector(31 DOWNTO 0);  -- uint32
        rd_rx_data_src_path     : OUT   std_logic_vector(2 DOWNTO 0);  -- ufix3
        wr_rst_reg              : IN    std_logic_vector(31 DOWNTO 0);  -- uint32
        wr_sysrst_reg           : IN    std_logic_vector(7 DOWNTO 0);  -- uint8
        wr_rxstrmenb_reg        : IN    std_logic_vector(31 DOWNTO 0);  -- uint32
        wr_rx_data_src_path     : IN    std_logic_vector(2 DOWNTO 0);  -- ufix3
        -- TX Ports 
        tx_clk                  : in  std_logic; 
        stream_enable_tx        : out std_logic; 
        int_select              : out std_logic;
        int_by_pass             : out std_logic;
        dut_tx_by_pass          : out std_logic;
        tx_data_path_rst        : out std_logic;  -- synced with dac clk
        -- TX REGISTERS         
        rd_tx_data_src_path     : OUT   std_logic_vector(2 DOWNTO 0);   -- ufix3
        wr_tx_data_src_path     : IN    std_logic_vector(2 DOWNTO 0);   -- ufix3
        rd_txstrmenb_reg        : OUT   std_logic_vector(31 DOWNTO 0);  -- uint32
        wr_txstrmenb_reg        : IN    std_logic_vector(31 DOWNTO 0)  -- uint32
        
    );
end axi_lite_system_config;

architecture rtl of axi_lite_system_config is

  --Base address system config 0x72200000
  constant sys_rst_reg_addr         : std_logic_vector(31 downto 0) := X"72200124";
  constant rx_stream_enb_reg_addr   : std_logic_vector(31 downto 0) := X"72200128";
  constant tx_stream_enb_reg_addr   : std_logic_vector(31 downto 0) := X"7220013C";
  constant rst_reg_addr             : std_logic_vector(31 downto 0) := X"72200130";


  signal sys_rst_reg        : std_logic;
  signal sys_reset_shft     : std_logic_vector(7 downto 0);
  signal sys_rst_clr        : std_logic;
  
  signal dec_by_pass_sync   : std_logic; 
  signal dut_by_pass_sync   : std_logic; 
  signal dec_select_sync    : std_logic;
  
  signal int_by_pass_sync       : std_logic; 
  signal dut_tx_by_pass_sync    : std_logic; 
  signal int_select_sync        : std_logic;
  
  signal rst_reg                : std_logic_vector(31 downto 0);
  signal rst_clr                : std_logic;
  signal i2c_reset_shft         : std_logic_vector(7 downto 0);
  signal reset_int              : std_logic;
  
  signal rx_data_path_rst_reg   : std_logic;
  signal rx_data_path_rst_shift : std_logic_vector(7 downto 0);
  signal rx_data_path_rst_clr   : std_logic;
  
  signal tx_data_path_rst_reg   : std_logic;
  signal tx_data_path_rst_shift : std_logic_vector(7 downto 0);
  signal tx_data_path_rst_clr   : std_logic;
  signal tx_data_path_rst_sync    : std_logic;
  
  signal rx_data_path_reset_int_sync1 : std_logic;
  signal rx_data_path_reset_int_sync2 : std_logic;
  signal rx_data_path_reset_int_sync3 : std_logic;

begin  -- rtl 

rd_ver_reg <= version;
rd_hwinfo1_reg <= hwinfo1;
rd_hwinfo2_reg <= hwinfo2;
rd_hwinfo3_reg <= hwinfo3;
rd_hwinfo4_reg <= hwinfo4;
rd_hwinfo5_reg <= hwinfo5;
rd_hwinfo6_reg <= hwinfo6;
rd_hwinfo7_reg <= hwinfo7;
rd_hwinfo8_reg <= hwinfo8;

rd_rxstrmenb_reg <= wr_rxstrmenb_reg;

rd_rx_data_src_path <= wr_rx_data_src_path;

rd_tx_data_src_path <= wr_tx_data_src_path;

rd_txstrmenb_reg <= wr_txstrmenb_reg;

process(clk, reset)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
            rst_reg <= (others => '0');
            sys_rst_reg <= '0';
            rx_data_path_rst_reg <= '0';

      else
            if (axi_awvalid = '1' and axi_wvalid = '1') then
                case axi_awaddr is
                    when rst_reg_addr =>
                        rst_reg <= axi_wdata;--wr_rst_reg;
                    when sys_rst_reg_addr =>
                        sys_rst_reg  <= '1';
                    when rx_stream_enb_reg_addr =>
                        rx_data_path_rst_reg <= axi_wdata(1);--wr_rxstrmenb_reg(1);
                    when tx_stream_enb_reg_addr =>
                        tx_data_path_rst_reg <= axi_wdata(1);
                    when others =>
                        -- do nothing
                end case;
            else
                if sys_rst_clr = '1' then
                    sys_rst_reg <= '0';
                end if;
                if rst_clr = '1' then
                    rst_reg          <= (others => '0');
                end if;
                if rx_data_path_rst_clr = '1' then
                    rx_data_path_rst_reg <= '0';
                end if;
                if tx_data_path_rst_clr = '1' then
                    tx_data_path_rst_reg <= '0';
                end if;
            end if;
      end if;
    end if;
  end process;
  
  rst_proc : process (clk)
  begin
    if clk'event and clk = '1' then
        
        if sys_rst_reg = '0' then
            sys_rst_clr    <= '0';
            sys_reset_shft <= sys_reset_shft (6 downto 0) & '0';
        else
            sys_reset_shft <= (others => '1');
            sys_rst_clr    <= '1';
        end if;
      --------------------------------------------------------------------
        if rst_reg(4) = '0' then
            rst_clr       <= '0';
            i2c_reset_shft <= i2c_reset_shft (6 downto 0) & '0';
        else
            i2c_reset_shft <= (others => '1');
            rst_clr       <= '1';
        end if;

    end if;
  end process rst_proc;
  
  tx_clk_rst_proc : process (tx_clk)
  begin
    if tx_clk'event and tx_clk = '1' then
    
        if tx_data_path_rst_reg = '0' then
            tx_data_path_rst_clr    <= '0';
            tx_data_path_rst_shift   <= tx_data_path_rst_shift (6 downto 0) & '0';
        else
            tx_data_path_rst_shift   <= (others => '1');
            tx_data_path_rst_clr    <= '1';
        end if;
      
    end if;
  end process tx_clk_rst_proc;
  
  rx_clk_rst_proc : process (rx_clk)
    begin
      if rx_clk'event and rx_clk = '1' then
          
          if rx_data_path_rst_reg = '0' then
              rx_data_path_rst_clr    <= '0';
              rx_data_path_rst_shift   <= rx_data_path_rst_shift (6 downto 0) & '0';
          else
              rx_data_path_rst_shift   <= (others => '1');
              rx_data_path_rst_clr    <= '1';
          end if;
  
      end if;
    end process rx_clk_rst_proc;

-------------------------------------------------------------------------------------------------------
reset_int    <= g_reset or sys_reset_shft(7);

rx_data_path_rst <= rx_data_path_reset_int_sync3 or rx_data_path_rst_shift(7);

rx_clk_sync_proc: process(rx_clk)
begin
  if rx_clk'event and rx_clk = '1' then
    dec_by_pass_sync <= wr_rx_data_src_path(0);
    dut_by_pass_sync <= wr_rx_data_src_path(1);
    dec_select_sync  <= wr_rx_data_src_path(2);
    dec_by_pass <= dec_by_pass_sync;
    dut_rx_by_pass <= dut_by_pass_sync;
    dec_select <= dec_select_sync;
    
    rx_data_path_reset_int_sync1 <=  reset_int;
    rx_data_path_reset_int_sync2 <= rx_data_path_reset_int_sync1;
    rx_data_path_reset_int_sync3 <= rx_data_path_reset_int_sync2;
  end if;
end process;

tx_clk_sync_proc: process(tx_clk)
begin
  if tx_clk'event and tx_clk = '1' then
      int_by_pass_sync      <= wr_tx_data_src_path(0);
      dut_tx_by_pass_sync   <= wr_tx_data_src_path(1);
      int_select_sync       <= wr_tx_data_src_path(2);
      int_by_pass           <= int_by_pass_sync;
      dut_tx_by_pass        <= dut_tx_by_pass_sync;
      int_select            <= int_select_sync;
      
      tx_data_path_rst_sync <= reset_int or tx_data_path_rst_shift(7);
      tx_data_path_rst      <= tx_data_path_rst_sync;
      
  end if;
end process;

-- Following signals are synchronized at destination.
stream_enable_rx <= wr_rxstrmenb_reg(0);
stream_enable_tx <= wr_txstrmenb_reg(0);

-- reset is AXI_Lite bus reset
i2c_reset <= i2c_reset_shft(7) or reset_int;


end rtl;