library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_Procesador_1_0_wrapper is
end tb_Procesador_1_0_wrapper;

architecture sim of tb_Procesador_1_0_wrapper is
    constant CLK_PERIOD : time := 10 ns; -- 100 MHz

    signal clk_0 : std_logic := '0';
    signal rst_0 : std_logic := '0';

    procedure wait_cycles(signal clk : in std_logic; constant n : natural) is
    begin
        for i in 1 to n loop
            wait until rising_edge(clk);
        end loop;
    end procedure;

begin
    -- DUT: Block Design wrapper
    DUT : entity work.Procesador_1_0_wrapper
        port map (
            clk_0 => clk_0,
            rst_0 => rst_0
        );

    -- Clock generation
    clk_gen : process
    begin
        while true loop
            clk_0 <= '0';
            wait for CLK_PERIOD / 2;
            clk_0 <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Stimulus
    stim_proc : process
    begin
        -- NOTE:
        -- Although BD metadata may say ACTIVE_LOW, your RTL reset logic is active-high.
        -- This TB drives reset high first to match the RTL behavior.
        rst_0 <= '1';
        wait_cycles(clk_0, 10);

        rst_0 <= '0';
        wait_cycles(clk_0, 400);

        -- End simulation
        assert false report "TB finished" severity failure;
        wait;
    end process;

end sim;