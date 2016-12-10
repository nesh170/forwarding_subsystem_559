library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.all;


ENTITY forwarding_test_subsystem IS
	PORT (clock    	            : IN  STD_LOGIC;
			reset    	            : IN  STD_LOGIC;
			start_test              : IN  STD_LOGIC;
			frame_out		         : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			frame_write	            : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) ;
			cntl_block_out          : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
			cb_write                : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			high_priority_out       : OUT STD_LOGIC
			);
END forwarding_test_subsystem;

ARCHITECTURE tester OF forwarding_test_subsystem IS 
	TYPE state_type is 
		(wait_state,process_stage,write_frame_stage,increment_cb_stage,check_cb_stage,end_stage);
	SIGNAL state_reg,next_state : state_type;
	SIGNAL register_input_cb_counter_1,register_output_cb_counter_1,register_input_cb_counter_2,register_output_cb_counter_2 : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL ctrl_write_counter_register : STD_LOGIC;
	SIGNAL cb_write_1_fwd,cb_write_2_fwd : STD_LOGIC;
	SIGNAL cb_memory_output_1,cb_memory_output_2 : STD_LOGIC_VECTOR(23 DOWNTO 0);

	
	--frame stuff ANKIT USE THESE PORTS :/
	SIGNAL frame_memory_output_1,frame_memory_output_2 : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL register_input_frame_counter_1,register_output_frame_counter_1,register_input_frame_counter_2,register_output_frame_counter_2 : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL ctrl_write_frame_1_register,ctrl_write_frame_2_register : STD_LOGIC;
	SIGNAL frame_write_1_fwd,frame_write_2_fwd: STD_LOGIC;
	

BEGIN

	cb_register_port_1 : register_8 PORT MAP (
		clock    	=> clock,
		reset    	=> reset,
		write_enable=> ctrl_write_counter_register,
		data_in		=> register_input_cb_counter_1,
		data_out	   => register_output_cb_counter_1
	);

	cb_register_port_2 : register_8 PORT MAP (
		clock    	=> clock,
		reset    	=> reset,
		write_enable=> ctrl_write_counter_register,
		data_in		=> register_input_cb_counter_2,
		data_out	   => register_output_cb_counter_2
	);
	
	frame_register_port_1 : register_8 PORT MAP (
		clock    	=> clock,
		reset    	=> reset,
		write_enable=> ctrl_write_frame_1_register,
		data_in		=> register_input_frame_counter_1,
		data_out	   => register_output_frame_counter_1
	);
	
	frame_register_port_2 : register_8 PORT MAP (
		clock    	=> clock,
		reset    	=> reset,
		write_enable=> ctrl_write_frame_2_register,
		data_in		=> register_input_frame_counter_2,
		data_out	   => register_output_frame_counter_2
	);
	
	cb_memory_1_inst: cb_memory_1 PORT MAP (
		aclr => reset,
		address => register_output_cb_counter_1(5 DOWNTO 0),
		clock => clock,
		q => cb_memory_output_1
	);
	
	cb_memory_2_inst: cb_memory_2 PORT MAP (
		aclr => reset,
		address => register_output_cb_counter_2(5 DOWNTO 0),
		clock => clock,
		q => cb_memory_output_2
	);
	
	recv_1_inst: recv_frame_1 PORT MAP (
		aclr => reset,
		address => register_output_frame_counter_1(5 DOWNTO 0),
		clock => clock,
		q => frame_memory_output_1
	);
	
	recv_2_inst: recv_frame_2 PORT MAP (
		aclr => reset,
		address => register_output_frame_counter_2(5 DOWNTO 0),
		clock => clock,
		q => frame_memory_output_2
	);
	
	
	forwarding_subsystem_inst: forwarding_subsystem PORT MAP (
		clock =>  clock,
		reset => reset,
		recv_ctrl_write_frame => '0' & '0' & frame_write_2_fwd & frame_write_1_fwd,
		recv_ctrl_write_control_block => '0' & '0' & cb_write_2_fwd & cb_write_1_fwd,
		recv_frame_in_1 => frame_memory_output_1,
		recv_frame_in_2 => frame_memory_output_2,

		recv_control_block_in_1 => cb_memory_output_1,
		recv_control_block_in_2 => cb_memory_output_2,
		
		
		recv_control_block_in_3 => x"000000",
		recv_control_block_in_4 => x"000000",
		recv_frame_in_3 => x"00",
		recv_frame_in_4 => x"00",
		
		xmit_frame_out => frame_out,
		xmit_ctrl_write_frame => frame_write,
		xmit_control_block_out => cntl_block_out,
		xmit_ctrl_write_control_block => cb_write,
		xmit_high_priority => high_priority_out
	);
	

	PROCESS(clock,reset)
	BEGIN
		if(reset = '1') then state_reg <= wait_state;
		elsif (clock'event and clock = '1') then 
			state_reg <= next_state;
		end if;
	END PROCESS;
	
	PROCESS(state_reg,cb_memory_output_1,cb_memory_output_2,register_output_cb_counter_1,register_output_cb_counter_2)
	BEGIN
		CASE state_reg IS
			WHEN wait_state =>
				if(start_test = '1' and (cb_memory_output_1 /= x"000000" or cb_memory_output_2 /= x"000000")) then
					next_state <= process_stage;
				else
					next_state <= wait_state;
				end if;
			when process_stage =>
				if(cb_memory_output_1 /= x"0000") then
					cb_write_1_fwd <= '1';
				end if;
				if(cb_memory_output_2 /= x"0000") then
					cb_write_2_fwd <= '1';
				end if;
				next_state <= write_frame_stage;
			when write_frame_stage =>
				--if frame_counter is reached, go on to the next increment_cb_stage
			when increment_cb_stage =>
				ctrl_write_frame_1_register <= '1';
				ctrl_write_frame_2_register <= '1';
				register_input_frame_counter_1 <= x"00";
				register_input_frame_counter_2 <= x"00";
				ctrl_write_counter_register <= '1';
				register_input_cb_counter_1 <= std_logic_vector(to_unsigned(to_integer(unsigned(register_output_cb_counter_1)) + 1,register_input_cb_counter_1'length));
				register_input_cb_counter_2 <= std_logic_vector(to_unsigned(to_integer(unsigned(register_output_cb_counter_2)) + 1,register_input_cb_counter_2'length));
				next_state <= check_cb_stage;
			when check_cb_stage => 
				ctrl_write_counter_register <= '0';
				ctrl_write_frame_1_register <= '0';
				ctrl_write_frame_2_register <= '0';				
				if((cb_memory_output_1 /= x"0000" or cb_memory_output_2 /= x"0000")) then 
					next_state <= process_stage;
				else
					next_state <= end_stage;
				end if;	
			when end_stage =>
				--do nothing :/ just turn on the lights
			
		END CASE;
	END PROCESS;
	
	
	


END tester;