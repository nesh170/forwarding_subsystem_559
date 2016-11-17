library ieee;
library work;
use ieee.std_logic_1164.all;
use work.all;

ENTITY register_1 IS
	PORT (clock    	: IN  STD_LOGIC;
			reset    	: IN  STD_LOGIC;
			write_enable: IN  STD_LOGIC;
			data_in		: IN  STD_LOGIC;
			data_out	   : OUT STD_LOGIC
		 );
END register_1;

ARCHITECTURE reg_1 OF register_1 IS 

BEGIN
		PROCESS(clock,reset,write_enable)
		BEGIN
			IF(reset = '1') THEN data_out <= '0';
			ELSIF(clock'EVENT AND clock ='1') THEN
				IF(write_enable = '1') THEN data_out <= data_in;
				END IF;
			END IF;	
		END PROCESS;


END reg_1;