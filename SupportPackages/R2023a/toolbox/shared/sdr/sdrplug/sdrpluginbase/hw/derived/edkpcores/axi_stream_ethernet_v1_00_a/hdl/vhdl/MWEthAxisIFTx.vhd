-- Interface from axi-s peripheral to ethernet mac
-- Functions: 
-- * data unpacking 32 bit-> 8 bit
-- * generate data eop and port signals
-- * data buffer for clock domain crossing from axi-s clock 100MHz to eth clock 125MHz 

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MWEthAxisIFTx is
generic (BUFFERADDRWIDTH: INTEGER :=  15);
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
end MWEthAxisIFTx;

architecture rtl of MWEthAxisIFTx is

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
  
  type DATA_UNPACKING_STATE is (IDLE, WAIT4VLD, DATA_1, DATA_2, DATA_3, DATA_4);
  
  signal dState       : DATA_UNPACKING_STATE;
  signal dFIFO        : std_logic_vector(31 downto 0);
  signal dFIFOVld     : std_logic;
  signal dFIFOLast    : std_logic;
  signal dFIFOKeep    : std_logic_vector(3 downto 0);
  signal dFIFODest    : std_logic_vector(1 downto 0);
  
  signal dFIFOReg     : std_logic_vector(31 downto 0);
  signal dFIFOLastReg : std_logic;
  signal dFIFOKeepReg : std_logic_vector(3 downto 0);
  signal dFIFODestReg : std_logic_vector(1 downto 0);  
  
  signal fifoDataIn   : std_logic_vector(38 downto 0);
  signal fifoReset    : std_logic;
  signal fifoFull     : std_logic;
  signal fifoDataOut  : std_logic_vector(38 downto 0);
  signal fifoDataEn   : std_logic;

begin

  -- data buffer
  fifoDataIn <= tdest(1 downto 0) & tkeep & tlast & tdata;
  fifoReset  <= txreset or (not arstn);
  tready     <=  not fifoFull; -- if fifo is full, AXI-S tready is low
  
  dFIFO      <= fifoDataOut(31 downto 0);
  dFIFOLast  <= fifoDataOut(32);
  dFIFOKeep  <= fifoDataOut(36 downto 33);
  dFIFODest  <= fifoDataOut(38 downto 37); 
  
  
  u_FIFO: MWEthAxisIFAsyncFIFO
  generic map(
          DATA_WIDTH => 39,
          ADDR_WIDTH => BUFFERADDRWIDTH
          )
  port map(
    data_in_clk    => aclk        ,
    data_in        => fifoDataIn  ,
    data_in_vld    => tvalid      ,
    data_out_clk   => txclk       ,
    data_rst       => fifoReset   ,
    data_out_en    => fifoDataEn  ,
    data_out       => fifoDataOut ,
    data_out_vld   => dFIFOVld    ,
    fifo_full      => fifoFull
    );

  -- data unpacking: 32 bit -> 8 bit
  process(txclk)
  begin
    if rising_edge(txclk) then
      if txreset = '1' then
        dState        <= IDLE;
        fifoDataEn    <= '0';
        txData        <= (others => '0');
        txdataVld     <= '0';
        txPort        <= "00";
        txEOP         <= '0';
        dFIFOReg      <= (others => '0');
        dFIFOLastReg  <= '0';
        dFIFOKeepReg  <= (others => '0');
        dFIFODestReg  <= "00";
      else
        case dState is
          when IDLE => 
            dState        <= IDLE;
            fifoDataEn    <= '0';
            txData        <= (others => '0');
            txdataVld     <= '0';
            txPort        <= "00";         
            txEOP         <= '0';
            dFIFOReg      <= (others => '0');
            dFIFOLastReg  <= '0';
            dFIFOKeepReg  <= (others => '0');
            dFIFODestReg  <= "00" ;           
            if txReady = '1' then
              dState     <= WAIT4VLD;
              fifoDataEn <= '1';
            end if;
          when WAIT4VLD =>
            if dFIFOVld = '1'  then
              dState        <= DATA_1;
              fifoDataEn    <= '0';
              txData        <= dFIFO(7 downto 0);
              txdataVld     <= dFIFOKeep(0);
              txPort        <= dFIFODest;
              dFIFOReg      <= dFIFO;     -- register valid value for p/s
              dFIFOLastReg  <= dFIFOLast;
              dFIFOKeepReg  <= dFIFOKeep;
              dFIFODestReg  <= dFIFODest;                 
              if (dFIFOKeep = "0001") and (dFIFOLast = '1') then
                txEOP      <= '1';
              else
                txEOP      <= '0';
              end if;
            elsif txReady = '0' then
              dState        <= IDLE;
              fifoDataEn    <= '0';
              txData        <= (others => '0');
              txdataVld     <= '0';
              txPort        <= "00";
              txEOP         <= '0';
              dFIFOReg      <= (others => '0');
              dFIFOLastReg  <= '0';
              dFIFOKeepReg  <= (others => '0');
              dFIFODestReg  <= "00" ;                    
            else -- txReady = 1 and dFIFOVld = '0' => wait for valid
              dState        <= WAIT4VLD;
              -- if WAIT4VLD, fifoDataEn toggles to avoid two consecutive asserts,
              -- so that the fifo wouldn't output two consecutive valid value.
              fifoDataEn    <= not fifoDataEn;
            end if;
          when DATA_1 =>
            dState     <= DATA_2;
            fifoDataEn <= '0';
            txData     <= dFIFOReg(15 downto 8); -- output registered value
            txdataVld  <= dFIFOKeepReg(1);
            txPort     <= dFIFODestReg;
            if (dFIFOKeepReg = "0011") and (dFIFOLastReg = '1') then
              txEOP      <= '1';
            else
              txEOP      <= '0';
            end if;            
          when DATA_2 =>
            dState     <= DATA_3;
            fifoDataEn <= txReady; -- assert fifoDataEn one clk ahead because fifo output has delay
            txData     <= dFIFOReg(23 downto 16);
            txdataVld  <= dFIFOKeepReg(2);
            txPort     <= dFIFODestReg;
            if (dFIFOKeepReg = "0111") and (dFIFOLastReg = '1') then
              txEOP      <= '1';
            else
              txEOP      <= '0';
            end if;       
          when DATA_3 =>
            dState     <= DATA_4;
            fifoDataEn <= '0';
            txData     <= dFIFOReg(31 downto 24);
            txdataVld  <= dFIFOKeepReg(3);
            txPort     <= dFIFODestReg;
            if (dFIFOKeepReg = "1111") and (dFIFOLastReg = '1') then
              txEOP      <= '1';
            else
              txEOP      <= '0';
            end if;          
          when DATA_4 =>
            if txReady = '0' then -- one sample unpacking is done. if txReady = '0' go to IDLE
              dState        <= IDLE;
              fifoDataEn    <= '0';
              txData        <= (others => '0');
              txdataVld     <= '0';
              txPort        <= "00";
              txEOP         <= '0';
              dFIFOReg      <= (others => '0');
              dFIFOLastReg  <= '0';
              dFIFOKeepReg  <= (others => '0');
              dFIFODestReg  <= "00" ;
            elsif dFIFOVld = '1' then
              dState        <= DATA_1;
              fifoDataEn    <= '0';
              txData        <= dFIFO(7 downto 0);
              txdataVld     <= dFIFOKeep(0);
              txPort        <= dFIFODest;
              dFIFOReg      <= dFIFO;     -- register valid value for p/s
              dFIFOLastReg  <= dFIFOLast;
              dFIFOKeepReg  <= dFIFOKeep;
              dFIFODestReg  <= dFIFODest;                               
              if (dFIFOKeep = "0001") and (dFIFOLast = '1') then
                txEOP      <= '1';
              else
                txEOP      <= '0';
              end if;  
            else
              dState        <= WAIT4VLD;
              fifoDataEn    <= '1';
              txData        <= (others => '0');
              txdataVld     <= '0';
              txPort        <= "00";
              txEOP         <= '0';
              dFIFOReg      <= (others => '0');
              dFIFOLastReg  <= '0';
              dFIFOKeepReg  <= (others => '0');
              dFIFODestReg  <= "00" ;              
            end if;
        end case;
      end if;
    end if;
  end process;

end rtl;