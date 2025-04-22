-- Student: Harry Zarcadoolas, Section: 11091, Course: EEL4712C Digital Design
-- Basic register module
library ieee;
use ieee.std_logic_1164.all;

entity reg is
  generic (
    WIDTH : positive := 32
  );
  port (
    clk    : in  std_logic;
    rst    : in  std_logic;
    en     : in  std_logic;
    d  : in  std_logic_vector(WIDTH-1 downto 0);
    q : out std_logic_vector(WIDTH-1 downto 0)
  );
end reg;

architecture BHV of reg is
begin
  process(clk, rst)
  begin
    if (rst = '1') then
      q <= (others => '0');
    elsif (clk'event and clk = '1') then
      if (en = '1') then
        q <= d;
      end if;
    end if;
  end process;
end BHV;
