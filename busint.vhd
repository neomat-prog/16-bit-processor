library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity busint is
port
(
     -- Clock signal added for synchronous operation
     clk     : in std_logic;
     
     -- Logical address inputs
     SEG     : in std_logic_vector(15 downto 0);    -- Segment address
     OFFSET  : in std_logic_vector(15 downto 0);    -- Offset address
     DO      : in std_logic_vector(15 downto 0);    -- Data to be written to memory
     
     -- Control signals
     Smar    : in std_logic;  -- MAR latch enable
     Smbr    : in std_logic;  -- MBR latch enable
     WRin    : in std_logic;  -- Write control input
     RDin    : in std_logic;  -- Read control input
     
     -- Physical address and data signals
     AD      : out std_logic_vector(15 downto 0);   -- Physical address output (16-bit)
     D       : inout std_logic_vector(15 downto 0); -- Data bus
     DI      : out std_logic_vector(15 downto 0);   -- Data from memory
     WR      : out std_logic;  -- Write signal to memory
     RD      : out std_logic   -- Read signal to memory
);
end entity;
 
architecture rtl of busint is
    -- Number of bits to shift segment address
    constant SHIFT_BITS : integer := 4; -- Example: 4-bit shift
    
    -- Internal signals
    signal MAR      : std_logic_vector(15 downto 0) := (others => '0');
    signal MBRin    : std_logic_vector(15 downto 0) := (others => '0');
    signal MBRout   : std_logic_vector(15 downto 0) := (others => '0');
    signal phy_addr : std_logic_vector(15 downto 0);
begin
    -- Physical address calculation
    phy_addr <= std_logic_vector(shift_left(unsigned(SEG), SHIFT_BITS) + unsigned(OFFSET));
    
    -- Synchronous process for registers
    process(clk)
    begin
        if rising_edge(clk) then
            -- MAR latch
            if Smar = '1' then
                MAR <= phy_addr;
            end if;
            
            -- MBR output latch
            if Smbr = '1' then
                MBRout <= DO;
            end if;
            
            -- MBR input latch
            if RDin = '1' then
                MBRin <= D;
            end if;
        end if;
    end process;
    
    -- Combinational outputs
    AD <= MAR;
    DI <= MBRin;
    WR <= WRin;
    RD <= RDin;
    
    -- Data bus control (tri-state)
    D <= MBRout when WRin = '1' else (others => 'Z');
end rtl;