library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Procesador_FPGA_Top is
    generic (
        LED_MMIO_ADDR_G : STD_LOGIC_VECTOR(31 downto 0) := x"00000100"
    );
    port (
        clk_i : in  STD_LOGIC;
        rst_i : in  STD_LOGIC;
        led_o : out STD_LOGIC_VECTOR(3 downto 0)
    );
end Procesador_FPGA_Top;

architecture Structural of Procesador_FPGA_Top is
    signal memwrite_s   : STD_LOGIC;
    signal alu_res_s    : STD_LOGIC_VECTOR(31 downto 0);
    signal store_data_s : STD_LOGIC_VECTOR(31 downto 0);
    signal led_reg_s    : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
begin
    U_CPU : entity work.Procesador_wrapper
        port map (
            ALUControl_0_0     => open,
            MemWrite_0_0       => memwrite_s,
            RegWrite_0_0       => open,
            alu_res_o_0        => alu_res_s,
            clk_0_0            => clk_i,
            lt_o_0             => open,
            ltu_o_0            => open,
            pc_o_0_0           => open,
            resultSrc_0_0      => open,
            rst_0_0            => rst_i,
            store_data_dbg_o_0 => store_data_s,
            zero_o_0           => open
        );

    process (clk_i)
    begin
        if rising_edge(clk_i) then
            if rst_i = '1' then
                led_reg_s <= (others => '0');
            elsif memwrite_s = '1' and alu_res_s = LED_MMIO_ADDR_G then
                led_reg_s <= store_data_s(3 downto 0);
            end if;
        end if;
    end process;

    led_o <= led_reg_s;
end Structural;
