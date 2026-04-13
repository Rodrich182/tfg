library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library std;
use std.env.all;

entity tb_rv32i_instruction_walk_wrapper is
end tb_rv32i_instruction_walk_wrapper;

architecture sim of tb_rv32i_instruction_walk_wrapper is
    constant CLK_PERIOD  : time := 10 ns;
    constant RUN_CYCLES  : natural := 400;

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';

    signal ALUControl_0_0     : std_logic_vector(3 downto 0);
    signal MemWrite_0_0       : std_logic;
    signal RegWrite_0_0       : std_logic;
    signal lt_o_0             : std_logic;
    signal ltu_o_0            : std_logic;
    signal pc_o_0_0           : std_logic_vector(31 downto 0);
    signal resultSrc_0_0      : std_logic_vector(1 downto 0);
    signal zero_o_0           : std_logic;
    signal alu_res_o_0        : std_logic_vector(31 downto 0);
    signal store_data_dbg_o_0 : std_logic_vector(31 downto 0);

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
            clk_0_0            => clk,
            lt_o_0             => lt_o_0,
            ltu_o_0            => ltu_o_0,
            pc_o_0_0           => pc_o_0_0,
            resultSrc_0_0      => resultSrc_0_0,
            rst_0_0            => rst,
            zero_o_0           => zero_o_0,
            alu_res_o_0        => alu_res_o_0,
            store_data_dbg_o_0 => store_data_dbg_o_0
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
    begin
        if rising_edge(clk) then
            if rst = '0' and MemWrite_0_0 = '1' then
                report "Store observed at address " &
                       integer'image(to_integer(unsigned(alu_res_o_0))) &
                       " with data " &
                       integer'image(to_integer(unsigned(store_data_dbg_o_0)))
                    severity note;
            end if;
        end if;
    end process;

    stim_proc : process
    begin
        rst <= '1';
        wait_cycles(clk, 5);
        rst <= '0';

        wait_cycles(clk, RUN_CYCLES);

        report "Instruction-walk simulation finished" severity note;
        finish;
        wait;
    end process;
end sim;
