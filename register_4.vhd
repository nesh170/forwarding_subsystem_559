
library ieee;
library work;
use ieee.std_logic_1164.all;
use work.all;

ENTITY register_4 IS
	PORT (clock    	: IN  STD_LOGIC;
			reset    	: IN  STD_LOGIC;
			write_enable: IN  STD_LOGIC;
			data_in		: IN  STD_LOGIC_VECTOR (3 DOWNTO 0);
			data_out	   : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
		 );
END register_4;

ARCHITECTURE reg_4 OF register_4 IS 

BEGIN
		PROCESS(clock,reset,write_enable)
		BEGIN
			IF(reset = '1') THEN data_out <= x"0";
			ELSIF(clock'EVENT AND clock ='1') THEN
				IF(write_enable = '1') THEN data_out <= data_in;
				END IF;
			END IF;	
		END PROCESS;


END reg_4;