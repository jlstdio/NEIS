
-- ----------------------------------------------
-- File Name: led_driver.vhd
-- Created:   23-Apr-2013 15:26:53
-- Copyright  2013 MathWorks, Inc.
-- ----------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;


ENTITY led_driver IS 
GENERIC (
         CNTWIDTH	: integer := 10;
		 bit_slice	: integer := 25
);

PORT (
      clk                             : IN  std_logic;
      rst                             : IN  std_logic;
      enb                             : IN  std_logic;
	  LED							  : OUT std_logic
);
END led_driver;

ARCHITECTURE rtl of led_driver IS

  SIGNAL cnt_tmp          	: unsigned(CNTWIDTH - 1 DOWNTO 0); 
  SIGNAL cnt              	: std_logic_vector(CNTWIDTH - 1 DOWNTO 0);

BEGIN

PROCESS (clk,rst)
BEGIN  -- PROCESS
  IF (rst ='1') THEN
     cnt_tmp <= (OTHERS => '0');
  ELSIF clk'event AND clk = '1' THEN
    IF enb = '1' THEN
     cnt_tmp <= cnt_tmp + to_unsigned(1,CNTWIDTH);
    END IF;
  END IF;
END PROCESS;

cnt <= std_logic_vector(cnt_tmp);
LED <= cnt(bit_slice);
END;
