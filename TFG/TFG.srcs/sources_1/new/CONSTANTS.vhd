library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package System_Config_Pkg is
    -- Core sizing
    constant DATA_WIDTH : integer := 32;
    constant ADDR_WIDTH : integer := 10;    --Ancho para direcciones en Memoria de datos
    constant OPP_SIZE : integer := 4;
    constant ADDR_LENGTH : integer := 5;    --Ancho para direcciones de banco de registro, Interesanter cambiar los nombres y poner un prefijo mas identiificativo (REG_ADDR_SIZE por ejemplo)
    constant REG_NUM : integer := 32;
    constant INSTRUCTION_NUMBER : integer := 64;
    constant PC_STEP : integer := 4;
    constant WORD_ADDR_LSB : integer := 2; -- byte address -> 32-bit word index (PC/4)


    -- Instruction field sizing/slices
    constant ImmSrc_size : integer := 3;
    constant OPCODE_SIZE : integer := 7;
    constant OPCODE_INT : integer := 0;
    constant OPCODE_END : integer := 6;
    constant RD_INIT : integer := 7;
    constant RD_END : integer := 11;
    constant FUNCT3_INIT : integer := 12;
    constant FUNCT3_END : integer := 14;
    constant RS1_INIT : integer := 15;
    constant RS1_END : integer := 19;
    constant RS2_INIT : integer := 20;
    constant RS2_END : integer := 24;
    constant FUNCT7_INIT : integer := 25;
    constant FUNCT7_END : integer := 31;
    constant FUNCT_CODE_SIZE : integer := 10;

    -- Derived sizes
    constant FUNCT3_SIZE : integer := FUNCT3_END - FUNCT3_INIT + 1;
    constant FUNCT7_SIZE : integer := FUNCT7_END - FUNCT7_INIT + 1;

    -- Funct_Code packing indexes (funct3 & funct7)
    constant FUNCTCODE_FUNCT7_INIT : integer := 0;
    constant FUNCTCODE_FUNCT7_END : integer := 6;
    constant FUNCTCODE_FUNCT3_INIT : integer := 7;
    constant FUNCTCODE_FUNCT3_END : integer := 9;

    -- Immediates (RV32)
    constant I_IMM_INIT : integer := 20;
    constant I_IMM_END : integer := 31;
    constant SB1_IMM_INIT : integer := 25;
    constant SB1_IMM_END : integer := 31;
    constant SB2_IMM_INIT : integer := 7;
    constant SB2_IMM_END : integer := 11;
    

    -- B-type bit mapping
    constant B_SIGN_BIT : integer := 31;
    constant B_BIT11 : integer := 7;    -- actua como bit 11 del inmediato, pero NO el bit 11 de la instrucción
    constant B_HIGH_INIT : integer := 25;
    constant B_HIGH_END : integer := 30;
    constant B_LOW_INIT : integer := 8;
    constant B_LOW_END : integer := 11;

    -- J-type bit mapping
    constant J_SIGN_BIT : integer := 31;
    constant J_MID_INIT : integer := 12;
    constant J_MID_END : integer := 19;
    constant J_BIT11 : integer := 20;
    constant J_LOW_INIT : integer := 21;
    constant J_LOW_END : integer := 30;

    -- Shifts / bit positions
    constant SHAMT_INIT : integer := 0;
    constant SHAMT_END : integer := 4;
    constant FUNCT7_ALT_BIT : integer := 5;



    
end package System_Config_Pkg;
