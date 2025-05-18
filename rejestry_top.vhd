library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RegisterFileTop is
    port (
        SW   : in std_logic_vector(9 downto 0);
        KEY  : in std_logic_vector(1 downto 0);
        LEDR : out std_logic_vector(15 downto 0);
        HEX0 : out std_logic_vector(6 downto 0)
    );
end entity;

architecture rtl of RegisterFileTop is

    component RegisterFile
        port (
            clk   : in std_logic;
            DI    : in signed(15 downto 0);
            BA    : in signed(15 downto 0);
            Sbb   : in signed(4 downto 0);
            Sbc   : in signed(4 downto 0);
            Sba   : in signed(4 downto 0);
            Sid   : in signed(2 downto 0);
            Sa    : in signed(1 downto 0);
            BB    : out signed(15 downto 0);
            BC    : out signed(15 downto 0);
            ADR   : out signed(31 downto 0);
            IRout : out signed(15 downto 0)
        );
    end component;

    signal DI, BA : signed(15 downto 0);
    signal BB     : signed(15 downto 0) := (others => '0');
    signal BC     : signed(15 downto 0) := (others => '0');
    signal ADR    : signed(31 downto 0);
    signal IRout  : signed(15 downto 0);
    signal clk_wr, clk_rd : std_logic;
    signal Sba, Sbb       : signed(4 downto 0) := (others => '0');
    signal Sbc            : signed(4 downto 0) := "00011";
    signal Sid            : signed(2 downto 0) := "000";
    signal Sa             : signed(1 downto 0) := "00";

    signal LEDR_internal : std_logic_vector(15 downto 0) := (others => '0');
    signal HEX0_internal : std_logic_vector(6 downto 0) := "1111111";

    function decode_hex(nibble: std_logic_vector(3 downto 0)) return std_logic_vector is
    begin
        case nibble is
            when "0000" => return "1000000"; -- 0
            when "0001" => return "1111001"; -- 1
            when "0010" => return "0100100"; -- 2
            when "0011" => return "0110000"; -- 3
            when "0100" => return "0011001"; -- 4
            when "0101" => return "0010010"; -- 5
            when "0110" => return "0000010"; -- 6
            when "0111" => return "1111000"; -- 7
            when "1000" => return "0000000"; -- 8
            when "1001" => return "0010000"; -- 9
            when others => return "1111111";
        end case;
    end function;

begin

    clk_wr <= not KEY(0); -- zapis
    clk_rd <= not KEY(1); -- odczyt

    DI <= signed("00000000" & SW(7 downto 0));
    BA <= signed("00000000" & SW(7 downto 0));

    -- tylko 3 rejestry: A (00), B (01), C (10)
    Sba <= signed("00" & SW(9 downto 8));
    Sbb <= signed("00" & SW(9 downto 8));

    U1 : RegisterFile
        port map (
            clk   => clk_wr or clk_rd,
            DI    => DI,
            BA    => BA,
            Sbb   => Sbb,
            Sbc   => Sbc,
            Sba   => Sba,
            Sid   => Sid,
            Sa    => Sa,
            BB    => BB,
            BC    => BC,
            ADR   => ADR,
            IRout => IRout
        );

    process(clk_rd)
    begin
        if rising_edge(clk_rd) then
            LEDR_internal(15 downto 3) <= (others => '0'); -- czyÅcimy pozostaÅe LEDy
            case SW(9 downto 8) is
                when "00" => LEDR_internal(0) <= '1'; -- A
                when "01" => LEDR_internal(1) <= '1'; -- B
                when "10" => LEDR_internal(2) <= '1'; -- C
                when others => null; -- brak rejestru D
            end case;
            LEDR_internal(9 downto 0) <= std_logic_vector(BB(9 downto 0));
            HEX0_internal <= decode_hex(std_logic_vector(BB(3 downto 0)));
        end if;
    end process;

    LEDR <= LEDR_internal;
    HEX0 <= HEX0_internal;

end architecture;
