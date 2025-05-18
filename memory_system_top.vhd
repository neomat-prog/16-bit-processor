LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY memory_system_top IS
PORT (
    -- Clock and control
    clk     : IN std_logic;  -- 50MHz clock from PIN_N2
    
    -- Input switches
    we      : IN std_logic;  -- Write enable from SW[0]
    address : IN std_logic_vector(15 downto 0);  -- Address from SW[1] to SW[16]
    
    -- Input buttons (for lower 4 bits of data)
    key_data: IN std_logic_vector(3 downto 0);  -- Data input from KEY[0] to KEY[3]
    
    -- Output displays
    hex0    : OUT std_logic_vector(6 downto 0);  -- Seven-segment display 0
    hex1    : OUT std_logic_vector(6 downto 0);  -- Seven-segment display 1
    hex2    : OUT std_logic_vector(6 downto 0);  -- Seven-segment display 2
    hex3    : OUT std_logic_vector(6 downto 0)   -- Seven-segment display 3
);
END ENTITY;

ARCHITECTURE structural OF memory_system_top IS
    -- Component declarations
    COMPONENT ram1 IS
    PORT (
        data    : IN std_logic_vector(15 downto 0);
        address : IN std_logic_vector(15 downto 0);
        we      : IN std_logic;
        clk     : IN std_logic;
        q       : OUT std_logic_vector(15 downto 0)
    );
    END COMPONENT;
    
    COMPONENT hex_display IS
    PORT (
        nibble_in     : IN std_logic_vector(3 downto 0);
        segments_out  : OUT std_logic_vector(6 downto 0)
    );
    END COMPONENT;
    
    -- Internal signals
    SIGNAL data   : std_logic_vector(15 downto 0);
    SIGNAL q      : std_logic_vector(15 downto 0);
    SIGNAL we_sync : std_logic;
    
    -- Test pattern counter for automatic testing
    SIGNAL test_counter : unsigned(11 downto 0) := (others => '0');
    SIGNAL clk_div     : unsigned(23 downto 0) := (others => '0');
    SIGNAL slow_clk    : std_logic := '0';
    
BEGIN
    -- Hardcode upper 12 bits of data input with test pattern
    -- KEY inputs are active LOW, so we need to invert them
    data(3 downto 0) <= not key_data;
    data(15 downto 4) <= std_logic_vector(test_counter);
    
    -- Clock divider for generating test patterns (slower clock)
    PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            clk_div <= clk_div + 1;
            IF clk_div = 0 THEN
                slow_clk <= not slow_clk;
                -- Update test pattern on slow clock
                IF slow_clk = '1' THEN
                    test_counter <= test_counter + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;
    
    -- Synchronize write enable to avoid metastability
    PROCESS(clk)
    BEGIN
        IF rising_edge(clk) THEN
            we_sync <= we;
        END IF;
    END PROCESS;
    
    -- Instantiate the RAM
    ram_inst: ram1
    PORT MAP (
        data    => data,
        address => address,
        we      => we_sync,
        clk     => clk,
        q       => q
    );
    
    -- Instantiate hex displays for output
    hex0_inst: hex_display
    PORT MAP (
        nibble_in     => q(3 downto 0),
        segments_out  => hex0
    );
    
    hex1_inst: hex_display
    PORT MAP (
        nibble_in     => q(7 downto 4),
        segments_out  => hex1
    );
    
    hex2_inst: hex_display
    PORT MAP (
        nibble_in     => q(11 downto 8),
        segments_out  => hex2
    );
    
    hex3_inst: hex_display
    PORT MAP (
        nibble_in     => q(15 downto 12),
        segments_out  => hex3
    );
    
END structural;