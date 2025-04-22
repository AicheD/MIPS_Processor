-- Student: Harry Zarcadoolas, Section: 11091, Course: EEL4712C Digital Design
-- IR codes package for MIPS Processor, extracted and built upon: https://github.com/analogdanny/MIPS
library ieee;
use ieee.std_logic_1164.all;

package IR_codes_pkg is	
    constant C_RTYPE_I  : std_logic_vector(5 downto 0) := "000000";	
	constant C_BEQ      : std_logic_vector(5 downto 0) := "000100";
	constant C_BNE      : std_logic_vector(5 downto 0) := "000101";
	constant C_BLEZ     : std_logic_vector(5 downto 0) := "000110";
	constant C_BGTZ     : std_logic_vector(5 downto 0) := "000111";
	constant C_BLTZ     : std_logic_vector(5 downto 0) := "000001";
	constant C_BGEZ     : std_logic_vector(5 downto 0) := "000001";
	constant C_HALT     : std_logic_vector(5 downto 0) := "111111";
	constant C_J        : std_logic_vector(5 downto 0) := "000010";
	constant C_JR       : std_logic_vector(5 downto 0) := "000000";
	constant C_JAL      : std_logic_vector(5 downto 0) := "000011";
	constant C_JR_5to0  : std_logic_vector(5 downto 0) := "001000";
	constant C_LW       : std_logic_vector(5 downto 0) := "100011";
	constant C_SW       : std_logic_vector(5 downto 0) := "101011";
	constant C_ADDIU_I  : std_logic_vector(5 downto 0) := "001001";
	constant C_SLTI_I   : std_logic_vector(5 downto 0) := "001010";
	constant C_SLTIU_I  : std_logic_vector(5 downto 0) := "001011";
	constant C_ANDI_I   : std_logic_vector(5 downto 0) := "001100";
	constant C_ORI_I    : std_logic_vector(5 downto 0) := "001101";
	constant C_XORI_I   : std_logic_vector(5 downto 0) := "001110";
	constant C_SUBIU_I  : std_logic_vector(5 downto 0) := "010000";
	constant C_MULT     : std_logic_vector(5 downto 0) := "011000";
	constant C_MULTU    : std_logic_vector(5 downto 0) := "011001";
	constant C_MFHI	    : std_logic_vector(5 downto 0) := "010000";
	constant C_MFLO     : std_logic_vector(5 downto 0) := "010010";
end package IR_codes_pkg;