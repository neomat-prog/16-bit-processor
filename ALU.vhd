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
        C : BUFFER STD_LOGIC  -- Carry flag (changed from OUT to BUFFER)
    );
END ALU;

ARCHITECTURE ALU_Arch OF ALU IS
BEGIN
    PROCESS (Salu, A, B, clk)
        VARIABLE res, AA, BB : SIGNED (16 DOWNTO 0); -- Extra bit for carry
        VARIABLE CC : SIGNED (16 DOWNTO 0) := (OTHERS => '0'); -- For carry-in
        VARIABLE ZF, SF : STD_LOGIC; -- Zero, Sign flags
        VARIABLE temp_mult : SIGNED (31 DOWNTO 0); -- For multiplication
    BEGIN
        -- Sign extension for A and B
        AA(16) := A(15);
        AA(15 DOWNTO 0) := A;
        BB(16) := B(15);
        BB(15 DOWNTO 0) := B;
        
        -- Initialize carry-in based on current carry flag
        CC := (OTHERS => '0');
        IF C = '1' THEN
            CC(0) := '1';
        END IF;

        -- Default flag initialization
        ZF := '0';
        SF := '0';

        -- Operation selection
        CASE Salu IS
            WHEN "00000" => res := BB; -- MOV: Y = B
            WHEN "00001" => res := BB; -- MOV: Y = B (redundant, kept for compatibility)
            WHEN "00010" => res := AA + BB; -- ADD: Y = A + B
            WHEN "00011" => 
                temp_mult := resize(AA * BB, 32); -- MUL: Y = A * B (resize to 32 bits)
                res := temp_mult(16 DOWNTO 0); -- Take lower 17 bits
            WHEN "00100" => res := AA OR BB; -- OR: Y = A OR B
            WHEN "00101" => res := AA AND BB; -- AND: Y = A AND B
            WHEN "00110" => res := AA XOR BB; -- XOR: Y = A XOR B
            WHEN "00111" => res := NOT (AA XOR BB); -- XNOR: Y = A XNOR B
            WHEN "01000" => res := NOT BB; -- NOT: Y = NOT B
            WHEN "01001" => res := -BB; -- NEG: Y = -B
            WHEN "01010" => res := (OTHERS => '0'); -- CLR: Y = 0
            WHEN "01011" => res := AA + BB + CC; -- ADC: Y = A + B + C
            WHEN "01100" => 
                temp_mult := resize(AA * BB, 32); -- MULC: Y = A * B + C
                res := temp_mult(16 DOWNTO 0) + CC; -- Add carry
            WHEN "01101" => res := BB + 1; -- INC: Y = B + 1
            WHEN "01110" => res := SHIFT_LEFT(BB, 1); -- SHL: Y = B SHL 1
            WHEN "01111" => res := SHIFT_RIGHT(BB, 1); -- SHR: Y = B SHR 1
            -- New instructions
            WHEN "10000" => res := BB - AA; -- SUB: Y = B - A
            WHEN "10001" => 
                res := BB - AA; -- CMP: Compare B with A
                -- CMP doesn't change Y, only affects flags
            WHEN "10010" => res := -BB; -- NEG: Y = -B
            WHEN "10011" => res := BB + 1; -- INC: Y = B + 1
            WHEN "10100" => res := BB - 1; -- DEC: Y = B - 1
            WHEN "10101" => res := AA AND BB; -- AND: Y = A AND B
            WHEN "10110" => res := AA OR BB; -- OR: Y = A OR B
            WHEN "10111" => res := AA XOR BB; -- XOR: Y = A XOR B
            WHEN "11000" => res := NOT BB; -- NOT: Y = NOT B
            WHEN OTHERS => res := BB; -- Default: Y = B
        END CASE;

        -- Assign output Y (except for CMP, which doesn't change Y)
        IF Salu /= "10001" THEN
            Y <= res(15 DOWNTO 0);
        ELSE
            Y <= A; -- CMP doesn't modify Y, keep previous value (A for simplicity)
        END IF;

        -- Zero flag
        IF res(15 DOWNTO 0) = x"0000" THEN
            ZF := '1';
        ELSE
            ZF := '0';
        END IF;
        Z <= ZF;

        -- Update flags on rising clock edge
        IF rising_edge(clk) THEN
            -- Carry flag (for arithmetic operations)
            IF Salu = "00010" OR Salu = "01011" OR Salu = "01101" OR Salu = "10000" OR 
               Salu = "10001" OR Salu = "10100" OR Salu = "10011" THEN
                C <= res(16); -- Carry/borrow for ADD, ADC, INC, SUB, CMP, DEC
            ELSIF Salu = "00011" OR Salu = "01100" THEN
                IF temp_mult > x"0000FFFF" THEN -- Check if result exceeds 16 bits
                    C <= '1';
                ELSE
                    C <= '0';
                END IF;
            ELSE
                C <= '0';
            END IF;

            -- Sign flag (most significant bit of result)
            SF := res(15);
        END IF;
    END PROCESS;
END ALU_Arch;
