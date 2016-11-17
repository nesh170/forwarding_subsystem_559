library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.all;

ENTITY forwarding_subsystem IS 
PORT(
		--General
		clock: IN STD_LOGIC;
		reset: IN STD_LOGIC;
		
		--Receive Subsystem
		recv_frame_in_1: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		recv_frame_in_2: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		recv_frame_in_3: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		recv_frame_in_4: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		recv_ctrl_write_frame: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		recv_control_block_in_1: IN STD_LOGIC_VECTOR(23 DOWNTO 0);
		recv_control_block_in_2: IN STD_LOGIC_VECTOR(23 DOWNTO 0);
		recv_control_block_in_3: IN STD_LOGIC_VECTOR(23 DOWNTO 0);
		recv_control_block_in_4: IN STD_LOGIC_VECTOR(23 DOWNTO 0);
		recv_ctrl_write_control_block: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		
		--Table Subsystem
		table_destination_port: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		table_input_ready: IN STD_LOGIC;
		table_output_ready: IN STD_LOGIC;
		table_source_address: OUT STD_LOGIC_VECTOR(47 DOWNTO 0);
		table_source_port: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		table_trigger: OUT STD_LOGIC;
		
		--Monitoring Subsystem
		monitor_look_now     : OUT STD_LOGIC;
		monitor_frame_id     : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
		monitor_tagged       : OUT STD_LOGIC;
		monitor_high_priority: OUT STD_LOGIC;
		
		--Transmit
		xmit_frame_out_1: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		xmit_frame_out_2: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		xmit_frame_out_3: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		xmit_frame_out_4: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		xmit_ctrl_write_frame:OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		xmit_control_block_out_1: OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
		xmit_control_block_out_2: OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
		xmit_control_block_out_3: OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
		xmit_control_block_out_4: OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
		xmit_ctrl_write_control_block: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		xmit_high_priority: OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END forwarding_subsystem;	
	
ARCHITECTURE fs_arch OF forwarding_subsystem IS
	SIGNAL recv_control_block_out_sig_1,recv_control_block_out_sig_2,recv_control_block_out_sig_3,recv_control_block_out_sig_4: STD_LOGIC_VECTOR(23 DOWNTO 0);
	SIGNAL recv_control_block_read,recv_control_block_empty,recv_frame_read,recv_frame_empty: STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL recv_frame_out_sig_1,recv_frame_out_sig_2,recv_frame_out_sig_3,recv_frame_out_sig_4: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL receive_port_read: STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL write_control_block_buffer,is_empty_stv,read_control_block_buffer: STD_LOGIC;
	SIGNAL control_block_buffer_in,control_block_buffer_out: STD_LOGIC_VECTOR(23 DOWNTO 0);
	SIGNAL is_empty_control_block_buffer,is_empty_frame_buffer: STD_LOGIC;
BEGIN
	recv_handler_1: receive_handler PORT MAP(
		clock => clock,
		reset => reset,
		control_block_in => recv_control_block_in_1,
		control_block_out => recv_control_block_out_sig_1,
		control_block_read => recv_control_block_read(0),
		control_block_write => recv_ctrl_write_control_block(0),
		control_block_empty => recv_control_block_empty(0),
		frame_out => recv_frame_out_sig_1,
		frame_read => recv_frame_read(0),
		frame_write => recv_ctrl_write_frame(0),
		frame_in => recv_frame_in_1,
		frame_empty => recv_frame_empty(0)
	);
	
	recv_handler_2: receive_handler PORT MAP(
		clock => clock,
		reset => reset,
		control_block_in => recv_control_block_in_2,
		control_block_out => recv_control_block_out_sig_2,
		control_block_read => recv_control_block_read(1),
		control_block_write => recv_ctrl_write_control_block(1),
		control_block_empty => recv_control_block_empty(1),
		frame_out => recv_frame_out_sig_2,
		frame_read => recv_frame_read(1),
		frame_write => recv_ctrl_write_frame(1),
		frame_in => recv_frame_in_2,
		frame_empty => recv_frame_empty(1)
	);

	recv_handler_3: receive_handler PORT MAP(
		clock => clock,
		reset => reset,
		control_block_in => recv_control_block_in_3,
		control_block_out => recv_control_block_out_sig_3,
		control_block_read => recv_control_block_read(2),
		control_block_write => recv_ctrl_write_control_block(2),
		control_block_empty => recv_control_block_empty(2),
		frame_out => recv_frame_out_sig_3,
		frame_read => recv_frame_read(2),
		frame_write => recv_ctrl_write_frame(2),
		frame_in => recv_frame_in_3,
		frame_empty => recv_frame_empty(2)
	);

	recv_handler_4: receive_handler PORT MAP(
		clock => clock,
		reset => reset,
		control_block_in => recv_control_block_in_4,
		control_block_out => recv_control_block_out_sig_4,
		control_block_read => recv_control_block_read(3),
		control_block_write => recv_ctrl_write_control_block(3),
		control_block_empty => recv_control_block_empty(3),
		frame_out => recv_frame_out_sig_4,
		frame_read => recv_frame_read(3),
		frame_write => recv_ctrl_write_frame(3),
		frame_in => recv_frame_in_4,
		frame_empty => recv_frame_empty(3)
	);
	
	cb_logic: control_block_logic PORT MAP(
		clock => clock,
		reset => reset,
		receive_port_read => receive_port_read,
		is_empty => recv_control_block_empty,
		data_in_1 => recv_control_block_out_sig_1,
		data_in_2 => recv_control_block_out_sig_2,
		data_in_3 => recv_control_block_out_sig_3,
		data_in_4 => recv_control_block_out_sig_4,
		read_enable => recv_control_block_read,
		write_enable => write_control_block_buffer,
		is_empty_stv => is_empty_stv,
		data_out => control_block_buffer_in
	);
	
	stvm_system: starvation_management_system PORT MAP(
		clock => clock,
		reset => reset,
		is_empty_control_block => is_empty_stv,
		is_empty_block_buffer => is_empty_control_block_buffer,
		is_empty_frame_buffer => is_empty_frame_buffer,
		recv_port_to_read => receive_port_read
	);
	
	control_block_buffer: control_block_queue PORT MAP (
		aclr		=> reset,	
		clock		=> clock,
		data		=> control_block_buffer_in,
		rdreq		=> read_control_block_buffer,
		wrreq		=> write_control_block_buffer,
		empty		=> is_empty_control_block_buffer,
		q			=> control_block_buffer_out
	);
	
	
	
	




END fs_arch;