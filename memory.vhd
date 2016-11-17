library ieee;
use ieee.std_logic_1164.all;

entity memory is 

	port (
			clk, reset, priority_in, port_ready, priority_ready: in std_logic;
			port_in: in std_logic_vector (3 downto 0);
			port_out: out std_logic_vector (3 downto 0);
			priority_out, start_out: out std_logic);
			
	end memory;

	architecture mem of memory is
	
		type state_type is
					(start, wait_cycle, idle);
					
		signal state_reg, state_next: state_type;
	
		component register_4 is
			port(
					clock    	: IN  STD_LOGIC;
					reset    	: IN  STD_LOGIC;
					write_enable: IN  STD_LOGIC;
					data_in		: IN  STD_LOGIC_VECTOR (3 DOWNTO 0);
					data_out	   : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
			);
			
		end component;
		
		component register_1 is
			port(
					clock    	: IN  STD_LOGIC;
					reset    	: IN  STD_LOGIC;
					write_enable: IN  STD_LOGIC;
					data_in		: IN  STD_LOGIC;
					data_out	   : OUT STD_LOGIC
			);
			
		end component;
		
	begin 
		
		port_reg: register_4 PORT MAP(
									clock => clk,
									reset => reset,
									write_enable => port_ready,
									data_in => port_in,
									data_out => port_out
									);
									
		priority_reg: register_1 PORT MAP(
									clock => clk,
									reset => reset,
									write_enable => priority_ready,
									data_in => priority_in,
									data_out => priority_out
									);
									
		process(clk,reset)
		
				begin
				
					if (reset='1') then state_reg <= idle;
					elsif (clk'event and clk='1') then state_reg <= state_next;
					end if;
	
		end process;
		
		process(state_reg, priority_ready)
			
			begin
				
				case state_reg is
					
					when idle =>
						
						if (priority_ready = '1') then state_next <= start;
						else state_next <= idle;
						end if;
						
					when start =>
						state_next <= wait_cycle;
					
					when wait_cycle =>
						state_next <= idle;
				end case;	
		end process;
		
		process(state_reg)
			
			begin
			
				case state_reg is
				
					when idle => 
						start_out <= '0';
						
					when start =>
						start_out <='1';
						
					when wait_cycle =>
						start_out <= '1';
			
				end case;
		end process;
		
									
	end mem;