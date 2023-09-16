LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.type_pkg.ALL;
ENTITY tb_two_d_mesh IS END tb_two_d_mesh;
	ARCHITECTURE test OF tb_two_d_mesh IS
		COMPONENT two_d_mesh IS
			GENERIC (
				n : NATURAL := 3;
				m : NATURAL := 3
			);
			PORT (
				rst : IN STD_LOGIC;
				clk : IN STD_LOGIC;
				mesh_init : IN a_t(1 TO n * m)
			);
		END COMPONENT;
		CONSTANT DECODER_WIDTH : INTEGER := 3;
		SIGNAL t_rst : std_logic;
		SIGNAL t_clk : std_logic := '0';
		SIGNAL t_a : a_t(1 TO DECODER_WIDTH * DECODER_WIDTH);
 
	BEGIN
		G1 : two_d_mesh
			GENERIC MAP(n => DECODER_WIDTH, m => DECODER_WIDTH)
		PORT MAP(t_rst, t_clk, t_a);
		t_rst <= '1', '0' AFTER 30 ns;
		t_clk <= NOT t_clk AFTER 60 ns;
		t_a <= (10, 11, 5, 3, 13, 2, 1, 12, 15);

END test;