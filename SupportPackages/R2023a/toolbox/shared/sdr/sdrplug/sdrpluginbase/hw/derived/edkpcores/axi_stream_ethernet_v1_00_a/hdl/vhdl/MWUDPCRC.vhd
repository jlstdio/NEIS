-- Functions:  
-- * remove data packet header
-- * udp packet crc check.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MWUDPCRC is
  generic(
          BUFFERADDRWIDTH: INTEGER :=  12
          );
  port(
        clk        : in  std_logic;
        reset      : in  std_logic;
        -----------------------------------------------------------------------
        dataIn     : in std_logic_vector(7 downto 0);
        dataVldIn  : in std_logic;
        EOPIn      : in std_logic;
        portIn     : in std_logic_vector(1 downto 0);
        CRCOK      : in std_logic;
        CRCBad     : in std_logic;
        -----------------------------------------------------------------------
        dataOut    : out std_logic_vector(7 downto 0);
        dataVldOut : out std_logic;
        EOPOut     : out std_logic;
        portOut    : out std_logic_vector(1 downto 0)     
        );
end MWUDPCRC;

architecture rtl of MWUDPCRC is

  component MWDPRAM
    generic (
      DATAWIDTH : INTEGER;
      ADDRWIDTH : INTEGER);
    port (
      clkA     : in  std_logic;
      enbA     : in  std_logic;
      wr_dinA  : in  std_logic_vector(DATAWIDTH-1 downto 0);
      wr_addrA : in  std_logic_vector(ADDRWIDTH-1 downto 0);
      wr_enA   : in  std_logic;
      clkB     : in  std_logic;
      enbB     : in  std_logic;
      rd_addrB : in  std_logic_vector(ADDRWIDTH-1 downto 0);
      rd_doutB : out std_logic_vector(DATAWIDTH-1 downto 0));
  end component;

  type PKT_STATE_TYPE is (IDLE, FIRSTBYTE, SECONDBYTE, THIRDBYTE, FOURTHBYTE, WAIT4EOP);
  type WR_STATE_TYPE  is (WR_IDLE, WR_DATA, WR_CHECKCRC);

  signal pktState     : PKT_STATE_TYPE;
  signal dataTmp      : std_logic_vector(7 downto 0);
  signal dataVldTmp   : std_logic;
  signal dataVldTmp_d : std_logic;
  signal EOPTmp       : std_logic;
  signal portTmp      : std_logic_vector(1 downto 0);
  signal CRCOKTmp     : std_logic;
  signal CRCBadTmp    : std_logic;
                        
  signal wrData       : std_logic_vector(10 downto 0); -- port(2) eop(1) data (8)
  signal rdData       : std_logic_vector(10 downto 0);
  signal wrAddr       : unsigned(BUFFERADDRWIDTH-1 downto 0);
  signal wrAddrFirst  : unsigned(BUFFERADDRWIDTH-1 downto 0); -- wrAddr for first byte of pkt
  signal wrAddrLast   : unsigned(BUFFERADDRWIDTH-1 downto 0); -- wrAddr for last byte of pkt
  signal rdAddr       : unsigned(BUFFERADDRWIDTH-1 downto 0);
  signal empty        : std_logic;
  signal pktStart     : std_logic;
  signal wrState      : WR_STATE_TYPE;
  signal rdDataVld    : std_logic;

begin
  -- remove data packet header
  process(clk)
  begin
   if rising_edge(clk) then
    if reset = '1' then
      pktState     <= IDLE;
      dataTmp    <= (others => '0');
      dataVldTmp <= '0';
      EOPTmp     <= '0';
      CRCOKTmp   <= '0';
      CRCBadTmp  <= '0';
      portTmp    <= "00";
    else
      dataTmp    <= dataIn;
      EOPTmp     <= EOPIn;
      CRCOKTmp   <= CRCOK;
      CRCBadTmp  <= CRCBad;
      portTmp    <= portIn; 
      case pktState is
        when IDLE =>
          pktState     <= IDLE;    
          dataVldTmp <= dataVldIn;
          if dataVldIn = '1' then
            pktState   <= FIRSTBYTE;
            if portIn(0) = '0' then -- data pkt
              dataVldTmp <= '0';
            end if;
          end if;
        when FIRSTBYTE =>
          if portIn(0) = '0' then
            pktState   <= SECONDBYTE;
          else
            pktState   <= WAIT4EOP;
          end if;
        when SECONDBYTE =>
          pktState     <= THIRDBYTE;
        when THIRDBYTE =>
          pktState     <= FOURTHBYTE;
        when FOURTHBYTE =>
          pktState     <= WAIT4EOP;
        when WAIT4EOP =>
          pktState     <= WAIT4EOP;
          dataVldTmp   <= dataVldIn;
          if EOPIn = '1' then
            pktState   <= IDLE;
          end if;
      end case;
    end if;
   end if;
  end process;
  
  -- UDP CRC Check
  
  -- DPRAM component
  u_MWDPRAM: MWDPRAM
  generic map (
    DATAWIDTH => 11,
    ADDRWIDTH => BUFFERADDRWIDTH)
  port map (
    clkA     => clk,
    enbA     => '1',
    wr_dinA  => wrData,
    wr_addrA => std_logic_vector(wrAddr), 
    wr_enA   => dataVldTmp,
    clkB     => clk,
    enbB     => '1',
    rd_addrB => std_logic_vector(rdAddr),
    rd_doutB => rdData);
    
  -- Detect start point of the packet (posedge of dataVldTmp)
  process (clk)
  begin
    if rising_edge(clk) then 
      dataVldTmp_d <= dataVldTmp;
    end if;
  end process;
  pktStart <= (not dataVldTmp_d) and dataVldTmp;
  
  -- DPRAM write FSM
  process (clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        wrState      <= WR_IDLE;
        wrAddr       <= (others => '0');
        wrAddrFirst  <= (others => '0');
        wrAddrLast   <= (others => '0');
      else
        case wrState is
          when WR_IDLE =>
            if pktStart = '1' then
              wrAddr      <= wrAddr + 1;
              wrAddrFirst <= wrAddr;
              wrState     <= WR_DATA;
            end if;
          when WR_DATA =>
            if dataVldTmp = '1' then
              wrAddr <= wrAddr + 1;
              if EOPTmp = '1' then -- crc check after EOP
                wrState <= WR_CHECKCRC;
              end if;
            end if;
          when WR_CHECKCRC =>
            if CRCOKTmp = '1' then
              wrAddrLast <= wrAddr; -- if crc ok, update wrAddrLast
              wrState    <= WR_IDLE;
            elsif CRCBadTmp = '1' then -- if crc bad, discard the packet by adjusting wrAddr
              wrAddr  <= wrAddrFirst;
              wrState <= WR_IDLE;
            end if;
        end case;  
      end if;
    end if;
  end process;
  
  -- DPRAM status
  empty <= '1' when rdAddr = wrAddrLast else '0';
  
  -- DPRAM read
  process (clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        rdAddr      <= (others => '0');
        rdDataVld   <= '0'; 
      else
        if empty = '1' then
          rdAddr     <= rdAddr;
          rdDataVld  <= '0';
        else
          rdAddr     <= rdAddr +1;
          rdDataVld  <= '1';
        end if;
      end if;
    end if;
  end process;

  -- DPRAM data in
  wrData <= portTmp & EOPTmp & dataTmp; -- 11 bits 
  
  -- DPRAM data out
  dataOut    <= rdData(7 downto 0);
  EOPOut     <= rdData(8);
  portOut    <= rdData(10 downto 9);
  dataVldOut <= rdDataVld;
  
end rtl;