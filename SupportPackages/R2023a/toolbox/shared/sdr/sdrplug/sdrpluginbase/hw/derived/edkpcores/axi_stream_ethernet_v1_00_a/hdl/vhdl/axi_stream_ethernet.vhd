library UNISIM;
use UNISIM.VComponents.all;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity axi_stream_ethernet is
PORT (
      sysrst               : in  std_logic;
      ETH_RXD              : in  std_logic_vector(7 downto 0);
      ETH_RXCLK            : in  std_logic;
      ETH_RXER             : in  std_logic;
      ETH_RXDV             : in  std_logic;
      ETH_COL              : in  std_logic;
      ETH_CRS              : in  std_logic;
      ETH_TXCLK            : in  std_logic;
      ETH_TXEN             : out std_logic;
      ETH_TXD              : out std_logic_vector(7 downto 0);
      ETH_RESET_n          : out std_logic;
      ETH_GTXCLK           : out std_logic;
      ETH_TXER             : out std_logic;
      ETH_MDC              : out std_logic;
      -- AXI-S I/F : FIFO 
      s2ff_aclk            : in  std_logic;
      s2ff_rstn            : in  std_logic;
      s2ff_tready          : in  std_logic;
      s2ff_tdata           : out std_logic_vector(31 downto 0);
      s2ff_tvalid          : out std_logic;
      s2ff_tkeep           : out std_logic_vector(3 downto 0);
      s2ff_tlast           : out std_logic;
      s2ff_tdest           : out std_logic_vector(3 downto 0);
      ff2s_aclk            : in  std_logic;
      ff2s_rstn            : in  std_logic;
      ff2s_tready          : out std_logic;
      ff2s_tdata           : in  std_logic_vector(31 downto 0);
      ff2s_tvalid          : in  std_logic;
      ff2s_tkeep           : in  std_logic_vector(3 downto 0);
      ff2s_tlast           : in  std_logic;
      ff2s_tdest           : in  std_logic_vector(3 downto 0);   
      -- AXI-S I/F : DMA 
      s2dma_aclk            : in  std_logic;
      s2dma_rstn            : in  std_logic;
      s2dma_tready          : in  std_logic;
      s2dma_tdata           : out std_logic_vector(31 downto 0);
      s2dma_tvalid          : out std_logic;
      s2dma_tkeep           : out std_logic_vector(3 downto 0);
      s2dma_tlast           : out std_logic;
      dma2s_aclk            : in  std_logic;
      dma2s_rstn            : in  std_logic;
      dma2s_tready          : out std_logic;
      dma2s_tdata           : in  std_logic_vector(31 downto 0);
      dma2s_tvalid          : in  std_logic;
      dma2s_tkeep           : in  std_logic_vector(3 downto 0);
      dma2s_tlast           : in  std_logic
    );
end axi_stream_ethernet;

architecture rtl of axi_stream_ethernet is

  component MWEthCommLayer is 
  port (
        rxclk                : in  std_logic;
        rxreset              : in  std_logic;
        gmii_rxd             : in  std_logic_vector(7 downto 0);
        gmii_rx_dv           : in  std_logic;
        gmii_rx_er           : in  std_logic;
        gmii_col             : in  std_logic;
        gmii_crs             : in  std_logic;
        txclk                : in  std_logic;
        txreset              : in  std_logic;
        s2ff_aclk            : in  std_logic;
        s2ff_rstn            : in  std_logic;
        s2ff_tready          : in  std_logic;
        gmii_txd             : out std_logic_vector(7 downto 0);
        gmii_tx_en           : out std_logic;
        gmii_tx_er           : out std_logic;
        s2ff_tdata           : out std_logic_vector(31 downto 0);
        s2ff_tvalid          : out std_logic;
        s2ff_tkeep           : out std_logic_vector(3 downto 0);
        s2ff_tlast           : out std_logic;
        s2ff_tdest           : out std_logic_vector(3 downto 0);
        ff2s_aclk            : in  std_logic;
        ff2s_rstn            : in  std_logic;
        ff2s_tready          : out std_logic;
        ff2s_tdata           : in  std_logic_vector(31 downto 0);
        ff2s_tvalid          : in  std_logic;
        ff2s_tkeep           : in  std_logic_vector(3 downto 0);
        ff2s_tlast           : in  std_logic;
        ff2s_tdest           : in  std_logic_vector(3 downto 0);
        s2dma_aclk           : in  std_logic;
        s2dma_rstn           : in  std_logic;
        s2dma_tready         : in  std_logic;
        s2dma_tdata          : out std_logic_vector(31 downto 0);
        s2dma_tvalid         : out std_logic;
        s2dma_tkeep          : out std_logic_vector(3 downto 0);
        s2dma_tlast          : out std_logic;     
        dma2s_aclk           : in  std_logic;
        dma2s_rstn           : in  std_logic;
        dma2s_tready         : out std_logic;
        dma2s_tdata          : in  std_logic_vector(31 downto 0);
        dma2s_tvalid         : in  std_logic;
        dma2s_tkeep          : in  std_logic_vector(3 downto 0);
        dma2s_tlast          : in  std_logic        
  );
  end component;

  signal gmii_tx_clk : std_logic;
  signal gmii_rx_clk : std_logic;
   
  signal gmii_rxd    : std_logic_vector(7 downto 0);
  signal gmii_rx_dv  : std_logic;
  signal gmii_rx_er  : std_logic;
  signal gmii_col    : std_logic;
  signal gmii_crs    : std_logic;
  
  signal gmii_txd    : std_logic_vector(7 downto 0);
  signal gmii_tx_en  : std_logic;
  signal gmii_tx_er  : std_logic;
  
  signal sysrst_rxclk_sync1 : std_logic;
  signal sysrst_rxclk_sync2 : std_logic;
  
  signal sysrst_txclk_sync1 : std_logic;
  signal sysrst_txclk_sync2 : std_logic;

  signal s2ff_rstn_sync1:     std_logic;  
  signal s2ff_rstn_sync2:     std_logic;    
                              
  signal ff2s_rstn_sync1:     std_logic;  
  signal ff2s_rstn_sync2:     std_logic;  

  signal s2dma_rstn_sync1:    std_logic;  
  signal s2dma_rstn_sync2:    std_logic;    
                              
  signal dma2s_rstn_sync1:    std_logic;  
  signal dma2s_rstn_sync2:    std_logic;  
  
begin
  
  -- GMII Interface
  gmii_rx_clk <= ETH_RXCLK;
  gmii_tx_clk <= ETH_TXCLK;
  
  ETH_MDC <= '0';
  
  u_ODDR: ODDR 
  generic map (DDR_CLK_EDGE => "OPPOSITE_EDGE",
  INIT => '0',
  SRTYPE => "SYNC"
  )
  port map(
          CE                   => '1',
          S                    => '0',
          C                    => gmii_tx_clk,
          D2                   => '0',
          Q                    => ETH_GTXCLK,
          R                    => '0',
          D1                   => '1'
  );
  
  -- Rx MAC signal register input
  process (gmii_rx_clk)
  begin
    if rising_edge(gmii_rx_clk) then 
      gmii_rxd      <= ETH_RXD;
      gmii_rx_dv    <= ETH_RXDV;
      gmii_rx_er    <= ETH_RXER;
      gmii_col      <= ETH_COL;
      gmii_crs      <= ETH_CRS;
    end if;
  end process;
  
  -- Tx MAC signal register output
  process (gmii_tx_clk)
  begin
    if rising_edge(gmii_tx_clk) then 
      ETH_TXD     <= gmii_txd  ;  
      ETH_TXEN    <= gmii_tx_en;  
      ETH_TXER    <= gmii_tx_er;
      ETH_RESET_n <=  NOT sysrst;
    end if;
  end process;

  -- reset sync
  process(gmii_rx_clk)  
  begin
    if rising_edge(gmii_rx_clk) then
      sysrst_rxclk_sync1 <= sysrst;
      sysrst_rxclk_sync2 <= sysrst_rxclk_sync1;
    end if;
  end process;

  process(gmii_tx_clk)  
  begin
    if rising_edge(gmii_tx_clk) then
      sysrst_txclk_sync1 <= sysrst;
      sysrst_txclk_sync2 <= sysrst_txclk_sync1;
    end if;
  end process;

  process(s2ff_aclk)  
  begin
    if rising_edge(s2ff_aclk) then
      s2ff_rstn_sync1 <= s2ff_rstn;
      s2ff_rstn_sync2 <= s2ff_rstn_sync1;
    end if;
  end process;

  process(ff2s_aclk)  
  begin
    if rising_edge(ff2s_aclk) then
      ff2s_rstn_sync1 <= ff2s_rstn;
      ff2s_rstn_sync2 <= ff2s_rstn_sync1;
    end if;
  end process;

  process(s2dma_aclk)  
  begin
    if rising_edge(s2dma_aclk) then
      s2dma_rstn_sync1 <= s2dma_rstn;
      s2dma_rstn_sync2 <= s2dma_rstn_sync1;
    end if;
  end process;

  process(dma2s_aclk)  
  begin
    if rising_edge(dma2s_aclk) then
      dma2s_rstn_sync1 <= dma2s_rstn;
      dma2s_rstn_sync2 <= dma2s_rstn_sync1;
    end if;
  end process;
  
  u_MWEthCommLayer: MWEthCommLayer
  port map(
        rxclk                => gmii_rx_clk       ,
        rxreset              => sysrst_rxclk_sync2,
        gmii_rxd             => gmii_rxd          ,
        gmii_rx_dv           => gmii_rx_dv        ,
        gmii_rx_er           => gmii_rx_er        ,
        gmii_col             => gmii_col          ,  
        gmii_crs             => gmii_crs          ,  
        txclk                => gmii_tx_clk       ,
        txreset              => sysrst_txclk_sync2,
        gmii_txd             => gmii_txd          ,     
        gmii_tx_en           => gmii_tx_en        ,
        gmii_tx_er           => gmii_tx_er        ,   
        s2ff_aclk            => s2ff_aclk         ,       
        s2ff_rstn            => s2ff_rstn_sync2   ,       
        s2ff_tready          => s2ff_tready       ,     
        s2ff_tdata           => s2ff_tdata        ,
        s2ff_tvalid          => s2ff_tvalid       ,
        s2ff_tkeep           => s2ff_tkeep        ,
        s2ff_tlast           => s2ff_tlast        ,
        s2ff_tdest           => s2ff_tdest        ,
        ff2s_aclk            => ff2s_aclk         ,   
        ff2s_rstn            => ff2s_rstn_sync2   ,   
        ff2s_tready          => ff2s_tready       ,   
        ff2s_tdata           => ff2s_tdata        ,   
        ff2s_tvalid          => ff2s_tvalid       ,   
        ff2s_tkeep           => ff2s_tkeep        ,   
        ff2s_tlast           => ff2s_tlast        ,   
        ff2s_tdest           => ff2s_tdest        ,
        s2dma_aclk           => s2dma_aclk        ,
        s2dma_rstn           => s2dma_rstn_sync2  ,
        s2dma_tready         => s2dma_tready      ,
        s2dma_tdata          => s2dma_tdata       ,
        s2dma_tvalid         => s2dma_tvalid      ,
        s2dma_tkeep          => s2dma_tkeep       ,
        s2dma_tlast          => s2dma_tlast       ,
        dma2s_aclk           => dma2s_aclk        ,
        dma2s_rstn           => dma2s_rstn_sync2  ,
        dma2s_tready         => dma2s_tready      ,
        dma2s_tdata          => dma2s_tdata       ,
        dma2s_tvalid         => dma2s_tvalid      ,
        dma2s_tkeep          => dma2s_tkeep       ,
        dma2s_tlast          => dma2s_tlast );

end rtl;