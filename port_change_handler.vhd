library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.all;

ENTITY port_change_handler IS
	PORT( clock					:IN STD_LOGIC;
			reset					:IN STD_LOGIC;
			receive_port_read	:IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			port_change			:OUT STD_LOGIC);
END port_change_handler;
		  
		
ARCHITECTURE port_change_architecture OF port_change_handler IS
	SIGNAL recv_port_signal: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL previous_port: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL write_ena: STD_LOGIC;
	
BEGIN
	recv_port_signal <= (31 downto receive_port_read'length => '0') & receive_port_read;
	
	reg : register_32 PORT MAP (
		clock	      => clock,
		reset	 	  => reset,
		write_enable  => write_ena,
		data_in       => recv_port_signal,
		data_out	  => previous_port
	);
	
	PROCESS(recv_port_signal, previous_port)
	BEGIN
		if(previous_port /= recv_port_signal) then 
			write_ena <= '1';
			port_change <= '1';
		else 
			write_ena <= '0';
			port_change <= '0';
		end if;
	END PROCESS;

END port_change_architecture;	
	