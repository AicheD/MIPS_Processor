-- Student: Harry Zarcadoolas, Section: 11091, Course: EEL4712C Digital Design
-- Memory Module for MIPS Processor
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity memory is
	generic(
		WIDTH : positive := 32
	);
    port (
        clk, rst, MemRead, MemWrite, InPort0_en, InPort1_en 	: in std_logic;
        InPort, addr, WrData 									: in  std_logic_vector(WIDTH-1 downto 0);
        OutPort, RdData 										: out std_logic_vector(WIDTH-1 downto 0)
    );
end memory;

architecture BHV of memory is 

	signal RAM_Wen, OutPort_en 									: std_logic;
	signal InPort0_out, InPort1_out, RAM_out 					: std_logic_vector(WIDTH-1 downto 0);
	signal RdDataSel, RdDataSel_to_reg 							: std_logic_vector(1 downto 0);

begin
	-- I/O Port instances --
	U_InPort0 : entity work.reg
	generic map(
		WIDTH => 32
	)
	port map(
		clk => clk,
		rst => rst,
		en => InPort0_en,
		d => InPort,
		q => InPort0_out
	);

	U_InPort1 : entity work.reg
		generic map(
			WIDTH => 32
		)
		port map(
			clk => clk,
			rst => rst,
			en => InPort1_en,
			d => InPort,
			q => InPort1_out
		);

	U_OutPort : entity work.reg
		generic map(
			WIDTH => 32
		)
		port map(
			clk => clk,
			rst => rst,
			en => OutPort_en,
			d => WrData,
			q => OutPort
		);
	-- End I/O Port instances --
	
	-- RAM instance
	U_RAM: entity work.ram
		port map(
			clock   => clk,
			wren  	=> RAM_Wen,
			address => addr(9 downto 2),
			data    => WrData,
			q		=> RAM_out
		);
	
	-- Register to synchronize RdDataSel signal
	U_RdDataSel_REG: entity work.reg
		generic map(
			WIDTH => 2
		)
		port map(
			clk => clk,
			rst => rst,
			en => MemRead,
			d => RdDataSel_to_reg,
			q => RdDataSel
		);
	
	U_MEM_LOGIC : entity work.mem_logic
		generic map(
			width => WIDTH
		)
		port map(
			MemWrite 	=> MemWrite,
			addr 		=> addr,
			OutPort_en 	=> OutPort_en,
			ram_wen 	=> RAM_Wen,
			RdDataSel 	=> RdDataSel_to_reg
		);
	
	-- MUX instance for RdData
	U_RdDataMUX: entity work.mux_3to1
		generic map(
			WIDTH => 32
		)
		port map(
			in1 	=> InPort0_out,
			in2 	=> InPort1_out,
			in3 	=> RAM_out,
			sel 	=> RdDataSel,
			output 	=> RdData
		);

end BHV;





























