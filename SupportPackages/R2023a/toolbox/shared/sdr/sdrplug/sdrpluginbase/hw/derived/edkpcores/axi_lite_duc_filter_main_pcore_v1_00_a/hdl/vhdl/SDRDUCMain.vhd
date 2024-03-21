-------------------------------------------------------------------------------
-- Title      : SDRDUCMain
-- Project    : SDR TX Interpolation Filters
-------------------------------------------------------------------------------
-- File       : SDRDUCMain.vhd
-- Author     : Garrey Rice
-- Company    : 
-- Created    : 2013-03-07
-------------------------------------------------------------------------------
-- Description: Interpolation filter chain with programmable rate.
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

----------------------------------------------------------------
-- DUC filter chain
----------------------------------------------------------------

entity SDRDUCMain is
    port(clk           : in  std_logic;
         clk_enable    : in  std_logic;
         reset         : in  std_logic;
         filter_in_re  : in  std_logic_vector(15 downto 0);
         filter_in_im  : in  std_logic_vector(15 downto 0);
         cic_enable    : in  std_logic;
         hb1_enable    : in  std_logic;
         hb2_enable    : in  std_logic;
         rate          : in  std_logic_vector(7 downto 0);
         cicfinegain   : in  std_logic_vector(15 downto 0);
         filter_out_re : out std_logic_vector(15 downto 0);
         filter_out_im : out std_logic_vector(15 downto 0);
         ce_out        : out std_logic
    );
end entity;

----------------------------------------------------------------
-- Architecture of DUC filter chain
----------------------------------------------------------------

architecture rtl of SDRDUCMain is

    component SDRDUCHalfband1
        port (
            clk           : in  std_logic;
            clk_enable    : in  std_logic;
            reset         : in  std_logic;
            filter_in_re  : in  std_logic_vector(15 downto 0);
            filter_in_im  : in  std_logic_vector(15 downto 0);
            filter_out_re : out std_logic_vector(17 downto 0);
            filter_out_im : out std_logic_vector(17 downto 0);
            ce_out        : out std_logic);
    end component;

    signal halfband1_ce_out : std_logic;
    signal halfband1_out_re : std_logic_vector(17 downto 0);
    signal halfband1_out_im : std_logic_vector(17 downto 0);

    signal hb1_ce_out_mux : std_logic;
    signal hb1_out_re_mux : std_logic_vector(17 downto 0);
    signal hb1_out_im_mux : std_logic_vector(17 downto 0);

    component SDRDUCHalfband2
        port (
            clk           : in  std_logic;
            clk_enable    : in  std_logic;
            reset         : in  std_logic;
            filter_in_re  : in  std_logic_vector(17 downto 0);
            filter_in_im  : in  std_logic_vector(17 downto 0);
            filter_out_re : out std_logic_vector(17 downto 0);
            filter_out_im : out std_logic_vector(17 downto 0);
            ce_out        : out std_logic);
    end component;

    signal halfband2_out_re : std_logic_vector(17 downto 0);
    signal halfband2_out_im : std_logic_vector(17 downto 0);
    signal halfband2_ce_out : std_logic;

    signal hb2_ce_out_mux : std_logic;
    signal hb2_out_re_mux : std_logic_vector(17 downto 0);
    signal hb2_out_im_mux : std_logic_vector(17 downto 0);

    component SDRDUCCICChain
        port (
            clk           : in  std_logic;
            clk_enable    : in  std_logic;
            reset         : in  std_logic;
            filter_in_re  : in  std_logic_vector(17 downto 0);
            filter_in_im  : in  std_logic_vector(17 downto 0);
            rate          : in  std_logic_vector(7 downto 0);
            load_rate     : in  std_logic;
            cicfinegain   : in  std_logic_vector(15 downto 0);
            filter_out_re : out std_logic_vector(17 downto 0);
            filter_out_im : out std_logic_vector(17 downto 0);
            ce_out        : out std_logic);
    end component;

    signal cic_out_re : std_logic_vector(17 downto 0);
    signal cic_out_im : std_logic_vector(17 downto 0);
    signal cic_ce_out : std_logic;

    signal cic_ce_out_mux : std_logic;
    signal cic_out_re_mux : std_logic_vector(17 downto 0);
    signal cic_out_im_mux : std_logic_vector(17 downto 0);

    component SDRDUCOutputConverter
        port (
            clk         : in  std_logic;
            reset       : in  std_logic;
            enb         : in  std_logic;
            data_in_re  : in  std_logic_vector(17 downto 0);
            data_in_im  : in  std_logic_vector(17 downto 0);
            data_out_re : out std_logic_vector(15 downto 0);
            data_out_im : out std_logic_vector(15 downto 0));
    end component;

begin

    ce_out <= hb1_ce_out_mux;
    
    ----------------------------------------------------------------------------
    -- halfband 1 and associated multiplexers
    ----------------------------------------------------------------------------

    hb1_ce_out_mux <= halfband1_ce_out when hb1_enable = '1' else halfband2_ce_out;

    duc_halfband1_i : SDRDUCHalfband1
    port map (
        clk           => clk,
        clk_enable    => hb2_ce_out_mux,
        reset         => reset,
        filter_in_re  => filter_in_re,
        filter_in_im  => filter_in_im,
        filter_out_re => halfband1_out_re,
        filter_out_im => halfband1_out_im,
        ce_out        => halfband1_ce_out);

    hb1_out_re_mux <= halfband1_out_re when hb1_enable = '1' else (filter_in_re(15) & filter_in_re & '0');
    hb1_out_im_mux <= halfband1_out_im when hb1_enable = '1' else (filter_in_im(15) & filter_in_im & '0');

    ----------------------------------------------------------------------------
    -- halfband 2 and associated multiplexers
    ----------------------------------------------------------------------------

    hb2_ce_out_mux <= halfband2_ce_out when hb2_enable = '1' else cic_ce_out;

    duc_halfband2_i : SDRDUCHalfband2
    port map (
        clk           => clk,
        clk_enable    => cic_ce_out_mux,
        reset         => reset,
        filter_in_re  => hb1_out_re_mux,
        filter_in_im  => hb1_out_im_mux,
        filter_out_re => halfband2_out_re,
        filter_out_im => halfband2_out_im,
        ce_out        => halfband2_ce_out);
    
    hb2_out_re_mux <= halfband2_out_re when hb2_enable = '1' else hb1_out_re_mux;
    hb2_out_im_mux <= halfband2_out_im when hb2_enable = '1' else hb1_out_im_mux;

    ----------------------------------------------------------------------------
    -- CIC filters chain and associated multiplexers
    ----------------------------------------------------------------------------

    cic_ce_out_mux <= cic_ce_out when cic_enable = '1' else clk_enable;
    
    duc_cic_chain_i: SDRDUCCICChain
        port map (
            clk           => clk,
            clk_enable    => clk_enable,
            reset         => reset,
            filter_in_re  => hb2_out_re_mux,
            filter_in_im  => hb2_out_im_mux,
            rate          => rate,
            load_rate     => '0',
            cicfinegain   => cicfinegain,
            filter_out_re => cic_out_re,
            filter_out_im => cic_out_im,
            ce_out        => cic_ce_out);

    cic_out_re_mux <= cic_out_re when cic_enable = '1' else hb2_out_re_mux;
    cic_out_im_mux <= cic_out_im when cic_enable = '1' else hb2_out_im_mux;
    
    ----------------------------------------------------------------------------
    -- output conversion to 16 bits
    ----------------------------------------------------------------------------

    duc_output_converter_i : SDRDUCOutputConverter
    port map (
        clk         => clk,
        reset       => reset,
        enb         => clk_enable,
        data_in_re  => cic_out_re_mux,
        data_in_im  => cic_out_im_mux,
        data_out_re => filter_out_re,
        data_out_im => filter_out_im);

end architecture;
