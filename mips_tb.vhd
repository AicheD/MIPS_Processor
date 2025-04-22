-- Student: Harry Zarcadoolas, Section: 11091, Course: EEL4712C Digital Design
-- MIPS Processor Top Level Testbench (runs .MIF Files)
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mips_tb is
end mips_tb;

architecture Behavioral of mips_tb is
    constant width : positive := 32;
    signal clk      : std_logic := '0';
    signal rst      : std_logic := '1';
    signal switches : std_logic_vector(9 downto 0);
    signal buttons  : std_logic_vector(1 downto 0);
    signal LEDs     : std_logic_vector(width-1 downto 0);
begin

    -- Instantiate the design under test
    DUT: entity work.mips
        generic map(
            width => width
        )
        port map(
            clk      => clk,
            rst      => rst,
            switches => switches,
            buttons  => buttons,
            LEDs     => LEDs
        );

    -- Clock generation process: 20 ns period, 3999 iterations
    CLK_PROC: process
    begin
        for i in 0 to 3999 loop
            clk <= '0';
            wait for 10 ns;
            clk <= '1';
            wait for 10 ns;
        end loop;
        wait;
    end process;

    -- Test stimulus process
    TEST_PROC: process
    begin
        -- Set switches so that inport0 = "011111111"
        -- For switches(9 downto 0), set bit 9 = '0' and bits (8 downto 0) = "011111111"
        switches <= "0111111111";
        -- Set buttons for inport0 enable high (buttons(0) must be '1')
        buttons  <= "01";

        -- Apply reset for 40 ns, then release
        rst <= '1';
        wait for 40 ns;
        rst <= '0';

        wait;
    end process;

end Behavioral;