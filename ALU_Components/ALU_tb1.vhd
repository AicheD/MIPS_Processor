-- Student: Harry Zarcadoolas, Section 11091, Couse: EEL4712C Digital Design
-- Testbench 1 for ALU - Case Testing
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ALU_OpSelect_codes_pkg.all; -- Import OpSelect codes package

entity ALU_tb1 is
end ALU_tb1;

architecture TB of ALU_tb1 is
    -- ALU Width
    constant WIDTH : integer := 32; 

    -- Signals for the ALU inputs and outputs
    signal A, B, Result, ResultHI   : std_logic_vector(WIDTH-1 downto 0);
    signal Shift                    : std_logic_vector(4 downto 0);
    signal OPSelect                 : std_logic_vector(5 downto 0);
    signal BranchTaken              : std_logic;

    begin
        U_ALU : entity work.ALU
        generic map (
            WIDTH => WIDTH
        ) port map (
            A => A,
            B => B,
            Shift => Shift,
            OPSelect => OPSelect,
            Result => Result,
            ResultHI => ResultHI,
            BranchTaken => BranchTaken
        );

        process
        begin
            SHIFT <= "00000"; -- No shift

            -- Test Case 1: ADDU (10 + 15)
            A <= std_logic_vector(to_unsigned(10, WIDTH));
            B <= std_logic_vector(to_unsigned(15, WIDTH));
            OPSelect <= OP_ADD;
            wait for 10 ns;
            assert Result = std_logic_vector(to_unsigned(25, WIDTH))
            report "Test Case 1 Failed: ADDU (10 + 15)" severity error;

            -- Test Case 2: SUBU (25 - 10)
            A <= std_logic_vector(to_unsigned(25, WIDTH));
            B <= std_logic_vector(to_unsigned(10, WIDTH));
            OPSelect <= OP_SUB;
            wait for 10 ns;
            assert Result = std_logic_vector(to_unsigned(15, WIDTH))
            report "Test Case 2 Failed: SUBU (25 - 10)" severity error;

            -- Test Case 3: MULT (10 * -4)
            A <= std_logic_vector(to_signed(10, WIDTH));
            B <= std_logic_vector(to_signed(-4, WIDTH));
            OPSelect <= OP_MULT;
            wait for 10 ns;
            assert Result = std_logic_vector(to_signed(-40, WIDTH))
            report "Test Case 3 Failed: MULT (10 * -4)" severity error;

            -- Test Case 4: AND (0x0000FFFF and 0xFFFF1234)
            A <= x"0000FFFF";
            B <= x"FFFF1234";
            OPSelect <= OP_AND;
            wait for 10 ns;
            assert Result = x"00001234"
            report "Test Case 4 Failed: AND (0x0000FFFF and 0xFFFF1234)" severity error;

            -- Test Case 5: SRL (0x0000000F by 4)
            B <= x"0000000F";
            Shift <= "00100"; -- Shift amount is 4
            OPSelect <= OP_SRL;
            wait for 10 ns;
            assert Result = x"00000000"
            report "Test Case 5 Failed: SRL (0x0000000F by 4)" severity error;

            -- Test Case 6: SRA (0xF0000008 by 1)
            B <= x"F0000008";
            Shift <= "00001"; -- Shift amount is 1
            OPSelect <= OP_SRA;
            wait for 10 ns;
            assert Result = x"F8000004"
            report "Test Case 6 Failed: SRA (0xF0000008 by 1)" severity error;

            -- Test Case 7: SRA (0x00000008 by 1)
            B <= x"00000008";
            Shift <= "00001"; -- Shift amount is 1
            OPSelect <= OP_SRA;
            wait for 10 ns;
            assert Result = x"00000004"
            report "Test Case 7 Failed: SRA (0xF0000008 by 1, repeated)" severity error;

            -- Test Case 8: SLT (A=10, B=15)
            A <= std_logic_vector(to_unsigned(10, WIDTH));
            B <= std_logic_vector(to_unsigned(15, WIDTH));
            OPSelect <= OP_SLT;
            wait for 10 ns;
            assert Result = std_logic_vector(to_unsigned(1, WIDTH))
            report "Test Case 8 Failed: SLT (A=10, B=15)" severity error;

            -- Test Case 9: SLTU (A=15, B=10)
            A <= std_logic_vector(to_unsigned(15, WIDTH));
            B <= std_logic_vector(to_unsigned(10, WIDTH));
            OPSelect <= OP_SLTU;
            wait for 10 ns;
            assert Result = std_logic_vector(to_unsigned(0, WIDTH))
            report "Test Case 9 Failed: SLTU (A=15, B=10)" severity error;

            -- Test Case 10: BLEZ (A=5)
            A <= std_logic_vector(to_unsigned(5, WIDTH));
            OPSelect <= OP_BLEZ;
            wait for 10 ns;
            assert BranchTaken = '0'
            report "Test Case 10 Failed: BLEZ (A=5)" severity error;

            -- Test Case 11: BGTZ (A=5)
            A <= std_logic_vector(to_unsigned(5, WIDTH));
            OPSelect <= OP_BGTZ;
            wait for 10 ns;
            assert BranchTaken = '1'
            report "Test Case 11 Failed: BGTZ (A=5)" severity error;

            report "All test cases completed! Author: Harry Zarcadoolas" severity note;
            wait;
        end process;
end TB;



