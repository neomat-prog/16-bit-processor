LIBRARY IEEE;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY ALU IS
    PORT (
        A : IN SIGNED (15 DOWNTO 0);       -- First operand (BB in image)
        B : IN SIGNED (15 DOWNTO 0);       -- Second operand (BC in image)
        Salu : IN STD_LOGIC_VECTOR (4 DOWNTO 0); -- 5 bits for operations 0 to 31
        clk : IN STD_LOGIC;                -- Clock input
        Y : OUT SIGNED (15 DOWNTO 0);      -- Result output
        Z : OUT STD_LOGIC;                 -- Zero flag
        C : BUFFER STD_LOGIC;              -- Carry flag - changed from OUT to BUFFER to allow reading
        N : OUT STD_LOGIC                  -- Negative flag
    );
END ALU;

ARCHITECTURE ALU_Arch OF ALU IS
    SIGNAL last_res : SIGNED(15 DOWNTO 0) := (OTHERS => '0'); -- For CMP operation
BEGIN
    PROCESS (Salu, A, B, clk)
        VARIABLE res : SIGNED (16 DOWNTO 0); -- Extra bit for carry
        VARIABLE AA, BB : SIGNED (16 DOWNTO 0); -- Sign extended operands
        VARIABLE carry_in : SIGNED (16 DOWNTO 0); -- For carry input
        VARIABLE CF, ZF, NF : STD_LOGIC; -- Carry, Zero, and Negative flags
    BEGIN
        -- Sign extension for A and B
        AA(16) := A(15);
        AA(15 DOWNTO 0) := A;
        BB(16) := B(15);
        BB(15 DOWNTO 0) := B;
        
        -- Initialize carry-in based on current carry flag
        carry_in := (OTHERS => '0');
        IF C = '1' THEN
            carry_in(0) := '1';
        END IF;

        -- Default flag initialization
        CF := '0';
        ZF := '0';
        NF := '0';

        -- Operation selection
        CASE Salu IS
            -- Original operations from the blue/yellow image
            WHEN "00000" => res := BB; -- Y = BB (A in the code)
            WHEN "00001" => res := AA; -- Y = BC (B in the code)
            WHEN "00010" => res := BB + AA; -- Y = BB + BC
            WHEN "00011" => res := BB - AA; -- Y = BB - BC
            WHEN "00100" => res := BB OR AA; -- Y = BB OR BC
            WHEN "00101" => res := BB AND AA; -- Y = BB AND BC
            WHEN "00110" => res := BB XOR AA; -- Y = BB XOR BC
            WHEN "00111" => res := NOT (BB XOR AA); -- Y = BB XNOR BC
            WHEN "01000" => res := NOT BB; -- Y = NOT BB
            WHEN "01001" => res := -BB; -- Y = -BB
            WHEN "01010" => res := (OTHERS => '0'); -- Y = 0
            WHEN "01011" => res := BB + AA + carry_in; -- Y = BB + BC + C
            WHEN "01100" => res := BB - AA - carry_in; -- Y = BB - BC - C
            WHEN "01101" => res := BB + 1; -- Y = BB + 1
            WHEN "01110" => res := SHIFT_LEFT(BB, 1); -- Y = BB SHL 1
            WHEN "01111" => res := SHIFT_RIGHT(BB, 1); -- Y = BB SHR 1
            
            -- Additional operations (9 more operations from the list)
            WHEN "10000" => 
                -- CMP R, st16 (Compare BB with BC without storing result)
                res := BB - AA;
                -- CMP doesn't change Y but sets flags
            WHEN "10001" => 
                -- NEG R (Negate BB)
                res := -BB;
            WHEN "10010" => 
                -- INC R (Increment BB)
                res := BB + 1;
            WHEN "10011" => 
                -- DEC R (Decrement BB)
                res := BB - 1;
            WHEN "10100" => 
                -- SHR R (Shift BB right by 1)
                res := SHIFT_RIGHT(BB, 1);
            WHEN "10101" => 
                -- SHL R (Shift BB left by 1)
                res := SHIFT_LEFT(BB, 1);
            WHEN "10110" => 
                -- NOT R (Bitwise NOT of BB)
                res := NOT BB;
            WHEN "10111" => 
                -- NOP (No operation, keep previous value)
                res(15 DOWNTO 0) := last_res;
                res(16) := '0';
            WHEN "11000" => 
                -- WAIT (No operation, similar to NOP but could be used differently)
                res(15 DOWNTO 0) := last_res;
                res(16) := '0';
            
            WHEN OTHERS => 
                res := BB; -- Default
        END CASE;

        -- Handle special cases for output
        IF Salu = "10000" THEN
            -- CMP doesn't update Y
            Y <= last_res;
        ELSE
            -- Update Y for all other operations
            Y <= res(15 DOWNTO 0);
            -- Store current result for operations that might need previous value
            IF rising_edge(clk) THEN
                last_res <= res(15 DOWNTO 0);
            END IF;
        END IF;

        -- Zero flag
        IF res(15 DOWNTO 0) = x"0000" THEN
            ZF := '1';
        ELSE
            ZF := '0';
        END IF;
        Z <= ZF;
        
        -- Negative flag
        NF := res(15);
        N <= NF;

        -- Update carry flag on rising clock edge
        IF rising_edge(clk) THEN
            -- Set carry flag for operations that might generate a carry
            IF Salu = "00010" OR Salu = "00011" OR Salu = "01011" OR 
               Salu = "01100" OR Salu = "01101" OR Salu = "01110" OR
               Salu = "10000" OR Salu = "10010" OR Salu = "10011" OR
               Salu = "10101" THEN
                CF := res(16); -- Carry/borrow
            END IF;
            C <= CF;
        END IF;
    END PROCESS;
END ALU_Arch;
