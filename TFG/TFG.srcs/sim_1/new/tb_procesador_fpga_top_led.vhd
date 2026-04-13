library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library std;
use std.env.all;

entity tb_procesador_fpga_top_led is
end tb_procesador_fpga_top_led;

architecture sim of tb_procesador_fpga_top_led is
    constant CLK_PERIOD   : time := 10 ns;
    constant EXPECTED_LED : STD_LOGIC_VECTOR(3 downto 0) := "1101";

    signal clk_s : STD_LOGIC := '0';
    signal rst_s : STD_LOGIC := '0';
    signal led_s : STD_LOGIC_VECTOR(3 downto 0);

    procedure wait_cycles(signal clk_i : in STD_LOGIC; constant n : natural) is
    begin
        for i in 1 to n loop
            wait until rising_edge(clk_i);
        end loop;
    end procedure;
begin
    DUT : entity work.Procesador_FPGA_Top
        port map (
            clk_i => clk_s,
            rst_i => rst_s,
            led_o => led_s
        );

    clk_gen : process
    begin
        while true loop
            clk_s <= '0';
            wait for CLK_PERIOD / 2;
            clk_s <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    stim_proc : process
    begin
        rst_s <= '1';
        wait_cycles(clk_s, 5);
        rst_s <= '0';

        wait until led_s = EXPECTED_LED;
        wait_cycles(clk_s, 6);

        assert led_s = EXPECTED_LED
            report "The LED output did not latch the expected binary value"
            severity failure;

        report "FPGA LED top test passed" severity note;
        finish;
        wait;
    end process;

    watchdog_proc : process
    begin
        wait for 10 us;
        assert false
            report "Timeout in FPGA LED top test"
            severity failure;
        wait;
    end process;
end sim;
