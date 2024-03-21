LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

entity rx_dut_wrapper is
  port( clk         :   in    std_logic;
        rst         :   in    std_logic;
        dataIn      :   in    std_logic_vector(31 DOWNTO 0);
        dataInVld   :   in    std_logic;
        dataOut     :   out   std_logic_vector(31 DOWNTO 0);
        dataOutVld  :   out   std_logic
        );
end rx_dut_wrapper;

architecture rtl of rx_dut_wrapper is

  -- Component Declarations
  component UnitDelayRxDUT
    port (
        clk         :   IN    std_logic;
        reset       :   IN    std_logic;
        clk_enable  :   IN    std_logic;
        ce_out      :   OUT   std_logic;    
        rxdut_in_I  :   IN    std_logic_vector(15 DOWNTO 0);  -- ufix16
        rxdut_in_Q  :   IN    std_logic_vector(15 DOWNTO 0);  -- ufix16
        rxdut_out_I :   OUT   std_logic_vector(15 DOWNTO 0);  -- ufix16
        rxdut_out_Q :   OUT   std_logic_vector(15 DOWNTO 0)  -- ufix16
        );
  end component;
  
  signal dataIn_I  :std_logic_vector(15 DOWNTO 0);
  signal dataIn_Q  :std_logic_vector(15 DOWNTO 0);
  signal dataOut_I :std_logic_vector(15 DOWNTO 0);
  signal dataOut_Q :std_logic_vector(15 DOWNTO 0);
  
begin
  
  UnitDelayRxDUT_inst: UnitDelayRxDUT
  port map (
    clk         => clk,
    reset       => rst,
    clk_enable  => dataInVld,
    ce_out      => dataOutVld, 
    rxdut_in_I  => dataIn_I, 
    rxdut_in_Q  => dataIn_Q,
    rxdut_out_I => dataOut_I,
    rxdut_out_Q => dataOut_Q
    );
  
  dataIn_I <= dataIn(15 downto 0);
  dataIn_Q <= dataIn(31 downto 16);
  
  dataOut <= dataOut_Q & dataOut_I;

end rtl;

