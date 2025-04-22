-- Student: Harry Zarcadoolas, Section: 11091, Course: EEL4712C Digital Design
-- Datapath Module for MIPS Processor
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity datapath is
	generic(
		WIDTH : positive := 32
	);
    port (
		clk 				: in std_logic;
		rst					: in std_logic;
	
		-- Controller Signals --
		PCWriteCond 		: in std_logic;
        PCWrite 			: in std_logic;
		IorD 				: in std_logic;
		MemRead				: in std_logic;
		MemWrite 			: in std_logic;
		MemToReg 			: in std_logic;
		IRWrite 			: in std_logic;
		JumpAndLink 		: in std_logic;
		IsSigned 			: in std_logic;
		PCSource 			: in std_logic_vector(1 downto 0);
		ALUOp 				: in std_logic_vector(3 downto 0);
		ALUSrcB 			: in std_logic_vector(1 downto 0);
		ALUSrcA 			: in std_logic;
		RegWrite 			: in std_logic;
		RegDst 				: in std_logic;

		-- IR signals to Controller --
		IR31downto26_out	: out std_logic_vector(5 downto 0);
		IR20downto16_out	: out std_logic_vector(4 downto 0);
		IR5downto0_out		: out std_logic_vector(5 downto 0);
		
		
		-- Top Level Signals --	
		Switches 			: in std_logic_vector(9 downto 0);
		Buttons 			: in std_logic_vector(1 downto 0);
		LEDs 				: out std_logic_vector(WIDTH-1 downto 0)
	);
end datapath;


architecture BHV of datapath is

	-- Internal datapath architecture signals (Is this implementation the absolute smartest way to do this? Probably not)
	signal IR				: std_logic_vector(WIDTH-1 downto 0);
	signal IR5to0 			: std_logic_vector(5 downto 0);
	signal IR10to6 			: std_logic_vector(4 downto 0);
	signal IR25to0 			: std_logic_vector(25 downto 0);
	signal IR25to21			: std_logic_vector(4 downto 0);
	signal IR20to16 		: std_logic_vector(4 downto 0);
	signal IR15to11			: std_logic_vector(4 downto 0);
	signal IR15to0 			: std_logic_vector(15 downto 0);

	signal OPSelect			: std_logic_vector(5 downto 0);
	signal HI_en 			: std_logic;
	signal LO_en 			: std_logic;
	signal ALU_LO_HI 		: std_logic_vector(1 downto 0);
	signal BranchTaken 		: std_logic;
	
	--Internal Signals
	signal PC_en 			: std_logic;
	signal PC_in			: std_logic_vector(WIDTH-1 downto 0);
	signal PC				: std_logic_vector(WIDTH-1 downto 0);
	signal ALU_out			: std_logic_vector(WIDTH-1 downto 0);
	signal IorD_out			: std_logic_vector(WIDTH-1 downto 0);
	signal RegA				: std_logic_vector(WIDTH-1 downto 0);
	signal RegB				: std_logic_vector(WIDTH-1 downto 0);
	signal RdData			: std_logic_vector(WIDTH-1 downto 0);
	signal swDataExtended	: std_logic_vector(WIDTH-1 downto 0);
	signal InPort0_en		: std_logic;
	signal InPort1_en		: std_logic;
	signal MDR				: std_logic_vector(WIDTH-1 downto 0);
	signal ALU_MUX_OUT		: std_logic_vector(WIDTH-1 downto 0);
	signal WriteReg  		: std_logic_vector(4 downto 0);
	signal WriteData 		: std_logic_vector(WIDTH-1 downto 0);
	signal RegA_in			: std_logic_vector(WIDTH-1 downto 0);
	signal RegB_in 			: std_logic_vector(WIDTH-1 downto 0);
	signal signExtended		: std_logic_vector(WIDTH-1 downto 0);
	signal RegA_mux_out 	: std_logic_vector(WIDTH-1 downto 0);
	signal RegB_mux_out 	: std_logic_vector(WIDTH-1 downto 0); 
	signal shiftLeft		: std_logic_vector(WIDTH-1 downto 0); 
	signal Result			: std_logic_vector(WIDTH-1 downto 0); 
	signal ResultHi			: std_logic_vector(WIDTH-1 downto 0); 
	signal LO				: std_logic_vector(WIDTH-1 downto 0);
	signal HI				: std_logic_vector(WIDTH-1 downto 0);
	signal Concat 			: std_logic_vector(WIDTH-1 downto 0);
	
begin
	-- combinational logic to determine where the PC is going to pull from
	PC_en <= (PCWriteCond and BranchTaken) or PCWrite;

	U_PC: entity work.reg
		generic map(
			WIDTH => WIDTH
		)
		port map(
			clk	  	=> clk,
			rst		=> rst,
			en		=> PC_en,
			d		=> PC_in,
			q		=> PC
		);
	
	-- Concatenate PC[31:28] with (IR[25:0] shifted left by 2)	
	Concat <= PC(31 downto 28) & IR25to0 & "00";
		
	U_PC_MUX: entity work.mux_3to1
		generic map(
			WIDTH => WIDTH
		)
		port map(
			in1		=> Result,
			in2		=> ALU_out,
			in3		=> Concat,
			sel		=> PCSource,
			output  => PC_in
		);

	U_IorD_MUX: entity work.mux_2to1
		generic map(
			WIDTH => WIDTH
		)
		port map(
			in1		=> PC,
			in2		=> ALU_out,
			sel		=> IorD,
			output	=> IorD_out
		);
	
	-- InPort enables determined by top level buttons
	InPort0_en <= (Buttons(0)) and (not Switches(9));
	InPort1_en <= (Buttons(1)) and (Switches(9));
	-- zero extend the switch data to 32 bits
	swDataExtended <= (31 downto 10 => '0') & Switches(9 downto 0);
	U_MEMORY: entity work.memory
        port map (
            clk       		=> clk,
            rst       		=> rst,
            MemRead   		=> MemRead,
            MemWrite 		=> MemWrite,
            InPort0_en 		=> InPort0_en,
            InPort1_en 		=> InPort1_en,
			addr 			=> IorD_out,
			WrData 			=> RegB,
			RdData		 	=> RdData,
            InPort    		=> swDataExtended,
            OutPort   		=> LEDs
        );
		
	U_MEMORY_DATA_REG: entity work.reg
		generic map(
			WIDTH => WIDTH
		)
		port map(
			clk	  	=> clk,
			rst		=> rst,
			en		=> '1',
			d		=> RdData,
			q		=> MDR
		);
	
	U_INSTRUCTION_REG: entity work.reg
	generic map(
		WIDTH => WIDTH
	)
	port map(
		clk	  	 => clk,
		rst		 => rst,
		en		 => IRWrite,
		d	 	 => RdData,
		q   	 => IR
	);
	-- break up the instruction into its components --
	IR31downto26_out 	<= IR(31 downto 26);
	IR25to21			<= IR(25 downto 21);
	IR25to0 			<= IR(25 downto 0);
	IR15to11			<= IR(15 downto 11);
	IR15to0 			<= IR(15 downto 0);
	IR20to16			<= IR(20 downto 16);
	IR20downto16_out 	<= IR(20 downto 16);
	IR10to6 	 		<= IR(10 downto 6);
	IR5to0  	 		<= IR(5 downto 0);
	IR5downto0_out   	<= IR(5 downto 0);
		
	U_REGDST_MUX: entity work.mux_2to1
		generic map(
			WIDTH => 5
		)
		port map(
			in1		=> IR20to16,
			in2		=> IR15to11,
			sel		=> RegDst,
			output	=> WriteReg
		);
	
	U_MEMTOREG_MUX: entity work.mux_2to1
		generic map(
			WIDTH => WIDTH
		)
		port map(
			in1		=> ALU_MUX_OUT,
			in2		=> MDR,
			sel		=> MemToReg,
			output	=> WriteData
		);
	
	U_REGISTER_FILE: entity work.register_file
		generic map(
			WIDTH => WIDTH
		)
		port map(
			clk          	=> clk,
			rst          	=> rst,
			RegWrite     	=> RegWrite,
			JumpAndLink  	=> JumpAndLink,
			Read_Reg1      	=> IR25to21,
			Read_Reg2      	=> IR20to16,
			WriteReg		=> WriteReg,
			WriteData    	=> WriteData,
			Read_Data1      => RegA_in,
			Read_Data2      => RegB_in
		);
	
	-- sign-extension for immediate values [IR15:0] --
	process(IsSigned, IR15to0)
	begin
		case IsSigned is
			when '1' =>
				signExtended <= std_logic_vector(resize(signed(IR15to0), WIDTH));
			when '0' =>
				signExtended <= std_logic_vector(resize(unsigned(IR15to0), WIDTH));
			when others =>
				signExtended <= (others => '0');
		end case;
	end process;
	-- end sign-extend process --
		
	U_REGA: entity work.reg
		generic map(
			WIDTH => WIDTH
		)
		port map(
			clk	  	=> clk,
			rst		=> rst,
			en		=> '1',
			d		=> RegA_in,
			q		=> RegA
		);
	
	U_REGB: entity work.reg
		generic map(
			WIDTH => WIDTH
		)
		port map(
			clk	  	=> clk,
			rst		=> rst,
			en		=> '1',
			d		=> RegB_in,
			q		=> RegB
		);
		
	U_REGA_MUX: entity work.mux_2to1
		generic map(
			WIDTH => WIDTH
		)
		port map(
			in1		=> PC,
			in2		=> RegA,
			sel		=> ALUSrcA,
			output	=> RegA_mux_out
		);
	
	-- Shift left the sign-extended immediate value by 2 bits
	shiftLeft <= std_logic_vector(shift_left(unsigned(signExtended), 2));
	
	U_REGB_MUX: entity work.mux_4to1
		generic map(
			WIDTH => WIDTH
		)
		port map(
			in1		=> RegB,
			in2		=> std_logic_vector(to_unsigned(4, WIDTH)),
			in3		=> signExtended,
			in4		=> shiftLeft, 
			sel		=> ALUSrcB,
			output	=> RegB_mux_out
		);
	
	U_ALU: entity work.alu
        generic map ( 
			WIDTH => WIDTH 
		)
        port map (
			A  		=> RegA_mux_out,
			B  		=> RegB_mux_out,
            Shift  		=> IR10to6,
            OPSelect      	=> OPSelect,
            Result   		=> Result,
            ResultHi 		=> ResultHi,
            BranchTaken	=> BranchTaken
		);
		
	U_ALU_OUT: entity work.reg
		generic map(
			WIDTH => WIDTH
		)
		port map(
			clk	  	=> clk,
			rst		=> rst,
			en		=> '1',
			d		=> Result,
			q		=> ALU_out
		);
	
	U_LO: entity work.reg
		generic map(
			WIDTH => WIDTH
		)
		port map(
			clk	  	=> clk,
			rst		=> rst,
			en		=> LO_en,
			d		=> Result,
			q		=> LO
		);
	
	U_HI: entity work.reg
		generic map(
			WIDTH => WIDTH
		)
		port map(
			clk	  	=> clk,
			rst		=> rst,
			en		=> HI_en,
			d		=> ResultHi,
			q		=> HI
		);

	U_ALU_CONTROL: entity work.alu_control
	generic map(
		WIDTH => WIDTH
	)
	port map(
		IR5to0		=> IR5to0,
		ALUOp		=> ALUOp,
		ALU_LO_HI 	=> ALU_LO_HI,
		OPSelect	=> OPSelect,
		HI_en		=> HI_en,
		LO_en		=> LO_en
	);

	U_ALU_MUX: entity work.mux_3to1
		generic map(
			WIDTH => WIDTH
		)
		port map(
			in1		=> ALU_out,
			in2		=> LO,
			in3		=> HI,
			sel		=> ALU_LO_HI,
			output  => ALU_MUX_OUT
		);
end BHV;