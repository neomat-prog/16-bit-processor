library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity ALU is
port (
      A : in signed(15 downto 0);
      B : in signed(15 downto 0);
		T1, T2 : in bit;
      Salu : in bit_vector (4 downto 0);
		Salu_out : out bit_vector (4 downto 0);
		Hex : out bit_vector (27 downto 0);
      LDF : out std_logic;
      clk : in bit;
      Y : out signed (15 downto 0);
      C,Z,S : out std_logic
		);
end entity;
 
architecture rtl of ALU is

function to_7segment(input : signed(3 downto 0)) return BIT_VECTOR is
        variable segments : BIT_VECTOR(6 downto 0);
    begin
        case input is
            when "0000" => segments := "1000000";  
            when "0001" => segments := "1111001";  
            when "0010" => segments := "0100100"; 
            when "0011" => segments := "0110000";  
            when "0100" => segments := "0011001"; 
            when "0101" => segments := "0010010"; 
            when "0110" => segments := "0000010";  
            when "0111" => segments := "1111000";  
            when "1000" => segments := "0000000";  
            when "1001" => segments := "0010000"; 
            when "1010" => segments := "0001000";  
            when "1011" => segments := "0000011";  
            when "1100" => segments := "1000110"; 
            when "1101" => segments := "0100001";  
            when "1110" => segments := "0000110";  
            when "1111" => segments := "0001110";  
            when others => segments := "1111111";  
        end case;
        return segments;
    end function;

begin
  process (Salu, A, B, clk)
       variable res, AA, BB,CC: signed (16 downto 0);
       variable A1, A2,B1, B2: signed (16 downto 0);
       variable CF,ZF,SF : std_logic;
		 
       begin
			A1 := "00000000000000001";
			A2 := "01111101111100111";
			B1 := "00000000000101001";
			B2 := "01111111111111111";
			if (T1='1') then 
				AA := A1;
				else
				AA := A2;
			end if;
			if (T2='1') then
				BB := B1;
				else
				BB := B2;
			end if;
			
         --AA(16) := A(15);
         --AA(15 downto 0) := A;
         --BB(16) := B(15);
         --BB(15 downto 0) := B;
			
         CC(0) := CF;
         CC(16 downto 1) := "0000000000000000";
			
         case Salu is
             when "00000" => res := AA; 
             when "00001" => res := BB;
             when "00010" => res := AA + BB;
             when "00011" => res := AA - BB;
             when "00100" => res := AA or BB;
             when "00101" => res := AA and BB;
             when "00110" => res := AA xor BB;
             when "00111" => res := AA xnor BB;
             when "01000" => res := not AA;
             when "01001" => res := -AA;
             when "01010" => res := "00000000000000000";
             when "01011" => res := AA + BB + CC;
             when "01100" => res := AA - BB - CC;
             when "01101" => res := AA + 1;
             when "01110" => res := AA sll 1;
				 when "01111" => res := AA srl 1;
				 when "10000" => res := (AA NAND BB);
				 when "10001" => res := AA - 1;
				 when "11010" => res := BB mod AA;
				 when "10011" => res := BB - 1; 
				 when "10101" => res := BB; 
				 when "11000" => res := ROTATE_LEFT(BB,1);  
				 when "11011" => 
					  if AA < BB then
							res := (OTHERS => '1'); 
					  else
							res := (OTHERS => '0'); 
					  end if;
             when others => res(16) := AA(16);
             res(15 downto 0) := AA(16 downto 1);
         end case;
         Y <= res(15 downto 0);
         C <= CF; --carry zakres
         S <= SF; --sign zmiana znaku
         Z <= ZF; -- zero jesli w wyniku jest zero
			
			Salu_out <= Salu;
			Hex(27 downto 21)<= to_7segment(res(15 downto 12));
			Hex(20 downto 14)<= to_7segment(res(11 downto 8));
			Hex(13 downto 7)<= to_7segment(res(7 downto 4));
			Hex(6 downto 0)<= to_7segment(res(3 downto 0));
         if (clk'event and clk='1') then
			--ldf to parzystosc
             if (res(0)='1') then
					  LDF <= '1';
                 if (res = "00000000000000000") then ZF:='1';
                 else ZF:='0';
					  LDF <= '0';
                 end if;
					  
             if (res(15)='1') then SF:='1';
             else SF:='0'; end if;
             CF := res(16) xor res(15);
             end if;
         end if;
  end process;
end rtl;