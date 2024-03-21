
-- ----------------------------------------------
-- File Name: SDRIQ_DCOffset.vhd
-- Created:   18-Nov-2013 17:04:14
-- Copyright  2013 MathWorks, Inc.
-- ----------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;


ENTITY SDRIQ_DCOffset IS 
PORT (
      reset                           : IN  std_logic;
      clock                           : IN  std_logic;
      iqbalbypass                     : IN  std_logic;
      dcoffbypass                     : IN  std_logic;
      coeff_I                         : IN  std_logic_vector(15 DOWNTO 0);
      coeff_Q                         : IN  std_logic_vector(15 DOWNTO 0);
      coeff_dcoffset_I                : IN  std_logic_vector(15 DOWNTO 0);
      coeff_dcoffset_Q                : IN  std_logic_vector(15 DOWNTO 0);
      strobe_in                       : IN  std_logic;
      x_in                            : IN  std_logic_vector(15 DOWNTO 0);
      y_in                            : IN  std_logic_vector(15 DOWNTO 0);
      strobe_out                      : OUT std_logic;
      x_out                           : OUT std_logic_vector(15 DOWNTO 0);
      y_out                           : OUT std_logic_vector(15 DOWNTO 0)
);
END SDRIQ_DCOffset;

ARCHITECTURE rtl of SDRIQ_DCOffset IS

COMPONENT SDRDCBlockerTop IS 
PORT (
      clk                             : IN  std_logic;
      data_in_im                      : IN  std_logic_vector(15 DOWNTO 0);
      clk_enable                      : IN  std_logic;
      bypass                          : IN  std_logic;
      data_in_re                      : IN  std_logic_vector(15 DOWNTO 0);
      rst                             : IN  std_logic;
      data_out_re                     : OUT std_logic_vector(15 DOWNTO 0);
      data_out_im                     : OUT std_logic_vector(15 DOWNTO 0);
      ce_out                          : OUT std_logic
);
END COMPONENT;

COMPONENT SDRIQBalance IS 
PORT (
      coeff_Q                         : IN  std_logic_vector(9 DOWNTO 0);
      clk                             : IN  std_logic;
      x_in                            : IN  std_logic_vector(15 DOWNTO 0);
      bypass                          : IN  std_logic;
      y_in                            : IN  std_logic_vector(15 DOWNTO 0);
      strobe_in                       : IN  std_logic;
      rst                             : IN  std_logic;
      coeff_I                         : IN  std_logic_vector(9 DOWNTO 0);
      strobe_out                      : OUT std_logic;
      y_out                           : OUT std_logic_vector(15 DOWNTO 0);
      x_out                           : OUT std_logic_vector(15 DOWNTO 0)
);
END COMPONENT;

  SIGNAL dcOffset_strobe                  : std_logic; -- boolean
  SIGNAL dcOffset_i                       : std_logic_vector(15 DOWNTO 0); -- std16
  SIGNAL dcOffset_q                       : std_logic_vector(15 DOWNTO 0); -- std16
  SIGNAL coeff_i_tmp                      : std_logic_vector(9 DOWNTO 0); -- std10
  SIGNAL coeff_q_tmp                      : std_logic_vector(9 DOWNTO 0); -- std10

BEGIN

u_SDRDCBlockerTop: SDRDCBlockerTop 
PORT MAP(
        clk                  => clock,
        data_in_im           => y_in,
        data_out_re          => dcOffset_i,
        clk_enable           => strobe_in,
        bypass               => dcoffbypass,
        data_in_re           => x_in,
        data_out_im          => dcOffset_q,
        ce_out               => dcOffset_strobe,
        rst                  => reset
);

u_SDRIQBalance: SDRIQBalance 
PORT MAP(
        coeff_Q              => coeff_q_tmp,
        clk                  => clock,
        strobe_out           => strobe_out,
        x_in                 => dcOffset_i,
        bypass               => iqbalbypass,
        y_out                => y_out,
        x_out                => x_out,
        y_in                 => dcOffset_q,
        strobe_in            => dcOffset_strobe,
        rst                  => reset,
        coeff_I              => coeff_i_tmp
);

coeff_i_tmp <= coeff_I(9 DOWNTO 0);
coeff_q_tmp <= coeff_Q(9 DOWNTO 0);

END;
