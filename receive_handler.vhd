library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.all;

ENTITY receive_handler IS
	PORT (
	clock : IN STD_LOGIC;
	reset : IN STD_LOGIC;
	control_block_in : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
	control_block_out : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
	control_block_read : IN STD_LOGIC;
	control_block_write : IN STD_LOGIC;
	control_block_empty : OUT STD_LOGIC;
	frame_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	frame_read : IN STD_LOGIC;
	frame_write : IN STD_LOGIC;
	frame_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	frame_empty : OUT STD_LOGIC);
END receive_handler;

ARCHITECTURE recv_handler_arch OF receive_handler IS

BEGIN

control_block_queue : recv_control_block_queue PORT MAP (
		aclr		=> reset,	
		clock		=> clock,
		data		=> control_block_in,
		rdreq		=> control_block_read,
		wrreq		=> control_block_write,
		empty		=> control_block_empty,
		q			=> control_block_out);

frame_queue : recv_frame_queue PORT MAP (
		aclr		=> reset,	
		clock		=> clock,
		data		=> frame_in,
		rdreq		=> frame_read,
		wrreq		=> frame_write,
		empty		=> frame_empty,
		q			=> frame_out);

END recv_handler_arch;