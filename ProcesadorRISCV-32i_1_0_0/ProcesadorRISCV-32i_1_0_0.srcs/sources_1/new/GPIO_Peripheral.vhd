library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity GPIO_Peripheral is
    port (
        clk_i       : in  STD_LOGIC;
        rst_i       : in  STD_LOGIC;
        led_we_i    : in  STD_LOGIC;
        wdata_i     : in  STD_LOGIC_VECTOR(31 downto 0);
        btn_i       : in  STD_LOGIC_VECTOR(3 downto 0);
        led_o       : out STD_LOGIC_VECTOR(3 downto 0);
        led_rdata_o : out STD_LOGIC_VECTOR(31 downto 0);
        btn_rdata_o : out STD_LOGIC_VECTOR(31 downto 0)
    );
end GPIO_Peripheral;

architecture Behavioral of GPIO_Peripheral is
    signal led_reg_s : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
begin
    process (clk_i)
    begin
        if rising_edge(clk_i) then
            if rst_i = '1' then
                led_reg_s <= (others => '0');
            elsif led_we_i = '1' then
                led_reg_s <= wdata_i(3 downto 0);
            end if;
        end if;
    end process;

    led_o       <= led_reg_s;
    led_rdata_o <= (31 downto 4 => '0') & led_reg_s;
    btn_rdata_o <= (31 downto 4 => '0') & btn_i;
end Behavioral;
