--The Frame Handler is responsible for pulling frames out of the frame queue by the receive 
--port based on the input of the control block it takes in and the receive port input.
--It will output a vector of control read enable signals, which will pass as inputs to the
--frame receive queues. There will also be an output of frame_finished which is an indication
--of when it has finished pulling one frame from the queue. It will output frame_data_block
--which represents a part of a frame, to the frame_buffer_queue (which will store one frame)
--at any given time. Finally, it also has an output of write_enable_frame_buffer_queue which
--is a write enable signal that is an input to the frame buffer queue



library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.all;

entity frame_handler is 
	port (
		clock_sig, reset_sig: 					in std_logic;
		control_block:								in std_logic_vector (24 DOWNTO 0);
		receive_port_to_read:					in std_logic_vector (3 DOWNTO 0);
		frame_peek_value_1:						in std_logic_vector (7 DOWNTO 0);
		frame_peek_value_2:						in std_logic_vector (7 DOWNTO 0);
		frame_peek_value_3:						in std_logic_vector (7 DOWNTO 0);
		frame_peek_value_4:						in std_logic_vector (7 DOWNTO 0);
		frame_queue_empty : 						in	std_logic;
		control_block_buffer_queue_empty : 	in std_logic;

		control_read_enable_frame_queue:		out std_logic_vector (3 DOWNTO 0);
		frame_finished:							out std_logic;
		frame_data_block:							out std_logic_vector (7 DOWNTO 0);
		write_enable_frame_buffer_queue:		out std_logic;
		counter_output:							out std_logic_vector (31 DOWNTO 0) --for debugging purposes
	);
end frame_handler;



architecture frame of frame_handler is
	type state_type is (wait_state, peek_state, write_state, delete_state, frame_finished_state);
	signal state_current, state_next : state_type;
	signal counter : integer range 0 to 2056 := 0; --2048 + 8 = 2056, holds the value of counter
	signal register_output : std_logic_vector (31 DOWNTO 0);
	signal register_input : std_logic_vector (31 DOWNTO 0);
	signal register_write_enable : std_logic;
	constant FRAME_CHUNK_SIZE : integer := 8;	
	
	
begin
	--always set counter to current value of register output
	counter <= to_integer(unsigned(register_output(10 DOWNTO 0)));
	counter_output <= std_logic_vector(to_unsigned(counter, counter_output'length));
	--port map register
	reg : register_32 PORT MAP (
		clock => clock_sig,
		reset => reset_sig,
		write_enable => register_write_enable,
		data_in => register_input,
		data_out => register_output
	);
	
	
	process(clock_sig, reset_sig)
	begin
	if (reset_sig = '1') then state_current <= wait_state;
	elsif(clock_sig'event and clock_sig='1') then
		--new current state becomes next state
		state_current <= state_next;
	end if;
	end process;
	--next state logic
	process(state_current, frame_queue_empty, control_block, counter, register_output, control_block_buffer_queue_empty)
	--initialize variable added_value to 0 at beginning
	variable added_value : integer := 0;
	begin
	case state_current is 
		when wait_state =>
			register_write_enable <= '0';
			register_input <= register_output;
			added_value := 0;
			if (control_block_buffer_queue_empty = '1') then state_next <= wait_state;
			else state_next <= peek_state;
			end if;
		when peek_state =>
			register_write_enable <= '0';
			register_input <= register_output;
			added_value := 0;
			--if current value of counter greater than or equal to frame size, then go to frame finished state
			if (counter >= to_integer(unsigned(control_block(11 DOWNTO 0)))) then
				state_next <= frame_finished_state;
			--if counter is less than frame size, then want to write data to queue, have to check that queue is not empty otherwise could write potentiall all 0's if queue is emty
			elsif (counter < to_integer(unsigned(control_block(11 DOWNTO 0))) and frame_queue_empty = '0') then
				state_next <= write_state;
			--if frame queue is empty, stay at peek state to do the checks again to see if frame is finished and so on
			elsif (frame_queue_empty = '1') then
				state_next <= peek_state;
			else state_next <= peek_state;
			end if;
		when write_state =>
			added_value := counter + FRAME_CHUNK_SIZE;
			state_next <= delete_state;
			if (added_value >= to_integer(unsigned(control_block(11 DOWNTO 0)))) then
				register_write_enable <= '1';
				register_input <= std_logic_vector(to_unsigned(to_integer(unsigned(control_block(11 DOWNTO 0))), register_input'length));
			else
				register_write_enable <= '1';
				register_input <= std_logic_vector(to_unsigned(added_value, register_input'length));
			end if;
		when delete_state =>
			added_value := 0;
			register_write_enable <= '0';
			register_input <= register_output;
			state_next <= peek_state;
		when frame_finished_state =>
			--reset counter
			added_value := 0;
			register_write_enable <= '1';
			register_input <= std_logic_vector(to_unsigned(added_value, register_input'length));
			state_next <= wait_state;
		end case;
	end process;
	
	process(receive_port_to_read, frame_peek_value_1, frame_peek_value_2, frame_peek_value_3, frame_peek_value_4)
	begin
		case receive_port_to_read is
			when "0001" =>
				frame_data_block <= frame_peek_value_1;
			when "0010" =>
				frame_data_block <= frame_peek_value_2;
			when "0100" =>
				frame_data_block <= frame_peek_value_3;
			when "1000" =>
				frame_data_block <= frame_peek_value_4;
			when others =>
				frame_data_block <= "00000000";
			end case;
	end process;
	process(state_current, receive_port_to_read)
	begin
		case state_current is 
			when wait_state =>
				control_read_enable_frame_queue <= "0000";
				frame_finished <= '0';
				write_enable_frame_buffer_queue <= '0';
			when peek_state =>
				control_read_enable_frame_queue <= "0000";
				frame_finished <= '0';
				write_enable_frame_buffer_queue <= '0';
			when write_state =>
				control_read_enable_frame_queue <= "0000";
				frame_finished <= '0';
				write_enable_frame_buffer_queue <= '1';
			when delete_state =>
				control_read_enable_frame_queue <= receive_port_to_read;
				frame_finished <= '0';
				write_enable_frame_buffer_queue <= '0';				
			when frame_finished_state =>
				control_read_enable_frame_queue <= "0000";
				frame_finished <= '1';
				write_enable_frame_buffer_queue <= '0';
			end case;
	end process;
end frame;




