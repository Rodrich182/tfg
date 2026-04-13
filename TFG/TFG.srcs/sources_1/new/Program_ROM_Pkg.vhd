library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.System_Config_Pkg.ALL;

package Program_ROM_Pkg is

  -- ROM de INSTRUCTION_NUMBER palabras de DATA_WIDTH bits
  type rom_type is array (0 to INSTRUCTION_NUMBER - 1)
    of std_logic_vector(DATA_WIDTH - 1 downto 0);

  --------------------------------------------------------------------------
  -- Programa ROM de ejemplo.
  --
  -- El core ya soporta RV32I base a nivel RTL, con estas notas:
  --   * fence/fence.i se tratan como NOP
  --   * ecall/ebreak detienen el PC
  --
  -- Esta ROM concreta sigue siendo un smoke test del subconjunto original.
  -- Puedes regenerarla desde GCC usando los scripts del directorio scripts/.
  --------------------------------------------------------------------------
    --
  constant MEMORIA : rom_type := (

    -- Inicialización de registros
    0  => x"00500093", -- addi x1,  x0, 5
    1  => x"00A00113", -- addi x2,  x0, 10

    -- R-type (ALU)
    2  => x"002081B3", -- add  x3,  x1, x2        ; x3=15
    3  => x"40110233", -- sub  x4,  x2, x1        ; x4=5
    4  => x"0020F2B3", -- and  x5,  x1, x2        ; 5 & 10 = 0
    5  => x"0020E333", -- or   x6,  x1, x2        ; 15
    6  => x"0020C3B3", -- xor  x7,  x1, x2        ; 15
    7  => x"00209433", -- sll  x8,  x1, x2        ; 5 << 10 = 5120 (0x1400)
    8  => x"001154B3", -- srl  x9,  x2, x1        ; 10 >> 5 = 0
    9  => x"40115533", -- sra  x10, x2, x1        ; 10 >>> 5 = 0
    10 => x"0020A5B3", -- slt  x11, x1, x2        ; 5 < 10 => 1
    11 => x"0020B633", -- sltu x12, x1, x2        ; 5 < 10 => 1

    -- I-type (ALU immediates)
    12 => x"00F0F693", -- andi x13, x1, 0x00F     ; 5
    13 => x"0010E713", -- ori  x14, x1, 0x001     ; 5
    14 => x"0FF0C793", -- xori x15, x1, 0x0FF     ; 5^255=250 (0xFA)
    15 => x"0010A813", -- slti x16, x1, 1         ; 5<1 =>0
    16 => x"0010B893", -- sltiu x17, x1, 1        ; 5<1 =>0
    17 => x"00209913", -- slli x18, x1, 2         ; 20
    18 => x"0010D993", -- srli x19, x1, 1         ; 2
    19 => x"4010DA13", -- srai x20, x1, 1         ; 2

    -- Base address para data memory (x21 = 0)
    20 => x"00000A93", -- addi x21, x0, 0

    -- Store/Load word
    21 => x"003AA023", -- sw   x3, 0(x21)         ; MEM[0]=15
    22 => x"000AAB03", -- lw   x22, 0(x21)        ; x22=15

    -- Branches (igualdad)
    23 => x"003B0463", -- beq  x22, x3, +8        ; tomado, salta 24
    24 => x"06300B93", -- addi x23, x0, 99        ; NO ejecutada
    25 => x"04D00C13", -- addi x24, x0, 77        ; ejecutada

    26 => x"004B1463", -- bne  x22, x4, +8        ; tomado, salta 27
    27 => x"03700C93", -- addi x25, x0, 55        ; NO ejecutada
    28 => x"00000013", -- nop

    ----------------------------------------------------------------------
    -- NUEVO: Branches de comparación (signed/unsigned)
    ----------------------------------------------------------------------
    29 => x"FFF00D13", -- addi x26, x0, -1        ; x26=0xFFFFFFFF
    30 => x"00100D93", -- addi x27, x0, 1         ; x27=1

    31 => x"01BD4463", -- blt  x26, x27, +8       ; (-1 < 1) tomado, salta 32
    32 => x"00B00E13", -- addi x28, x0, 11        ; NO ejecutada
    33 => x"01600E13", -- addi x28, x0, 22        ; ejecutada (destino)

    34 => x"01ADD463", -- bge  x27, x26, +8       ; (1 >= -1) tomado, salta 35
    35 => x"02100E93", -- addi x29, x0, 33        ; NO ejecutada
    36 => x"02C00E93", -- addi x29, x0, 44        ; ejecutada (destino)

    37 => x"01ADE463", -- bltu x27, x26, +8       ; (1 < 0xFFFFFFFF) tomado, salta 38
    38 => x"03700F13", -- addi x30, x0, 55        ; NO ejecutada
    39 => x"04200F13", -- addi x30, x0, 66        ; ejecutada (destino)

    40 => x"01BD7463", -- bgeu x26, x27, +8       ; (0xFFFFFFFF >= 1) tomado, salta 41
    41 => x"04D00F93", -- addi x31, x0, 77        ; NO ejecutada
    42 => x"00000013", -- nop_end

    ----------------------------------------------------------------------
    -- Instrucciones RV32I adicionales ya soportadas por el core.
    -- La ROM de ejemplo no las usa todavía.
    ----------------------------------------------------------------------
    -- 43 => x"12345D37", -- lui   x26, 0x12345
    -- 44 => x"00001DB7", -- auipc x27, 0x00001
    -- 45 => x"0000006F", -- jal   x0, 0
    -- 46 => x"00000067", -- jalr  x0, 0(x0)

    others => (others => '0')
  );

  --------------------------------------------------------------------------
  -- ESTRUCTURA GOLDEN: valores esperados por instrucción
  --
  -- Esta tabla NO ejecuta nada: solo es "oracle" para el testbench.
  --
  -- regwrite:  '1' si la instrucción escribe registro (rd != x0)
  -- rd:        índice de rd (5 bits)
  -- rd_val:    dato esperado escrito en rd
  --
  -- memwrite:  '1' si la instrucción hace store (sw)
  -- mem_addr:  dirección byte esperada del store
  -- mem_data:  dato esperado del store
  --------------------------------------------------------------------------

  type expected_step_t is record
    regwrite : std_logic;
    rd       : std_logic_vector(ADDR_LENGTH - 1 downto 0);
    rd_val   : std_logic_vector(DATA_WIDTH - 1 downto 0);
    memwrite : std_logic;
    mem_addr : std_logic_vector(DATA_WIDTH - 1 downto 0);
    mem_data : std_logic_vector(DATA_WIDTH - 1 downto 0);
  end record;

  type expected_array_t is array (0 to INSTRUCTION_NUMBER - 1) of expected_step_t;

  constant EXPECTED : expected_array_t := (

    0  => (regwrite=>'1', rd=>"00001", rd_val=>x"00000005", memwrite=>'0', mem_addr=>x"00000000", mem_data=>x"00000000"),
    1  => (regwrite=>'1', rd=>"00010", rd_val=>x"0000000A", memwrite=>'0', mem_addr=>x"00000000", mem_data=>x"00000000"),

    2  => (regwrite=>'1', rd=>"00011", rd_val=>x"0000000F", memwrite=>'0', mem_addr=>x"00000000", mem_data=>x"00000000"),
    3  => (regwrite=>'1', rd=>"00100", rd_val=>x"00000005", memwrite=>'0', mem_addr=>x"00000000", mem_data=>x"00000000"),
    4  => (regwrite=>'1', rd=>"00101", rd_val=>x"00000000", memwrite=>'0', mem_addr=>x"00000000", mem_data=>x"00000000"),
    5  => (regwrite=>'1', rd=>"00110", rd_val=>x"0000000F", memwrite=>'0', mem_addr=>x"00000000", mem_data=>x"00000000"),
    6  => (regwrite=>'1', rd=>"00111", rd_val=>x"0000000F", memwrite=>'0', mem_addr=>x"00000000", mem_data=>x"00000000"),
    7  => (regwrite=>'1', rd=>"01000", rd_val=>x"00001400", memwrite=>'0', mem_addr=>x"00000000", mem_data=>x"00000000"),
    8  => (regwrite=>'1', rd=>"01001", rd_val=>x"00000000", memwrite=>'0', mem_addr=>x"00000000", mem_data=>x"00000000"),
    9  => (regwrite=>'1', rd=>"01010", rd_val=>x"00000000", memwrite=>'0', mem_addr=>x"00000000", mem_data=>x"00000000"),
    10 => (regwrite=>'1', rd=>"01011", rd_val=>x"00000001", memwrite=>'0', mem_addr=>x"00000000", mem_data=>x"00000000"),
    11 => (regwrite=>'1', rd=>"01100", rd_val=>x"00000001", memwrite=>'0', mem_addr=>x"00000000", mem_data=>x"00000000"),

    12 => (regwrite=>'1', rd=>"01101", rd_val=>x"00000005", memwrite=>'0', mem_addr=>x"00000000", mem_data=>x"00000000"),
    13 => (regwrite=>'1', rd=>"01110", rd_val=>x"00000005", memwrite=>'0', mem_addr=>x"00000000", mem_data=>x"00000000"),
    14 => (regwrite=>'1', rd=>"01111", rd_val=>x"000000FA", memwrite=>'0', mem_addr=>x"00000000", mem_data=>x"00000000"),
    15 => (regwrite=>'1', rd=>"10000", rd_val=>x"00000000", memwrite=>'0', mem_addr=>x"00000000", mem_data=>x"00000000"),
    16 => (regwrite=>'1', rd=>"10001", rd_val=>x"00000000", memwrite=>'0', mem_addr=>x"00000000", mem_data=>x"00000000"),
    17 => (regwrite=>'1', rd=>"10010", rd_val=>x"00000014", memwrite=>'0', mem_addr=>x"00000000", mem_data=>x"00000000"),
    18 => (regwrite=>'1', rd=>"10011", rd_val=>x"00000002", memwrite=>'0', mem_addr=>x"00000000", mem_data=>x"00000000"),
    19 => (regwrite=>'1', rd=>"10100", rd_val=>x"00000002", memwrite=>'0', mem_addr=>x"00000000", mem_data=>x"00000000"),

    20 => (regwrite=>'1', rd=>"10101", rd_val=>x"00000000", memwrite=>'0', mem_addr=>x"00000000", mem_data=>x"00000000"),

    21 => (regwrite=>'0', rd=>"00000", rd_val=>x"00000000", memwrite=>'1', mem_addr=>x"00000000", mem_data=>x"0000000F"),
    22 => (regwrite=>'1', rd=>"10110", rd_val=>x"0000000F", memwrite=>'0', mem_addr=>x"00000000", mem_data=>x"00000000"),

    23 => (regwrite=>'0', rd=>"00000", rd_val=>x"00000000", memwrite=>'0', mem_addr=>x"00000000", mem_data=>x"00000000"),
    24 => (regwrite=>'0', rd=>"00000", rd_val=>x"00000000", memwrite=>'0', mem_addr=>x"00000000", mem_data=>x"00000000"), -- saltada (beq tomado)
    25 => (regwrite=>'1', rd=>"11000", rd_val=>x"0000004D", memwrite=>'0', mem_addr=>x"00000000", mem_data=>x"00000000"),

    26 => (regwrite=>'0', rd=>"00000", rd_val=>x"00000000", memwrite=>'0', mem_addr=>x"00000000", mem_data=>x"00000000"),
    27 => (regwrite=>'0', rd=>"00000", rd_val=>x"00000000", memwrite=>'0', mem_addr=>x"00000000", mem_data=>x"00000000"), -- saltada (bne tomado)
    28 => (regwrite=>'0', rd=>"00000", rd_val=>x"00000000", memwrite=>'0', mem_addr=>x"00000000", mem_data=>x"00000000"),

    29 => (regwrite=>'1', rd=>"11010", rd_val=>x"FFFFFFFF", memwrite=>'0', mem_addr=>x"00000000", mem_data=>x"00000000"),
    30 => (regwrite=>'1', rd=>"11011", rd_val=>x"00000001", memwrite=>'0', mem_addr=>x"00000000", mem_data=>x"00000000"),

    31 => (regwrite=>'0', rd=>"00000", rd_val=>x"00000000", memwrite=>'0', mem_addr=>x"00000000", mem_data=>x"00000000"),
    32 => (regwrite=>'0', rd=>"00000", rd_val=>x"00000000", memwrite=>'0', mem_addr=>x"00000000", mem_data=>x"00000000"), -- saltada (blt tomado)
    33 => (regwrite=>'1', rd=>"11100", rd_val=>x"00000016", memwrite=>'0', mem_addr=>x"00000000", mem_data=>x"00000000"),

    34 => (regwrite=>'0', rd=>"00000", rd_val=>x"00000000", memwrite=>'0', mem_addr=>x"00000000", mem_data=>x"00000000"),
    35 => (regwrite=>'0', rd=>"00000", rd_val=>x"00000000", memwrite=>'0', mem_addr=>x"00000000", mem_data=>x"00000000"), -- saltada (bge tomado)
    36 => (regwrite=>'1', rd=>"11101", rd_val=>x"0000002C", memwrite=>'0', mem_addr=>x"00000000", mem_data=>x"00000000"),

    37 => (regwrite=>'0', rd=>"00000", rd_val=>x"00000000", memwrite=>'0', mem_addr=>x"00000000", mem_data=>x"00000000"),
    38 => (regwrite=>'0', rd=>"00000", rd_val=>x"00000000", memwrite=>'0', mem_addr=>x"00000000", mem_data=>x"00000000"), -- saltada (bltu tomado)
    39 => (regwrite=>'1', rd=>"11110", rd_val=>x"00000042", memwrite=>'0', mem_addr=>x"00000000", mem_data=>x"00000000"),

    40 => (regwrite=>'0', rd=>"00000", rd_val=>x"00000000", memwrite=>'0', mem_addr=>x"00000000", mem_data=>x"00000000"),
    41 => (regwrite=>'0', rd=>"00000", rd_val=>x"00000000", memwrite=>'0', mem_addr=>x"00000000", mem_data=>x"00000000"), -- saltada (bgeu tomado)
    42 => (regwrite=>'0', rd=>"00000", rd_val=>x"00000000", memwrite=>'0', mem_addr=>x"00000000", mem_data=>x"00000000"),

    others => (regwrite=>'0', rd=>(others=>'0'), rd_val=>(others=>'0'),
               memwrite=>'0', mem_addr=>(others=>'0'), mem_data=>(others=>'0'))
  );

end package Program_ROM_Pkg;
