
-- ----------------------------------------------
-- File Name: axi_lite_simpledec.vhd
-- Created:   23-Apr-2013 15:26:50
-- Copyright  2013 MathWorks, Inc.
-- ----------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_lite_simpledec is
  port (
    clk   : in std_logic;
    reset : in std_logic;

    din_I     		: in std_logic_vector(15 downto 0);
    din_Q     		: in std_logic_vector(15 downto 0);
    strobe_in 		: in std_logic;
    wr_decFactor 		: in std_logic_vector(31 downto 0);

    dout_I     		: out std_logic_vector(15 downto 0);
    dout_Q     		: out std_logic_vector(15 downto 0);
    strobe_out 		: out std_logic;
	rd_decFactor	:   out  std_logic_vector(31 downto 0)  -- uint32
	
    );
end entity;

architecture rtl of axi_lite_simpledec is

  component SDRSimpleDec is
	port (
    clk   : in std_logic;
    reset : in std_logic;

    din_I     : in std_logic_vector(15 downto 0);
    din_Q     : in std_logic_vector(15 downto 0);
    strobe_in : in std_logic;
    decFactor : in std_logic_vector(31 downto 0);

    dout_I     : out std_logic_vector(15 downto 0);
    dout_Q     : out std_logic_vector(15 downto 0);
    strobe_out : out std_logic
    );
	end component;
	 
	
 signal decFactor : std_logic_vector(31 downto 0);
 
begin
  
	u_SDRSimpleDec : SDRSimpleDec
		port map(
			clk   		=> clk,   		
			reset       => reset,     
						
			din_I       => din_I,     
			din_Q       => din_Q,     
			strobe_in   => strobe_in, 
			decFactor   => decFactor,
								
			dout_I      => dout_I,    
			dout_Q      => dout_Q,    
			strobe_out  => strobe_out	
		);

	decFactor <= wr_decFactor;
	rd_decFactor <= wr_decFactor;
  
end rtl;

