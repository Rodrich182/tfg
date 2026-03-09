----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.01.2026 02:44:05
-- Design Name: 
-- Module Name: ALU - Behavioral
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.System_Config_Pkg.ALL;
use work.ISA_Config_Pkg.ALL;

entity ALU is
    port (
        in1  : in  STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
        in2  : in  STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
        op   : in  STD_LOGIC_VECTOR (OPP_SIZE - 1 downto 0);
        res  : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
        zero : out STD_LOGIC;
        lt   : out STD_LOGIC;
        ltu  : out STD_LOGIC
    );
end ALU;

architecture Behavioral of ALU is
    signal res_temp : std_logic_vector(DATA_WIDTH - 1 downto 0);
begin
    lt  <= '1' when signed(in1)   < signed(in2)   else '0';
    ltu <= '1' when unsigned(in1) < unsigned(in2) else '0';

    process (in1, in2, op)
    begin
        res_temp <= (others => '0');

        case op is
            when ALUCTRL_ADD =>
                res_temp <= std_logic_vector(signed(in1) + signed(in2));
            when ALUCTRL_SUB =>
                res_temp <= std_logic_vector(signed(in1) - signed(in2));
            when ALUCTRL_SLL =>
                res_temp <= std_logic_vector(shift_left(unsigned(in1), to_integer(unsigned(in2(SHAMT_END downto SHAMT_INIT)))));
            when ALUCTRL_SLT =>
                if signed(in1) < signed(in2) then
                    res_temp <= std_logic_vector(to_unsigned(1, DATA_WIDTH));
                else
                    res_temp <= (others => '0');
                end if;
            when ALUCTRL_SLTU =>
                if unsigned(in1) < unsigned(in2) then
                    res_temp <= std_logic_vector(to_unsigned(1, DATA_WIDTH));
                else
                    res_temp <= (others => '0');
                end if;
            when ALUCTRL_SEQ =>
                if in1 = in2 then
                    res_temp <= std_logic_vector(to_unsigned(1, DATA_WIDTH));
                else
                    res_temp <= (others => '0');
                end if;
            when ALUCTRL_XOR =>
                res_temp <= in1 XOR in2;
            when ALUCTRL_SRL =>
                res_temp <= std_logic_vector(shift_right(unsigned(in1), to_integer(unsigned(in2(SHAMT_END downto SHAMT_INIT)))));
            when ALUCTRL_SRA =>
                res_temp <= std_logic_vector(shift_right(signed(in1), to_integer(unsigned(in2(SHAMT_END downto SHAMT_INIT)))));
            when ALUCTRL_OR =>
                res_temp <= in1 or in2;
            when ALUCTRL_AND =>
                res_temp <= in1 and in2;
            when others =>
                res_temp <= (others => '0');
        end case;
    end process;

    res  <= res_temp;
    zero <= '1' when unsigned(res_temp) = 0 else '0';
end Behavioral;