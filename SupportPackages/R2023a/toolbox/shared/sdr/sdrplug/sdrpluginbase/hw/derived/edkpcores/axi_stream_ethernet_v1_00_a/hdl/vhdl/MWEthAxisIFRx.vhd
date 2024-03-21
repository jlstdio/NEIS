-- Interface from ethernet mac to axi-s peripheral 
-- Functions: 
-- * data packing 8 bit-> 32 bit
-- * generate axi-s signals 
-- * data buffer for clock domain crossing from eth clock 125MHz to axi-s clock 100MHz

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MWEthAxisIFRx is
generic (BUFFERADDRWIDTH: INTEGER :=  15);
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
end MWEthAxisIFRx;

architecture rtl of MWEthAxisIFRx is

  component MWEthAxisIFAsyncFIFO
  generic (
          DATA_WIDTH :integer;
          ADDR_WIDTH :integer
          );
  port (
    data_in_clk    :in  std_logic;
    data_in        :in  std_logic_vector (DATA_WIDTH-1 downto 0);
    data_in_vld    :in  std_logic;
    data_out_clk   :in  std_logic;
    data_rst       :in  std_logic;
    data_out_en    :in  std_logic;
    data_out       :out std_logic_vector (DATA_WIDTH-1 downto 0);
    data_out_vld   :out std_logic;
    fifo_full      :out std_logic
    );
  end component;
  
  type DATA_PACKING_STATE is (IDLE, DATA_1, DATA_2, DATA_3, DATA_4);
  
  signal dState           : DATA_PACKING_STATE;
  signal dPacked          : std_logic_vector(31 downto 0);
  signal dPackedVld       : std_logic;
  signal dPackedKeep      : std_logic_vector(3 downto 0);
  signal dPackedLast      : std_logic;
  signal dPackedDest      : std_logic_vector(1 downto 0);
  
  signal fifoDataIn       : std_logic_vector(38 downto 0);
  signal fifoReset        : std_logic;
  signal fifoDataOut      : std_logic_vector(38 downto 0);
  signal fifoDataOutVld   : std_logic;
  signal treadyDelay      : std_logic;
  signal treadyPosEdge    : std_logic;
  signal treadyNegEdge    : std_logic;

  signal tdataTmp         : std_logic_vector(31 downto 0);
  signal tvalidTmp        : std_logic;
  signal tkeepTmp         : std_logic_vector(3 downto 0);
  signal tlastTmp         : std_logic;
  signal tdestTmp         : std_logic_vector(3 downto 0);

begin
  -- data packing: 8 bit -> 32 bit
  process(rxclk)
  begin
    if rising_edge(rxclk) then
      if rxreset = '1' then
        dState       <= IDLE;
        dPacked      <= (others => '0');
        dPackedKeep  <= (others => '0');
        dPackedVld   <= '0';
        dPackedLast  <= '0';
        dPackedDest  <= (others => '0');
      else
        dPackedLast  <= rxEOP and rxDataVld;
        dPackedDest  <= rxPort; -- tdest is the port number
        case dState is
          when IDLE =>
            if rxDataVld = '1' then
              if rxEOP = '0' then
                dState      <= DATA_1;  
                dPackedVld  <= '0';
              else
                dState      <= IDLE;  
                dPackedVld  <= '1';
              end if;
              dPacked(7 downto 0)  <= rxData;
              dPacked(31 downto 8) <= (others => '0');
              dPackedKeep          <= "0001";
            else
              dState       <= IDLE;
              dPacked      <= (others => '0');
              dPackedKeep  <= (others => '0');
              dPackedVld   <= '0';
            end if;
          when DATA_1 =>
            if rxDataVld = '1' then
              if rxEOP = '0' then
                dState      <= DATA_2;  
                dPackedVld  <= '0';
              else
                dState      <= IDLE;  
                dPackedVld  <= '1';
              end if;
              dPacked(15 downto 8)  <= rxData;
              dPacked(31 downto 16) <= (others => '0');
              dPackedKeep           <= "0011";
            else
              dState        <= DATA_1;
              dPackedVld    <= '0';
            end if;
          when DATA_2 =>
            if rxDataVld = '1' then
              if rxEOP = '0' then
                dState      <= DATA_3;  
                dPackedVld  <= '0';
              else
                dState      <= IDLE;  
                dPackedVld  <= '1';
              end if;
              dPacked(23 downto 16) <= rxData;
              dPacked(31 downto 24) <= (others => '0');
              dPackedKeep           <= "0111";         
            else
              dState         <= DATA_2;
              dPackedVld     <= '0';
            end if;
          when DATA_3 =>
            if rxDataVld = '1' then
              if rxEOP = '0' then
                dState      <= DATA_4;  
                dPackedVld  <= '1'; -- assert every 4 valid data
              else
                dState      <= IDLE;  
                dPackedVld  <= '1';
              end if;
              dPacked(31 downto 24) <= rxData;
              dPackedKeep           <= "1111";
            else
              dState        <= DATA_3;
              dPackedVld    <= '0';
            end if;            
          when DATA_4 =>
            if rxDataVld = '1' then
              if rxEOP = '0' then
                dState      <= DATA_1;  
                dPackedVld  <= '0';
              else
                dState      <= IDLE;  
                dPackedVld  <= '1';
              end if;
              dPacked(7 downto 0)  <= rxData;
              dPacked(31 downto 8) <= (others => '0');
              dPackedKeep          <= "0001";
            else
              dState       <= DATA_4;
              dPackedVld   <= '0';
            end if;
        end case;
      end if;
    end if;
  end process;
  
  -- Data buffer
  fifoDataIn <= dPackedDest & dPackedKeep & dPackedLast & dPacked;
  fifoReset  <= rxreset or (not arstn);
  
  u_FIFO: MWEthAxisIFAsyncFIFO
  generic map(
          DATA_WIDTH => 39,
          ADDR_WIDTH => BUFFERADDRWIDTH
          )
  port map(
    data_in_clk    => rxclk          ,
    data_in        => fifoDataIn     ,
    data_in_vld    => dPackedVld     ,
    data_out_clk   => aclk           ,
    data_rst       => fifoReset      ,
    data_out_en    => tready         ,
    data_out       => fifoDataOut    ,
    data_out_vld   => fifoDataOutVld ,
    fifo_full      => open
    );

  -- tready signal positive/negative edge detection
  process(aclk)
  begin
    if rising_edge(aclk) then
      treadyDelay <= tready;
    end if;
  end process;
  
  treadyPosEdge <= tready and (not treadyDelay);
  treadyNegEdge <= (not tready) and treadyDelay;
  
  registered_output: process(aclk)
  begin
    if rising_edge(aclk) then
      if arstn = '0' then
        tdataTmp  <= (others => '0');
        tlastTmp  <= '0';
        tkeepTmp  <= (others => '0');
        tdestTmp  <= (others => '0');
        tvalidTmp <= '0';
        tdata     <= (others => '0');
        tlast     <= '0';
        tkeep     <= (others => '0');
        tdest     <= (others => '0');
        tvalid    <= '0';        
      elsif treadyNegEdge = '1' then -- save fifo output
        tdataTmp  <= fifoDataOut(31 downto 0);
        tlastTmp  <= fifoDataOut(32);
        tkeepTmp  <= fifoDataOut(36 downto 33);
        tdestTmp  <= "00" & fifoDataOut(38 downto 37);
        tvalidTmp <= fifoDataOutVld;
      elsif treadyPosEdge = '1' then -- load saved fifo output
        tdata     <= tdataTmp ;
        tlast     <= tlastTmp ;
        tkeep     <= tkeepTmp ;
        tdest     <= tdestTmp ;
        tvalid    <= tvalidTmp;
      elsif tready = '1' then
        tdata     <= fifoDataOut(31 downto 0);
        tlast     <= fifoDataOut(32);
        tkeep     <= fifoDataOut(36 downto 33);
        tdest     <= "00" & fifoDataOut(38 downto 37);
        tvalid    <= fifoDataOutVld;
      end if;
    end if;
  end process;


end rtl;