-- Student: Harry Zarcadoolas, Section: 11091, Course: EEL4712C Digital Design
-- ALU Operation Select codes package
library ieee;
use ieee.std_logic_1164.all;

package ALU_OpSelect_codes_pkg is
	-- OpSelect
	constant OP_ADD   	: std_logic_vector(5 downto 0) := "100001";
	constant OP_SUB   	: std_logic_vector(5 downto 0) := "100011";
	constant OP_MULT  	: std_logic_vector(5 downto 0) := "011000";
	constant OP_MULTU 	: std_logic_vector(5 downto 0) := "011001";
	constant OP_AND   	: std_logic_vector(5 downto 0) := "100100";
	constant OP_OR    	: std_logic_vector(5 downto 0) := "100101";
	constant OP_XOR   	: std_logic_vector(5 downto 0) := "100110";
	constant OP_SRL   	: std_logic_vector(5 downto 0) := "000010";
	constant OP_SLL   	: std_logic_vector(5 downto 0) := "000000";
	constant OP_SRA   	: std_logic_vector(5 downto 0) := "000011";
	constant OP_SLT   	: std_logic_vector(5 downto 0) := "101010";
	constant OP_SLTU  	: std_logic_vector(5 downto 0) := "101011";
	constant OP_BEQ   	: std_logic_vector(5 downto 0) := "101100";
	constant OP_BNE   	: std_logic_vector(5 downto 0) := "101101";
	constant OP_BLEZ  	: std_logic_vector(5 downto 0) := "101110";
	constant OP_BGTZ  	: std_logic_vector(5 downto 0) := "101111";
	constant OP_BLTZ  	: std_logic_vector(5 downto 0) := "110001";
	constant OP_BGEZ  	: std_logic_vector(5 downto 0) := "110010";
	constant OP_JR    	: std_logic_vector(5 downto 0) := "001000";
	constant OP_MFHI	: std_logic_vector(5 downto 0) := "010000"; -- Move from HI reg
	constant OP_MFLO   	: std_logic_vector(5 downto 0) := "010010"; -- Move from LO reg
end ALU_OpSelect_codes_pkg;
