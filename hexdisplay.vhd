library ieee;
use ieee.std_logic_1164.all;

entity hex_display is
    port (
        nibble_in : in  std_logic_vector(3 downto 0);
        segments_out : out std_logic_vector(6 downto 0)
    );
end entity;

architecture Behavioral of hex_display is
begin
    process(nibble_in)
    begin
        case nibble_in is
            when "0000" => segments_out <= "1000000";  -- 0
            when "0001" => segments_out <= "1111001";  -- 1
            when "0010" => segments_out <= "0100100";  -- 2
            when "0011" => segments_out <= "0110000";  -- 3
            when "0100" => segments_out <= "0011001";  -- 4
            when "0101" => segments_out <= "0010010";  -- 5
            when "0110" => segments_out <= "0000010";  -- 6
            when "0111" => segments_out <= "1111000";  -- 7
            when "1000" => segments_out <= "0000000";  -- 8
            when "1001" => segments_out <= "0010000";  -- 9
            when "1010" => segments_out <= "0001000";  -- A
            when "1011" => segments_out <= "0000011";  -- b
            when "1100" => segments_out <= "1000110";  -- C
            when "1101" => segments_out <= "0100001";  -- d
            when "1110" => segments_out <= "0000110";  -- E
            when "1111" => segments_out <= "0001110";  -- F
            when others => segments_out <= "1111111";  -- WyÅÄczone
        end case;
    end process;
end architecture;
