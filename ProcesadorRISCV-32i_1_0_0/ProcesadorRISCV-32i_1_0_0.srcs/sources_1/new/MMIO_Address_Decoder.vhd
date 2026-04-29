library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MMIO_Address_Decoder is
    generic (
        RAM_LAST_ADDR_G : STD_LOGIC_VECTOR(31 downto 0) := x"00000FFF";
        LED_ADDR_G      : STD_LOGIC_VECTOR(31 downto 0) := x"00001000";
        BTN_ADDR_G      : STD_LOGIC_VECTOR(31 downto 0) := x"00001004"
    );
    port (
        addr_i       : in  STD_LOGIC_VECTOR(31 downto 0);
        memwrite_i   : in  STD_LOGIC;
        ram_rdata_i  : in  STD_LOGIC_VECTOR(31 downto 0);
        led_rdata_i  : in  STD_LOGIC_VECTOR(31 downto 0);
        btn_rdata_i  : in  STD_LOGIC_VECTOR(31 downto 0);
        ram_we_o     : out STD_LOGIC;
        led_we_o     : out STD_LOGIC;
        ram_sel_o    : out STD_LOGIC;
        led_sel_o    : out STD_LOGIC;
        btn_sel_o    : out STD_LOGIC;
        rdata_o      : out STD_LOGIC_VECTOR(31 downto 0)
    );
end MMIO_Address_Decoder;

architecture Behavioral of MMIO_Address_Decoder is
    signal ram_sel_s : STD_LOGIC;
    signal led_sel_s : STD_LOGIC;
    signal btn_sel_s : STD_LOGIC;
begin
    ram_sel_s <= '1' when unsigned(addr_i) <= unsigned(RAM_LAST_ADDR_G) else '0';
    led_sel_s <= '1' when addr_i = LED_ADDR_G else '0';
    btn_sel_s <= '1' when addr_i = BTN_ADDR_G else '0';

    ram_we_o <= memwrite_i and ram_sel_s;
    led_we_o <= memwrite_i and led_sel_s;

    ram_sel_o <= ram_sel_s;
    led_sel_o <= led_sel_s;
    btn_sel_o <= btn_sel_s;

    rdata_o <= ram_rdata_i when ram_sel_s = '1' else
               led_rdata_i when led_sel_s = '1' else
               btn_rdata_i when btn_sel_s = '1' else
               (others => '0');
end Behavioral;
