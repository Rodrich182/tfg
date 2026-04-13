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
  --Tendré que chekear posibles porblemas en caso de que instrucrion number no sea potencia de 2 
  --I will have to check possible problems in case instruction number is not a power of 2
  constant rom_idx_width : natural := clog2(INSTRUCTION_NUMBER);    
  signal rom_index : natural range 0 to INSTRUCTION_NUMBER - 1;    
begin
  rom_index <= to_integer(unsigned(addr(WORD_ADDR_LSB + rom_idx_width - 1 downto WORD_ADDR_LSB)));
                                       


  inst      <= MEMORIA(rom_index);  
end Behavioral;
