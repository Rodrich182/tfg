library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library std;
use std.env.all;
use work.RV32I_Wrapper_Test_Vectors_Pkg.ALL;

entity tb_rv32i_ctrl_wrapper is
end tb_rv32i_ctrl_wrapper;

architecture sim of tb_rv32i_ctrl_wrapper is
    constant CLK_PERIOD : time := 10 ns;
    constant STORE_COUNT : natural := RV32I_CTRL_EXPECTED_STORES'length;

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';

    signal ALUControl_0_0     : std_logic_vector(3 downto 0);
    signal MemWrite_0_0       : std_logic;
    signal RegWrite_0_0       : std_logic;
    signal alu_res_o_0        : std_logic_vector(31 downto 0);
    signal lt_o_0             : std_logic;
    signal ltu_o_0            : std_logic;
    signal pc_o_0_0           : std_logic_vector(31 downto 0);
    signal resultSrc_0_0      : std_logic_vector(1 downto 0);
    signal store_data_dbg_o_0 : std_logic_vector(31 downto 0);
    signal zero_o_0           : std_logic;

    signal store_index_s : natural range 0 to STORE_COUNT := 0;

    procedure wait_cycles(signal clk_i : in std_logic; constant n : natural) is
    begin
        for i in 1 to n loop
            wait until rising_edge(clk_i);
        end loop;
    end procedure;
begin
    DUT : entity work.Procesador_wrapper
        port map (
            ALUControl_0_0     => ALUControl_0_0,
            MemWrite_0_0       => MemWrite_0_0,
            RegWrite_0_0       => RegWrite_0_0,
            alu_res_o_0        => alu_res_o_0,
            clk_0_0            => clk,
            lt_o_0             => lt_o_0,
            ltu_o_0            => ltu_o_0,
            pc_o_0_0           => pc_o_0_0,
            resultSrc_0_0      => resultSrc_0_0,
            rst_0_0            => rst,
            store_data_dbg_o_0 => store_data_dbg_o_0,
            zero_o_0           => zero_o_0
        );

    clk_gen : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    monitor_proc : process(clk)
        variable idx : natural;
    begin
        if rising_edge(clk) then
            if rst = '0' and MemWrite_0_0 = '1' then
                idx := store_index_s;
                assert idx < STORE_COUNT
                    report "An unexpected extra store occurred in rv32i_ctrl"
                    severity failure;
                assert alu_res_o_0 = RV32I_CTRL_EXPECTED_STORES(idx).addr
                    report "Unexpected store address in rv32i_ctrl"
                    severity failure;
                assert store_data_dbg_o_0 = RV32I_CTRL_EXPECTED_STORES(idx).data
                    report "Unexpected store data in rv32i_ctrl"
                    severity failure;
                store_index_s <= store_index_s + 1;
            end if;
        end if;
    end process;

    stim_proc : process
    begin
        rst <= '1';
        wait_cycles(clk, 5);
        rst <= '0';

        wait until store_index_s = STORE_COUNT;
        wait_cycles(clk, 6);

        assert pc_o_0_0 = RV32I_CTRL_HALT_PC
            report "The PC did not halt at the expected address in rv32i_ctrl"
            severity failure;
        assert MemWrite_0_0 = '0'
            report "MemWrite remained asserted after halt in rv32i_ctrl"
            severity failure;

        report "rv32i_ctrl wrapper test passed" severity note;
        finish;
        wait;
    end process;

    watchdog_proc : process
    begin
        wait for 20 us;
        assert false
            report "Timeout in rv32i_ctrl wrapper test"
            severity failure;
        wait;
    end process;
end sim;
