library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;
use work.all;

ENTITY control_block_logic_tester IS
	PORT( clock: 			IN STD_LOGIC;
			reset: 			IN STD_LOGIC;
			start_empty:	IN STD_LOGIC;
			start_queue:	IN STD_LOGIC;
			success_empty: OUT STD_LOGIC;
			success_queue: OUT STD_LOGIC;
			seg_display_1: OUT STD_LOGIC_VECTOR(6 DOWNTO 0); --lowest
			seg_display_2: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			seg_display_3: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			seg_display_4: OUT STD_LOGIC_VECTOR(6 DOWNTO 0); --highest
			out_counter  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
			);
END control_block_logic_tester;

ARCHITECTURE cblt OF control_block_logic_tester IS	
	TYPE state_type IS
		(start_state,set_up_empty_state,is_empty_success_state,set_up_write_state,hold_counter_state,write_success);
	SIGNAL state_reg, next_state: state_type;
	SIGNAL data_in_to_port_1,data_out: STD_LOGIC_VECTOR(23 DOWNTO 0);
	SIGNAL recv_port,is_empty_port,read_out: STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL is_empty_out,port_change,write_to_register,write_out: STD_LOGIC;
	SIGNAL counter,register_output: STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	

BEGIN
	out_counter <= register_output;
	seg_1: seg7 PORT MAP (
		clk => clock,
		bcd => register_output(3 DOWNTO 0),
		segment7 => seg_display_1
	);
	
	seg_2: seg7 PORT MAP (
		clk => clock,
		bcd => register_output(7 DOWNTO 4),
		segment7 => seg_display_2
	);
	
	seg_3: seg7 PORT MAP (
		clk => clock,
		bcd => register_output(11 DOWNTO 8),
		segment7 => seg_display_3
	);
	
	seg_4: seg7 PORT MAP (
		clk => clock,
		bcd => register_output(15 DOWNTO 12),
		segment7 => seg_display_4
	);

	reg : register_32 PORT MAP (
		clock	        => clock,
		reset	 	     => reset,
		write_enable  => write_to_register,
		data_in       => counter,
		data_out	     => register_output
	);

	cbl : control_block_logic PORT MAP (
		clock => clock,
		reset => reset,
		receive_port_read => recv_port,
		is_empty => is_empty_port,
		data_in_1 => std_logic_vector(to_unsigned(1024, data_in_to_port_1'LENGTH)),
		data_in_2 => std_logic_vector(to_unsigned(0, data_in_to_port_1'LENGTH)),
		data_in_3 => std_logic_vector(to_unsigned(0, data_in_to_port_1'LENGTH)),
		data_in_4 => std_logic_vector(to_unsigned(0, data_in_to_port_1'LENGTH)),
		read_enable => read_out,
		write_enable => write_out, 
		is_empty_stv => is_empty_out, --important
		port_change_output => port_change,
		data_out => data_out,
		counter_output => counter
	);
	
	PROCESS(clock, reset)
	BEGIN
		IF(reset = '1') THEN state_reg <= start_state;
		ELSIF(clock'EVENT and clock ='1') THEN
			state_reg <= next_state;
		END IF;
	END PROCESS;
	
	PROCESS(state_reg,start_empty,start_queue,is_empty_out,write_out,counter)
	BEGIN
		CASE state_reg IS
			WHEN start_state =>
				recv_port <= "0000";
				is_empty_port <= "0000";
				write_to_register <= '1';
				IF(start_empty = '1' and start_queue = '0') THEN next_state <= set_up_empty_state;
				ELSIF(start_queue = '1' and start_empty = '0') THEN next_state <= set_up_write_state;
				ELSE next_state <= start_state;
				END IF;
			WHEN set_up_empty_state =>
				recv_port <= "0001";
				is_empty_port <= "0001";
				write_to_register <= '1';
				IF(is_empty_out = '1') THEN next_state <= is_empty_success_state;
				ELSE next_state <= set_up_empty_state;
				END IF;
			WHEN is_empty_success_state =>
				recv_port <= "0001";
				is_empty_port <= "0000";
				write_to_register <= '1';
				next_state <= is_empty_success_state;
			WHEN set_up_write_state =>
				recv_port <= "0001";
				is_empty_port <= "0000";
				write_to_register <= '1';
				IF(write_out = '1') THEN next_state <= hold_counter_state;
				ELSE next_state <= set_up_write_state;
				END IF;
			WHEN hold_counter_state =>
				recv_port <= "0001";
				is_empty_port <= "0000";
				IF(or_reduce(counter) = '1') THEN 
					write_to_register <= '1';
					next_state <= hold_counter_state;
				ELSE
					write_to_register <= '0';
					next_state <= write_success;
				END IF;
			WHEN write_success =>
				recv_port <= "0001";
				is_empty_port <= "0000";
				write_to_register <= '0';
				next_state <= write_success;
		END CASE;
	END PROCESS;
	
	PROCESS (state_reg)
	BEGIN
		CASE state_reg IS
			WHEN start_state =>
				success_empty <= '0';
				success_queue <= '0';
			WHEN set_up_empty_state =>
				success_empty <= '0';
				success_queue <= '0';
			WHEN is_empty_success_state =>
				success_empty <= '1';
				success_queue <= '0';
			WHEN set_up_write_state =>
				success_empty <= '0';
				success_queue <= '0';
			WHEN hold_counter_state =>
				success_empty <= '0';
				success_queue <= '0';
			WHEN write_success =>
				success_empty <= '0';
				success_queue <= '1';
		END CASE;
	END PROCESS;


	
END cblt;		