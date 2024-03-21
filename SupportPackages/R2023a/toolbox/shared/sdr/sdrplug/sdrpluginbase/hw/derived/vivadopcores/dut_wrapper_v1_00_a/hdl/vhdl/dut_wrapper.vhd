
-- ----------------------------------------------
-- File Name: DUTWrapper.vhd
-- Copyright  2014 MathWorks, Inc.
-- ----------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dut_wrapper is
generic(
    bit_width   : integer := 64
);
port (
      clk                : in  std_logic;
      reset              : in  std_logic;
      -- input axis
      s_axis_tvalid      : in  std_logic;
      s_axis_tdata       : in  std_logic_vector (bit_width - 1 downto 0);
      -- output axis
      m_axis_tdata       : out std_logic_vector (bit_width - 1 downto 0);
      m_axis_tvalid      : out std_logic
);
end dut_wrapper;

architecture rtl of dut_wrapper is

component UnitDelayDUT is
  port( clk                       :   in    std_logic;
        reset                     :   in    std_logic;
        clk_enable                :   in    std_logic;
        dut_ch1_in_re             :   in    std_logic_vector(15 downto 0);  -- int16
        dut_ch1_in_im             :   in    std_logic_vector(15 downto 0);  -- int16
        dut_ch2_in_re             :   in    std_logic_vector(15 downto 0);  -- int16
        dut_ch2_in_im             :   in    std_logic_vector(15 downto 0);  -- int16
        ce_out                    :   out   std_logic;
        dut_ch1_out_re            :   out   std_logic_vector(15 downto 0);  -- int16
        dut_ch1_out_im            :   out   std_logic_vector(15 downto 0);  -- int16
        dut_ch2_out_re            :   out   std_logic_vector(15 downto 0);  -- int16
        dut_ch2_out_im            :   out   std_logic_vector(15 downto 0)  -- int16
        );
end component UnitDelayDUT;

  signal ce_out_tmp               : std_logic; -- boolean
  signal ce_in_tmp                : std_logic; -- boolean

begin

ce_in_tmp <= s_axis_tvalid;

m_axis_tvalid <= ce_out_tmp;

   
   gen_unit_delay:
   for n in 0 to ((bit_width/64)-1) generate
    i_RxDUT : UnitDelayDUT 
    port map(
        clk            => clk,
        reset          => reset,
        clk_enable     => ce_in_tmp,
        dut_ch1_in_re  => s_axis_tdata((15+(n*64)) downto (0+(n*64))), 
        dut_ch1_in_im  => s_axis_tdata((31+(n*64)) downto (16+(n*64))),        
        dut_ch2_in_re  => s_axis_tdata((47+(n*64)) downto (32+(n*64))),        
        dut_ch2_in_im  => s_axis_tdata((63+(n*64)) downto (48+(n*64))),        
        ce_out         => ce_out_tmp,       
        dut_ch1_out_re => m_axis_tdata((15+(n*64)) downto (0 +(n*64))), 
        dut_ch1_out_im => m_axis_tdata((31+(n*64)) downto (16+(n*64))), 
        dut_ch2_out_re => m_axis_tdata((47+(n*64)) downto (32+(n*64))), 
        dut_ch2_out_im => m_axis_tdata((63+(n*64)) downto (48+(n*64)))
    );
   end generate gen_unit_delay;


end;
