library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

entity ALU is
port (
      A : in signed(15 downto 0);
      B : in signed(15 downto 0);
      Salu : in bit_vector (4 downto 0);
      LDF : in bit;
      clk : in bit;
      Y : out signed (15 downto 0);
      C,Z,S,P : out std_logic
);
end entity;
 
architecture rtl of ALU is
begin
  process (Salu, A, B, clk)
       variable res, AA, BB, CC: signed (16 downto 0);
       variable CF, ZF, SF, PF : std_logic;
       begin
         AA(16) := A(15);
         AA(15 downto 0) := A;
			
         BB(16) := B(15);
         BB(15 downto 0) := B;
			
         CC(0) := CF;
         CC(16 downto 1) := "0000000000000000";
			
         case Salu is
             when "00000" => res := AA;
             when "00001" => res := BB;
				 when "00010" => res := AA + BB;
				 when "00011" => res := AA - BB;
				 when "00100" => res := (AA OR BB);
				 when "00101" => res := (AA AND BB);
				 when "00110" => res := (AA XOR BB);
				 when "00111" => res := (AA XNOR BB);
			    when "01000" => res := NOT AA;
				 when "01001" => res := 0 - AA;
				 when "01010" => res := (others => '0');
				 when "01011" => res := AA + BB + CC;
				 when "01100" => res := AA - BB - CC;
				 when "01101" => res := AA + 1;
				 when "01110" => res := SHIFT_LEFT(AA, 1);
				 when "01111" => res := SHIFT_RIGHT(AA, 1);
				 
				 when "10000" => res := NOT BB;
				 when "10001" => res := (others => '1');
				 when "10010" => res := BB + 1;
				 when "10011" => res := BB - 1;


				 
				 when others => res := AA;
         end case;
			
         Y <= res(15 downto 0);
         Z <= ZF;
         S <= SF;
         C <= CF;

			if (clk'event and clk='1') then
				if (LDF='1') then
					if (res = "00000000000000000") then 
						ZF:='1';
					else 
						ZF:='0';
					end if;
					if (res(15)='1') then 
						SF:='1';
					else 
						SF:='0'; 
					end if;
					CF := res(16) xor res(15);
					PF := xor_reduce(std_logic_vector(res(15 downto 0)));
				end if;
			end if;
	
end process;
end rtl;

