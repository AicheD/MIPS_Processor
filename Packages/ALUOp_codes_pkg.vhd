-- Student: Harry Zarcadoolas, Section: 11091, Course: EEL4712C Digital Design
-- ALUOp codes package
library ieee;
use ieee.std_logic_1164.all;

package ALUOp_codes_pkg is
		-- ALUOps for R-TYPE Instructions
		constant C_RTYPE    : std_logic_vector(3 downto 0) := "0001";
		
		-- ALUOp for I-TYPE Instructions
		constant C_ADDIU  	: std_logic_vector(3 downto 0) := "1000";
		constant C_SLTI   	: std_logic_vector(3 downto 0) := "1001";
		constant C_SLTIU  	: std_logic_vector(3 downto 0) := "1010";
		constant C_ANDI   	: std_logic_vector(3 downto 0) := "1011";
		constant C_ORI    	: std_logic_vector(3 downto 0) := "1100";
		constant C_XORI   	: std_logic_vector(3 downto 0) := "1101";
		constant C_SUBIU  	: std_logic_vector(3 downto 0) := "1110";

		-- ALUOp for Branch Instructions
		constant C_BR_BEQ   : std_logic_vector(3 downto 0) := "0010";	
		constant C_BR_BNE   : std_logic_vector(3 downto 0) := "0011";	
		constant C_BR_BLEZ 	: std_logic_vector(3 downto 0) := "0100";	
		constant C_BR_BGTZ  : std_logic_vector(3 downto 0) := "0101";	
		constant C_BR_BLTZ  : std_logic_vector(3 downto 0) := "0110";	
		constant C_BR_BGEZ 	: std_logic_vector(3 downto 0) := "0111";
		constant C_JAL_OP   : std_logic_vector(3 downto 0) := "1111"; -- Jump and Link
		
		-- ALUOp for Instruction states that intrinsically use the ADD operation at certain points, i.e. computing memory address for LW Instruction
		constant C_ADD_only : std_logic_vector(3 downto 0) := "0000";
end package ALUOp_codes_pkg;
	