-- Student: Harry Zarcadoolas, Section: 11091, Course: EEL4712C Digital Design
-- Testbench 2 for ALU — Exhaustive Testbench (8‑bit mode)
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.ALU_OpSelect_codes_pkg.all; -- Import OpSelect codes package

entity ALU_tb2 is
end ALU_tb2;

architecture TB of ALU_tb2 is
  -- limit the ALU to 8 bits so the exhaustive loop finishes in reasonable time
  constant WIDTH : integer := 8;

  -- DUT interface
  signal A, B        : std_logic_vector(WIDTH-1 downto 0);
  signal Shift       : std_logic_vector(4 downto 0);
  signal OPSelect    : std_logic_vector(5 downto 0);
  signal Result      : std_logic_vector(WIDTH-1 downto 0);
  signal ResultHI    : std_logic_vector(WIDTH-1 downto 0);
  signal BranchTaken : std_logic;
begin

  -- instantiate 8‑bit ALU
  U_ALU: entity work.ALU
    generic map ( WIDTH => WIDTH )
    port map (
      A           => A,
      B           => B,
      Shift       => Shift,
      OPSelect    => OPSelect,
      Result      => Result,
      ResultHI    => ResultHI,
      BranchTaken => BranchTaken
    );

    stimulus : process
        -- loop indices
        variable a_idx, b_idx : integer;
        variable s_idx        : integer;
        variable op_idx       : integer;

        -- for computing expected outputs
        variable uA, uB : unsigned(WIDTH-1 downto 0);
        variable sA, sB : signed(  WIDTH-1 downto 0);
        variable expR   : std_logic_vector(WIDTH-1 downto 0);
        variable expHI  : std_logic_vector(WIDTH-1 downto 0);
        variable expBT  : std_logic;

        -- temporaries for wide multiplies
        variable tmp_s : signed((WIDTH*2)-1 downto 0);
        variable tmp_u : unsigned((WIDTH*2)-1 downto 0);
        begin
        -- walk every combination
        for a_idx in 0 to 2**WIDTH-1 loop
        for b_idx in 0 to 2**WIDTH-1 loop
            for s_idx in 0 to 2**5-1 loop
            for op_idx in 0 to 63 loop
                -- drive DUT inputs
                A        <= std_logic_vector(to_unsigned(a_idx, WIDTH));
                B        <= std_logic_vector(to_unsigned(b_idx, WIDTH));
                Shift    <= std_logic_vector(to_unsigned(s_idx, 5));
                OPSelect <= std_logic_vector(to_unsigned(op_idx, 6));
                wait for 1 ns;

                -- compute expected
                uA := unsigned(A);
                uB := unsigned(B);
                sA := signed(A);
                sB := signed(B);
                expR  := (others => '0');
                expHI := (others => '0');
                expBT := '0';

                case OPSelect is
                when OP_ADD  => expR := std_logic_vector(uA + uB);
                when OP_SUB  => expR := std_logic_vector(uA - uB);
                when OP_MULT  =>
                    tmp_s := sA * sB;
                    expR  := std_logic_vector(tmp_s(WIDTH-1 downto 0));
                    expHI := std_logic_vector(tmp_s((WIDTH*2)-1 downto WIDTH));
                when OP_MULTU =>
                    tmp_u := uA * uB;
                    expR  := std_logic_vector(tmp_u(WIDTH-1 downto 0));
                    expHI := std_logic_vector(tmp_u((WIDTH*2)-1 downto WIDTH));
                when OP_AND   => expR := std_logic_vector(uA and uB);
                when OP_OR    => expR := std_logic_vector(uA or uB);
                when OP_XOR   => expR := std_logic_vector(uA xor uB);
                when OP_SRL   => expR := std_logic_vector(shift_right(uB, to_integer(unsigned(Shift))));
                when OP_SRA   => expR := std_logic_vector(shift_right(sB, to_integer(unsigned(Shift))));
                when OP_SLT   => if sA < sB then expR(0) := '1'; expBT := '1'; end if;
                when OP_SLTU  => if uA < uB then expR(0) := '1'; expBT := '1'; end if;
                when OP_BLEZ  => if sA <= to_signed(0, WIDTH) then expBT := '1'; end if;
                when OP_BGTZ  => if sA >  to_signed(0, WIDTH) then expBT := '1'; end if;
                when OP_SLL   => expR := std_logic_vector(shift_left(unsigned(uB), to_integer(unsigned(Shift))));
                when OP_BEQ   => if A = B then expBT := '1'; end if;
                when OP_BNE   => if A /= B then expBT := '1'; end if;
                when OP_BLTZ  => if sA <  to_signed(0, WIDTH) then expBT := '1'; end if;
                when OP_BGEZ  => if sA >= to_signed(0, WIDTH) then expBT := '1'; end if;
                when OP_JR    =>
                    expR  := A;
                    expBT := '1';
                when others   => null;
                end case;

                -- check DUT vs expected
                assert (Result = expR and ResultHI = expHI and BranchTaken = expBT)
                report
                    "Mismatch A=" & integer'image(a_idx) &
                    " B=" & integer'image(b_idx) &
                    " S=" & integer'image(s_idx) &
                    " OP=" & integer'image(to_integer(unsigned(OPSelect))) &
                    " got R=" & integer'image(to_integer(unsigned(Result))) &
                    "/" & integer'image(to_integer(unsigned(ResultHI))) &
                    " BT=" & std_logic'image(BranchTaken)
                severity error;
            end loop;
            end loop;
        end loop;
        end loop;
    
        report "Exhaustive ALU Test Completed! Author: Harry Zarcadoolas" severity note;
        wait;  -- all done
  end process;

end TB;