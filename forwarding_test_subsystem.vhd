library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.all;


ENTITY forwarding_test_subsystem IS
	PORT (clock    	            : IN  STD_LOGIC;
			inv_reset    	            : IN  STD_LOGIC;
			inv_start_test              : IN  STD_LOGIC;
			frame_out		         : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			frame_write	            : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) ;
			cntl_block_out          : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
			cb_write                : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			high_priority_out       : OUT STD_LOGIC;
			end_test						: OUT STD_LOGIC;
			
			
			--debugging ports
			memory_cb_1 : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
			frame_memory_1 : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			frame_write_queue_1 : OUT STD_LOGIC;
			address_frame_1_debug: OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
			wait_state_out : OUT STD_LOGIC
			);
END forwarding_test_subsystem;

ARCHITECTURE tester OF forwarding_test_subsystem IS 
	TYPE state_type is 
		(wait_state,process_stage,delay_stage,write_frame_stage,increment_cb_stage,check_cb_stage,end_state);
	SIGNAL state_reg,next_state : state_type;
	SIGNAL register_input_cb_counter_1,register_output_cb_counter_1,register_input_cb_counter_2,register_output_cb_counter_2 : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL ctrl_write_counter_register : STD_LOGIC;
	SIGNAL cb_write_1_fwd,cb_write_2_fwd : STD_LOGIC;
	SIGNAL cb_memory_output_1,cb_memory_output_2 : STD_LOGIC_VECTOR(23 DOWNTO 0);
	SIGNAL start_test,reset: STD_LOGIC;

	
	--frame stuff ANKIT USE THESE PORTS, regsiter_input_frame_counter and register_output_frame_counter are incremented by one eachtime:/
	--register_input_frame_end 
	--frame_memory_output_1,2 are the frame data from both receive ports
	--frame_write_1_fwd is write enable of receive port- have to asswert that
	--register output frame counter holds the current memory address - has to be incremented by one each time
	--make new register for the endpoints
	SIGNAL frame_memory_output_1,frame_memory_output_2 : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL register_input_frame_counter_1,register_output_frame_counter_1,register_input_frame_counter_2,register_output_frame_counter_2 : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL register_input_frame_endpoint_1, register_output_frame_endpoint_1, register_input_frame_endpoint_2, register_output_frame_endpoint_2 : STD_LOGIC_VECTOR(7 DOWNTO 0);
	SIGNAL ctrl_write_frame_1_register,ctrl_write_frame_2_register, ctrl_write_frame_endpoint_1_register, ctrl_write_frame_endpoint_2_register : STD_LOGIC;
	SIGNAL frame_write_1_fwd,frame_write_2_fwd: STD_LOGIC;
	SIGNAL current_memory_address_1, current_memory_address_2 : integer range 0 to 63 := 0;
	SIGNAL frame_endpoint_1, frame_endpoint_2 : integer range 0 to 63 := 0;
BEGIN
	current_memory_address_1 <= to_integer(unsigned(register_output_frame_counter_1(7 DOWNTO 0)));
	current_memory_address_2 <= to_integer(unsigned(register_output_frame_counter_2(7 DOWNTO 0)));
	frame_endpoint_1 <= to_integer(unsigned(register_output_frame_endpoint_1(7 DOWNTO 0)));
	frame_endpoint_2 <= to_integer(unsigned(register_output_frame_endpoint_2(7 DOWNTO 0)));
	start_test <= not inv_start_test;
	reset <= not inv_reset;
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
	frame_register_endpoint_port_1 : register_8 PORT MAP (
		clock 		=> clock,
		reset 		=> reset,
		write_enable => ctrl_write_frame_endpoint_1_register,
		data_in 		=> register_input_frame_endpoint_1,
		data_out		=> register_output_frame_endpoint_1
	);
	
	
	frame_register_endpoint_port_2 : register_8 PORT MAP (
		clock 		=> clock,
		reset 		=> reset,
		write_enable => ctrl_write_frame_endpoint_2_register,
		data_in		=> register_input_frame_endpoint_2,
		data_out 	=> register_output_frame_endpoint_2
	);
	cb_memory_1_inst: cb_memory_1 PORT MAP (
		aclr => reset,
		address => register_output_cb_counter_1(5 DOWNTO 0),
		clock => clock,
		q => cb_memory_output_1
	);
	
	memory_cb_1 <= cb_memory_output_1;
	
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
	frame_memory_1 <= frame_memory_output_1;
	address_frame_1_debug <= register_output_frame_counter_1(5 DOWNTO 0);
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
	
	frame_write_queue_1 <= frame_write_1_fwd;
	PROCESS(clock,reset)
	BEGIN
		if(reset = '1') then state_reg <= wait_state;
		elsif (clock'event and clock = '1') then 
			state_reg <= next_state;
		end if;
	END PROCESS;
	
	PROCESS(state_reg,start_test,cb_memory_output_1,cb_memory_output_2,register_output_cb_counter_1,register_output_cb_counter_2, current_memory_address_1, current_memory_address_2, frame_endpoint_1, frame_endpoint_2, register_output_frame_counter_1, register_output_frame_counter_2, register_output_frame_endpoint_1, register_output_frame_endpoint_2)
	BEGIN
		CASE state_reg IS
			WHEN wait_state =>
				register_input_frame_counter_1 <= register_output_frame_counter_1;
				register_input_cb_counter_1 <= register_output_cb_counter_1;
				register_input_cb_counter_2 <= register_output_cb_counter_2;
				register_input_frame_counter_2 <= register_output_frame_counter_2;
				register_input_frame_endpoint_1 <= register_output_frame_endpoint_1;
				register_input_frame_endpoint_2 <= register_output_frame_endpoint_2;
				ctrl_write_frame_1_register <= '0';
				ctrl_write_frame_2_register <= '0';	
				ctrl_write_frame_endpoint_1_register <= '0';
				ctrl_write_frame_endpoint_2_register <= '0';
				frame_write_1_fwd <= '0';
				frame_write_2_fwd <= '0';
				cb_write_1_fwd <= '0';
				cb_write_2_fwd <= '0';
				ctrl_write_counter_register <= '0';
				if(start_test = '1' and (cb_memory_output_1 /= x"000000" or cb_memory_output_2 /= x"000000")) then
					next_state <= process_stage;
				else
					next_state <= wait_state;
				end if;
			when process_stage =>
				frame_write_1_fwd <= '0';
				frame_write_2_fwd <= '0';
				register_input_frame_counter_1 <= register_output_frame_counter_1;
				register_input_frame_counter_2 <= register_output_frame_counter_2;
				register_input_cb_counter_1 <= register_output_cb_counter_1;
				register_input_cb_counter_2 <= register_output_cb_counter_2;
				ctrl_write_frame_1_register <= '0';
				ctrl_write_frame_2_register <= '0';
				ctrl_write_counter_register <= '0';
				register_input_frame_endpoint_1 <= std_logic_vector(to_unsigned(to_integer(unsigned(register_output_frame_endpoint_1)) + to_integer(unsigned(cb_memory_output_1(11 DOWNTO 0))),register_input_frame_endpoint_1'length));	
				register_input_frame_endpoint_2 <= std_logic_vector(to_unsigned(to_integer(unsigned(register_output_frame_endpoint_2)) + to_integer(unsigned(cb_memory_output_2(11 DOWNTO 0))),register_input_frame_endpoint_2'length));
				if(cb_memory_output_1 /= x"000000") then
					cb_write_1_fwd <= '1';
					ctrl_write_frame_endpoint_1_register <= '1';
				else
					cb_write_1_fwd <= '0';
					ctrl_write_frame_endpoint_1_register <= '0';
				end if;
				if(cb_memory_output_2 /= x"000000") then
					cb_write_2_fwd <= '1';
					ctrl_write_frame_endpoint_2_register <= '1';
				else
					cb_write_2_fwd <= '0';
					ctrl_write_frame_endpoint_2_register <= '0';
				end if;
				next_state <= delay_stage;
			when delay_stage =>
				cb_write_1_fwd <= '0';
				cb_write_2_fwd <= '0';
				frame_write_1_fwd <= '0';
				frame_write_2_fwd <= '0';
				register_input_cb_counter_1 <= register_output_cb_counter_1;
				register_input_cb_counter_2 <= register_output_cb_counter_2;
				register_input_frame_counter_1 <= register_output_frame_counter_1;
				register_input_frame_counter_2 <= register_output_frame_counter_2;
				ctrl_write_frame_1_register <= '0';
				ctrl_write_frame_2_register <= '0';
				ctrl_write_frame_endpoint_1_register <= '0';
				ctrl_write_frame_endpoint_2_register <= '0';
				ctrl_write_counter_register <= '0';
				register_input_frame_endpoint_1 <= register_output_frame_endpoint_1;
				register_input_frame_endpoint_2 <= register_output_frame_endpoint_2;
				next_state <= write_frame_stage;
			when write_frame_stage =>
				cb_write_1_fwd <= '0';
				cb_write_2_fwd <= '0';
				register_input_cb_counter_1 <= register_output_cb_counter_1;
				register_input_cb_counter_2 <= register_output_cb_counter_2;
				ctrl_write_frame_endpoint_1_register <= '0';
				ctrl_write_frame_endpoint_2_register <= '0';
				ctrl_write_counter_register <= '0';
				register_input_frame_endpoint_1 <= register_output_frame_endpoint_1;
				register_input_frame_endpoint_2 <= register_output_frame_endpoint_2;
				if(current_memory_address_1 = frame_endpoint_1 and current_memory_address_2 = frame_endpoint_2) then
					frame_write_1_fwd <= '0';
					frame_write_2_fwd <= '0';
					ctrl_write_frame_1_register <= '0';
					ctrl_write_frame_2_register <= '0';
					register_input_frame_counter_1 <= register_output_frame_counter_1;
					register_input_frame_counter_2 <= register_output_frame_counter_2;
					next_state <= increment_cb_stage;
				elsif (current_memory_address_1 = frame_endpoint_1) then
					frame_write_1_fwd <= '0';
					frame_write_2_fwd <= '1';
					register_input_frame_counter_1 <= register_output_frame_counter_1;
					register_input_frame_counter_2 <= std_logic_vector(to_unsigned(to_integer(unsigned(register_output_frame_counter_2)) + 1,register_input_frame_counter_2'length));
					ctrl_write_frame_1_register <= '0';
					ctrl_write_frame_2_register <= '1';
					next_state <= delay_stage;
				--if frame_counter is reached, go on to the next increment_cb_stage
				elsif (current_memory_address_2 = frame_endpoint_2) then
					frame_write_1_fwd <= '1';
					frame_write_2_fwd <= '0';
					register_input_frame_counter_1 <= std_logic_vector(to_unsigned(to_integer(unsigned(register_output_frame_counter_1)) + 1,register_input_frame_counter_1'length));
					register_input_frame_counter_2 <= register_output_frame_counter_2;
					ctrl_write_frame_1_register <= '1';
					ctrl_write_frame_2_register <= '0';
					next_state <= delay_stage;
				else
					frame_write_1_fwd <= '1';
					frame_write_2_fwd <= '1';
					ctrl_write_frame_1_register <= '1';
					ctrl_write_frame_2_register <= '1';
					register_input_frame_counter_1 <= std_logic_vector(to_unsigned(to_integer(unsigned(register_output_frame_counter_1)) + 1,register_input_frame_counter_1'length));
					register_input_frame_counter_2 <= std_logic_vector(to_unsigned(to_integer(unsigned(register_output_frame_counter_2)) + 1,register_input_frame_counter_2'length));
					next_state <= delay_stage;
				end if;
			when increment_cb_stage =>
				cb_write_1_fwd <= '0';
				cb_write_2_fwd <= '0';
				ctrl_write_frame_endpoint_1_register <= '0';
				ctrl_write_frame_endpoint_2_register <= '0';
				ctrl_write_frame_1_register <= '0';
				ctrl_write_frame_2_register <= '0';
				frame_write_1_fwd <= '0';
				frame_write_2_fwd <= '0';
				register_input_frame_counter_1 <= register_output_frame_counter_1;
				register_input_frame_counter_2 <= register_output_frame_counter_2;
				register_input_frame_endpoint_1 <= register_output_frame_endpoint_1;
				register_input_frame_endpoint_2 <= register_output_frame_endpoint_2;
				ctrl_write_counter_register <= '1';
				register_input_cb_counter_1 <= std_logic_vector(to_unsigned(to_integer(unsigned(register_output_cb_counter_1)) + 1,register_input_cb_counter_1'length));
				register_input_cb_counter_2 <= std_logic_vector(to_unsigned(to_integer(unsigned(register_output_cb_counter_2)) + 1,register_input_cb_counter_2'length));
				next_state <= check_cb_stage;
			when check_cb_stage => 
				cb_write_1_fwd <= '0';
				cb_write_2_fwd <= '0';
				ctrl_write_counter_register <= '0';
				register_input_frame_counter_1 <= register_output_frame_counter_1;
				register_input_frame_counter_2 <= register_output_frame_counter_2;
				register_input_frame_endpoint_1 <= register_output_frame_endpoint_1;
				register_input_frame_endpoint_2 <= register_output_frame_endpoint_2;
				register_input_cb_counter_1 <= register_output_cb_counter_1;
				register_input_cb_counter_2 <= register_output_cb_counter_2;
				ctrl_write_frame_endpoint_1_register <= '0';
				ctrl_write_frame_endpoint_2_register <= '0';
				ctrl_write_counter_register <= '0';
				ctrl_write_frame_1_register <= '0';
				ctrl_write_frame_2_register <= '0';
				frame_write_1_fwd <= '0';
				frame_write_2_fwd <= '0';				
				if((cb_memory_output_1 /= x"000000" or cb_memory_output_2 /= x"000000")) then 
					next_state <= process_stage;
				else
					next_state <= end_state;
				end if;	
			when end_state =>
				--do nothing :/ just turn on the lights
				cb_write_1_fwd <= '0';
				cb_write_2_fwd <= '0';
				ctrl_write_frame_1_register <= '0';
				ctrl_write_frame_2_register <= '0';	
				ctrl_write_frame_endpoint_1_register <= '0';
				ctrl_write_frame_endpoint_2_register <= '0';
				frame_write_1_fwd <= '0';
				frame_write_2_fwd <= '0';
				ctrl_write_counter_register <= '0';
				register_input_frame_counter_1 <= register_output_frame_counter_1;
				register_input_frame_counter_2 <= register_output_frame_counter_2;
				register_input_frame_endpoint_1 <= register_output_frame_endpoint_1;
				register_input_frame_endpoint_2 <= register_output_frame_endpoint_2;
				register_input_cb_counter_1 <= register_output_cb_counter_1;
				register_input_cb_counter_2 <= register_output_cb_counter_2;
				next_state <= end_state;
		END CASE;
	END PROCESS;
	
	PROCESS(state_reg)
	BEGIN
		CASE state_reg IS
			WHEN end_state =>
				end_test <= '1';
				wait_state_out <= '0';
			WHEN wait_state =>
				end_test <= '0';
				wait_state_out <= '1';
			WHEN others =>
				end_test <= '0';
				wait_state_out <= '0';
		END CASE;
	END PROCESS;
	
	
	


END tester;