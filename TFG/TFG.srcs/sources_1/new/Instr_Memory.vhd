library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.System_Config_Pkg.ALL;
use work.Program_ROM_Pkg.ALL;

entity rom_instrucciones_2 is
  Port (
    addr : in  STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
    inst : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0)
  );
end rom_instrucciones_2;

architecture Behavioral of rom_instrucciones_2 is
  -- bit_count = 0
  -- pow2 = 1
  --clog2(8) = 3
  -- while 1 < 8 loop
  --   pow2 = 1 * 2 = 2
  --   bit_count = 0 + 1 = 1
  -- while 2 < 8 loop
  --   pow2 = 2 * 2 = 4
  --   bit_count = 1 + 1 = 2
  -- while 4 < 8 loop
  --   pow2 = 4 * 2 = 8
  --   bit_count = 2 + 1 = 3
  -- while 8 < 8 loop
  --   (no se cumple, sale del loop)
  -- return bit_count = 3  
  function clog2(n : natural) return natural is
    variable bit_count : natural := 0;
    variable pow2      : natural := 1;
  begin
    while pow2 < n loop
      pow2      := pow2 * 2;
      bit_count := bit_count + 1;
    end loop;
    return bit_count;
  end function;
  
  constant rom_idx_width : natural := clog2(INSTRUCTION_NUMBER);    --Saco el maximo bit que usaré para indexar la ROM, dado el numero de instrucciones que tengo
  signal rom_index : natural range 0 to INSTRUCTION_NUMBER - 1;     --Esto hará que si me salgo del rango, el index se vuelva 0 (comportamiento de un contador con overflow)
begin
  rom_index <= to_integer(unsigned(addr(WORD_ADDR_LSB + rom_idx_width - 1 downto WORD_ADDR_LSB)));
                                        --El maximo bit para el que tiene sentido (sabiendo que el numero de instrucciones es muy limitado)


  inst      <= MEMORIA(rom_index);  --Simplemente asigno la salida conforme a la estructura de datos de la ROM de instrucciones.
end Behavioral;
