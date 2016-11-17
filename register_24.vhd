
library ieee;
library work;
use ieee.std_logic_1164.all;
use work.all;

ENTITY register_24 IS
	PORT (clock    	: IN  STD_LOGIC;
			reset    	: IN  STD_LOGIC;
			write_enable: IN  STD_LOGIC;
			data_in		: IN  STD_LOGIC_VECTOR (23 DOWNTO 0);
			data_out	   : OUT STD_LOGIC_VECTOR (23 DOWNTO 0)
		 );
END register_24;

ARCHITECTURE reg_24 OF register_24 IS 

BEGIN
		PROCESS(clock,reset,write_enable)
		BEGIN
			IF(reset = '1') THEN data_out <= x"000000";
			ELSIF(clock'EVENT AND clock ='1') THEN
				IF(write_enable = '1') THEN data_out <= data_in;
				END IF;
			END IF;	
		END PROCESS;


END reg_24;