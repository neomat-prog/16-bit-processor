LIBRARY IEEE;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY ALU IS
    PORT (
        A : IN SIGNED (15 DOWNTO 0);
        B : IN SIGNED (15 DOWNTO 0);
        Salu : IN STD_LOGIC_VECTOR (4 DOWNTO 0); -- 5 bits for operations 0 to 31
        clk : IN STD_LOGIC; -- Clock input
        Y : OUT SIGNED (15 DOWNTO 0);
        Z : OUT STD_LOGIC; -- Zero flag
        C : OUT STD_LOGIC  -- Carry flag
    );
END ALU;

ARCHITECTURE ALU_Arch OF ALU IS
BEGIN
    PROCESS (Salu, A, B, clk)
        VARIABLE res, AA, BB, CC : SIGNED (16 DOWNTO 0); -- Extra bit for carry
        VARIABLE CF, ZF, SF : STD_LOGIC; -- Carry, Zero, Sign flags
        VARIABLE temp_mult : SIGNED (31 DOWNTO 0); -- For multiplication
    BEGIN
        -- Sign extension for A and B
        AA(16) := A(15);
        AA(15 DOWNTO 0) := A;
        BB(16) := B(15);
        BB(15 DOWNTO 0) := B;
        CC := (OTHERS => '0'); -- Initialize carry-in as 0

        -- Default flag initialization
        CF := '0';
        ZF := '0';
        SF := '0';

        -- Operation selection
        CASE Salu IS
            WHEN "00000" => res := BB; -- MOV: Y = BB
            WHEN "00001" => res := BB; -- MOV: Y = BB (redundant, kept for compatibility)
            WHEN "00010" => res := BB + BB; -- ADD: Y = BB + BB
            WHEN "00011" => 
                temp_mult := resize(BB * BB, 32); -- MUL: Y = BB * BB (resize to 32 bits)
                res := temp_mult(16 DOWNTO 0); -- Take lower 17 bits
            WHEN "00100" => res := BB OR BB; -- OR: Y = BB OR BB
            WHEN "00101" => res := BB AND BB; -- AND: Y = BB AND BB
            WHEN "00110" => res := BB XOR BB; -- XOR: Y = BB XOR BB
            WHEN "00111" => res := NOT (BB XOR BB); -- XNOR: Y = BB XNOR BB
            WHEN "01000" => res := NOT BB; -- NOT: Y = NOT BB
            WHEN "01001" => res := -BB; -- NEG: Y = -BB
            WHEN "01010" => res := (OTHERS => '0'); -- CLR: Y = 0
            WHEN "01011" => res := BB + BB + CC; -- ADC: Y = BB + BB + C
            WHEN "01100" => 
                temp_mult := resize(BB * BB, 32); -- MULC: Y = BB * BB - C (resize to 32 bits)
                res := temp_mult(16 DOWNTO 0) - CC; -- Subtract carry
            WHEN "01101" => res := BB + 1; -- INC: Y = BB + 1
            WHEN "01110" => res := SHIFT_LEFT(BB, 1); -- SHL: Y = BB SHL 1
            WHEN "01111" => res := SHIFT_RIGHT(BB, 1); -- SHR: Y = BB SHR 1
            -- New instructions
            WHEN "10000" => res := BB - BB; -- SUB: Y = BB - BB
            WHEN "10001" => res := BB - BB; -- CMP: Y unchanged, set flags
            WHEN "10010" => res := -BB; -- NEG: Y = -BB
            WHEN "10011" => res := BB + 1; -- INC: Y = BB + 1
            WHEN "10100" => res := BB - 1; -- DEC: Y = BB - 1
            WHEN "10101" => res := BB AND BB; -- AND: Y = BB AND BB
            WHEN "10110" => res := BB OR BB; -- OR: Y = BB OR BB
            WHEN "10111" => res := BB XOR BB; -- XOR: Y = BB XOR BB
            WHEN "11000" => res := NOT BB; -- NOT: Y = NOT BB
            WHEN OTHERS => res := BB; -- Default: Y = BB
        END CASE;

        -- Assign output Y (except for CMP, which doesn’t change Y)
        IF Salu /= "10001" THEN
            Y <= res(15 DOWNTO 0);
        ELSE
            Y <= A; -- CMP doesn’t modify Y, keep previous value (A for simplicity)
        END IF;

        -- Zero flag
        IF res(15 DOWNTO 0) = "0000000000000000" THEN
            ZF := '1';
        ELSE
            ZF := '0';
        END IF;
        Z <= ZF;

        -- Update flags on rising clock edge
        IF rising_edge(clk) THEN
            -- Carry flag (for arithmetic operations)
            IF Salu = "00010" OR Salu = "01011" OR Salu = "01101" OR Salu = "10000" OR Salu = "10001" OR Salu = "10100" OR Salu = "10011" THEN
                CF := res(16); -- Carry/borrow for ADD, ADC, INC, SUB, CMP, DEC
            ELSIF Salu = "00011" OR Salu = "01100" THEN
                CF := temp_mult(31); -- Overflow for MUL, MULC
            ELSE
                CF := '0';
            END IF;
            C <= CF;

            -- Sign flag (most significant bit of result)
            SF := res(15);
        END IF;
    END PROCESS;
END ALU_Arch;