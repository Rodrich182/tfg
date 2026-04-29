----------------------------------------------------------------------------------
-- Module Name: Banco_Registros - Behavioral
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.System_Config_Pkg.ALL;

entity Banco_Registros is
    port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        a1  : in STD_LOGIC_VECTOR (ADDR_LENGTH - 1 downto 0);
        a2  : in STD_LOGIC_VECTOR (ADDR_LENGTH - 1 downto 0);
        a3  : in STD_LOGIC_VECTOR (ADDR_LENGTH - 1 downto 0);
        wd3 : in STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
        we3 : in STD_LOGIC;
        rd1 : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
        rd2 : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0)
    );
end Banco_Registros;

architecture Behavioral of Banco_Registros is
    type reg_array is array (0 to REG_NUM - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal regs : reg_array := (others => (others => '0'));
begin
    process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                regs <= (others => (others => '0'));
            elsif we3 = '1' then
                if unsigned(a3) /= 0 then
                    regs(to_integer(unsigned(a3))) <= wd3;
                end if;
            end if;
        end if;
    end process;

    rd1 <= (others => '0') when unsigned(a1) = 0 else regs(to_integer(unsigned(a1)));
    rd2 <= (others => '0') when unsigned(a2) = 0 else regs(to_integer(unsigned(a2)));
end Behavioral;