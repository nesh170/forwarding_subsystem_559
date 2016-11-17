library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.all;

entity vlan is
port(
		frame_seg : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		ctrl_block : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
		buffer_empty : IN STD_LOGIC;
		clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		table_rdy : IN STD_LOGIC;
		read_enable: OUT STD_LOGIC;
		priority_bit : OUT STD_LOGIC;
		tagged_bit : OUT STD_LOGIC;
		discard_bit : OUT STD_LOGIC;
		src_addr : OUT STD_LOGIC_VECTOR(47 DOWNTO 0);
		dest_addr : OUT STD_LOGIC_VECTOR(47 DOWNTO 0);
		extract_read_valid : OUT STD_LOGIC;
		priority_read_valid : OUT STD_LOGIC;
		frame_read_valid : OUT STD_LOGIC;
		--counter_one : OUT integer range 0 to 11;
		--counter_two : OUT integer range 0 to 15;
		--test_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		frame_id : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
);
end entity vlan;


architecture check of vlan IS

signal addr_count : integer range 0 to 11;
signal priority_count : integer range 0 to 15;
signal end_spot : integer range 0 to 119;
signal store_length :STD_LOGIC_VECTOR(11 DOWNTO 0);
signal queue : STD_LOGIC_VECTOR(127 DOWNTO 0);
signal vlan_value : STD_LOGIC_VECTOR(7 DOWNTO 0);
signal priority_bits :STD_LOGIC_VECTOR(2 DOWNTO 0);
signal buff_prior : STD_LOGIC;
signal buff_extract : STD_LOGIC;


begin
	process(frame_seg, ctrl_block, buffer_empty, clk, reset)
	begin
			if(clk'event and clk = '1') then
			
				if(buffer_empty = '0') then -- segments are in buffer
				
					if(priority_count = 0) then -- get length and frame id, set everything else to zero on first cycle
						tagged_bit <= '0';
						priority_bit <= '0';
						discard_bit <= '0';
						end_spot <= 111;
						priority_read_valid <= '0';
						extract_read_valid <= '0';
						frame_read_valid <= '1';
						store_length <= ctrl_block(11 DOWNTO 0);
						frame_id <= ctrl_block(23 DOWNTO 12);
						dest_addr <= (0 => '0', others => '0');
						src_addr <= (0 => '0', others => '0');
						buff_extract <= '0';
						buff_prior <= '0';
						read_enable <= '1';
					end if;
					
					if(priority_count = 0) then
						queue(127 DOWNTO 120) <= frame_seg;
					elsif(priority_count = 1) then
						queue(119 DOWNTO 112) <= frame_seg;
					elsif(priority_count = 2) then
						queue(111 DOWNTO 104) <= frame_seg;
					elsif(priority_count = 3) then
						queue(103 DOWNTO 96) <= frame_seg;
					elsif(priority_count = 4) then
						queue(95 DOWNTO 88) <= frame_seg;
					elsif(priority_count = 5) then
						queue(87 DOWNTO 80) <= frame_seg;
					elsif(priority_count = 6) then
						queue(79 DOWNTO 72) <= frame_seg;
					elsif(priority_count = 7) then
						queue(71 DOWNTO 64) <= frame_seg;
					elsif(priority_count = 8) then
						queue(63 DOWNTO 56) <= frame_seg;
					elsif(priority_count = 9) then
						queue(55 DOWNTO 48) <= frame_seg;
					elsif(priority_count = 10) then
						queue(47 DOWNTO 40) <= frame_seg;
					elsif(priority_count = 11) then
						queue(39 DOWNTO 32) <= frame_seg;
					elsif(priority_count = 12) then
						queue(31 DOWNTO 24) <= frame_seg;
					elsif(priority_count = 13) then
						queue(23 DOWNTO 16) <= frame_seg;
					elsif(priority_count = 14) then
						queue(15 DOWNTO 8) <= frame_seg;
					elsif(priority_count = 15) then
						queue(7 DOWNTO 0) <= frame_seg;
					end if;
					
					if(priority_count < 15) then  -- this will happen on the first cycle as well, increase counter
						--queue(127 DOWNTO 120) <= frame_seg;  -- store frame
						--end_spot <= end_spot - 8;  -- move spot
						
						if(addr_count < 11) then -- increase counter
							addr_count <= addr_count + 1;
						else							 -- do not increase counter, set buffer addr look now bit
							buff_extract <= '1';
						end if;
						
						if(priority_count = 14) then	-- store priority bits, set buffer priority look now bit
					--		priority_bits <= frame_seg(7 DOWNTO 5);
							buff_prior <= '1';
						end if;
						priority_count <= priority_count + 1;
					end if;
					
				end if; 
				
				--counter_one <= addr_count;	-- testing purposes
				--counter_two <= priority_count;  -- testing purposes
				
				if(buff_extract = '1' and table_rdy = '1') then -- set actual look now addr bit
					extract_read_valid <= '1';
				end if;
				
				if(buff_prior = '1') then  -- set actual look now priority bit
					priority_read_valid <= '1';
				end if;
				
				dest_addr <= queue(127 DOWNTO 80);
				src_addr <= queue(79 DOWNTO 32);
				--test_out <= queue(15 DOWNTO 0);
--				
				if(queue(31 DOWNTO 16) = "1000000100000000" ) then	-- set tagged bit
					tagged_bit <= '1';
					if(queue(15 DOWNTO 13) = "111") then  -- set priority bit
						priority_bit <= '1';
						if(store_length > "10000000") then  -- set discard bit
							discard_bit <= '1';
						end if;
					else  -- set priority bit low
						priority_bit <= '0';
					end if;
				else  -- set tagged and priority bit low
					tagged_bit <= '0';
					priority_bit <= '0';
				end if;
--				
				if(buffer_empty = '1' or reset = '1') then  -- buffer is empty, reset everything
					frame_read_valid <= '0';
					discard_bit <= '0';
					addr_count <= 0;
					priority_count <= 0;
					priority_bit <= '0';
					end_spot <= 119;
					priority_read_valid <= '0';
					extract_read_valid <= '0';
					store_length <= (0 => '0', others => '0');
					dest_addr <= (0 => '0', others => '0');
					src_addr <= (0 => '0', others => '0');
					queue <= (0 => '0', others => '0');
					buff_extract <= '0';
					buff_prior <= '0';
					tagged_bit <= '0';
					read_enable <= '0';
				end if;
			end if;
	end process;

end check;