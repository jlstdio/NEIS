-- AXI-S ethernet comm layer
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MWEthCommLayer is
  port(
        -- Rx MAC 
        rxclk         : in std_logic;
        rxreset       : in std_logic;
        gmii_rxd      : in  std_logic_vector(7 downto 0);
        gmii_rx_dv    : in  std_logic;
        gmii_rx_er    : in  std_logic;
        gmii_col      : in  std_logic;
        gmii_crs      : in  std_logic;
        -- Tx MAC     
        txclk         : in std_logic;
        txreset       : in std_logic;
        gmii_txd      : out std_logic_vector(7 downto 0);
        gmii_tx_en    : out std_logic;
        gmii_tx_er    : out std_logic;
        -- Rx AXI-S interface: AXIS FIFO
        s2ff_aclk     : in  std_logic;
        s2ff_rstn     : in  std_logic;
        s2ff_tready   : in  std_logic;
        s2ff_tdata    : out std_logic_vector(31 downto 0);
        s2ff_tvalid   : out std_logic;
        s2ff_tkeep    : out std_logic_vector(3 downto 0);
        s2ff_tlast    : out std_logic;
        s2ff_tdest    : out std_logic_vector(3 downto 0);
        -- Tx AXI-S interface: AXIS FIFO
        ff2s_aclk     : in  std_logic;
        ff2s_rstn     : in  std_logic;
        ff2s_tready   : out std_logic;
        ff2s_tdata    : in  std_logic_vector(31 downto 0);
        ff2s_tvalid   : in  std_logic;
        ff2s_tkeep    : in  std_logic_vector(3 downto 0);
        ff2s_tlast    : in  std_logic;
        ff2s_tdest    : in  std_logic_vector(3 downto 0);
        -- Rx AXI-S interface: AXIS DMA
        s2dma_aclk    : in  std_logic;
        s2dma_rstn    : in  std_logic;
        s2dma_tready  : in  std_logic;
        s2dma_tdata   : out std_logic_vector(31 downto 0);
        s2dma_tvalid  : out std_logic;
        s2dma_tkeep   : out std_logic_vector(3 downto 0);
        s2dma_tlast   : out std_logic;     
        -- Tx AXI-S interface: AXIS DMA
        dma2s_aclk    : in  std_logic;
        dma2s_rstn    : in  std_logic;
        dma2s_tready  : out std_logic;
        dma2s_tdata   : in  std_logic_vector(31 downto 0);
        dma2s_tvalid  : in  std_logic;
        dma2s_tkeep   : in  std_logic_vector(3 downto 0);
        dma2s_tlast   : in  std_logic
        );
end MWEthCommLayer;

architecture rtl of MWEthCommLayer is

  component MWMAC is
  generic (MWMACADDR1: integer;
           MWMACADDR2: integer;
           MWMACADDR3: integer;
           MWMACADDR4: integer;
           MWMACADDR5: integer;
           MWMACADDR6: integer;
           MWIPADDR1:  integer;
           MWIPADDR2:  integer;
           MWIPADDR3:  integer;
           MWIPADDR4:  integer;
           ONEUDP:     integer;
           BUFFERADDRWIDTH: integer
           );
  port (
        rxclk          : in  std_logic;
        rxclk_en       : in  std_logic;
        txclk          : in  std_logic;
        txclk_en       : in  std_logic;
        gmii_rxd       : in  std_logic_vector(7 downto 0);
        gmii_rx_dv     : in  std_logic;
        gmii_rx_er     : in  std_logic;
        gmii_col       : in  std_logic;
        gmii_crs       : in  std_logic;
        RxReset        : in  std_logic;
        TxData         : in  std_logic_vector(7 downto 0);
        TxDataValid    : in  std_logic;
        TxEOP          : in  std_logic;
        TxDataLength   : in  std_logic_vector(12 downto 0);
        TxSrcPort      : in  std_logic_vector(1 downto 0);
        TxReset        : in  std_logic;
        gmii_txd       : out std_logic_vector(7 downto 0);
        gmii_tx_en     : out std_logic;
        gmii_tx_er     : out std_logic;
        RxData         : out std_logic_vector(7 downto 0);
        RxDataValid    : out std_logic;
        RxEOP          : out std_logic;
        RxCRCOK        : out std_logic;
        RxCRCBad       : out std_logic;
        RxDstPort      : out std_logic_vector(1 downto 0);
        TxReady        : out std_logic
        );
  end component;

  component  MWUDPCRC
  generic(BUFFERADDRWIDTH: integer);
  port(
        clk        : in  std_logic;
        reset      : in  std_logic;
        ---------------------------------------------------------------------
        dataIn     : in std_logic_vector(7 downto 0);
        dataVldIn  : in std_logic;
        EOPIn      : in std_logic;
        portIn     : in std_logic_vector(1 downto 0);
        CRCOK      : in std_logic;
        CRCBad     : in std_logic;
        ---------------------------------------------------------------------
        dataOut    : out std_logic_vector(7 downto 0);
        dataVldOut : out std_logic;
        EOPOut     : out std_logic;
        portOut    : out std_logic_vector(1 downto 0) 
        );
  end component;   

  component MWUDPPKTBuilder
  generic ( DATA_BUF_WIDTH           : integer;
            DATA_PKTINFO_BUF_WIDTH   : integer;
            MAX_DATA_PKTLEN          : integer;
            STATUS_BUF_WIDTH         : integer;
            STATUS_PKTINFO_BUF_WIDTH : integer;
            MAX_STATUS_PKTLEN        : integer
           );
  port(
        clk        : in  std_logic;
        reset      : in  std_logic;
        ----------------------------------------------
        dataIn     : in  std_logic_vector(7 downto 0);
        dataVld    : in  std_logic;
        dataEOP    : in  std_logic;
        statusIn   : in  std_logic_vector(7 downto 0);
        statusVld  : in  std_logic;
        statusEOP  : in  std_logic;
        statusPort : in  std_logic_vector(1 downto 0);
        dataReady  : out std_logic;
        statusReady: out std_logic;
        ----------------------------------------------
        txReady    : in  std_logic; -- from Tx MAC, MAC is ready for tx
        txRequest  : out std_logic; -- to Tx MAC, pkt builder is ready for tx
        pktData    : out std_logic_vector(7 downto 0);
        pktDataVld : out std_logic;
        pktPort    : out std_logic_vector(1 downto 0);
        pktLen     : out std_logic_vector(12 downto 0)
        );
  end component;
  
  component MWEthAxisIF
  generic( CMD_BUFFER_WIDTH   : integer;
           STATUS_BUFFER_WIDTH: integer;
           TXDATA_BUFFER_WIDTH: integer;
           RXDATA_BUFFER_WIDTH: integer
          );
  port(
        -- Rx Ethernet interface
        rxclk        : in std_logic;
        rxreset      : in std_logic;
        rxData       : in std_logic_vector(7 downto 0);
        rxDataVld    : in std_logic;
        rxEOP        : in std_logic;
        rxPort       : in std_logic_vector(1 downto 0);  
        -- Tx Ethernet interface
        txclk        : in  std_logic;
        txreset      : in  std_logic;
        txDataReady  : in  std_logic;
        txStatusReady: in  std_logic;
        txData       : out std_logic_vector(7 downto 0);
        txDataVld    : out std_logic;
        txDataEOP    : out std_logic;
        txStatus     : out std_logic_vector(7 downto 0);
        txStatusVld  : out std_logic;
        txStatusEOP  : out std_logic;
        txStatusPort : out std_logic_vector(1 downto 0);   
        -- Rx AXI-S interface: AXIS FIFO
        s2ff_aclk    : in  std_logic;
        s2ff_rstn    : in  std_logic;
        s2ff_tready  : in  std_logic;
        s2ff_tdata   : out std_logic_vector(31 downto 0);
        s2ff_tvalid  : out std_logic;
        s2ff_tkeep   : out std_logic_vector(3 downto 0);
        s2ff_tlast   : out std_logic;
        s2ff_tdest   : out std_logic_vector(3 downto 0);
        -- Tx AXI-S interface: AXIS FIFO
        ff2s_aclk    : in  std_logic;
        ff2s_rstn    : in  std_logic;
        ff2s_tready  : out std_logic;
        ff2s_tdata   : in  std_logic_vector(31 downto 0);
        ff2s_tvalid  : in  std_logic;
        ff2s_tkeep   : in  std_logic_vector(3 downto 0);
        ff2s_tlast   : in  std_logic;
        ff2s_tdest   : in  std_logic_vector(3 downto 0);
        -- Rx AXI-S interface: AXIS DMA
        s2dma_aclk    : in  std_logic;
        s2dma_rstn    : in  std_logic;
        s2dma_tready  : in  std_logic;
        s2dma_tdata   : out std_logic_vector(31 downto 0);
        s2dma_tvalid  : out std_logic;
        s2dma_tkeep   : out std_logic_vector(3 downto 0);
        s2dma_tlast   : out std_logic;     
        -- Tx AXI-S interface: AXIS DMA
        dma2s_aclk    : in  std_logic;
        dma2s_rstn    : in  std_logic;
        dma2s_tready  : out std_logic;
        dma2s_tdata   : in  std_logic_vector(31 downto 0);
        dma2s_tvalid  : in  std_logic;
        dma2s_tkeep   : in  std_logic_vector(3 downto 0);
        dma2s_tlast   : in  std_logic
        );
  end component;
  
  -- Rx Ethernet signals  
  signal rxData              : std_logic_vector(7 downto 0);
  signal rxDataVld           : std_logic;
  signal rxEOP               : std_logic;
  signal rxCRCOK             : std_logic;
  signal rxCRCBad            : std_logic;
  signal rxPort              : std_logic_vector(1 downto 0);
  
  signal axis_if_rxData      : std_logic_vector(7 downto 0);
  signal axis_if_rxDataVld   : std_logic;
  signal axis_if_rxEOP       : std_logic;
  signal axis_if_rxPort      : std_logic_vector(1 downto 0);
  
  -- Tx Ethernet signals  
  signal txData              : std_logic_vector(7 downto 0);
  signal txDataVld           : std_logic;
  signal txReady             : std_logic;
  signal txRequest           : std_logic;
  signal txDataLen           : std_logic_vector(12 downto 0);
  signal txPort              : std_logic_vector(1 downto 0);
  
  signal axis_if_txDataReady   : std_logic;
  signal axis_if_txStatusReady : std_logic;
  signal axis_if_txData        : std_logic_vector(7 downto 0);
  signal axis_if_txDataVld     : std_logic;
  signal axis_if_txDataEOP     : std_logic;
  signal axis_if_txStatus      : std_logic_vector(7 downto 0);
  signal axis_if_txStatusVld   : std_logic;
  signal axis_if_txStatusEOP   : std_logic;  
  signal axis_if_txStatusPort  : std_logic_vector(1 downto 0);   
                         
begin
  u_MWMAC: MWMAC 
  generic map (
               MWMACADDR1 => 0, -- MAC: 00-0A-35-02-59-EC
               MWMACADDR2 => 10,
               MWMACADDR3 => 53,
               MWMACADDR4 => 2,
               MWMACADDR5 => 89,
               MWMACADDR6 => 236,
               MWIPADDR1 => 192,  -- IP: 192.168.2.2
               MWIPADDR2 => 168,
               MWIPADDR3 => 2,
               MWIPADDR4 => 2,
               ONEUDP => 0,       -- 4 ports
               BUFFERADDRWIDTH => 12
               )
  port map(
          rxclk                => rxclk,
          rxclk_en             => '1',
          txclk                => txclk,
          txclk_en             => '1',
          gmii_rxd             => gmii_rxd,
          gmii_rx_dv           => gmii_rx_dv,
          gmii_rx_er           => gmii_rx_er,
          gmii_txd             => gmii_txd,
          gmii_tx_en           => gmii_tx_en,
          gmii_tx_er           => gmii_tx_er,
          gmii_col             => gmii_col,
          gmii_crs             => gmii_crs,
          RxData               => rxData,
          RxDataValid          => rxDataVld,
          RxEOP                => rxEOP,
          RxCRCOK              => rxCRCOK,
          RxCRCBad             => rxCRCBad,
          RxDstPort            => rxPort,
          RxReset              => rxreset,
          TxData               => txData,
          TxDataValid          => txDataVld,
          TxReady              => txReady,
          TxEOP                => txRequest,
          TxDataLength         => txDataLen,
          TxSrcPort            => txPort,
          TxReset              => txreset
         );

  u_MWUDPCRC: MWUDPCRC
  generic map (BUFFERADDRWIDTH => 12)
  port map(
           clk        =>  rxclk            ,   
           reset      =>  rxreset          ,   
           dataIn     =>  rxData           ,   
           dataVldIn  =>  rxDataVld        ,   
           EOPIn      =>  rxEOP            ,   
           portIn     =>  rxPort           ,  
           CRCOK      =>  rxCRCOK          ,   
           CRCBad     =>  rxCRCBad         ,
           dataOut    =>  axis_if_rxData   ,
           dataVldOut =>  axis_if_rxDataVld,
           EOPOut     =>  axis_if_rxEOP    ,
           portOut    =>  axis_if_rxPort
          );

  u_MWUDPPKTBuilder: MWUDPPKTBuilder
  generic map ( DATA_BUF_WIDTH           =>  12  ,
                DATA_PKTINFO_BUF_WIDTH   =>  3   ,
                MAX_DATA_PKTLEN          =>  1464,
                STATUS_BUF_WIDTH         =>  12  ,
                STATUS_PKTINFO_BUF_WIDTH =>  3   ,
                MAX_STATUS_PKTLEN        =>  1464
              )
  port map(
           clk         =>  txclk                ,
           reset       =>  txreset              ,
           dataIn      =>  axis_if_txData       ,
           dataVld     =>  axis_if_txDataVld    ,
           dataEOP     =>  '0'                  , -- no EOP for data
           statusIn    =>  axis_if_txStatus     ,
           statusVld   =>  axis_if_txStatusVld  ,
           statusEOP   =>  axis_if_txStatusEOP  ,
           statusPort  =>  axis_if_txStatusPort ,
           dataReady   =>  axis_if_txDataReady  ,
           statusReady =>  axis_if_txStatusReady,
           txReady     =>  txReady              ,
           txRequest   =>  txRequest            ,
           pktData     =>  txData               ,
           pktDataVld  =>  txDataVld            ,
           pktPort     =>  txPort               ,
           pktLen      =>  txDataLen 
          );                  
  
   u_MWEthAxisIF: MWEthAxisIF
   generic map( CMD_BUFFER_WIDTH     => 8 ,
                STATUS_BUFFER_WIDTH  => 8 ,
                TXDATA_BUFFER_WIDTH  => 13,
                RXDATA_BUFFER_WIDTH  => 13
              )
   port map(
      rxclk          =>  rxclk                 ,   
      rxreset        =>  rxreset               ,   
      rxData         =>  axis_if_rxData        ,
      rxDataVld      =>  axis_if_rxDataVld     ,
      rxEOP          =>  axis_if_rxEOP         ,
      rxPort         =>  axis_if_rxPort        ,
      txclk          =>  txclk                 ,
      txreset        =>  txreset               ,
      txDataReady    =>  axis_if_txDataReady   ,
      txStatusReady  =>  axis_if_txStatusReady ,
      txData         =>  axis_if_txData        ,
      txDataVld      =>  axis_if_txDataVld     ,
      txDataEOP      =>  axis_if_txDataEOP     ,
      txStatus       =>  axis_if_txStatus      ,
      txStatusVld    =>  axis_if_txStatusVld   ,
      txStatusEOP    =>  axis_if_txStatusEOP   ,
      txStatusPort   =>  axis_if_txStatusPort  ,    
      s2ff_aclk      =>  s2ff_aclk             ,
      s2ff_rstn      =>  s2ff_rstn             ,
      s2ff_tready    =>  s2ff_tready           ,
      s2ff_tdata     =>  s2ff_tdata            ,  
      s2ff_tvalid    =>  s2ff_tvalid           ,  
      s2ff_tkeep     =>  s2ff_tkeep            ,  
      s2ff_tlast     =>  s2ff_tlast            ,  
      s2ff_tdest     =>  s2ff_tdest            ,
      ff2s_aclk      =>  ff2s_aclk             , 
      ff2s_rstn      =>  ff2s_rstn             ,
      ff2s_tready    =>  ff2s_tready           ,
      ff2s_tdata     =>  ff2s_tdata            ,
      ff2s_tvalid    =>  ff2s_tvalid           ,
      ff2s_tkeep     =>  ff2s_tkeep            ,
      ff2s_tlast     =>  ff2s_tlast            ,
      ff2s_tdest     =>  ff2s_tdest            ,
      s2dma_aclk     =>  s2dma_aclk            ,
      s2dma_rstn     =>  s2dma_rstn            ,
      s2dma_tready   =>  s2dma_tready          ,
      s2dma_tdata    =>  s2dma_tdata           ,
      s2dma_tvalid   =>  s2dma_tvalid          ,
      s2dma_tkeep    =>  s2dma_tkeep           ,
      s2dma_tlast    =>  s2dma_tlast           ,
      dma2s_aclk     =>  dma2s_aclk            ,
      dma2s_rstn     =>  dma2s_rstn            ,
      dma2s_tready   =>  dma2s_tready          ,
      dma2s_tdata    =>  dma2s_tdata           ,
      dma2s_tvalid   =>  dma2s_tvalid          ,
      dma2s_tkeep    =>  dma2s_tkeep           ,
      dma2s_tlast    =>  dma2s_tlast  
      );                  

end rtl;