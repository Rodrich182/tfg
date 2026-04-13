library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package RV32I_Wrapper_Test_Vectors_Pkg is
    type store_event_t is record
        addr : std_logic_vector(31 downto 0);
        data : std_logic_vector(31 downto 0);
    end record;

    type store_event_array_t is array (natural range <>) of store_event_t;

    constant RV32I_ALU_UPPER_HALT_PC : std_logic_vector(31 downto 0) := x"000000C8";
    constant RV32I_ALU_UPPER_EXPECTED_STORES : store_event_array_t(0 to 21) := (
        0 => (addr => x"00000000", data => x"0000000F"),
        1 => (addr => x"00000004", data => x"00000005"),
        2 => (addr => x"00000008", data => x"00000000"),
        3 => (addr => x"0000000C", data => x"0000000F"),
        4 => (addr => x"00000010", data => x"0000000F"),
        5 => (addr => x"00000014", data => x"00000014"),
        6 => (addr => x"00000018", data => x"00000002"),
        7 => (addr => x"0000001C", data => x"FFFFFFFC"),
        8 => (addr => x"00000020", data => x"00000001"),
        9 => (addr => x"00000024", data => x"00000001"),
        10 => (addr => x"00000028", data => x"00000011"),
        11 => (addr => x"0000002C", data => x"00000002"),
        12 => (addr => x"00000030", data => x"0000000D"),
        13 => (addr => x"00000034", data => x"0000000A"),
        14 => (addr => x"00000038", data => x"00000001"),
        15 => (addr => x"0000003C", data => x"00000001"),
        16 => (addr => x"00000040", data => x"00000028"),
        17 => (addr => x"00000044", data => x"00000005"),
        18 => (addr => x"00000048", data => x"FFFFFFF8"),
        19 => (addr => x"0000004C", data => x"12345000"),
        20 => (addr => x"00000050", data => x"000010B4"),
        21 => (addr => x"00000054", data => x"00000055")
    );

    constant RV32I_MEM_HALT_PC : std_logic_vector(31 downto 0) := x"0000007C";
    constant RV32I_MEM_EXPECTED_STORES : store_event_array_t(0 to 13) := (
        0 => (addr => x"00000080", data => x"000080FF"),
        1 => (addr => x"00000000", data => x"000080FF"),
        2 => (addr => x"00000004", data => x"FFFFFFFF"),
        3 => (addr => x"00000008", data => x"000000FF"),
        4 => (addr => x"0000000C", data => x"FFFFFF80"),
        5 => (addr => x"00000010", data => x"00000080"),
        6 => (addr => x"00000014", data => x"FFFF80FF"),
        7 => (addr => x"00000018", data => x"000080FF"),
        8 => (addr => x"00000084", data => x"FFFFFFAA"),
        9 => (addr => x"0000001C", data => x"000000AA"),
        10 => (addr => x"00000020", data => x"000000AA"),
        11 => (addr => x"00000088", data => x"00001234"),
        12 => (addr => x"00000024", data => x"00001234"),
        13 => (addr => x"00000028", data => x"00001234")
    );

    constant RV32I_CTRL_HALT_PC : std_logic_vector(31 downto 0) := x"00000084";
    constant RV32I_CTRL_EXPECTED_STORES : store_event_array_t(0 to 2) := (
        0 => (addr => x"00000000", data => x"00000048"),
        1 => (addr => x"00000004", data => x"0000005C"),
        2 => (addr => x"00000008", data => x"00000070")
    );

    constant RV32I_EBREAK_HALT_PC : std_logic_vector(31 downto 0) := x"0000000C";
    constant RV32I_EBREAK_EXPECTED_STORES : store_event_array_t(0 to 0) := (
        0 => (addr => x"00000000", data => x"00000066")
    );

end package RV32I_Wrapper_Test_Vectors_Pkg;
