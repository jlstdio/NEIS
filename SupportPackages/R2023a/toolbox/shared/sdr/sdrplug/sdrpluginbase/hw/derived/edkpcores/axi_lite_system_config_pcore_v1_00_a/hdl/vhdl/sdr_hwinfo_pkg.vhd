
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

package sdr_hwinfo_pkg is

    constant VERSION            : std_logic_vector(31 downto 0) := x"000A0000";
    constant HWINFO1            : std_logic_vector(31 downto 0) := x"00DD0303";
    constant HWINFO2            : std_logic_vector(31 downto 0) := x"07735940";
    constant HWINFO3            : std_logic_vector(31 downto 0) := x"CC95298E";
    constant HWINFO4            : std_logic_vector(31 downto 0) := x"00000000";
    constant HWINFO5            : std_logic_vector(31 downto 0) := x"00000000";
    constant HWINFO6            : std_logic_vector(31 downto 0) := x"00000000";
    constant HWINFO7            : std_logic_vector(31 downto 0) := x"00000000";
    constant HWINFO8            : std_logic_vector(31 downto 0) := x"00000000";

end package;

