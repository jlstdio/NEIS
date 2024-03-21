-- Ethernet AXI-S interface
-- Interface between Ethernet MAC and AXI FIFO/DMA
--                  __________________
--                  |   __________   |
--                  |  |          |  |
--                  |  |  CMD_IF  |  |=> AXI FIFO RXD
--                  |  |__________|  |
--       RX MAC  ==>|   __________   |
--                  |  |          |  |
--                  |  | TXDATA_IF|  |=> AXI DMA S2MM Slave
--                  |  |__________|  |
--                  |   __________   |
--                  |  |          |  |
--       TX MAC  <==|  | STATUS_IF|  |<=  AXI FIFO TXD
--                  |  |__________|  |
--                  |   __________   |
--                  |  |          |  |
--       TX MAC  <==|  | RXDATA_IF|  |<=  AXI DMA MM2S Master
--                  |  |__________|  |
--                  |________________|
--  

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MWEthAxisIF is
 generic( CMD_BUFFER_WIDTH   : integer := 15;
          STATUS_BUFFER_WIDTH: integer := 15;
          TXDATA_BUFFER_WIDTH: integer := 15;
          RXDATA_BUFFER_WIDTH: integer := 15
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
end MWEthAxisIF;

architecture rtl of MWEthAxisIF is

  component MWEthAxisIFRx
  generic (BUFFERADDRWIDTH : integer);
  port(
        -- Ethernet interface
        rxclk        : in std_logic;
        rxreset      : in std_logic;
        rxData       : in std_logic_vector(7 downto 0);
        rxDataVld    : in std_logic;
        rxEOP        : in std_logic;
        rxPort       : in std_logic_vector(1 downto 0);
        -- AXI-S interface
        aclk         : in  std_logic;
        arstn        : in  std_logic;
        tready       : in  std_logic;
        tdata        : out std_logic_vector(31 downto 0);
        tvalid       : out std_logic;
        tkeep        : out std_logic_vector(3 downto 0);
        tlast        : out std_logic;
        tdest        : out std_logic_vector(3 downto 0)
        );
  end component;
  
  component MWEthAxisIFTx
  generic (BUFFERADDRWIDTH : integer);
  port(
        -- Ethernet interface
        txclk        : in  std_logic;
        txreset      : in  std_logic;
        txReady      : in  std_logic;
        txData       : out std_logic_vector(7 downto 0);
        txDataVld    : out std_logic;
        txEOP        : out std_logic;
        txPort       : out std_logic_vector(1 downto 0);
        -- AXI-S interface
        aclk         : in  std_logic;
        arstn        : in  std_logic;
        tready       : out std_logic;
        tdata        : in  std_logic_vector(31 downto 0);
        tvalid       : in  std_logic;
        tkeep        : in  std_logic_vector(3 downto 0);
        tlast        : in  std_logic;
        tdest        : in  std_logic_vector(3 downto 0)
        );
  end component;  
  
  signal data_rxDataVld   : std_logic;
  signal cmd_rxDataVld    : std_logic;

begin
  
  -- data port : 00 | 10
  -- cmd  port : 01 | 11
  -- data go to TXDATA_IF; cmd go to CMD_IF
  data_rxDataVld <= rxDataVld when rxPort(0) = '0' else '0';
  cmd_rxDataVld  <= rxDataVld when rxPort(0) = '1' else '0';

  u_TXDATA_IF: MWEthAxisIFRx
  generic map(BUFFERADDRWIDTH => TXDATA_BUFFER_WIDTH)
  port map(
           rxclk       =>    rxclk         ,  
           rxreset     =>    rxreset       ,  
           rxData      =>    rxData        ,  
           rxDataVld   =>    data_rxDataVld,  
           rxEOP       =>    rxEOP         ,  
           rxPort      =>    "00"          ,  
           aclk        =>    s2dma_aclk    ,  
           arstn       =>    s2dma_rstn    ,  
           tready      =>    s2dma_tready  ,  
           tdata       =>    s2dma_tdata   ,  
           tvalid      =>    s2dma_tvalid  ,  
           tkeep       =>    s2dma_tkeep   ,  
           tlast       =>    s2dma_tlast   ,  
           tdest       =>    open       
           );

  u_CMD_IF: MWEthAxisIFRx
  generic map(BUFFERADDRWIDTH => CMD_BUFFER_WIDTH)
  port map(
           rxclk       =>    rxclk         ,  
           rxreset     =>    rxreset       ,  
           rxData      =>    rxData        ,  
           rxDataVld   =>    cmd_rxDataVld ,  
           rxEOP       =>    rxEOP         ,  
           rxPort      =>    rxPort        ,  
           aclk        =>    s2ff_aclk     ,  
           arstn       =>    s2ff_rstn     ,  
           tready      =>    s2ff_tready   ,  
           tdata       =>    s2ff_tdata    ,  
           tvalid      =>    s2ff_tvalid   ,  
           tkeep       =>    s2ff_tkeep    ,  
           tlast       =>    s2ff_tlast    ,  
           tdest       =>    s2ff_tdest       
           );
        
  u_STATUS_IF: MWEthAxisIFTx
  generic map(BUFFERADDRWIDTH => STATUS_BUFFER_WIDTH)
  port map(
           txclk       =>    txclk            ,
           txreset     =>    txreset          ,
           txReady     =>    txStatusReady    ,
           txData      =>    txStatus         ,
           txDataVld   =>    txStatusVld      ,
           txEOP       =>    txStatusEOP      ,
           txPort      =>    txStatusPort     ,
           aclk        =>    ff2s_aclk        ,
           arstn       =>    ff2s_rstn        ,
           tready      =>    ff2s_tready      ,
           tdata       =>    ff2s_tdata       ,
           tvalid      =>    ff2s_tvalid      ,
           tkeep       =>    ff2s_tkeep       ,
           tlast       =>    ff2s_tlast       ,
           tdest       =>    ff2s_tdest       
           ); 
           
  u_RXDATA_IF: MWEthAxisIFTx
  generic map(BUFFERADDRWIDTH => RXDATA_BUFFER_WIDTH)
  port map(
           txclk       =>    txclk          ,
           txreset     =>    txreset        ,
           txReady     =>    txDataReady    ,
           txData      =>    txData         ,
           txDataVld   =>    txDataVld      ,
           txEOP       =>    txDataEOP      ,
           txPort      =>    open           ,
           aclk        =>    dma2s_aclk     ,
           arstn       =>    dma2s_rstn     ,
           tready      =>    dma2s_tready   ,
           tdata       =>    dma2s_tdata    ,
           tvalid      =>    dma2s_tvalid   ,
           tkeep       =>    dma2s_tkeep    ,
           tlast       =>    dma2s_tlast    ,
           tdest       =>    "0000"   
           );           
end rtl;