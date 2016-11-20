library ieee;
library my_lib;
use ieee.std_logic_1164.all;
use my_lib.data_types.all;

entity compare is port(
	cmp_address_to_compare: in std_logic_vector(47 downto 0);
	cmp_reg_output_address: in reg_output_type;
	cmp_compare_result: out std_logic_vector(31 downto 0)
	);
end compare;

architecture compare_rtl of compare is


	begin
	
	process(cmp_reg_output_address, cmp_address_to_compare)
	begin
		for cmp_it in 0 to 31 loop
			if (cmp_reg_output_address(cmp_it)(51 downto 4) = cmp_address_to_compare) then
				cmp_compare_result(cmp_it) <= '1';
			else
				cmp_compare_result(cmp_it) <= '0';
			end if;
		end loop;
		
	end process;
	
end compare_rtl;