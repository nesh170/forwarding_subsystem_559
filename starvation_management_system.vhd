library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.all;

entity starvation_management_system is
	port(clock		   			:in std_logic;
		  reset		   			:in std_logic;
		  is_empty_control_block:in std_logic;
		  is_empty_block_buffer :in std_logic;
		  is_empty_frame_buffer :in std_logic;
		  frame_fully_transmited:in std_logic;
		  recv_port_to_read		:out std_logic_vector (3 downto 0));
end starvation_management_system;

architecture starvation_management_system_architecture of starvation_management_system is
	
	signal rcv_port_temp: integer range 1 to 4;
	
begin
	
	process(clock, reset, is_empty_block_buffer, is_empty_control_block, is_empty_frame_buffer,frame_fully_transmited)
	begin
		if(reset = '1') then rcv_port_temp <= 1;
		elsif(clock = '1' and clock'event) then 
			if(is_empty_control_block = '1' or (is_empty_block_buffer = '1' and is_empty_frame_buffer = '1' and frame_fully_transmited = '1')) then
				if(rcv_port_temp = 4) then rcv_port_temp <= 1;
				else rcv_port_temp <= rcv_port_temp + 1;
				end if;
			end if;
		end if;
	end process;
	
	process(rcv_port_temp)
	begin
		case rcv_port_temp is
			when 1 => recv_port_to_read <= "0001";
			when 2 => recv_port_to_read <= "0010";
			when 3 => recv_port_to_read <= "0100";
			when 4 => recv_port_to_read <= "1000";
		end case;
	end process;	

end starvation_management_system_architecture;
	