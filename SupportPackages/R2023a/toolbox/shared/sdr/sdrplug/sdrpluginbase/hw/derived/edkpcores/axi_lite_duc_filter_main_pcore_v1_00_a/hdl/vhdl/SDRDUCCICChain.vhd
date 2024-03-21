
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


----------------------------------------------------------------
-- DUC CIC chain
----------------------------------------------------------------

entity SDRDUCCICChain is
    port(clk           : in  std_logic;
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
end entity;

----------------------------------------------------------------
-- DUC CIC chain architecture
-- Consists of a CIC compensation filter, a CIC interpolator
-- and fine gain compensation connected in series.
----------------------------------------------------------------

architecture rtl of SDRDUCCICChain is

    component SDRDUCCFIR
        port (
            clk           : in  std_logic;
            clk_enable    : in  std_logic;
            reset         : in  std_logic;
            filter_in_re  : in  std_logic_vector(17 downto 0);
            filter_in_im  : in  std_logic_vector(17 downto 0);
            filter_out_re : out std_logic_vector(17 downto 0);
            filter_out_im : out std_logic_vector(17 downto 0));
    end component;

    signal cfir_out_re : std_logic_vector(17 downto 0);
    signal cfir_out_im : std_logic_vector(17 downto 0);

    component SDRDUCCIC
        port (
            clk           : in  std_logic;
            clk_enable    : in  std_logic;
            reset         : in  std_logic;
            filter_in_re  : in  std_logic_vector(17 downto 0);
            filter_in_im  : in  std_logic_vector(17 downto 0);
            rate          : in  std_logic_vector(7 downto 0);
            load_rate     : in  std_logic;
            filter_out_re : out std_logic_vector(17 downto 0);
            filter_out_im : out std_logic_vector(17 downto 0);
            ce_out        : out std_logic);
    end component;

    signal cic_out_re : std_logic_vector(17 downto 0);
    signal cic_out_im : std_logic_vector(17 downto 0);

    signal cic_ce_out : std_logic;

begin

    ce_out <= cic_ce_out;

    duc_cfir_i : SDRDUCCFIR
    port map (
        clk           => clk,
        clk_enable    => cic_ce_out,
        reset         => reset,
        filter_in_re  => filter_in_re,
        filter_in_im  => filter_in_im,
        filter_out_re => cfir_out_re,
        filter_out_im => cfir_out_im);

    duc_cic_i : SDRDUCCIC
    port map (
        clk           => clk,
        clk_enable    => clk_enable,
        reset         => reset,
        filter_in_re  => cfir_out_re,
        filter_in_im  => cfir_out_im,
        rate          => rate,
        load_rate     => load_rate,
        filter_out_re => cic_out_re,
        filter_out_im => cic_out_im,
        ce_out        => cic_ce_out);

    duc_fine_gain : process (clk)
        variable product_re : signed(33 downto 0);
        variable product_im : signed(33 downto 0);
    begin
      if clk'event and clk = '1' then
        if reset = '1' then
            filter_out_re <= (others => '0');
            filter_out_im <= (others => '0');
        elsif clk_enable = '1' then
            product_re    := signed(cic_out_re) * signed(cicfinegain);
            product_im    := signed(cic_out_im) * signed(cicfinegain);
            filter_out_re <= std_logic_vector(resize(shift_right(product_re(31 downto 13) + 1, 1), 18));
            filter_out_im <= std_logic_vector(resize(shift_right(product_im(31 downto 13) + 1, 1), 18));
        end if;
      end if;
    end process;

end architecture;
