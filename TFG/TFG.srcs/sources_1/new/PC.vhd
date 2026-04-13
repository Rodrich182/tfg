library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.System_Config_Pkg.ALL;

entity PC is
    Port (
        clk     : in  STD_LOGIC;
        reset   : in  STD_LOGIC;
        PCEn    : in  STD_LOGIC;
        PCSrc   : in  STD_LOGIC;
        Addrin  : in  STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
        Addrout : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0)
    );
end PC;

architecture Behavioral of PC is
    signal pc_reg : STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                pc_reg <= (others => '0');
            elsif PCEn = '1' then
                if PCSrc = '1' then
                    pc_reg <= Addrin;
                else
                    pc_reg <= std_logic_vector(unsigned(pc_reg) + to_unsigned(PC_STEP, DATA_WIDTH));
                end if;
            end if;
        end if;
    end process;

    Addrout <= pc_reg;
end Behavioral;
