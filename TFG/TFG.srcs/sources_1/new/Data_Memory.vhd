----------------------------------------------------------------------------------
-- Module Name: Data_memory - Behavioral
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.System_Config_Pkg.ALL;

entity Data_memory is
    port (
        clk     : in  STD_LOGIC;
        we      : in  STD_LOGIC;
        Result  : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
        addr    : in  STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
        data_in : in  STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0)
    );
end Data_memory;

architecture Behavioral of Data_memory is
    type ram_type is array(0 to (2**ADDR_WIDTH) - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal RAM      : ram_type := (others => (others => '0'));
    signal addr_idx : integer range 0 to (2**ADDR_WIDTH) - 1;
begin
    addr_idx <= to_integer(unsigned(addr(ADDR_WIDTH + 1 downto 2)));

    process(clk)
    begin
        if rising_edge(clk) then
            if we = '1' then
                RAM(addr_idx) <= data_in;
            end if;
        end if;
    end process;

    Result <= RAM(addr_idx);
end Behavioral;