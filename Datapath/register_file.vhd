-- Register file, commented/reviewed by Harry Zarcadoolas
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity register_file is 
	generic(
		WIDTH : positive := 32
	);
    port (
        clk          	: in std_logic;
        rst          	: in std_logic;
        RegWrite     	: in std_logic;
		JumpAndLink  	: in std_logic;
        Read_Reg1      	: in std_logic_vector(4 downto 0);
        Read_Reg2      	: in std_logic_vector(4 downto 0);
        WriteReg		: in std_logic_vector(4 downto 0);
        WriteData      	: in std_logic_vector(WIDTH-1 downto 0);
		Read_Data1      : out std_logic_vector(WIDTH-1 downto 0);
        Read_Data2      : out std_logic_vector(WIDTH-1 downto 0)
    );
end register_file;

architecture BHV of register_file is

	type registers_array is array(0 to WIDTH-1) of std_logic_vector(WIDTH-1 downto 0);
	signal registers : registers_array;

begin

	process(clk, rst)
	begin
		if (rst = '1') then
			-- clear each individual register
			for i in registers'range loop
				registers(i) <= (others => '0');
			end loop;
		elsif (rising_edge(clk)) then
			if(RegWrite = '1') then
				if (JumpAndLink = '1') then
					registers(31) <= WriteData;	-- if JAL, set the return adddress register (register 31, $ra)			
				else				
					registers(to_integer(unsigned(WriteReg))) <= WriteData; -- otherwise, write to target reg	
				end if;
			end if;
		end if;
	end process;
	
	-- NOTE: Data to be read will have to wait a cycle if trying to read from a register that was just written to
	Read_Data1 <= registers(to_integer(unsigned(Read_Reg1)));
	Read_Data2 <= registers(to_integer(unsigned(Read_Reg2)));

end BHV;