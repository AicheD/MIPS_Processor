-- Student: Harry Zarcadoolas, Section: 11091, Course: EEL4712C Digital Design
-- Memory Combinatorial Logic for Memory Module of MIPS Processor
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity mem_logic is
	generic(
		width : positive := 32
	);
    port (
        MemWrite			: in std_logic;
        addr     			: in std_logic_vector(width - 1 downto 0);
		OutPort_en, ram_wen : out std_logic;
		RdDataSel 			: out std_logic_vector(1 downto 0)
    );
end mem_logic;


architecture BHV of mem_logic is

begin

	MEM_LOGIC : process(MemWrite, addr)
	begin
		-- default values
		RAM_Wen <= '0';
		OutPort_en <= '0';
		RdDataSel <= "10";
			
		if (MemWrite = '1') then
			-- write to outport or RAM
			if (addr = x"0000FFFC") then		
				OutPort_en <= '1';			
			elsif (unsigned(addr) < 1024) then
				RAM_Wen <= '1';				
			end if;
		else
			if (unsigned(addr) < 1024) then
				-- read from RAM		
				RdDataSel <= "10";
			elsif (addr = x"0000FFF8") then		
				-- read from InPort0
				RdDataSel <= "00";
			elsif (addr = x"0000FFFC") then
				-- read from InPort1		
				RdDataSel <= "01";
			end if;
		end if;
	end process MEM_LOGIC;

end BHV;