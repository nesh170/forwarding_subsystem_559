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
		priority_bit : OUT STD_LOGIC;
		src_addr : OUT STD_LOGIC_VECTOR(47 DOWNTO 0);
		dest_addr : OUT STD_LOGIC_VECTOR(47 DOWNTO 0);
		extract_read_valid : OUT STD_LOGIC;
		priority_read_valid : OUT STD_LOGIC;
		discard_bit : OUT STD_LOGIC;
		counter : OUT integer range 0 to 19
);
end entity vlan;


architecture check of vlan IS

signal addr_count : integer range 0 to 19;
signal priority_count : integer range 0 to 21;
signal end_spot : integer range 0 to 167;
signal store_length :STD_LOGIC_VECTOR(11 DOWNTO 0);
signal queue : STD_LOGIC_VECTOR(175 DOWNTO 0);
signal vlan_value : STD_LOGIC_VECTOR(7 DOWNTO 0);
signal priority_bits :STD_LOGIC_VECTOR(2 DOWNTO 0);
signal buff_prior : STD_LOGIC;
signal buff_extract : STD_LOGIC;


begin
	process(frame_seg, ctrl_block, buffer_empty, clk)
	begin
			if(clk'event and clk = '1') then
				if(buffer_empty = '0') then
					if(priority_count = 0) then
						priority_bit <= '0';
						end_spot <= 167;
						priority_read_valid <= '0';
						extract_read_valid <= '0';
						store_length <= ctrl_block(23 DOWNTO 12);
						dest_addr <= (0 => '0', others => '0');
						src_addr <= (0 => '0', others => '0');
						buff_extract <= '0';
						buff_prior <= '0';

					end if;

					if(priority_count < 21) then
						queue(175 DOWNTO 168) <= frame_seg;
						end_spot <= end_spot - 8;
						if(addr_count < 19) then 
							addr_count <= addr_count + 1;
						else
							buff_extract <= '1';
						end if;
						priority_count <= priority_count + 1;	
					else
						priority_bits <= frame_seg(7 DOWNTO 5);
						buff_prior <= '1';
					end if;
				end if; 
				counter <= addr_count;
				if(buff_extract = '1') then
					extract_read_valid <= '1';
				end if;
				
				if(buff_prior = '1') then
					priority_read_valid <= '1';
				end if;
				
				dest_addr <= queue(111 DOWNTO 64);
				src_addr <= queue(63 DOWNTO 16);

--				
				if(queue(15 DOWNTO 0) = x"8100" ) then					
					if(priority_bits = "111") then
						if(store_length > "10000000") then
							priority_bit <= '0';
							discard_bit <= '1';
						else
							priority_bit <= '1';
						end if;
					else
						priority_bit <= '0';
					end if;
				else
					priority_bit <= '0';
				end if;
--				
				if(buffer_empty = '1') then
					addr_count <= 0;
					priority_count <= 0;
					priority_bit <= '0';
					end_spot <= 167;
					priority_read_valid <= '0';
					extract_read_valid <= '0';
					store_length <= ctrl_block(23 DOWNTO 12);
					dest_addr <= (0 => '0', others => '0');
					src_addr <= (0 => '0', others => '0');
					buff_extract <= '0';
					buff_prior <= '0';
				end if;
			end if;
	end process;

end check;