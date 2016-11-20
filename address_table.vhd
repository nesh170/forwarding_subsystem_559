library ieee;
library my_lib;
use ieee.std_logic_1164.all;
use my_lib.data_types.all;

entity address_table is port(
	-- 50 MHz clock
	clock: in std_logic;
	-- asynchronous clear
	reset: in std_logic;		
	
	-- 48-bit source MAC address
	source_address: in std_logic_vector(47 downto 0);
	-- one-hot encoded source port (0-3)
	source_port: in std_logic_vector(3 downto 0);
	-- 48-bit destination MAC address 
	destination_address: in std_logic_vector(47 downto 0);
	-- trigger for table to latch input values
	trigger: in std_logic;
	
	-- one-hot encoded destination port (0-3)
	-- only valid upon pos edge of output_ready
	destination_port: out std_logic_vector(3 downto 0);
	-- signal showing output is valid (single clock cycle)
	output_ready: out std_logic;
	-- signal showing trigger can be pulled
	input_ready: out std_logic;
	
	-- signal showing port not found for an address 
	-- guaranteed active for single cycle only
	monitor_not_found: out std_logic;
	-- signal showing access (read and write)
	-- guaranteed active for single cycle only
	monitor_access: out std_logic
	);

end address_table;

architecture address_table_rtl of address_table is	
	-- 48-bit bus that contains latched SA
	signal latched_source_address: std_logic_vector(47 downto 0);
	-- 4-bit bus that contains latched SP
	signal latched_source_port: std_logic_vector(3 downto 0);
	-- 48-bit bus that contains latched DA
	signal latched_destination_address: std_logic_vector(47 downto 0);
	
	-- 48-bit bus that contains double-latched SA
	signal double_latched_source_address: std_logic_vector(47 downto 0);
	-- 4-bit bus that contains double-latched SP
	signal double_latched_source_port: std_logic_vector(3 downto 0);

	
	-- 32-bit bus for calculated register write-enable
	signal calculated_write_enable: std_logic_vector(31 downto 0);
	-- 32-bit bus for register write-enable
	signal write_enable: std_logic_vector(31 downto 0);
	-- 32 52-bit bus for register output
	signal reg_output: reg_output_type;
	
	
	-- 48-bit bus for compare module to compare to (either SA or DA)
	signal address_to_compare: std_logic_vector(47 downto 0);
	-- 32-bit bus for comparison with SA/DA (1 == same)
	signal compare_result: std_logic_vector(31 downto 0);
	
	-- 52-bit bus for value to be stored into first register
	signal first_value: std_logic_vector(51 downto 0);
	-- 52-bit bus for value found in registers
	signal compute_output: std_logic_vector(51 downto 0);
	
	-- 1-bit not found output from compare
	signal not_found: std_logic;
	
	-- current state defined in data_types
	signal state_reg: state_type;
	
	-- register_chain module
	--
	-- Takes clock, reset, write_enable, first_value
	-- Emits reg_output
	component register_chain port(
		rc_clock: in std_logic;
		rc_reset: in std_logic;
		rc_first_value: in std_logic_vector(51 downto 0);
		rc_write_enable: in std_logic_vector(31 downto 0);
		rc_reg_output: out reg_output_type
		);
	end component;
	
	
	-- comparison module
	--
	-- Takes address to compare, reg_output 
	-- Emits comparison_result
	component compare port(
		cmp_address_to_compare: in std_logic_vector(47 downto 0);
		cmp_reg_output_address: in reg_output_type;
		cmp_compare_result: out std_logic_vector(31 downto 0)
		);
	end component;
	
	
	-- compute module
	--
	-- Takes reg_output, comparison_result, FSM state, SA/DA [for first_value]
	-- Emits write_enable, first_value, destination_port
	component compute port(
		cpt_state: in state_type;
		cpt_reg_output_address: in reg_output_type;
		cpt_compare_result: in std_logic_vector(31 downto 0);
		cpt_first_value: out std_logic_vector(51 downto 0);
		cpt_write_enable: out std_logic_vector(31 downto 0)
		);
	end component;
	
	-- fsm module
	--
	-- Takes clock, reset, trigger
	-- Emits output_ready, input_ready, state
	component fsm port(
		fsm_clock: in std_logic;
		fsm_reset: in std_logic;
		fsm_trigger: in std_logic;
		fsm_compute_output: in std_logic_vector(3 downto 0);
		fsm_not_found: in std_logic;
		fsm_state: out state_type;
		fsm_input_ready: out std_logic;
		fsm_output_ready: out std_logic;
		fsm_destination_port: out std_logic_vector(3 downto 0)
		);
	end component;
	
	begin 
		-- register_chain port mapping
		register_chain_inst: register_chain port map(
			rc_clock => clock,
			rc_reset => reset,
			rc_first_value => first_value,
			rc_write_enable => write_enable,
			rc_reg_output => reg_output
		);
		
		-- compare port mapping
		compare_inst: compare port map(
			cmp_address_to_compare => address_to_compare,
			cmp_reg_output_address => reg_output,
			cmp_compare_result => compare_result
		);
		
		-- compute port mapping
		compute_inst: compute port map(
			cpt_state => state_reg,
			cpt_reg_output_address => reg_output,
			cpt_compare_result => compare_result,
			cpt_first_value => compute_output,
			cpt_write_enable => calculated_write_enable
		);
		
		-- fsm port mapping
		fsm_inst: fsm port map(
			fsm_clock => clock,
			fsm_reset => reset,
			fsm_trigger => trigger,
			fsm_state => state_reg,
			fsm_input_ready => input_ready,
			fsm_output_ready => output_ready,
			fsm_compute_output => compute_output(3 downto 0),
			fsm_not_found => not_found,
			fsm_destination_port => destination_port
		);

	
	-- upon changing state, 
	-- first_value changes
	process (state_reg, compute_output, latched_destination_address, not_found, 
		double_latched_source_address, double_latched_source_port, calculated_write_enable)
	begin
		case state_reg is
			when reset_state => 
				-- any value
				first_value <= (51 downto 0 => '0');
				-- any value
				address_to_compare <= (47 downto 0 => '0');
				monitor_not_found <= '0';
				monitor_access <= '0';
				write_enable <= (31 downto 0 => '0');
			when read_state =>
				-- compute_output
				first_value <= compute_output;
				-- compare destination address
				address_to_compare <= latched_destination_address;
				monitor_not_found <= not_found;
				monitor_access <= '1';
				write_enable <= calculated_write_enable;
			when write_state =>
				first_value <= double_latched_source_address & double_latched_source_port;
				-- compare source address
				address_to_compare <= double_latched_source_address;
				monitor_not_found <= '0';
				monitor_access <= '0';
				write_enable <= '1' & calculated_write_enable(30 downto 0);
		end case;
	end process;
	
	-- latch inputs
	process (clock, reset, source_address, source_port, destination_address)
	begin
		if (reset = '1') then
			latched_source_address <= (47 downto 0 => '0');
			latched_source_port <= (3 downto 0 => '0');
			latched_destination_address <= (47 downto 0 => '0');
		elsif (clock'event and clock = '1') then
			latched_source_address <= source_address;
			latched_source_port <= source_port;
			latched_destination_address <= destination_address;
		end if;
	end process;
	
	-- double latch inputs
	process (clock, reset, latched_source_address, latched_source_port) 
	begin
		if (reset = '1') then
			double_latched_source_address <= (47 downto 0 => '0');
			double_latched_source_port <= (3 downto 0 => '0');
		elsif (clock'event and clock ='1') then
			double_latched_source_address <= latched_source_address;
			double_latched_source_port <= latched_source_port;
		end if;
	end process;
	
	-- determine whether comparison output = 0
	process (compare_result)
	begin
		if (compare_result = (31 downto 0 => '0')) then
			not_found <= '1';
		else
			not_found <= '0';
		end if;
	end process;
	
end address_table_rtl;