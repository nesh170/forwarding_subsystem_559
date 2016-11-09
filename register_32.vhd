library ieee;
library work;
use ieee.std_logic_1164.all;
use work.all;

ENTITY register_32 IS
	PORT (clock    	: IN  STD_LOGIC;
			reset    	: IN  STD_LOGIC;
			write_enable: IN  STD_LOGIC;
			data_in		: IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
			data_out	   : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
		 );
END register_32;

ARCHITECTURE reg_32 OF register_32 IS 

BEGIN
		PROCESS(clock,reset,write_enable)
		BEGIN
			IF(reset = '1') THEN data_out <= x"00000000";
			ELSIF(clock'EVENT AND clock ='1') THEN
				IF(write_enable = '1') THEN data_out <= data_in;
				END IF;
			END IF;	
		END PROCESS;


END reg_32;