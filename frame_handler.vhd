library ieee;
use ieee.std_logic_1164.all;

entity frame_handler is 
	port (
		clock_sig, reset_sig: 					in std_logic;
		control_block:								in std_logic_vector (24 DOWNTO 0);
		receive_port_to_read:					in std_logic_vector (3 DOWNTO 0);
		frame_content:								in std_logic_vector (7 DOWNTO 0);
		control_read_enable_frame_queue:		out std_logic_vector (3 DOWNTO 0);
		frame_finished:							out std_logic;
		frame_data_block:							out std_logic_vector (7 DOWNTO 0);
		write_enable_frame_buffer_queue:		out std_logic
	);
end frame_handler;

--The Frame Handler is responsible for pulling frames out of the frame queue by the receive 
--port based on the input of the control block it takes in and the receive port input.
--It will output a vector of control read enable signals, which will pass as inputs to the
--frame receive queues. There will also be an output of frame_finished which is an indication
--of when it has finished pulling one frame from the queue. It will output frame_data_block
--which represents a part of a frame, to the frame_buffer_queue (which will store one frame)
--at any given time. Finally, it also has an output of write_enable_frame_buffer_queue which
--is a write enable signal that is an input to the frame buffer queue