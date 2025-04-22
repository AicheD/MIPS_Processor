-- Student: Harry Zarcadoolas, Section: 11091, Course: EEL4712C Digital Design
-- ALU Control Unit for MIPS Processor
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.ALU_OpSelect_codes_pkg.all;
use work.ALUOp_codes_pkg.all;

entity ALU_Control is
	generic(
		WIDTH : positive := 32
	);
    port (
        IR5to0			: in std_logic_vector(5 downto 0);
		ALUOp			: in std_logic_vector(3 downto 0);
		OPSelect		: out std_logic_vector(5 downto 0);
		ALU_LO_HI 		: out std_logic_vector(1 downto 0);
		HI_en, LO_en	: out std_logic
    );
end ALU_Control;

architecture BHV of ALU_Control is
begin
	process(ALUOp, IR5to0)
		
	begin
		-- Default values
		HI_en <= '0'; -- disable HI reg
		LO_en <= '0'; -- disable LO reg
		ALU_LO_HI <= "00"; -- ALU_out
		OPSelect <= (others => '1'); -- blank code "111111"
		
		case ALUOp is
			-- R-Type Instructions 
			when C_RTYPE =>
				--IR5-0 (func) can go directly to the ALU
				OPSelect <= IR5to0;				
				-- check for long result operation (multiply)
				if( (IR5to0 = OP_MULT) or (IR5to0 = OP_MULTU) ) then				
					HI_en <= '1';
					LO_en <= '1';			
				-- load HI reg for MFHI Instruction
				elsif (IR5to0 = OP_MFHI) then				
					ALU_LO_HI <= "10";
				-- load LO reg for MFLO Instructions
				elsif (IR5to0 = OP_MFLO) then							
					ALU_LO_HI <= "01";		
				end if;
			
			--I-TYPE Instructions
			when C_ADDIU =>
				OPSelect <= OP_ADD;
			when C_SLTI =>
				OPSelect <= OP_SLT;
			when C_SLTIU =>
				OPSelect <= OP_SLTU;
			when C_ANDI =>
				OPSelect <= OP_AND;
			when C_ORI =>
				OPSelect <= OP_OR;
			when C_XORI =>
				OPSelect <= OP_XOR;
			when C_SUBIU =>
				OPSelect <= OP_SUB;
			
			--Branch Instructions
			when C_BR_BEQ => 				
				OPSelect <= OP_BEQ;				
			when C_BR_BNE => 				
				OPSelect <= OP_BNE;				
			when C_BR_BLEZ => 				
				OPSelect <= OP_BLEZ;				
			when C_BR_BGTZ => 				
				OPSelect <= OP_BGTZ;				
			when C_BR_BLTZ => 				
				OPSelect <= OP_BLTZ;				
			when C_BR_BGEZ => 				
				OPSelect <= OP_BGEZ;
			-- Jump and Link Instruction, a special little branch instruction
			when C_JAL_OP =>
				OPSelect <= OP_JR;

			-- Instruction states that intrinsically use the ADD operation at certain points, i.e. computing memory address
			when C_ADD_only =>
				OPSelect <= OP_ADD;
				
			when others =>
				-- For the madmen that want to use squeeze all the life out the ALU (crazy instructions)

		end case;
	end process;
end BHV;