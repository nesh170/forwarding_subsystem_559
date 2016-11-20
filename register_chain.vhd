library ieee;
library my_lib;
use ieee.std_logic_1164.all;
use my_lib.data_types.all;

entity register_chain is port(
	rc_clock: in std_logic;
	-- async reset
	rc_reset: in std_logic;
	rc_first_value: in std_logic_vector(51 downto 0);
	rc_write_enable: in std_logic_vector(31 downto 0);
	
	-- register chain output
	rc_reg_output: out reg_output_type
	);
end register_chain;

architecture register_chain_rtl of register_chain is
	-- internal signals go here
	signal current_reg_output: reg_output_type;
	
	component reg52 port(
		reg52_in: in std_logic_vector;
		reg52_clock: in std_logic;
		reg52_reset: in std_logic;
		reg52_write_enable: in std_logic;
		reg52_out: out std_logic_vector
		);
	end component;

	begin
	
	-- map first register		
	reg52_31_inst: reg52 port map(
		reg52_in => rc_first_value,
		reg52_clock => rc_clock,
		reg52_reset => rc_reset,
		reg52_write_enable => rc_write_enable(31),
		reg52_out => current_reg_output(31)
	);
	
	reg52_30_inst: reg52 port map(
		reg52_in => current_reg_output(31),
		reg52_clock => rc_clock,
		reg52_reset => rc_reset,
		reg52_write_enable => rc_write_enable(30),
		reg52_out => current_reg_output(30)
	);
	
	 reg52_29_inst: reg52 port map(
        reg52_in => current_reg_output(30),
        reg52_clock => rc_clock,
        reg52_reset => rc_reset,
        reg52_write_enable => rc_write_enable(29),
        reg52_out => current_reg_output(29)
    );

    reg52_28_inst: reg52 port map(
        reg52_in => current_reg_output(29),
        reg52_clock => rc_clock,
        reg52_reset => rc_reset,
        reg52_write_enable => rc_write_enable(28),
        reg52_out => current_reg_output(28)
    );

    reg52_27_inst: reg52 port map(
        reg52_in => current_reg_output(28),
        reg52_clock => rc_clock,
        reg52_reset => rc_reset,
        reg52_write_enable => rc_write_enable(27),
        reg52_out => current_reg_output(27)
    );

    reg52_26_inst: reg52 port map(
        reg52_in => current_reg_output(27),
        reg52_clock => rc_clock,
        reg52_reset => rc_reset,
        reg52_write_enable => rc_write_enable(26),
        reg52_out => current_reg_output(26)
    );

    reg52_25_inst: reg52 port map(
        reg52_in => current_reg_output(26),
        reg52_clock => rc_clock,
        reg52_reset => rc_reset,
        reg52_write_enable => rc_write_enable(25),
        reg52_out => current_reg_output(25)
    );

    reg52_24_inst: reg52 port map(
        reg52_in => current_reg_output(25),
        reg52_clock => rc_clock,
        reg52_reset => rc_reset,
        reg52_write_enable => rc_write_enable(24),
        reg52_out => current_reg_output(24)
    );

    reg52_23_inst: reg52 port map(
        reg52_in => current_reg_output(24),
        reg52_clock => rc_clock,
        reg52_reset => rc_reset,
        reg52_write_enable => rc_write_enable(23),
        reg52_out => current_reg_output(23)
    );

    reg52_22_inst: reg52 port map(
        reg52_in => current_reg_output(23),
        reg52_clock => rc_clock,
        reg52_reset => rc_reset,
        reg52_write_enable => rc_write_enable(22),
        reg52_out => current_reg_output(22)
    );

    reg52_21_inst: reg52 port map(
        reg52_in => current_reg_output(22),
        reg52_clock => rc_clock,
        reg52_reset => rc_reset,
        reg52_write_enable => rc_write_enable(21),
        reg52_out => current_reg_output(21)
    );

    reg52_20_inst: reg52 port map(
        reg52_in => current_reg_output(21),
        reg52_clock => rc_clock,
        reg52_reset => rc_reset,
        reg52_write_enable => rc_write_enable(20),
        reg52_out => current_reg_output(20)
    );

    reg52_19_inst: reg52 port map(
        reg52_in => current_reg_output(20),
        reg52_clock => rc_clock,
        reg52_reset => rc_reset,
        reg52_write_enable => rc_write_enable(19),
        reg52_out => current_reg_output(19)
    );

    reg52_18_inst: reg52 port map(
        reg52_in => current_reg_output(19),
        reg52_clock => rc_clock,
        reg52_reset => rc_reset,
        reg52_write_enable => rc_write_enable(18),
        reg52_out => current_reg_output(18)
    );

    reg52_17_inst: reg52 port map(
        reg52_in => current_reg_output(18),
        reg52_clock => rc_clock,
        reg52_reset => rc_reset,
        reg52_write_enable => rc_write_enable(17),
        reg52_out => current_reg_output(17)
    );

    reg52_16_inst: reg52 port map(
        reg52_in => current_reg_output(17),
        reg52_clock => rc_clock,
        reg52_reset => rc_reset,
        reg52_write_enable => rc_write_enable(16),
        reg52_out => current_reg_output(16)
    );

    reg52_15_inst: reg52 port map(
        reg52_in => current_reg_output(16),
        reg52_clock => rc_clock,
        reg52_reset => rc_reset,
        reg52_write_enable => rc_write_enable(15),
        reg52_out => current_reg_output(15)
    );

    reg52_14_inst: reg52 port map(
        reg52_in => current_reg_output(15),
        reg52_clock => rc_clock,
        reg52_reset => rc_reset,
        reg52_write_enable => rc_write_enable(14),
        reg52_out => current_reg_output(14)
    );

    reg52_13_inst: reg52 port map(
        reg52_in => current_reg_output(14),
        reg52_clock => rc_clock,
        reg52_reset => rc_reset,
        reg52_write_enable => rc_write_enable(13),
        reg52_out => current_reg_output(13)
    );

    reg52_12_inst: reg52 port map(
        reg52_in => current_reg_output(13),
        reg52_clock => rc_clock,
        reg52_reset => rc_reset,
        reg52_write_enable => rc_write_enable(12),
        reg52_out => current_reg_output(12)
    );

    reg52_11_inst: reg52 port map(
        reg52_in => current_reg_output(12),
        reg52_clock => rc_clock,
        reg52_reset => rc_reset,
        reg52_write_enable => rc_write_enable(11),
        reg52_out => current_reg_output(11)
    );

    reg52_10_inst: reg52 port map(
        reg52_in => current_reg_output(11),
        reg52_clock => rc_clock,
        reg52_reset => rc_reset,
        reg52_write_enable => rc_write_enable(10),
        reg52_out => current_reg_output(10)
    );

    reg52_9_inst: reg52 port map(
        reg52_in => current_reg_output(10),
        reg52_clock => rc_clock,
        reg52_reset => rc_reset,
        reg52_write_enable => rc_write_enable(9),
        reg52_out => current_reg_output(9)
    );

    reg52_8_inst: reg52 port map(
        reg52_in => current_reg_output(9),
        reg52_clock => rc_clock,
        reg52_reset => rc_reset,
        reg52_write_enable => rc_write_enable(8),
        reg52_out => current_reg_output(8)
    );

    reg52_7_inst: reg52 port map(
        reg52_in => current_reg_output(8),
        reg52_clock => rc_clock,
        reg52_reset => rc_reset,
        reg52_write_enable => rc_write_enable(7),
        reg52_out => current_reg_output(7)
    );

    reg52_6_inst: reg52 port map(
        reg52_in => current_reg_output(7),
        reg52_clock => rc_clock,
        reg52_reset => rc_reset,
        reg52_write_enable => rc_write_enable(6),
        reg52_out => current_reg_output(6)
    );

    reg52_5_inst: reg52 port map(
        reg52_in => current_reg_output(6),
        reg52_clock => rc_clock,
        reg52_reset => rc_reset,
        reg52_write_enable => rc_write_enable(5),
        reg52_out => current_reg_output(5)
    );

    reg52_4_inst: reg52 port map(
        reg52_in => current_reg_output(5),
        reg52_clock => rc_clock,
        reg52_reset => rc_reset,
        reg52_write_enable => rc_write_enable(4),
        reg52_out => current_reg_output(4)
    );

    reg52_3_inst: reg52 port map(
        reg52_in => current_reg_output(4),
        reg52_clock => rc_clock,
        reg52_reset => rc_reset,
        reg52_write_enable => rc_write_enable(3),
        reg52_out => current_reg_output(3)
    );

    reg52_2_inst: reg52 port map(
        reg52_in => current_reg_output(3),
        reg52_clock => rc_clock,
        reg52_reset => rc_reset,
        reg52_write_enable => rc_write_enable(2),
        reg52_out => current_reg_output(2)
    );

    reg52_1_inst: reg52 port map(
        reg52_in => current_reg_output(2),
        reg52_clock => rc_clock,
        reg52_reset => rc_reset,
        reg52_write_enable => rc_write_enable(1),
        reg52_out => current_reg_output(1)
    );

    reg52_0_inst: reg52 port map(
        reg52_in => current_reg_output(1),
        reg52_clock => rc_clock,
        reg52_reset => rc_reset,
        reg52_write_enable => rc_write_enable(0),
        reg52_out => current_reg_output(0)
    );

	
	process (current_reg_output)
	begin
		rc_reg_output <= current_reg_output;
	end process;
	
end register_chain_rtl;