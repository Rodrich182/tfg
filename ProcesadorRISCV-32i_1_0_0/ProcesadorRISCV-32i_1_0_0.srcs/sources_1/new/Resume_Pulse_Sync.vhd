library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Resume_Pulse_Sync is
    port (
        clk_i   : in  STD_LOGIC;
        rst_i   : in  STD_LOGIC;
        async_i : in  STD_LOGIC;
        sync_o  : out STD_LOGIC;
        pulse_o : out STD_LOGIC
    );
end Resume_Pulse_Sync;

architecture Behavioral of Resume_Pulse_Sync is
    constant DEBOUNCE_CYCLES_C : natural := 500000; -- 5 ms at 100 MHz

    signal sync_ff1_s      : STD_LOGIC := '0';
    signal sync_ff2_s      : STD_LOGIC := '0';
    signal stable_s        : STD_LOGIC := '0';
    signal stable_prev_s   : STD_LOGIC := '0';
    signal debounce_cnt_s  : natural range 0 to DEBOUNCE_CYCLES_C := 0;
begin
    process (clk_i)
    begin
        if rising_edge(clk_i) then
            if rst_i = '1' then
                sync_ff1_s     <= '0';
                sync_ff2_s     <= '0';
                stable_s       <= '0';
                stable_prev_s  <= '0';
                debounce_cnt_s <= 0;
            else
                sync_ff1_s    <= async_i;
                sync_ff2_s    <= sync_ff1_s;
                stable_prev_s <= stable_s;

                if sync_ff2_s = stable_s then
                    debounce_cnt_s <= 0;
                elsif debounce_cnt_s = DEBOUNCE_CYCLES_C - 1 then
                    stable_s       <= sync_ff2_s;
                    debounce_cnt_s <= 0;
                else
                    debounce_cnt_s <= debounce_cnt_s + 1;
                end if;
            end if;
        end if;
    end process;

    sync_o  <= stable_s;
    pulse_o <= stable_s and not stable_prev_s;
end Behavioral;
