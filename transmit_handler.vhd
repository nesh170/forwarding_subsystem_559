library ieee;
use ieee.std_logic_1164.all;

entity transmit_handler is

	port (
			clock, reset, priority_in, frame_q_is_empty, start, discard: in std_logic;
			dest_port: in std_logic_vector (3 downto 0);
			frame_data_in: in std_logic_vector (7 downto 0);
			ctrl_block_in: in std_logic_vector (23 downto 0);
			priority_out, sig_complete, read_frame_q, read_ctrl_q: out std_logic;
			ctrl_block_we, frame_we: out std_logic_vector (3 downto 0);
			frame_data_out: out std_logic_vector (7 downto 0);
			ctrl_block_out: out std_logic_vector (23 downto 0)
			);
			
	end transmit_handler;
	
	architecture tr_handle of transmit_handler is
		
		type state_type is
				(complete, waiting, first_transmit, transmitting);
				signal state_reg, state_next: state_type;
		
		signal ctrl_we_block, frame_we_block, discard_block, frame_q_block: std_logic_vector(3 downto 0);
		
		component register_1 is
								PORT(clock: in std_logic;
									  reset: in std_logic;
									  write_enable: in std_logic;
									  data_in: in std_logic;
									  data_out: out std_logic
									  );
		end component;
		
		component register_4 is
								PORT(clock: in std_logic;
									  reset: in std_logic;
									  write_enable: in std_logic;
									  data_in: in std_logic_vector(3 downto 0);
									  data_out: out std_logic_vector (3 downto 0)
									  );
									  
		end component;
									  
		component register_8 IS
								PORT (clock    	: IN  STD_LOGIC;
										reset    	: IN  STD_LOGIC;
										write_enable: IN  STD_LOGIC;
										data_in		: IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
										data_out	   : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
										);
		END component;
		
		component register_24 IS
								PORT (clock    	: IN  STD_LOGIC;
										reset    	: IN  STD_LOGIC;
										write_enable: IN  STD_LOGIC;
										data_in		: IN  STD_LOGIC_VECTOR (23 DOWNTO 0);
										data_out	   : OUT STD_LOGIC_VECTOR (23 DOWNTO 0)
										);
		END component;
		
	begin
		discard_block(3) <= not discard;
		discard_block(2) <= not discard;	
		discard_block(1) <= not discard;
		discard_block(0) <= not discard;
		
		frame_q_block(3) <= not frame_q_is_empty;
		frame_q_block(2) <= not frame_q_is_empty;
		frame_q_block(1) <= not frame_q_is_empty;
		frame_q_block(0) <= not frame_q_is_empty;
		
		priority_reg: register_1 PORT MAP(
							clock => not clock,
							reset => reset,
							write_enable => '1',
							data_in => priority_in,
							data_out => priority_out
							);
							
		port_reg: register_4 PORT MAP(
							clock => not clock,
							reset => reset,
							write_enable => '1',
							data_in => (frame_we_block and discard_block and frame_q_block) ,
							data_out => frame_we
							);
							
		ctrl_port_reg: register_4 PORT MAP(
							clock => not clock,
							reset => reset,
							write_enable => '1',
							data_in => (ctrl_we_block and discard_block and frame_q_block),
							data_out => ctrl_block_we
							);
							
		frame_data_reg: register_8 PORT MAP(
							clock => not clock,
							reset => reset,
							write_enable => '1',
							data_in => frame_data_in,
							data_out => frame_data_out
							);
							
		ctrl_block_reg: register_24 PORT MAP(
							clock => not clock,
							reset => reset,
							write_enable => '1',
							data_in => ctrl_block_in,
							data_out => ctrl_block_out
							);
							
							
		process(clock,reset)
			begin
			
				if (reset='1') then state_reg <= waiting;
				elsif (clock'event and clock='1') then state_reg <= state_next;
				end if;
				
			end process;

		process(state_reg, frame_q_is_empty, start)
			
			begin
			
				case state_reg is
				
					when waiting =>
						if(start = '1') then state_next <= first_transmit;
						else state_next <= waiting;
						end if;
						
					when first_transmit =>
						state_next <= transmitting;
						
					when transmitting =>
						if(frame_q_is_empty = '1' and start = '0') then state_next <= complete;
						elsif (frame_q_is_empty = '1' and start = '1') then state_next <= first_transmit;
						else state_next <= transmitting;
						end if;
					
					when complete =>
						state_next <= waiting;
					
				end case;
		end process;
		
		process(state_reg, dest_port)
		
			begin
			
				case state_reg is
				
					when waiting => 
						ctrl_we_block <= "0000";
						frame_we_block <= "0000";
						sig_complete <= '0';
						read_frame_q <= '0';
						read_ctrl_q <= '0';
						
					when first_transmit =>
						ctrl_we_block <= dest_port;
						frame_we_block <= dest_port;
						sig_complete <= '0';
						read_frame_q <= '1';
						read_ctrl_q <= '1';
						
					when transmitting =>
						ctrl_we_block <= "0000";
						frame_we_block <= dest_port;
						sig_complete <= '0';
						read_frame_q <= '1';
						read_ctrl_q <= '0';
					
					when complete => 
						ctrl_we_block <= "0000";
						frame_we_block <= "0000";
						sig_complete <= '1';
						read_frame_q <= '0';
						read_ctrl_q <= '0';
						
				end case;
			end process;
		
	end tr_handle;		  
			
			
			
