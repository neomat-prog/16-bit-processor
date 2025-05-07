library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity rejestry_top is
port (
	hex_disp		: OUT std_logic_vector(0 to 6);
	hex_disp_1	: OUT std_logic_vector(0 to 6);
	hex_disp_2	: OUT std_logic_vector(0 to 6);
	hex_disp_3	: OUT std_logic_vector(0 to 6);
	hex_disp_4	: OUT std_logic_vector(0 to 6);
	hex_disp_5	: OUT std_logic_vector(0 to 6);
	sw_in			: IN 	std_logic_vector(7 downto 0);
	led_out		: OUT std_logic_vector(9 downto 0);
	sw_hard		: IN  std_logic_vector(1 downto 0);
	clk			: IN  std_logic
);
end entity;


architecture rtl of rejestry_top is
	signal hex_to_disp   : std_logic_vector(3 downto 0);
	signal hex_to_disp_1 : std_logic_vector(3 downto 0);
	signal hex_to_disp_2 : std_logic_vector(3 downto 0);
	signal hex_to_disp_3 : std_logic_vector(3 downto 0);
	signal hex_to_disp_4 : std_logic_vector(3 downto 0);
	signal hex_to_disp_5 : std_logic_vector(3 downto 0);


	signal DI    : signed (15 downto 0);
	signal BA    : signed (15 downto 0);
	signal Sbb   : signed (4 downto 0);
	signal Sbc   : signed (4 downto 0);
	signal Sba   : signed (4 downto 0);
	signal Sid   : signed (2 downto 0);
	signal Sa 	 : signed (1 downto 0);
	signal BB    : signed (15 downto 0);
	signal BC    : signed (15 downto 0);
	signal ADR   : signed (31 downto 0);
	signal IRout : signed (15 downto 0);

begin
	--Salu <= to_bitvector(sw_in);
	
	SA <= signed(sw_in(7 downto 6));
	Sid <= signed(sw_in(5 downto 3));
	Sbc <= "10" & signed(sw_in(2 downto 0));
	
	led_out <= std_logic_vector(BC(9 downto 0));
	
	ent_alu: entity work.rejestry(rtl)
		port map (
			clk => clk,
			DI => DI,
			BA => BA, --
			Sbb => Sbb,
			Sbc => Sbc,
			Sba => Sba,
			Sid => Sid,
			Sa => Sa,
			BB => BB,
			BC => BC,
			ADR => ADR,
			IRout => IRout
	);
	
	process(sw_hard)
	begin
		case sw_hard is
			when "00" => 
				BA <= x"0000";
			when "01" => 
				BA <= x"5555";
			when "10" => 
				BA <= x"AAAA";
			when "11" => 
				BA <= x"FFFF";			
		end case;
	end process;
	
	
	hex_to_disp <= std_logic_vector(BA(3 downto 0));
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

	hex_to_disp_1 <= std_logic_vector(Sba(3 downto 0));
	process(hex_to_disp_1)
	begin
		case hex_to_disp_1 is
			when "0000" => hex_disp_1 <= "0000001";     
			when "0001" => hex_disp_1 <= "1001111"; 
			when "0010" => hex_disp_1 <= "0010010"; 
			when "0011" => hex_disp_1 <= "0000110"; 
			when "0100" => hex_disp_1 <= "1001100"; 
			when "0101" => hex_disp_1 <= "0100100"; 
			when "0110" => hex_disp_1 <= "0100000"; 
			when "0111" => hex_disp_1 <= "0001111"; 
			when "1000" => hex_disp_1 <= "0000000";     
			when "1001" => hex_disp_1 <= "0000100";
			when "1010" => hex_disp_1 <= "0001000"; 
			when "1011" => hex_disp_1 <= "1100000"; 
			when "1100" => hex_disp_1 <= "0110001"; 
			when "1101" => hex_disp_1 <= "1000010"; 
			when "1110" => hex_disp_1 <= "0110000"; 
			when "1111" => hex_disp_1 <= "0111000"; 
		end case;
	end process;

	hex_to_disp_2 <= std_logic_vector(Sbb(3 downto 0));
	process(hex_to_disp_2)
	begin
		case hex_to_disp_2 is
			when "0000" => hex_disp_2 <= "0000001";     
			when "0001" => hex_disp_2 <= "1001111"; 
			when "0010" => hex_disp_2 <= "0010010"; 
			when "0011" => hex_disp_2 <= "0000110"; 
			when "0100" => hex_disp_2 <= "1001100"; 
			when "0101" => hex_disp_2 <= "0100100"; 
			when "0110" => hex_disp_2 <= "0100000"; 
			when "0111" => hex_disp_2 <= "0001111"; 
			when "1000" => hex_disp_2 <= "0000000";     
			when "1001" => hex_disp_2 <= "0000100";
			when "1010" => hex_disp_2 <= "0001000"; 
			when "1011" => hex_disp_2 <= "1100000"; 
			when "1100" => hex_disp_2 <= "0110001"; 
			when "1101" => hex_disp_2 <= "1000010"; 
			when "1110" => hex_disp_2 <= "0110000"; 
			when "1111" => hex_disp_2 <= "0111000"; 
		end case;
	end process;
	
	hex_to_disp_3 <= std_logic_vector(Sbc(3 downto 0));
	process(hex_to_disp_3)
	begin
		case hex_to_disp_3 is
			when "0000" => hex_disp_3 <= "0000001";     
			when "0001" => hex_disp_3 <= "1001111"; 
			when "0010" => hex_disp_3 <= "0010010"; 
			when "0011" => hex_disp_3 <= "0000110"; 
			when "0100" => hex_disp_3 <= "1001100"; 
			when "0101" => hex_disp_3 <= "0100100"; 
			when "0110" => hex_disp_3 <= "0100000"; 
			when "0111" => hex_disp_3 <= "0001111"; 
			when "1000" => hex_disp_3 <= "0000000";     
			when "1001" => hex_disp_3 <= "0000100";
			when "1010" => hex_disp_3 <= "0001000"; 
			when "1011" => hex_disp_3 <= "1100000"; 
			when "1100" => hex_disp_3 <= "0110001"; 
			when "1101" => hex_disp_3 <= "1000010"; 
			when "1110" => hex_disp_3 <= "0110000"; 
			when "1111" => hex_disp_3 <= "0111000"; 
		end case;
	end process;
	
	
	hex_to_disp_4 <= std_logic_vector('0' & Sid);
	process(hex_to_disp_4)
	begin
		case hex_to_disp_4 is
			when "0000" => hex_disp_4 <= "0000001";     
			when "0001" => hex_disp_4 <= "1001111"; 
			when "0010" => hex_disp_4 <= "0010010"; 
			when "0011" => hex_disp_4 <= "0000110"; 
			when "0100" => hex_disp_4 <= "1001100"; 
			when "0101" => hex_disp_4 <= "0100100"; 
			when "0110" => hex_disp_4 <= "0100000"; 
			when "0111" => hex_disp_4 <= "0001111"; 
			when "1000" => hex_disp_4 <= "0000000";     
			when "1001" => hex_disp_4 <= "0000100";
			when "1010" => hex_disp_4 <= "0001000"; 
			when "1011" => hex_disp_4 <= "1100000"; 
			when "1100" => hex_disp_4 <= "0110001"; 
			when "1101" => hex_disp_4 <= "1000010"; 
			when "1110" => hex_disp_4 <= "0110000"; 
			when "1111" => hex_disp_4 <= "0111000"; 
		end case;
	end process;
	
	
	hex_to_disp_5 <= "00"&std_logic_vector(Sa);
	process(hex_to_disp_5)
	begin
		case hex_to_disp_5 is
			when "0000" => hex_disp_5 <= "0000001";     
			when "0001" => hex_disp_5 <= "1001111"; 
			when "0010" => hex_disp_5 <= "0010010"; 
			when "0011" => hex_disp_5 <= "0000110"; 
			when "0100" => hex_disp_5 <= "1001100"; 
			when "0101" => hex_disp_5 <= "0100100"; 
			when "0110" => hex_disp_5 <= "0100000"; 
			when "0111" => hex_disp_5 <= "0001111"; 
			when "1000" => hex_disp_5 <= "0000000";     
			when "1001" => hex_disp_5 <= "0000100";
			when "1010" => hex_disp_5 <= "0001000"; 
			when "1011" => hex_disp_5 <= "1100000"; 
			when "1100" => hex_disp_5 <= "0110001"; 
			when "1101" => hex_disp_5 <= "1000010"; 
			when "1110" => hex_disp_5 <= "0110000"; 
			when "1111" => hex_disp_5 <= "0111000"; 
		end case;
	end process;
end rtl;
