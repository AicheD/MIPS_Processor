-- Student: Harry Zarcadoolas, Section: 11091, Course: EEL4712C Digital Design
-- Controller Module for MIPS Processor, inspired by: https://github.com/analogdanny/MIPS
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.ALUOp_codes_pkg.all; -- Import the ALU opcodes package
use work.IR_codes_pkg.all; -- Import the IR opcodes package

entity controller is
	generic(
		width : positive := 32
	);
    port (
		clk 		: in std_logic;
		rst			: in std_logic;
		
		-- IR input signals for decoding
		IR31to26	: in std_logic_vector(5 downto 0); -- I consider this the beating soul of the decode, unless the instruction is "SPECIAL" (MIPS ISA Full Manual said it not me)
		IR20to16	: in std_logic_vector(4 downto 0); -- this is used like once, come on man... (for some branch determining logic)
		IR5to0		: in std_logic_vector(5 downto 0); -- Used for RTYPE and JUMP instructions (and maybe some other instructions that I won't implement?)

		-- Controller out signals
		PCWriteCond : out std_logic;
        PCWrite 	: out std_logic;
		IorD 		: out std_logic;
		MemRead		: out std_logic;
		MemWrite 	: out std_logic;
		MemToReg 	: out std_logic;
		IRWrite 	: out std_logic;
		JumpAndLink : out std_logic;
		IsSigned 	: out std_logic;
		PCSource 	: out std_logic_vector(1 downto 0);
		ALUOp 		: out std_logic_vector(3 downto 0);
		ALUSrcB 	: out std_logic_vector(1 downto 0);
		ALUSrcA 	: out std_logic;
		RegWrite 	: out std_logic;
		RegDst 		: out std_logic
	);
end controller;

architecture BHV of controller is

	type STATE_TYPE is (S_START, S_FETCH, S_FETCH2, S_DECODE, S_RTYPE_EXECUTE, S_RTYPE_COMPLETE, 
						S_MEMORY_COMPUTE, S_LW, S_SW, S_LW_WB, S_MEMREAD_COMPLETE, S_BRANCH, 
						S_JUMP, S_TARGET_ADDRESS, S_ITYPE_EXECUTE, 
						S_ITYPE_COMPLETE, S_JAL, S_HALT);
	signal state, next_state : STATE_TYPE;
begin
	process (clk, rst)
	begin
		if (rst = '1') then
			state <= S_START;
		elsif (clk = '1' and clk'event) then
			state <= next_state;
		end if;
	end process;
	
	
	process (state, IR31to26, IR5to0)
	begin
		-- default values
		PCWrite 	<= '0';
		PCWriteCond <= '0';
		IorD 		<= '0';
		MemRead		<= '0';
		MemWrite 	<= '0';
		MemToReg 	<= '0';
		IRWrite 	<= '0';
		JumpAndLink <= '0';
		IsSigned 	<= '0';
		PCSource 	<= (others => '0');
		ALUOp 		<= (others => '0');
		ALUSrcA 	<= '0';
		ALUSrcB 	<= (others => '0');
		RegWrite 	<= '0';
		RegDst 		<= '0';
		next_state  <= state;
		
		case state is 
		-- initial wait state
			when S_START =>
				next_state <= S_FETCH;

		-- FETCH --
			when S_FETCH =>
				-- load into memory
				MemRead <= '1';
				-- set PC to update on next cycle
				ALUSrcB <= "01";
				PCWrite <= '1';

				next_state <= S_FETCH2;
			
			when S_FETCH2 =>
				-- load instruction to IR
				IRWrite <= '1';

				next_state <= S_DECODE;
		-- END FETCH --

		
			
		-- DECODE --
			when S_DECODE =>
				ALUSrcB <= "11"; -- helps with JUMP Instr lookahead target address compute for current 256 MB-aligned region. "The low 28 bits of the target address is the instr_index field shifted left 2 bits"

			-- RTYPE Instruction
			if (IR31to26 = C_RTYPE_I) then				
			next_state <= S_RTYPE_EXECUTE;
			-- LW/SW (Memory) Instruction
			elsif ((IR31to26 = C_LW) or (IR31to26 = C_SW)) then 				
				next_state <= S_MEMORY_COMPUTE;
			-- ITYPE Instruction	
			elsif ((IR31to26 >= C_ADDIU_I) and (IR31to26 <= C_SUBIU_I)) then
				next_state <= S_ITYPE_EXECUTE;
			-- BRANCH Instruction
			elsif (((IR31to26 >= C_BEQ) and (IR31to26 <= C_BGTZ)) or IR31to26 = C_BLTZ) then 
				next_state <= S_TARGET_ADDRESS;	
			-- JUMP Instruction	(can be thought of as a special BRANCH Instruction)			
			elsif ((IR31to26 = C_J) or (IR31to26 = C_JAL)) then
				next_state <= S_JUMP;
			-- HALT Instruction	
			elsif (IR31to26 = C_HALT) then
				next_state <= S_HALT;
			end if;
		-- END DECODE --
		
		-- LW/SW (Memory) Instruction --
			when S_MEMORY_COMPUTE =>
			ALUSrcA <= '1'; -- RegA selected (target register)
			ALUSrcB <= "10"; -- sign-extended IR[15:0] selected (offset)
			ALUOp <= C_ADD_only; -- add offset and register to compute memory location

			-- next stage determined by LW or SW functionality
			if(IR31to26 = C_LW) then
				next_state <= S_LW;
			elsif (IR31to26 = C_SW) then 
				next_state <= S_SW;
			end if;
			
			-- LW --			
			when S_LW =>
				IorD <= '1'; -- ALU_Out selected: holds the computed target address from the ALU in the previous state
				MemRead <= '1'; -- Read data at memory address ALU_Out
				next_state <= S_LW_WB;
			when S_LW_WB =>
				-- wait for memory read to complete/synchronize
				next_state <= S_MEMREAD_COMPLETE;
			when S_MEMREAD_COMPLETE =>
				RegDst <= '0'; -- the register to write to is selected from IR[20:16]
				MemToReg <= '1'; -- the data to write to register file is selected to be from memory
				RegWrite <= '1'; -- write the data to the reg file
				next_state <= S_FETCH;
			-- End LW  --
				
			-- SW --
			when S_SW =>
				IorD <= '1'; -- ALU_Out selected: holds the computed target address from the ALU in the previous state
				MemWrite <= '1'; -- Write data at memory address ALU_Out
				next_state <= S_FETCH;
			-- End SW --
		-- End LW/SW (Memory) Instruction --

		-- ITYPE Instruction --
		when S_ITYPE_EXECUTE =>
		ALUSrcA <= '1'; -- target register selected
		ALUSrcB <= "10"; -- (extended) immediate value selected

		-- ALUOp will reflect the operation, some will conditionally write to the PC
		if (IR31to26 = C_ADDIU_I) then
			IsSigned <= '1';
			ALUOp <= C_ADDIU;
		elsif (IR31to26 = C_SLTI_I) then
			IsSigned <= '1';
			PCWriteCond <= '1';
			ALUOp <= C_SLTI;
		elsif (IR31to26 = C_SLTIU_I) then
			IsSigned <= '1';
			PCWriteCond <= '1';
			ALUOp <= C_SLTIU;
		elsif (IR31to26 = C_ANDI_I) then
			ALUOp <= C_ANDI;
		elsif (IR31to26 = C_ORI_I) then
			ALUOp <= C_ORI;
		elsif (IR31to26 = C_XORI_I) then
			ALUOp <= C_XORI;
		elsif (IR31to26 = C_SUBIU_I) then
			IsSigned <= '1';
			ALUOp <= C_SUBIU;
		end if;

		next_state <= S_ITYPE_COMPLETE;
			
		when S_ITYPE_COMPLETE =>
			RegWrite <= '1'; -- update the reg file with the computed value
			next_state <= S_FETCH;			
		-- ITYPE Instruction --
		
			
		-- RTYPE Instruction --
			when S_RTYPE_EXECUTE =>
				ALUOp <= C_RTYPE; -- This will basically pass the func field from IR[5:0] straight to the ALU
				PCWriteCond <= '1'; -- Conditionally write PC for JUMP Register Instruction
				ALUSrcA <= '1'; -- RegA selected
				
				if ((IR5to0 = C_MULT) or (IR5to0 = C_MULTU)) then
					next_state <= S_FETCH; -- the result is going to be where we want it, the LO and HI regs
				else
					next_state <= S_RTYPE_COMPLETE;
				end if;
				
			when S_RTYPE_COMPLETE =>
				-- Move From LO/HI instruction
				if ((IR5to0 = C_MFHI) or (IR5to0 = C_MFLO)) then
					ALUOp <= C_RTYPE; -- pass the func field from the instruction to the ALU
				end if;
				
				-- write to register if not a JUMP Register instruction
				RegDst <= '1'; -- register destination will be IR[15:11]
				if (IR5to0 /= C_JR_5to0) then
					RegWrite <= '1';	
				end if;
				
				next_state <= S_FETCH;
		-- End RTYPE Instruction --

		-- BRANCH Instruction --
		when S_TARGET_ADDRESS =>
		ALUSrcB <= "11"; -- selection: IR[15:0] sign-extended << 2
		IsSigned <= '1'; -- account for negative offset when sign-extending, I believe
		ALUOp <= C_ADD_only; -- deliberately showing that you should add for computing memory location *nod*
		
		next_state <= S_BRANCH;

		when S_BRANCH =>
			ALUSrcA <= '1'; -- RegA selected
			PCWriteCond <= '1'; -- write to the PC is BranchTaken flag is set
			PCSource <= "01"; -- ALU_Out is the selection to the PC (has target address)

			-- see which branch it is and determine ALU operation based on that
			if IR31to26 = C_BEQ then ALUOp <= C_BR_BEQ;
			elsif IR31to26 = C_BGTZ then ALUOp <= C_BR_BGTZ;
			elsif IR31to26 = C_BLEZ then ALUOp <= C_BR_BLEZ;
			elsif IR31to26 = C_BLTZ or IR31to26 = C_BGEZ then
				if IR20to16 = "00000" then ALUOp <= C_BR_BLTZ;
				elsif IR20to16 = "00001" then ALUOp <= C_BR_BGEZ;
				end if;
			elsif IR31to26 = C_BNE then ALUOp <= C_BR_BNE;
			end if;
			
			next_state <= S_FETCH;
		-- End BRANCH Instruction --
			
			
			
		-- JUMP Instruction --
			when S_JUMP =>
				PCSource <= "10"; -- ALU_Out selected
				PCWrite <= '1'; -- The "branch" is always taken, write the JUMP address
				
				if(IR31to26 = C_JAL) then -- you ain't done yet pal
					ALUOp <= C_JAL_OP; -- perform the link process
					next_state <= S_JAL;
				else 
					next_state <= S_FETCH;
				end if;
				
			when S_JAL =>
					ALUOp <= C_JAL_OP; -- perform the link process
					JumpAndLink <= '1'; -- set JAL flag
					RegWrite <= '1'; -- write value to the register
					next_state <= S_FETCH;
		-- End JUMP Instruction --
		
			when S_HALT =>
				next_state <= S_HALT;
		
		end case;
		
	end process;

end BHV;