library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.all;


ENTITY control_block_logic IS
	PORT (	clock : IN	STD_LOGIC;
				reset	: IN	STD_LOGIC;
				receive_port_read : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            is_empty : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
				data_in_1 : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
				data_in_2 : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
				data_in_3 : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
				data_in_4 : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
				read_enable : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
				write_enable : OUT STD_LOGIC;
				is_empty_stv : OUT STD_LOGIC;
				port_change_output: OUT STD_LOGIC;
				data_out : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
				counter_output : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
END control_block_logic;

ARCHITECTURE cbl OF control_block_logic IS 
	TYPE state_type is 
		(wait_state,check_empty_state,empty_state,peek_queue_state,write_queue_state,pop_queue_state);
	SIGNAL state_reg, next_state: state_type;
	SIGNAL port_change: STD_LOGIC;
	SIGNAL counter: integer range 0 to 4096 := 0;
	SIGNAL register_output: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL register_input : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL write_to_register: STD_LOGIC;
	SIGNAL is_empty_temp: STD_LOGIC;
	SIGNAL control_block: STD_LOGIC_VECTOR(23 DOWNTO 0) ;
	SIGNAL current_read_enable: STD_LOGIC; 
	CONSTANT MAX_FRAME_SIZE : integer := 2047; 
	
BEGIN
	data_out <= control_block;
	counter <= to_integer(unsigned(register_output(10 downto 0)));
	counter_output <= std_logic_vector(to_unsigned(counter, counter_output'length));
	port_change_output <= port_change;
	
	reg : register_32 PORT MAP (
		clock	      => clock,
		reset	 	  => reset,
		write_enable  => write_to_register,
		data_in       => register_input,
		data_out	  => register_output
	);
	
	port_change_control: port_change_handler PORT MAP (
		clock => clock,
		reset => reset,
		receive_port_read => receive_port_read,
		port_change =>  port_change
	);

	PROCESS(clock,reset)
	BEGIN
		if(reset = '1') then state_reg <= wait_state;
		elsif (clock'event and clock = '1') then 
			state_reg <= next_state;
			if(state_reg /= peek_queue_state) then counter <= counter; end if;
		end if;
	END PROCESS;
	
	PROCESS(state_reg, port_change, is_empty_temp, counter, control_block, register_output)
	variable added_value : integer := 0;
	BEGIN
		case state_reg is
			when wait_state => 
				write_to_register <= '0'; 
				added_value := 0;
				register_input <= register_output;
				if (port_change = '0') then next_state <= wait_state;
				else next_state <= check_empty_state;
				end if;
			when check_empty_state =>
				write_to_register <= '0'; 
				added_value := 0;
				register_input <= register_output;
				if (is_empty_temp = '1') then next_state <= empty_state;
				else next_state <= peek_queue_state;
				end if;
			when empty_state => 
				write_to_register <= '0'; 
				added_value := 0;
				register_input <= register_output;
				next_state <= wait_state;
			when peek_queue_state =>
				added_value := counter + to_integer(unsigned(control_block(10 downto 0)));
				if(added_value <= MAX_FRAME_SIZE AND is_empty_temp = '0') then
					write_to_register <= '1';
					register_input <= std_logic_vector(to_unsigned(added_value, register_input'length));
					next_state <= write_queue_state;
				else
					write_to_register <= '1';
					register_input <= std_logic_vector(to_unsigned(0, register_input'length));
					next_state <= wait_state;
				end if;	
			when write_queue_state =>
				added_value := 0;
				write_to_register <= '0'; 
				register_input <= register_output;
				next_state <= pop_queue_state;
			when pop_queue_state => 
				added_value := 0;
				write_to_register <= '0'; 
				register_input <= register_output;
				next_state <= peek_queue_state;
			END case;
	END PROCESS;

	PROCESS(receive_port_read, current_read_enable, is_empty, data_in_1, data_in_2, data_in_3, data_in_4)
	BEGIN
		case receive_port_read is 
			when "0001" =>
				control_block <= data_in_1;
				if(current_read_enable = '1') then read_enable <= "0001";
				else read_enable <= "0000";
				end if;
				is_empty_temp <= is_empty(0);
			when "0010" =>
				control_block <= data_in_2;
				if(current_read_enable = '1') then read_enable <= "0010";
				else read_enable <= "0000";
				end if;
				is_empty_temp <= is_empty(1);
			when "0100" =>
				control_block <= data_in_3;
				if(current_read_enable = '1') then read_enable <= "0100";
				else read_enable <= "0000";
				end if;
				is_empty_temp <= is_empty(2);
			when "1000" =>
				control_block <= data_in_4;
				if(current_read_enable = '1') then read_enable <= "1000";
				else read_enable <= "0000";
				end if;	
				is_empty_temp <= is_empty(3);
			when others =>
				control_block <= data_in_1;
				if(current_read_enable = '1') then read_enable <= "0001";
				else read_enable <= "0000";
				end if;
				is_empty_temp <= is_empty(0);
		END CASE;
	END PROCESS;
	
	PROCESS(state_reg)
	BEGIN
		case state_reg is
			when wait_state => 
				write_enable <= '0';
				is_empty_stv <= '0';
				current_read_enable <= '0';
			when check_empty_state =>
				write_enable <= '0';
				is_empty_stv <= '0';
				current_read_enable <= '0';
			when empty_state =>
				write_enable <= '0';
				is_empty_stv <= '1';
				current_read_enable <= '0';
			when peek_queue_state =>
				write_enable <= '0';
				is_empty_stv <= '0';
				current_read_enable <= '0';
			when write_queue_state =>
				write_enable <= '1';
				is_empty_stv <= '0';
				current_read_enable <= '0';
			when pop_queue_state =>
				write_enable <= '0';
				is_empty_stv <= '0';
				current_read_enable <= '1';
		END CASE;
	END PROCESS;
	
END cbl;
		
		

