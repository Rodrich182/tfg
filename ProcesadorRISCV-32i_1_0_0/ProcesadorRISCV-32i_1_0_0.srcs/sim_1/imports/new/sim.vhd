library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library std;
use std.env.all;

entity sim is
end sim;

architecture Behavioral of sim is
    constant CLK_PERIOD            : time := 10 ns; -- 100 MHz
    constant WAIT_SHORT_CYCLES     : natural := 1500000;
    constant WAIT_LONG_CYCLES      : natural := 8000000;
    constant ANIMATION_EXIT_HOLD   : time := 20 ms;
    constant RESUME_HIGH_CYCLES    : natural := 600000;
    constant RESUME_GAP_CYCLES     : natural := 50000;
    constant BTN_STAGE_HIGH_CYCLES : natural := 600000;
    constant BTN_STAGE_GAP_CYCLES  : natural := 50000;

    signal clk_s            : std_logic := '0';
    signal rst_s            : std_logic := '0';
    signal btn_s            : std_logic_vector(3 downto 0) := (others => '0');
    signal btn_sel_s        : std_logic;
    signal halted_s         : std_logic;
    signal led_s            : std_logic_vector(3 downto 0);
    signal led_sel_s        : std_logic;
    signal ram_sel_s        : std_logic;
    signal resume_pulse_s   : std_logic;
    signal store_data_dbg_s : std_logic_vector(31 downto 0);

    procedure wait_cycles(signal clk_i : in std_logic; constant n : natural) is
    begin
        for i in 1 to n loop
            wait until rising_edge(clk_i);
        end loop;
    end procedure;

    procedure pulse_button(
        signal clk_i  : in std_logic;
        signal btn_io : inout std_logic_vector(3 downto 0);
        constant idx  : natural;
        constant high_cycles : natural := 8;
        constant gap_cycles  : natural := 8
    ) is
    begin
        btn_io(idx) <= '1';
        wait_cycles(clk_i, high_cycles);
        btn_io(idx) <= '0';
        wait_cycles(clk_i, gap_cycles);
    end procedure;

    procedure wait_until_halted(
        signal clk_i     : in std_logic;
        signal halted_i  : in std_logic;
        constant max_cycles : natural;
        constant label_s : string
    ) is
    begin
        for i in 0 to max_cycles loop
            if halted_i = '1' then
                return;
            end if;
            wait until rising_edge(clk_i);
        end loop;

        assert false
            report "Timeout waiting for halt at " & label_s
            severity failure;
    end procedure;

    procedure wait_until_running(
        signal clk_i     : in std_logic;
        signal halted_i  : in std_logic;
        constant max_cycles : natural;
        constant label_s : string
    ) is
    begin
        for i in 0 to max_cycles loop
            if halted_i = '0' then
                return;
            end if;
            wait until rising_edge(clk_i);
        end loop;

        assert false
            report "Timeout waiting for run state at " & label_s
            severity failure;
    end procedure;

    procedure wait_for_led(
        signal clk_i     : in std_logic;
        signal led_i     : in std_logic_vector(3 downto 0);
        constant expected : std_logic_vector(3 downto 0);
        constant max_cycles : natural;
        constant label_s : string
    ) is
    begin
        for i in 0 to max_cycles loop
            if led_i = expected then
                return;
            end if;
            wait until rising_edge(clk_i);
        end loop;

        assert false
            report "Timeout waiting for LED pattern at " & label_s
            severity failure;
    end procedure;

    function has_unknown(vec : std_logic_vector) return boolean is
    begin
        for i in vec'range loop
            if vec(i) /= '0' and vec(i) /= '1' then
                return true;
            end if;
        end loop;
        return false;
    end function;
begin
    DUT : entity work.cpu_2_0_0_wrapper
        port map (
            btn_i_0_0            => btn_s,
            btn_sel_o_0_0        => btn_sel_s,
            clk_0_0              => clk_s,
            halted_o_0_0         => halted_s,
            led_o_0_0            => led_s,
            led_sel_o_0_0        => led_sel_s,
            ram_sel_o_0_0        => ram_sel_s,
            resume_pulse_o_0_0   => resume_pulse_s,
            rst_0_0              => rst_s,
            store_data_dbg_o_0_0 => store_data_dbg_s
        );

    clk_proc : process
    begin
        while true loop
            clk_s <= '0';
            wait for CLK_PERIOD / 2;
            clk_s <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    trace_proc : process(clk_s)
        variable last_led_v          : std_logic_vector(3 downto 0) := (others => 'U');
        variable last_halted_v       : std_logic := 'U';
        variable last_resume_pulse_v : std_logic := 'U';
    begin
        if rising_edge(clk_s) then
            if led_s /= last_led_v and not has_unknown(led_s) then
                report "TRACE led=" & integer'image(to_integer(unsigned(led_s))) severity note;
                last_led_v := led_s;
            end if;

            if halted_s /= last_halted_v then
                report "TRACE halted=" & std_logic'image(halted_s) severity note;
                last_halted_v := halted_s;
            end if;

            if resume_pulse_s /= last_resume_pulse_v then
                report "TRACE resume_pulse=" & std_logic'image(resume_pulse_s) severity note;
                last_resume_pulse_v := resume_pulse_s;
            end if;
        end if;
    end process;

    stim_proc : process
    begin
        report "TB: reset" severity note;
        rst_s <= '1';
        btn_s <= (others => '0');
        wait_cycles(clk_s, 12);

        rst_s <= '0';
        wait_cycles(clk_s, 4);

        report "TB: waiting for first breakpoint, expected FIB(2)=1" severity note;
        wait_until_halted(clk_s, halted_s, WAIT_SHORT_CYCLES, "first ecall");
        wait_for_led(clk_s, led_s, "0001", WAIT_SHORT_CYCLES, "FIB(2)");

        report "TB: resume to second breakpoint, expected LED=15" severity note;
        pulse_button(clk_s, btn_s, 0, high_cycles => RESUME_HIGH_CYCLES, gap_cycles => RESUME_GAP_CYCLES);
        wait_until_running(clk_s, halted_s, WAIT_SHORT_CYCLES, "after first resume");
        wait_until_halted(clk_s, halted_s, WAIT_SHORT_CYCLES, "second ecall");
        wait_for_led(clk_s, led_s, "1111", WAIT_SHORT_CYCLES, "all leds on");

        report "TB: resume into counter stage" severity note;
        pulse_button(clk_s, btn_s, 0, high_cycles => RESUME_HIGH_CYCLES, gap_cycles => RESUME_GAP_CYCLES);
        wait_until_running(clk_s, halted_s, WAIT_SHORT_CYCLES, "counter stage");

        report "TB: increment counter with button 1" severity note;
        pulse_button(clk_s, btn_s, 1, high_cycles => BTN_STAGE_HIGH_CYCLES, gap_cycles => BTN_STAGE_GAP_CYCLES);
        wait_for_led(clk_s, led_s, "0001", WAIT_SHORT_CYCLES, "counter increment to 1");

        pulse_button(clk_s, btn_s, 1, high_cycles => BTN_STAGE_HIGH_CYCLES, gap_cycles => BTN_STAGE_GAP_CYCLES);
        wait_for_led(clk_s, led_s, "0010", WAIT_SHORT_CYCLES, "counter increment to 2");

        report "TB: exit counter stage with button 0" severity note;
        pulse_button(clk_s, btn_s, 0, high_cycles => BTN_STAGE_HIGH_CYCLES, gap_cycles => BTN_STAGE_GAP_CYCLES);
        wait_until_halted(clk_s, halted_s, WAIT_SHORT_CYCLES, "halt before animation");

        report "TB: resume into animation stage" severity note;
        pulse_button(clk_s, btn_s, 0, high_cycles => RESUME_HIGH_CYCLES, gap_cycles => RESUME_GAP_CYCLES);
        wait_until_running(clk_s, halted_s, WAIT_SHORT_CYCLES, "animation stage");
        wait_for_led(clk_s, led_s, "0001", WAIT_LONG_CYCLES, "animation pattern 1");
        wait_for_led(clk_s, led_s, "0010", WAIT_LONG_CYCLES, "animation pattern 2");

        report "TB: hold button 0 to leave animation" severity note;
        btn_s(0) <= '1';
        wait for ANIMATION_EXIT_HOLD;
        btn_s(0) <= '0';
        wait_until_halted(clk_s, halted_s, WAIT_LONG_CYCLES, "halt after animation");

        report "TB: resume into final forever loop" severity note;
        pulse_button(clk_s, btn_s, 0, high_cycles => RESUME_HIGH_CYCLES, gap_cycles => RESUME_GAP_CYCLES);
        wait_until_running(clk_s, halted_s, WAIT_SHORT_CYCLES, "forever loop");
        wait_for_led(clk_s, led_s, "0000", WAIT_SHORT_CYCLES, "final LED=0");
        wait_cycles(clk_s, 40);

        assert led_s = "0000"
            report "Final LED value is not 0"
            severity failure;

        assert halted_s = '0'
            report "CPU should be running after the last resume"
            severity failure;

        assert not has_unknown(store_data_dbg_s)
            report "store_data_dbg has unknown values"
            severity failure;

        report "TB PASSED: cpu_2_0_0_wrapper completed the four-stage FPGA demo sequence" severity note;
        finish;
    end process;

    watchdog_proc : process
    begin
        wait for 200 ms;
        assert false
            report "Global simulation timeout"
            severity failure;
        wait;
    end process;
end Behavioral;
