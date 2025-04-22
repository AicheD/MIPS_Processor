-- Student: Harry Zarcadoolas, Section: 11091, Course: EEL4712C Digital Design
-- ALU unit for MIPS processor
-- Description: The ALU supports basic arithmetic, including logical operations, and 
-- shift operations as well as branch operations and jump register functionality.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 
use work.ALU_OpSelect_codes_pkg.all; -- Import OpSelect codes package

entity ALU is
	generic (
		WIDTH : positive := 32
	);
	port (
		A, B 			 	: in std_logic_vector(WIDTH-1 downto 0);
		OPSelect 		 	: in std_logic_vector(5 downto 0);
		Shift   		 	: in std_logic_vector(4 downto 0); -- Shift amount from IR[10:6]
		Result, ResultHI 	: out std_logic_vector(WIDTH-1 downto 0);
		BranchTaken 	 	: out std_logic
	);
end ALU;	

architecture BHV of ALU is
begin
	process(A, B, Shift, OPSelect)

		variable temp : unsigned(WIDTH-1 downto 0);
		-- create (WIDTH*2) 64-bit variables for operations have Result and ResultHi
		variable temp_long : signed((WIDTH*2)-1 downto 0);
		variable temp_longu : unsigned((WIDTH*2)-1 downto 0);

	begin
		-- assign default values
		Result <= (others => '0');
		ResultHi <= (others => '0');
		BranchTaken <= '0';
	
		case OPSelect is
			-- Basic operations
			when OP_ADD =>
				Result <= std_logic_vector(unsigned(A) + unsigned(B));
				
			when OP_SUB =>
				Result <= std_logic_vector(unsigned(A) - unsigned(B));
				
			when OP_AND =>
				Result <= A and B;
			
			when OP_OR =>
				Result <= A or B;
			
			when OP_XOR =>
				Result <= A xor B;
								
			when OP_MULT =>
				temp_long := signed(A) * signed(B);
				Result <= std_logic_vector(temp_long(WIDTH-1 downto 0));
				ResultHI <= std_logic_vector(temp_long((WIDTH*2)-1 downto WIDTH));
			
			when OP_MULTU =>
				temp_longu := unsigned(A) * unsigned(B);
				Result <= std_logic_vector(temp_longu(WIDTH-1 downto 0));
				ResultHI <= std_logic_vector(temp_longu((WIDTH*2)-1 downto WIDTH));
			
			-- Shift operations
			when OP_SRL =>
				Result <= std_logic_vector(shift_right(unsigned(B), to_integer(unsigned(Shift))));
			
			when OP_SLL =>
				Result <= std_logic_vector(shift_left(unsigned(B), to_integer(unsigned(Shift))));
			
			when OP_SRA =>
				Result <= std_logic_vector(shift_right(signed(B), to_integer(unsigned(Shift))));
		
			when OP_SLT =>
				if(signed(A) < signed(B)) then
					Result <= std_logic_vector(to_unsigned(1, WIDTH));
				end if;
					
			when OP_SLTU =>
				if(unsigned(A) < unsigned(B)) then
					Result <= std_logic_vector(to_unsigned(1, WIDTH));
				end if;
			
			-- Branch operations (set flag)	
			when OP_BEQ =>
				if (unsigned(A) = unsigned(B)) then
					BranchTaken <= '1';
				end if;
			
			when OP_BNE =>
				if (unsigned(A) /= unsigned(B)) then
					BranchTaken <= '1';
				end if;
			
			when OP_BLEZ =>
				if (signed(A) <= to_signed(0, WIDTH)) then
					BranchTaken <= '1';
				end if;
			
			when OP_BGTZ =>
				if (signed(A) > to_signed(0, WIDTH)) then
					BranchTaken <= '1';
				end if;
			
			when OP_BLTZ =>
				if (signed(A) < to_signed(0, WIDTH)) then
					BranchTaken <= '1';
				end if;
			
			when OP_BGEZ =>
				if (signed(A) >= to_signed(0, WIDTH)) then
					BranchTaken <= '1';
				end if;

			-- Jump register operation (basically a branch to the address in A)
			when OP_JR =>
				Result <= A;
				BranchTaken <= '1';
				
			when others => NULL;
		end case;
	end process;
end BHV;
