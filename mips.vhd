-- Student: Harry Zarcadoolas, Section: 11091, Course: EEL4712C Digital Design
-- MIPS Processor Top Level Module
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mips is
    generic(
        WIDTH : positive := 32
    );
    port(
        clk         : in std_logic;
        rst         : in std_logic;
        switches    : in std_logic_vector(9 downto 0);
        buttons     : in std_logic_vector(1 downto 0);
        LEDs        : out std_logic_vector(WIDTH-1 downto 0) -- this should really be called OutPort
    );
end mips;

architecture Behavioral of mips is

    -- Signals connecting datapath to controller
    signal PCWrite, PCWriteCond, IorD, MemRead, MemWrite, MemToReg, IRWrite, JumpAndLink, IsSigned, ALUSrcA, RegWrite, RegDst : std_logic;
    signal PCSource : std_logic_vector(1 downto 0);
    signal ALUOp    : std_logic_vector(3 downto 0);
    signal ALUSrcB  : std_logic_vector(1 downto 0);

    signal IR5to0    : std_logic_vector(5 downto 0);
    signal IR20to16  : std_logic_vector(4 downto 0);
    signal IR31to26  : std_logic_vector(5 downto 0);

    -- wow, lights, so cool
    signal lights              : std_logic_vector(WIDTH-1 downto 0);
begin

    U_DATAPATH: entity work.datapath
        generic map(
            WIDTH => WIDTH
        )
        port map(
            clk                 => clk,
            rst                 => rst,
            PCWriteCond         => PCWriteCond,
            PCWrite             => PCWrite,
            IorD                => IorD,
            MemRead             => MemRead,
            MemWrite            => MemWrite,
            MemToReg            => MemToReg,
            IRWrite             => IRWrite,
            JumpAndLink         => JumpAndLink,
            IsSigned            => IsSigned,
            PCSource            => PCSource,
            ALUOp               => ALUOp,
            ALUSrcB             => ALUSrcB,
            ALUSrcA             => ALUSrcA,
            RegWrite            => RegWrite,
            RegDst              => RegDst,
            IR31downto26_out    => IR31to26,
            IR20downto16_out    => IR20to16,
            IR5downto0_out      => IR5to0,
            switches            => switches,
            buttons             => buttons,
            LEDs                => lights
        );

    U_CONTROLLER: entity work.controller
        generic map(
            WIDTH => WIDTH
        )
        port map(
            clk                 => clk,
            rst                 => rst,
            IR31to26            => IR31to26,
            IR20to16            => IR20to16,
            IR5to0              => IR5to0,
            PCWrite             => PCWrite,
            PCWriteCond         => PCWriteCond,
            IorD                => IorD,
            MemRead             => MemRead,
            MemWrite            => MemWrite,
            MemToReg            => MemToReg,
            IRWrite             => IRWrite,
            JumpAndLink         => JumpAndLink,
            IsSigned            => IsSigned,
            PCSource            => PCSource,
            ALUOp               => ALUOp,
            ALUSrcA             => ALUSrcA,
            ALUSrcB             => ALUSrcB,
            RegWrite            => RegWrite,
            RegDst              => RegDst
        );

    LEDs <= lights;

end Behavioral;