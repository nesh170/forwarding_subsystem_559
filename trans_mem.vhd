library ieee;
use ieee.std_logic_1164.all;

entity trans_mem is
		
		port (
				clk, reset, priority_in, port_ready, priority_ready, discard: in std_logic;
				frame_q_is_empty: in std_logic;
				frame_data_in: in std_logic_vector (7 downto 0);
				ctrl_block_in: in std_logic_vector (23 downto 0);
				port_in: in std_logic_vector (3 downto 0);

				priority_out, sig_complete, read_frame_q, read_ctrl_q: out std_logic;
				ctrl_block_we, frame_we: out std_logic_vector (3 downto 0);
				frame_data_out: out std_logic_vector (7 downto 0);
				ctrl_block_out: out std_logic_vector (23 downto 0)
				);
				
		end trans_mem;
		
		architecture t_mem of trans_mem is
		
			component memory is
			
				port (
					clk, reset, priority_in, port_ready, priority_ready: in std_logic;
					port_in: in std_logic_vector (3 downto 0);
					port_out: out std_logic_vector (3 downto 0);
					priority_out, start_out: out std_logic
					);
			
			end component;
			
			component transmit_handler is
			
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
					
				end component;
				
				signal port_between: std_logic_vector(3 downto 0);
				signal priority_between, start_between: std_logic;
				
			begin
				
				mem: memory PORT MAP(
					clk => clk,
					reset => reset,
					priority_in => priority_in,
					port_ready => port_ready,
					priority_ready => priority_ready,
					port_in => port_in,
					port_out => port_between,
					priority_out => priority_between,
					start_out => start_between
					);
					
				trans: transmit_handler PORT MAP(
					clock => clk,
					reset => reset,
					priority_in => priority_between,
					frame_q_is_empty => frame_q_is_empty,
					start => start_between,
					discard => discard,
					dest_port => port_between,
					frame_data_in => frame_data_in,
					ctrl_block_in => ctrl_block_in,
					priority_out => priority_out,
					sig_complete => sig_complete,
					read_frame_q => read_frame_q,
					read_ctrl_q => read_ctrl_q,
					ctrl_block_we => ctrl_block_we,
					frame_we => frame_we,
					frame_data_out => frame_data_out,
					ctrl_block_out => ctrl_block_out
					);
					
				end t_mem;
					
				
