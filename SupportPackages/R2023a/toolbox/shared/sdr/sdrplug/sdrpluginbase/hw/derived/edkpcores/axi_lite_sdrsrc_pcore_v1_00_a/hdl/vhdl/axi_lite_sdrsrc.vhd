
-- ----------------------------------------------
-- File Name: axi_lite_sdrsrc.vhd
-- Created:   23-Apr-2013 15:26:50
-- Copyright  2013 MathWorks, Inc.
-- ----------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_lite_sdrsrc is
  port (
    clk       : in std_logic;
    reset     : in std_logic;
    stream_en : in std_logic;

    wr_src_sel    : in std_logic_vector(1 downto 0);
    wr_src_amp   : in std_logic_vector(31 downto 0);
    wr_src_freq  : in std_logic_vector(31 DOWNTO 0);

    rd_src_sel    : out std_logic_vector(1 downto 0);
    rd_src_amp   : out std_logic_vector(31 downto 0);
    rd_src_freq  : out std_logic_vector(31 downto 0);
    

    RFIn_I    : in std_logic_vector(15 downto 0);
    RFIn_Q    : in std_logic_vector(15 downto 0);
    RFIn_strb : in std_logic;

    loop_I    : in std_logic_vector(15 downto 0);
    loop_Q    : in std_logic_vector(15 downto 0);
    loop_vld :  in std_logic;

    src_strobe : out std_logic;
    src_I      : out std_logic_vector(15 downto 0);
    src_Q      : out std_logic_vector(15 downto 0));
end entity;

architecture rtl of axi_lite_sdrsrc is
    
    component SDRSrc is
        port (
            clk       : in std_logic;
            reset     : in std_logic;
            stream_en : in std_logic;
    
            srcSel    : in std_logic_vector(1 downto 0);
            cnt_max   : in std_logic_vector(15 downto 0);
    
            RFIn_I    : in std_logic_vector(15 downto 0);
            RFIn_Q    : in std_logic_vector(15 downto 0);
            RFIn_strb : in std_logic;
    
            loop_I    : in std_logic_vector(15 downto 0);
            loop_Q    : in std_logic_vector(15 downto 0);
            loop_vld :  in std_logic;
    
            src_strobe : out std_logic;
            src_I      : out std_logic_vector(15 downto 0);
            src_Q      : out std_logic_vector(15 downto 0) );	
        end component;
    
    FOR ALL : SDRSrc
    USE ENTITY work.SDRSrc(rtl);

    signal cnt_max_int : std_logic_vector(15 downto 0);
begin

        u_sdrsrc: SDRSrc
        port map(
            clk        => clk,       
            reset      => reset,     
            stream_en  => stream_en, 
                                        
            srcSel     => wr_src_sel,    
            cnt_max    => cnt_max_int,
                                        
            RFIn_I     => RFIn_I,    
            RFIn_Q     => RFIn_Q,    
            RFIn_strb  => RFIn_strb, 
                                        
            loop_I     => loop_I,    
            loop_Q     => loop_Q,    
            loop_vld   => loop_vld,  
                        
            src_strobe => src_strobe,
            src_I      => src_I,     
            src_Q      => src_Q
            );
            
  cnt_max_int <= wr_src_amp(15 downto 0);
  
  rd_src_sel <= wr_src_sel;
  rd_src_amp <= wr_src_amp;
  rd_src_freq <= wr_src_freq;

end rtl;