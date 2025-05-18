LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ram1 IS
PORT (
    data    : IN std_logic_vector(15 downto 0);
    address : IN std_logic_vector(15 downto 0);  -- Physical address input
    we, clk : IN std_logic;                      -- Write enable and clock
    q       : OUT std_logic_vector(15 downto 0)  -- Output data
);
END ram1;

ARCHITECTURE rtl OF ram1 IS
   -- Reduce memory size for synthesis feasibility
   CONSTANT ADDR_WIDTH : integer := 10;           -- 1024 memory locations
   -- Oblicz głębokość pamięci i maksymalny adres jako stałe
   CONSTANT MEM_DEPTH  : integer := 2**ADDR_WIDTH; -- 2^10 = 1024
   CONSTANT MAX_ADDR   : integer := MEM_DEPTH - 1;  -- 1023

   -- Użyj stałej MAX_ADDR w definicji typu
   TYPE mem IS ARRAY(0 to MAX_ADDR) OF std_logic_vector(15 downto 0);
   SIGNAL ram_block : mem;

   -- Użyj stałej MAX_ADDR w deklaracji sygnału.
   -- Zamiast 'natural', można bezpiecznie użyć 'integer', ponieważ zakres jest jawnie zdefiniowany.
   SIGNAL addr_int : integer range 0 to MAX_ADDR;
   -- Lub jeśli wolisz 'natural', to też powinno działać z MAX_ADDR:
   -- SIGNAL addr_int : natural range 0 to MAX_ADDR;

   SIGNAL q_reg : std_logic_vector(15 downto 0);
BEGIN
   -- Konwersja adresu do integer, używając tylko dolnych ADDR_WIDTH bitów
   addr_int <= to_integer(unsigned(address(ADDR_WIDTH-1 downto 0)));

   -- W pełni synchroniczny proces pamięci
   PROCESS(clk)
   BEGIN
      IF rising_edge(clk) THEN
         -- Odczyt synchroniczny - ważne jest, aby odczyt był przed zapisem
         -- w tym samym cyklu, aby uzyskać zachowanie "read-before-write"
         -- jeśli adres odczytu i zapisu jest ten sam.
         -- Jeśli chcesz "write-through" (odczyt nowej wartości po zapisie),
         -- zamień kolejność odczytu i zapisu wewnątrz IF(we='1').
         q_reg <= ram_block(addr_int);

         -- Zapis synchroniczny
         IF(we = '1') THEN
            ram_block(addr_int) <= data;
         END IF;
      END IF;
   END PROCESS;

   -- Przypisanie wyjścia
   q <= q_reg;
END rtl;