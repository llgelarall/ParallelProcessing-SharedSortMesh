LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
PACKAGE type_pkg IS
	TYPE a_t IS ARRAY(NATURAL RANGE <>) OF INTEGER;
END PACKAGE type_pkg;

USE work.type_pkg.ALL;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY two_d_mesh IS
	GENERIC (
		n : NATURAL := 3;
		m : NATURAL := 3
	);
	PORT (
		rst : IN STD_LOGIC;
		clk : IN STD_LOGIC;
		mesh_init : IN a_t(1 TO n * m)
	);
END two_d_mesh;

ARCHITECTURE behavioral_2d_mesh OF two_d_mesh IS

	TYPE mesh_type IS ARRAY (1 TO n, 1 TO m) OF INTEGER;
	SIGNAL mesh : mesh_type;
	SIGNAL mesh_out : mesh_type := (OTHERS => (OTHERS => 0));
	TYPE mesh_connections_type IS ARRAY (1 TO m * n, 1 TO 4) OF INTEGER;
	SIGNAL connections : mesh_connections_type;
	SIGNAL done : STD_LOGIC := '0';

-- Function to calculate log2 .
	FUNCTION log2_unsigned (x : NATURAL) RETURN NATURAL IS
		VARIABLE temp : NATURAL := x;
		VARIABLE n : NATURAL := 0;

	BEGIN
		WHILE temp > 1 LOOP
			temp := temp / 2;
			n := n + 1;
		END LOOP; 
		RETURN n;
	END FUNCTION log2_unsigned;

BEGIN

-- Initialize mesh as a matrix and connections.

	init : PROCESS (clk, rst)
	BEGIN
		IF rst = '0' THEN
			IF clk = '1' THEN
				done <= '0';
				-- Initialize mesh .
				LOOP_Init_Mesh : FOR i IN 1 TO n LOOP
					LOOP_ADD2 : FOR j IN 1 TO m LOOP
						mesh(i, j) <= mesh_init(((i - 1) * m) + j);
					END LOOP;
				END LOOP;
				-- Initielize connections , each nodes connestions are in its index.
				FOR i IN 1 TO n LOOP
					FOR j IN 1 TO m LOOP
						connections((i - 1) * m + j, 1) <= (i - 1) * m + j - m;
						connections((i - 1) * m + j, 2) <= (i - 1) * m + j + m;
						connections((i - 1) * m + j, 3) <= (i - 1) * m + j - 1;
						connections((i - 1) * m + j, 4) <= (i - 1) * m + j + 1;
						CASE i IS
							WHEN 1 => 
								connections((i - 1) * m + j, 1) <= ((n - 1) * m) + i * j;
							WHEN n => 
								connections((i - 1) * m + j, 2) <= j;
							WHEN OTHERS => NULL;
						END CASE;

						CASE j IS
							WHEN 1 => 
								connections((i - 1) * m + j, 3) <= (i) * m;
							WHEN m => 
								connections((i - 1) * m + j, 4) <= (i - 1) * m + 1;
							WHEN OTHERS => NULL;
						END CASE;

					END LOOP;
				END LOOP;
				done <= '1';
			END IF;
		ELSE
			mesh <= (OTHERS => (OTHERS => 0));
			connections <= (OTHERS => (OTHERS => 0));
			done <= '0';
 
		END IF;
	END PROCESS;

-- Shear sort.
	P1 : PROCESS (done)
		VARIABLE y : STD_LOGIC := '1';
		VARIABLE temp : NATURAL;
		VARIABLE log : INTEGER;
		VARIABLE ftemp : INTEGER;
		VARIABLE stemp : INTEGER;
		VARIABLE mesh_var : mesh_type;
	BEGIN
		IF rst = '0' THEN
		-- After finish initialization.
			IF done = '1' THEN
				mesh_var := mesh;
				log := log2_unsigned(n) + 1;
				-- "Snakelike sort" and "Column sort" are repeated in log2 and for sorting, we used the bubble sort technique.
				FOR d IN 1 TO log LOOP
					FOR s IN 1 TO n LOOP
						-- Snakelike is implied for every row, even rows are sorted in ltr and odd rows are sorted in rtl.
						IF y = '1' THEN --even row
							FOR i IN 0 TO m - 1 LOOP
								FOR j IN 1 TO m - i - 1 LOOP
									stemp := mesh_var(s, j + 1);
									ftemp := mesh_var(s, j);
									IF (mesh_var(s, j) > mesh_var(s, j + 1)) THEN
										temp := mesh_var(s, j + 1);
										mesh_var(s, j + 1) := mesh_var(s, j);
										mesh_var(s, j) := temp;
									END IF;
								END LOOP;
							END LOOP;
						ELSE -- Odd row
							FOR i IN 0 TO m - 1 LOOP
								FOR j IN 1 TO m - i - 1 LOOP
									stemp := mesh_var(s, j + 1);
									ftemp := mesh_var(s, j);
									IF (mesh_var(s, j) < mesh_var(s, j + 1)) THEN
										temp := mesh_var(s, j + 1);
										mesh_var(s, j + 1) := mesh_var(s, j);
										mesh_var(s, j) := temp;
									END IF;
								END LOOP;
							END LOOP;
						END IF;
						y := NOT y; -- Change from rtl to ltr and versa versa.
					END LOOP;
					-- Coloumn Sort is implied for every coloumn.
					FOR c IN 1 TO m LOOP
						FOR i IN 0 TO n - 1 LOOP
							FOR j IN 1 TO n - i - 1 LOOP
								IF (mesh_var(j, c) > mesh_var(j + 1, c)) THEN
									stemp := mesh_var(j + 1, c);
									ftemp := mesh_var(j, c);
									temp := mesh_var(j + 1, c);
									mesh_var(j + 1, c) := mesh_var(j, c);
									mesh_var(j, c) := temp;
								END IF;
							END LOOP;
						END LOOP;
					END LOOP;
					
				END LOOP;-- End of log2 iterations.

				-- Last Snake like sort 
				y := '1';
				FOR s IN 1 TO m LOOP
					IF y = '1' THEN
						FOR i IN 0 TO m - 1 LOOP
							FOR j IN 1 TO m - i - 1 LOOP
								IF (mesh_var(s, j) > mesh_var(s, j + 1)) THEN
									stemp := mesh_var(s, j + 1);
									ftemp := mesh_var(s, j);
									temp := mesh_var(s, j + 1);
									mesh_var(s, j + 1) := mesh_var(s, j);
									mesh_var(s, j) := temp;
								END IF;
							END LOOP;
						END LOOP;
					ELSE
						FOR i IN 0 DOWNTO m - 1 LOOP
							FOR j IN m - i - 1 DOWNTO 1 LOOP
								IF (mesh_var(s, j) > mesh_var(s, j - 1)) THEN
									stemp := mesh_var(s, j + 1);
									ftemp := mesh_var(s, j);
									temp := mesh_var(s, j - 1);
									mesh_var(s, j - 1) := mesh_var(s, j);
									mesh_var(s, j) := temp;
								END IF;
							END LOOP;
						END LOOP;
					END IF;
					y := NOT y;
				END LOOP;
				
				-- End of Shear sort in mesh.
			ELSE
				NULL;
			END IF;
			mesh_out <= mesh_var;
		ELSE
			mesh_out <= (OTHERS => (OTHERS => 0));
			mesh_var := (OTHERS => (OTHERS => 0));
			log := 0;
		END IF;
	END PROCESS P1;

END behavioral_2d_mesh;