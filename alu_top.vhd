library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity alu_top is
port (
	hex_disp		: OUT std_logic_vector(0 to 6);
	sw_in			: IN 	std_logic_vector(4 downto 0);
	led_out		: OUT std_logic_vector(4 downto 0);
	led_czsp		: OUT std_logic_vector(4 downto 0);
	sw_hard		: IN  std_logic_vector(1 downto 0);
	clk			: IN  std_logic
);
end entity;


architecture rtl of alu_top is
	signal hex_to_disp : std_logic_vector(3 downto 0);

	signal A 		: signed(15 downto 0);
	signal B 		: signed(15 downto 0);
	signal Salu 	: bit_vector (4 downto 0);
	signal LDF 		: bit;
	signal Y 		: signed (15 downto 0);
	signal C,Z,S,P : std_logic;
	
begin
	Salu <= to_bitvector(sw_in);
	led_out <= sw_in;
	ent_alu: entity work.alu(rtl)
		port map (
			A => A,
			B => B,
			Salu => Salu, --
			LDF => '1',
			clk => to_bit(clk),
			Y => Y,
			C => C,
			Z => Z,
			S => S,
			P => P
	);


	hex_to_disp <= std_logic_vector(Y(3 downto 0));
	process(hex_to_disp)
	begin
		case hex_to_disp is
			when "0000" => hex_disp <= "0000001";     
			when "0001" => hex_disp <= "1001111"; 
			when "0010" => hex_disp <= "0010010"; 
			when "0011" => hex_disp <= "0000110"; 
			when "0100" => hex_disp <= "1001100"; 
			when "0101" => hex_disp <= "0100100"; 
			when "0110" => hex_disp <= "0100000"; 
			when "0111" => hex_disp <= "0001111"; 
			when "1000" => hex_disp <= "0000000";     
			when "1001" => hex_disp <= "0000100";
			when "1010" => hex_disp <= "0001000"; 
			when "1011" => hex_disp <= "1100000"; 
			when "1100" => hex_disp <= "0110001"; 
			when "1101" => hex_disp <= "1000010"; 
			when "1110" => hex_disp <= "0110000"; 
			when "1111" => hex_disp <= "0111000"; 
		end case;
	end process;
	
	process(sw_hard)
	begin
		case sw_hard is
			when "00" => 
				A <= x"0000";
				B <= x"0000";
			when "01" => 
				A <= x"5555";
				B <= x"5555";
			when "10" => 
				A <= x"AAAA";
				B <= x"AAAA";
			when "11" => 
				A <= x"FFFF";
				B <= x"FFFF";				
		end case;
	end process;
	
	led_czsp <= clk&C&Z&S&P;
	
end rtl;
