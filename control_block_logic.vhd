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
				data_out : OUT STD_LOGIC_VECTOR(23 DOWNTO 0));
END control_block_logic;

ARCHITECTURE cbl OF control_block_logic IS 
	TYPE state_type is 
		(wait_state,check_empty_state,empty_state,peek_queue_state,write_queue_state,pop_queue_state);
	SIGNAL state_reg, next_state: state_type;
	
	SIGNAL previous_port: integer range 1 to 4 := 1;
	SIGNAL current_port: integer range 0 to 4;
	SIGNAL port_change: STD_LOGIC;
	SIGNAL counter: integer range 0 to 10239;
	SIGNAL is_empty_temp: STD_LOGIC;
	SIGNAL control_block: STD_LOGIC_VECTOR(23 DOWNTO 0) ;
	SIGNAL current_read_enable: STD_LOGIC; --create drivers for this
	CONSTANT MAX_FRAME_SIZE : integer := 8192; 
	
BEGIN
	PROCESS(clock,reset)
	BEGIN
		if(reset = '1') then state_reg <= wait_state;
		elsif (clock'event and clock = '1') then state_reg <= next_state;
		end if;
	END PROCESS;
	
	PROCESS(state_reg, port_change, is_empty_temp, counter)
	BEGIN
		case state_reg is
			when wait_state => 
				if (port_change = '0') then next_state <= wait_state;
				else next_state <= check_empty_state;
				end if;
			when check_empty_state =>
				if (is_empty_temp = '1') then next_state <= empty_state;
				else next_state <= peek_queue_state;
				end if;
			when empty_state => next_state <= wait_state;
			when peek_queue_state =>
				counter <= counter + to_integer(unsigned(control_block(10 downto 0)));
				if(counter <= MAX_FRAME_SIZE AND is_empty_temp = '0') then
					next_state <= write_queue_state;
				elsif(counter > MAX_FRAME_SIZE OR is_empty_temp = '1') then
					next_state <= wait_state;
				else
					next_state <= peek_queue_state;
				end if;	
			when write_queue_state => 
				next_state <= pop_queue_state;
			when pop_queue_state => 
				next_state <= peek_queue_state;
			END case;
	END PROCESS;

	PROCESS(receive_port_read)
	BEGIN
		case receive_port_read is
			when "0001" => 
			current_port <= 1;
			when "0010" => 
			current_port <= 2;
			when "0100" => 
			current_port <= 3;
			when "1000" => 
			current_port <= 4;
			when others => 
			current_port <= 1;
		end case;
		
		if(previous_port /= current_port) then 
			previous_port <= current_port;
			port_change <= '1';
		else port_change <= '0';
		end if;
	END PROCESS;
	
	PROCESS(receive_port_read, current_read_enable)
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
		
		

