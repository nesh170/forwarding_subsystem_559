library ieee;
library my_lib;
use ieee.std_logic_1164.all;
use my_lib.data_types.all;

entity compute is port(
	cpt_state: in state_type;
	cpt_reg_output_address: in reg_output_type;
	cpt_compare_result: in std_logic_vector(31 downto 0);
	cpt_first_value: out std_logic_vector(51 downto 0);
	cpt_write_enable: out std_logic_vector(31 downto 0)
	);
end compute;

architecture compute_rtl of compute is
	signal tmp_reg_output: reg_output_type;

	begin
	
	-- perform thermometer encoding
	-- http://electronics.stackexchange.com/questions/85922/vhdl-or-ing-bits-of-a-vector-together
	process(cpt_compare_result, cpt_state)
	begin
		case cpt_state is
			when reset_state =>
				cpt_write_enable <= (31 downto 0 => '0');
			when read_state => 
				for thermo_it in 0 to 31 loop
					if (cpt_compare_result(thermo_it downto 0) = (thermo_it downto 0 => '0')) then
						cpt_write_enable(thermo_it) <= '0';
					else
						cpt_write_enable(thermo_it) <= '1';
					end if;
				end loop;
			when write_state =>
				if (cpt_compare_result = (31 downto 0 => '0')) then
					cpt_write_enable <= (31 downto 0 => '1');
				else
					for thermo_it in 0 to 31 loop
						if (cpt_compare_result(thermo_it downto 0) = (thermo_it downto 0 => '0')) then
							cpt_write_enable(thermo_it) <= '0';
						else
							cpt_write_enable(thermo_it) <= '1';
						end if;
					end loop;
				end if;
		end case;
	end process;
	
	-- perform first_value selection
	process (cpt_compare_result, cpt_reg_output_address)
	begin
		for cmp_it in 0 to 31 loop
			if (cpt_compare_result(cmp_it) = '1') then
				tmp_reg_output(cmp_it) <= cpt_reg_output_address(cmp_it);
			else
				tmp_reg_output(cmp_it) <= (51 downto 0 => '0');
			end if;
		end loop;
	end process;
	
	process (tmp_reg_output)
	begin
		for it in 0 to 51 loop
			cpt_first_value(it) <= tmp_reg_output(31)(it) or tmp_reg_output(30)(it) or tmp_reg_output(29)(it) or tmp_reg_output(28)(it) or tmp_reg_output(27)(it) or tmp_reg_output(26)(it) or tmp_reg_output(25)(it) or tmp_reg_output(24)(it) or tmp_reg_output(23)(it) or tmp_reg_output(22)(it) or tmp_reg_output(21)(it) or tmp_reg_output(20)(it) or tmp_reg_output(19)(it) or tmp_reg_output(18)(it) or tmp_reg_output(17)(it) or tmp_reg_output(16)(it) or tmp_reg_output(15)(it) or tmp_reg_output(14)(it) or tmp_reg_output(13)(it) or tmp_reg_output(12)(it) or tmp_reg_output(11)(it) or tmp_reg_output(10)(it) or tmp_reg_output(9)(it) or tmp_reg_output(8)(it) or tmp_reg_output(7)(it) or tmp_reg_output(6)(it) or tmp_reg_output(5)(it) or tmp_reg_output(4)(it) or tmp_reg_output(3)(it) or tmp_reg_output(2)(it) or tmp_reg_output(1)(it) or tmp_reg_output(0)(it);
		end loop;
	end process;
	
end compute_rtl;