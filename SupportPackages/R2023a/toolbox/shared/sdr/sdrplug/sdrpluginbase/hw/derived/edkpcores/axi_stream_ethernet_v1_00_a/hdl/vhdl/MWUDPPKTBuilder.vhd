-- Functions:
-- * build UDP packets for data/status

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MWUDPPKTBuilder is
  generic ( DATA_BUF_WIDTH           : integer :=  12  ;
            DATA_PKTINFO_BUF_WIDTH   : integer :=  4   ;
            MAX_DATA_PKTLEN          : integer :=  1464;
            STATUS_BUF_WIDTH         : integer :=  12  ;
            STATUS_PKTINFO_BUF_WIDTH : integer :=  4   ;
            MAX_STATUS_PKTLEN        : integer :=  100
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
end MWUDPPKTBuilder;

architecture rtl of MWUDPPKTBuilder is
  
  constant DATA_HEADER_LENGTH    : integer := 5; 

  component MWPKTBuffer
    generic ( DATA_BUF_WIDTH    : integer;
              PKTINFO_BUF_WIDTH : integer;
              MAXPKTLEN         : integer
            );
    port(
          clk                  : in  std_logic;
          reset                : in  std_logic;
          dataIn               : in  std_logic_vector(7 downto 0);
          dataVldIn            : in  std_logic;
          EOP                  : in  std_logic;
          dataPort             : in  std_logic_vector(1 downto 0);
          bufferReady          : out std_logic;
          rdEn                 : in std_logic;        
          dataOut              : out std_logic_vector(7 downto 0);
          dataVldOut           : out std_logic;
          PKTLoad              : in std_logic;
          PKTReady             : out std_logic;
          PKTLen               : out unsigned(DATA_BUF_WIDTH downto 0);
          PKTPort              : out std_logic_vector(1 downto 0)
          );
  end component;
  
  signal dataPKTLoad  : std_logic;
  signal dataPKTReady : std_logic;
  signal dataPKTLen   : unsigned(DATA_BUF_WIDTH downto 0);
  signal dataPKTEn    : std_logic;
  signal dataPKT      : std_logic_vector(7 downto 0);
  signal dataPKTVld   : std_logic;
  
  signal statusPKTLoad   : std_logic;
  signal statusPKTReady  : std_logic;
  signal statusPKTLen    : unsigned(STATUS_BUF_WIDTH downto 0);
  signal statusPKTPort   : std_logic_vector(1 downto 0);
  signal statusPKTEn     : std_logic;
  signal statusPKT       : std_logic_vector(7 downto 0);
  signal statusPKTVld    : std_logic;
  
  type PKT_STATE_TYPE is (IDLE, PKT_READY, STATUS_MODE, STATUS_PKT, DATA_MODE, DATA_PKT_HEADER, DATA_PKT_PAYLOAD);  
  
  signal pktState                : PKT_STATE_TYPE; 
  signal thisPKTPort             : std_logic_vector(1 downto 0);
  signal thisPKTLen              : unsigned(12 downto 0);
  signal dataHeader              : std_logic_vector(39 downto 0); 
  signal dataHeaderReg           : std_logic_vector(39 downto 0); 
  signal seqNumber               : unsigned(15 downto 0); 
  signal waitCycle               : unsigned(6 downto 0);  
  signal txReady_d, txReadyTmp   : std_logic;

begin
  --buffer to hold data packets
  u_DATA_BUF: MWPKTBuffer
  generic map (
                DATA_BUF_WIDTH    => DATA_BUF_WIDTH,
                PKTINFO_BUF_WIDTH => DATA_PKTINFO_BUF_WIDTH,
                MAXPKTLEN         => MAX_DATA_PKTLEN
               )
  port map (
            clk          => clk,
            reset        => reset,
            dataIn       => dataIn,
            dataVldIn    => dataVld,
            EOP          => dataEOP,
            dataPort     => "00",
            bufferReady  => dataReady,            
            rdEn         => dataPKTEn,
            dataOut      => dataPKT,
            dataVldOut   => dataPKTVld,
            PKTLoad      => dataPKTLoad,
            PKTReady     => dataPKTReady,
            PKTLen       => dataPKTLen,
            PKTPort      => open
            );

  --buffer to hold status packets
  u_STATUS_BUF: MWPKTBuffer
  generic map (
                DATA_BUF_WIDTH    => STATUS_BUF_WIDTH,
                PKTINFO_BUF_WIDTH => STATUS_PKTINFO_BUF_WIDTH,
                MAXPKTLEN         => MAX_STATUS_PKTLEN
               )
  port map (
            clk         => clk,
            reset       => reset,
            dataIn      => statusIn,
            dataVldIn   => statusVld,
            EOP         => statusEOP,
            dataPort    => statusPort,
            bufferReady => statusReady,            
            rdEn        => statusPKTEn,
            dataOut     => statusPKT,
            dataVldOut  => statusPKTVld,
            PKTLoad     => statusPKTLoad,
            PKTReady    => statusPKTReady,
            PKTLen      => statusPKTLen,
            PKTPort     => statusPKTPort
            );            

  ---------------------  FSM to build packets ---------------------------------------------------------
  dataHeader(39 downto 32)   <= X"00";
  dataHeader(31 downto 24)   <= std_logic_vector(seqNumber(7 downto 0));
  dataHeader(23 downto 16)   <= std_logic_vector(seqNumber(15 downto 8));
  dataHeader(15 downto 8)    <= X"00"; -- bufferStatus;
  dataHeader(7 downto 0)     <= X"00"; -- pStatus;
 
  process (clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        pktState         <= IDLE;
        pktData          <= (others => '0');
        pktDataVld       <= '0';
        pktLen           <= (others => '0');
        pktPort          <= "00";
        seqNumber        <= (others => '0');
        waitCycle        <= (others => '0');
        dataHeaderReg    <= dataHeader;
        txRequest        <= '0';
        statusPKTEn      <= '0';
        statusPKTLoad    <= '0';
        dataPKTEn        <= '0';
        dataPKTLoad      <= '0';
        thisPKTPort      <= (others => '0');
        thisPKTLen       <= (others => '0');
      else
        case pktState is
          when IDLE =>
            pktState          <= IDLE;
            pktData           <= (others => '0');
            pktDataVld        <= '0';
            pktLen            <= (others => '0');
            pktPort           <= "00";
            waitCycle         <= (others => '0');
            dataHeaderReg     <= dataHeader;
            statusPKTEn       <= '0';
            statusPKTLoad     <= '0';
            dataPKTEn         <= '0';
            dataPKTLoad       <= '0';            
            txRequest         <= '0';
            thisPKTPort       <= (others => '0');
            thisPKTLen        <= (others => '0');            
            if statusPKTReady = '1' or dataPKTReady = '1' then
              pktState <= PKT_READY;
            end if;
          when PKT_READY =>
            if statusPKTReady = '1' then
              pktState      <= STATUS_MODE;
              thisPKTPort   <= statusPKTPort;
              thisPKTLen    <= resize(statusPKTLen, 13);
              statusPKTLoad <= '1';
            else
              pktState      <= DATA_MODE;
              thisPKTPort   <= "00";
              thisPKTLen    <= resize(dataPKTLen + DATA_HEADER_LENGTH,13);
              dataPKTLoad   <= '1';
              seqNumber     <= seqNumber + 1;
            end if;
          when STATUS_MODE =>
            txRequest  <= '1';
            pktPort    <= thisPKTPort;
            pktLen     <= std_logic_vector(thisPKTLen);
            statusPKTLoad    <= '0';
            if txReadyTmp = '1' then
              pktState     <= STATUS_PKT;
              statusPKTEn  <= txReadyTmp;
              pktData      <= statusPKT;
              pktDataVld   <= statusPKTVld;
             end if;
          when STATUS_PKT =>
            pktState      <= STATUS_PKT;
            statusPKTEn   <= txReadyTmp;
            pktData       <= statusPKT;
            pktDataVld    <= statusPKTVld;  
            txRequest     <= '0';             
            if statusPKTEn = '0' then
              pktState <= IDLE;
            end if;
          when DATA_MODE =>
            txRequest     <= '1';
            pktPort       <= thisPKTPort;
            pktLen        <= std_logic_vector(thisPKTLen);
            dataPKTLoad   <= '0';
            if txReadyTmp = '1' then
              pktState   <= DATA_PKT_HEADER;
            end if;
          when DATA_PKT_HEADER =>
            waitCycle    <= waitCycle + 1;
            txRequest    <= '0';
            if waitCycle >= 1 and waitCycle <= 5 then
              pktData       <= dataHeaderReg(39 downto 32);
              pktDataVld    <= '1';
              dataHeaderReg(39 downto 8) <= dataHeaderReg(31 downto 0 );
              dataHeaderReg( 7 downto 0) <=  (others => '0');
              if waitCycle = 4 then
                dataPKTEn       <= txReadyTmp;
              end if;
            end if;
            if waitCycle = 6 then
              pktState     <= DATA_PKT_PAYLOAD;
              dataPKTEn    <= txReadyTmp;
              pktData      <= dataPKT;
              pktDataVld   <= dataPKTVld;
              waitCycle    <= (others => '0');
            end if;
          when DATA_PKT_PAYLOAD =>
            pktState   <= DATA_PKT_PAYLOAD;
            dataPKTEn  <= txReadyTmp;
            pktData    <= dataPKT;
            pktDataVld <= dataPKTVld;             
            if dataPKTEn = '0' then
              pktState <= IDLE;
            end if;
        end case;
      end if;
    end if;
  end process;
  
  process (clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        txReady_d  <= '0';
        txReadyTmp <= '0';
      else
        txReady_d  <= txReady;
        txReadyTmp <= txReady_d;
      end if;
    end if;
  end process;

end rtl;