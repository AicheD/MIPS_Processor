library ieee;
use ieee.std_logic_1164.all;

entity mux_2to1 is
  generic (
    WIDTH : positive
  );
  port (
    in1    : in  std_logic_vector(WIDTH-1 downto 0);
    in2    : in  std_logic_vector(WIDTH-1 downto 0);
    sel    : in  std_logic;
    output : out std_logic_vector(WIDTH-1 downto 0)
  );
end mux_2to1;

architecture BHV of mux_2to1 is
begin
  with sel select
    output <=
      in1 when '0',
      in2 when others;
end BHV;