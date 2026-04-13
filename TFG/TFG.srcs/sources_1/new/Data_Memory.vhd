----------------------------------------------------------------------------------
-- Module Name: Data_memory - Behavioral
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.System_Config_Pkg.ALL;
use work.ISA_Config_Pkg.ALL;

entity Data_memory is
    port (
        clk     : in  STD_LOGIC;
        we      : in  STD_LOGIC;
        funct3  : in  STD_LOGIC_VECTOR (FUNCT3_SIZE - 1 downto 0);
        Result  : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
        addr    : in  STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
        data_in : in  STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0)
    );
end Data_memory;

architecture Behavioral of Data_memory is
    type ram_type is array(0 to (2**ADDR_WIDTH) - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal RAM      : ram_type := (others => (others => '0'));
    signal addr_idx : integer range 0 to (2**ADDR_WIDTH) - 1;
    signal byte_off : std_logic_vector(1 downto 0);
begin
    addr_idx <= to_integer(unsigned(addr(ADDR_WIDTH + 1 downto 2)));
    byte_off <= addr(1 downto 0);

    process(clk)
        variable word_v : std_logic_vector(DATA_WIDTH - 1 downto 0);
    begin
        if rising_edge(clk) then
            if we = '1' then
                word_v := RAM(addr_idx);

                case funct3 is
                    when FUNCT3_SB =>
                        case byte_off is
                            when "00" =>
                                word_v(7 downto 0) := data_in(7 downto 0);
                            when "01" =>
                                word_v(15 downto 8) := data_in(7 downto 0);
                            when "10" =>
                                word_v(23 downto 16) := data_in(7 downto 0);
                            when others =>
                                word_v(31 downto 24) := data_in(7 downto 0);
                        end case;

                    when FUNCT3_SH =>
                        if byte_off(1) = '0' then
                            word_v(15 downto 0) := data_in(15 downto 0);
                        else
                            word_v(31 downto 16) := data_in(15 downto 0);
                        end if;

                    when others =>
                        word_v := data_in;
                end case;

                RAM(addr_idx) <= word_v;
            end if;
        end if;
    end process;

    Result <= RAM(addr_idx);
end Behavioral;
