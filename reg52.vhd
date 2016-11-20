library ieee;
use ieee.std_logic_1164.all;

entity reg52 is port(
	reg52_in: in std_logic_vector(51 downto 0);
	reg52_clock: in std_logic;
	reg52_reset: in std_logic;
	reg52_write_enable: in std_logic;
	reg52_out: out std_logic_vector(51 downto 0)
	);
end reg52;

architecture reg52_rtl of reg52 is
	
	begin
	
	process (reg52_clock, reg52_reset, reg52_write_enable, reg52_in)
	begin
		if (reg52_reset = '1') then
			reg52_out <= (51 downto 0 => '0');
		elsif (reg52_clock'event and reg52_clock = '1' and reg52_write_enable = '1') then
			reg52_out <= reg52_in;
		end if;
	end process;
end reg52_rtl;