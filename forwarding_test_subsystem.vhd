library ieee;
library work;
use ieee.std_logic_1164.all;
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
	SIGNAL cb_Write_1_fwd,cb_Write_2_fwd : STD_LOGIC;
	SIGNAL cb_memory_output_1,cb_memory_output_2 : STD_LOGIC_VECTOR(23 DOWNTO 0);
	SIGNAL frame_memory_output_1,frame_memory_output_2 : STD_LOGIC_VECTOR(7 DOWNTO 0);
	

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
	
	
	
	

	PROCESS(clock,reset)
	BEGIN
		if(reset = '1') then state_reg <= wait_state;
		elsif (clock'event and clock = '1') then 
			state_reg <= next_state;
		end if;
	END PROCESS;
	
	PROCESS(state_reg)
	BEGIN
		CASE state_reg IS
			WHEN wait_state =>
				if(start_test = '1' and (cb_memory_output_1 /= x"0000" or cb_memory_output_2 /= x"0000")) then
					next_state <= process_stage;
				else
					next_state <= wait_state;
				end if;
			when process_stage =>
				if(cb_memory_output_1 /= x"0000") then
					cb_Write_1_fwd <= '1';
				end if;
				if(cb_memory_output_2 /= x"0000") then
					cb_Write_2_fwd <= '1';
				end if;
			when write_frame_stage =>
				--if frame_counter is reached, go on to the next increment_cb_stage
			when increment_cb_stage =>
				ctrl_write_counter_register <= '1';
				register_output_cb_counter_1 <= register_input_cb_counter_1 + 1;
				register_output_cb_counter_2 <= register_input_cb_counter_2 + 1;
			when check_cb_stage => 
			when end_stage =>
			
		END CASE;
	END PROCESS;
	
	
	


END tester;