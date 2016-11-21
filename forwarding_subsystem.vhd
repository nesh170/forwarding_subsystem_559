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
--		table_destination_port: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
--		table_input_ready: IN STD_LOGIC;
--		table_output_ready: IN STD_LOGIC;
--		table_source_address: OUT STD_LOGIC_VECTOR(47 DOWNTO 0);
--		table_destination_address: OUT STD_LOGIC_VECTOR(47 DOWNTO 0);
--		table_source_port: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
--		table_trigger: OUT STD_LOGIC;
		
		--Monitoring Subsystem
		monitor_look_now     : OUT STD_LOGIC;
		monitor_frame_id     : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
		monitor_tagged       : OUT STD_LOGIC;
		monitor_high_priority: OUT STD_LOGIC;
		
		--Transmit
		xmit_frame_out: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		xmit_ctrl_write_frame:OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		xmit_control_block_out: OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
		xmit_ctrl_write_control_block: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		xmit_high_priority:OUT STD_LOGIC;
		
		--Debugging Port
		control_block_debug_out: OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
		recv_port_currently_debug: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		is_empty_debug_recv_control_block:OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		recv_handler_1_control_block_debug_out: OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
		frame_queue_in_debug_out: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		frame_buffer_empty_out_debug: OUT STD_LOGIC;
		vlan_discard_out_debug	: OUT STD_LOGIC;
		control_block_buffer_read_debug_out : OUT STD_LOGIC;
		frame_buffer_read_debug_out : OUT STD_LOGIC;
		debug_start_between_out: OUT STD_LOGIC;
		frame_transmitted_debug_out: OUT STD_LOGIC;
		table_trigger_debug_out,table_output_ready_debug_out,table_input_ready_debug_out: OUT STD_LOGIC;
		frame_finished_signal_debug_out: OUT STD_LOGIC;
		vlan_high_priority_debug_out: OUT STD_LOGIC
	);
END forwarding_subsystem;	
	
ARCHITECTURE fs_arch OF forwarding_subsystem IS
	SIGNAL recv_control_block_out_sig_1,recv_control_block_out_sig_2,recv_control_block_out_sig_3,recv_control_block_out_sig_4: STD_LOGIC_VECTOR(23 DOWNTO 0);
	SIGNAL recv_control_block_read,recv_control_block_empty,recv_frame_read,recv_frame_empty: STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL recv_frame_out_sig_1,recv_frame_out_sig_2,recv_frame_out_sig_3,recv_frame_out_sig_4: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL receive_port_read: STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL write_control_block_buffer,is_empty_stv,read_control_block_buffer: STD_LOGIC;
	SIGNAL control_block_buffer_in,control_block_buffer_out: STD_LOGIC_VECTOR(23 DOWNTO 0);
	SIGNAL is_empty_control_block_buffer,is_empty_frame_buffer,frame_buffer_read, is_empty_frame_buffer_vlan, frame_buffer_read_vlan: STD_LOGIC;
	SIGNAL frame_finished_sig,write_enable_frame_buffer_queue: STD_LOGIC;
	SIGNAL frame_queue_in,frame_queue_out, frame_queue_out_vlan: STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL vlan_priority_bit, vlan_tagged_bit, vlan_discard_bit, vlan_extract_read_valid, vlan_priority_read_valid: STD_LOGIC;
	SIGNAL frame_fully_transmitted_sig: STD_LOGIC;
	
	
	
	--TABLE SIGNAL (SWITCH TO INPUT OUTPUT LATER)
		SIGNAL table_destination_port: STD_LOGIC_VECTOR(3 DOWNTO 0);
		SIGNAL table_input_ready: STD_LOGIC;
		SIGNAL table_output_ready: STD_LOGIC;
		SIGNAL table_source_address: STD_LOGIC_VECTOR(47 DOWNTO 0);
		SIGNAL table_destination_address: STD_LOGIC_VECTOR(47 DOWNTO 0);
		SIGNAL table_source_port: STD_LOGIC_VECTOR(3 DOWNTO 0);
		SIGNAL table_trigger: STD_LOGIC;
BEGIN
is_empty_debug_recv_control_block <= recv_control_block_empty;
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
	
	recv_handler_1_control_block_debug_out <= recv_control_block_out_sig_1;
	
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
		frame_fully_transmited => frame_fully_transmitted_sig,
		recv_port_to_read => receive_port_read
	);
	
	frame_transmitted_debug_out <= frame_fully_transmitted_sig;
	recv_port_currently_debug <= receive_port_read;
	
	control_block_buffer: control_block_queue PORT MAP (
		aclr		=> reset,	
		clock		=> clock,
		data		=> control_block_buffer_in,
		rdreq		=> read_control_block_buffer,
		wrreq		=> write_control_block_buffer,
		empty		=> is_empty_control_block_buffer,
		q			=> control_block_buffer_out
	);
	
	control_block_debug_out <= control_block_buffer_out;
	
	frame_handle: frame_handler PORT MAP (
		clock_sig => clock,
		reset_sig => reset,
		control_block => control_block_buffer_out,
		receive_port_to_read => receive_port_read,
		frame_peek_value_1 => recv_frame_out_sig_1,
		frame_peek_value_2 => recv_frame_out_sig_2,
		frame_peek_value_3 => recv_frame_out_sig_3,
		frame_peek_value_4 => recv_frame_out_sig_4,
		frame_queue_empty => recv_frame_empty,
		control_block_buffer_queue_empty => is_empty_control_block_buffer,
		control_read_enable_frame_queue => recv_frame_read,
		frame_finished => frame_finished_sig,
		frame_data_block => frame_queue_in,
		transmit_finished => frame_fully_transmitted_sig,
		write_enable_frame_buffer_queue => write_enable_frame_buffer_queue
	);
	
	frame_queue_in_debug_out <= frame_queue_in;
	frame_finished_signal_debug_out <= frame_finished_sig; 

	frame_buffer : frame_queue PORT MAP (
		aclr		=> reset,	
		clock		=> clock,
		data		=> frame_queue_in,
		rdreq		=> frame_buffer_read,
		wrreq		=> write_enable_frame_buffer_queue,
		empty		=> is_empty_frame_buffer,
		q			=> frame_queue_out
	);	
	
	frame_buffer_vlan : frame_queue PORT MAP (
		aclr		=> reset or vlan_priority_read_valid,	
		clock		=> clock,
		data		=> frame_queue_in,
		rdreq		=> frame_buffer_read_vlan,
		wrreq		=> write_enable_frame_buffer_queue,
		empty		=> is_empty_frame_buffer_vlan,
		q			=> frame_queue_out_vlan
	);	
	
	vlan_handler : vlan PORT MAP (
		frame_seg => frame_queue_out_vlan,
		ctrl_block => control_block_buffer_out,
		buffer_empty => is_empty_frame_buffer_vlan,
		clk => clock,
		reset => reset,
		table_rdy => table_input_ready,
		priority_bit => vlan_priority_bit,
		tagged_bit => vlan_tagged_bit,
		discard_bit => vlan_discard_bit,
		src_addr => table_source_address,
		dest_addr => table_destination_address,
		extract_read_valid => table_trigger,
		priority_read_valid => vlan_priority_read_valid,
		read_enable => frame_buffer_read_vlan,
		frame_id => monitor_frame_id,
		start_bit => frame_finished_sig
	);
	
	vlan_high_priority_debug_out <= vlan_priority_bit;
	
	--table source port
	table_source_port <= receive_port_read;
	--monitor outputs
		monitor_look_now <= vlan_priority_read_valid; 
		monitor_tagged <= vlan_tagged_bit;
		monitor_high_priority <= vlan_priority_bit;
		
	trans_mem_handler: trans_mem PORT MAP( 
		clk => clock,
		reset => reset,
		priority_in => vlan_priority_bit,
		port_ready =>  table_output_ready, 
		priority_ready => vlan_priority_read_valid,
		frame_q_is_empty => is_empty_frame_buffer,
		frame_data_in => frame_queue_out,
		ctrl_block_in => control_block_buffer_out,
		port_in => table_destination_port,
		priority_out => xmit_high_priority,
		read_frame_q => frame_buffer_read,
		read_ctrl_q => read_control_block_buffer,
		ctrl_block_we => xmit_ctrl_write_control_block,
		frame_we => xmit_ctrl_write_frame,
		frame_data_out => xmit_frame_out,
		ctrl_block_out => xmit_control_block_out,
		discard => vlan_discard_bit,
		start_between_debug_out => debug_start_between_out,
		sig_complete => frame_fully_transmitted_sig
	);
	control_block_buffer_read_debug_out <= read_control_block_buffer;
	frame_buffer_read_debug_out <= frame_buffer_read;
	frame_buffer_empty_out_debug <= is_empty_frame_buffer;
	vlan_discard_out_debug <= vlan_discard_bit;
	
	
	table : address_table PORT MAP(
		clock => clock,
		reset => reset,
		source_address => table_source_address,
		source_port => table_source_port,
		destination_address => table_destination_address,
		trigger => table_trigger,
		destination_port => table_destination_port,
		output_ready => table_output_ready,
		input_ready => table_input_ready
	);
	
	table_trigger_debug_out <= table_trigger;
	table_output_ready_debug_out <= table_output_ready;
	table_input_ready_debug_out <= table_input_ready;

END fs_arch;