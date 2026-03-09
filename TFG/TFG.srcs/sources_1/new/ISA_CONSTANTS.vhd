library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.System_Config_Pkg.ALL;

package ISA_Config_Pkg is
    -- ALUOp (Main Control -> ALU Decoder)
    constant ALUOP_SIZE : integer := 2;
    constant ALUOP_ADD : std_logic_vector(ALUOP_SIZE - 1 downto 0) := "00";
    constant ALUOP_SUB : std_logic_vector(ALUOP_SIZE - 1 downto 0) := "01";
    constant ALUOP_DECODE : std_logic_vector(ALUOP_SIZE - 1 downto 0) := "10";  -- La ALU decide la operacion 
    --a realizar segun el funct3 y funct7 de la instruccion, y no solo segun el opcode. Por eso necesito esta señal extra para indicarle a la ALU que haga un "decode" de esos campos.

    -- ALUControl (ALU Decoder -> ALU)
    constant ALUCTRL_SIZE : integer := OPP_SIZE;
    constant ALUCTRL_ADD : std_logic_vector(ALUCTRL_SIZE - 1 downto 0) := "0000";
    constant ALUCTRL_SUB : std_logic_vector(ALUCTRL_SIZE - 1 downto 0) := "0001";
    constant ALUCTRL_SLL : std_logic_vector(ALUCTRL_SIZE - 1 downto 0) := "0010";
    constant ALUCTRL_SLT : std_logic_vector(ALUCTRL_SIZE - 1 downto 0) := "0100";
    constant ALUCTRL_SLTU : std_logic_vector(ALUCTRL_SIZE - 1 downto 0) := "0110";
    constant ALUCTRL_SEQ : std_logic_vector(ALUCTRL_SIZE - 1 downto 0) := "0111";
    constant ALUCTRL_XOR : std_logic_vector(ALUCTRL_SIZE - 1 downto 0) := "1000";
    constant ALUCTRL_SRL : std_logic_vector(ALUCTRL_SIZE - 1 downto 0) := "1010";
    constant ALUCTRL_SRA : std_logic_vector(ALUCTRL_SIZE - 1 downto 0) := "1011";
    constant ALUCTRL_OR : std_logic_vector(ALUCTRL_SIZE - 1 downto 0) := "1100";
    constant ALUCTRL_AND : std_logic_vector(ALUCTRL_SIZE - 1 downto 0) := "1110";

    -- RV32 subset opcodes
    constant OPCODE_RTYPE : std_logic_vector(OPCODE_SIZE - 1 downto 0) := "0110011";
    constant OPCODE_LOAD : std_logic_vector(OPCODE_SIZE - 1 downto 0) := "0000011";
    constant OPCODE_STORE : std_logic_vector(OPCODE_SIZE - 1 downto 0) := "0100011";
    constant OPCODE_BRANCH : std_logic_vector(OPCODE_SIZE - 1 downto 0) := "1100011";
    constant OPCODE_ITYPE : std_logic_vector(OPCODE_SIZE - 1 downto 0) := "0010011";

    -- funct3 encodings
    constant FUNCT3_ADD_SUB : std_logic_vector(FUNCT3_SIZE - 1 downto 0) := "000";
    constant FUNCT3_SLL : std_logic_vector(FUNCT3_SIZE - 1 downto 0) := "001";
    constant FUNCT3_SLT : std_logic_vector(FUNCT3_SIZE - 1 downto 0) := "010";
    constant FUNCT3_SLTU : std_logic_vector(FUNCT3_SIZE - 1 downto 0) := "011";
    constant FUNCT3_XOR : std_logic_vector(FUNCT3_SIZE - 1 downto 0) := "100";
    constant FUNCT3_SRL_SRA : std_logic_vector(FUNCT3_SIZE - 1 downto 0) := "101";
    constant FUNCT3_OR : std_logic_vector(FUNCT3_SIZE - 1 downto 0) := "110";
    constant FUNCT3_AND : std_logic_vector(FUNCT3_SIZE - 1 downto 0) := "111";

    -- Branch funct3 encodings (semantically explicit aliases)
    constant FUNCT3_BEQ  : std_logic_vector(FUNCT3_SIZE - 1 downto 0) := "000"; -- 000
    constant FUNCT3_BNE  : std_logic_vector(FUNCT3_SIZE - 1 downto 0) := "001";     -- 001
    constant FUNCT3_BLT  : std_logic_vector(FUNCT3_SIZE - 1 downto 0) := "100";     -- 100
    constant FUNCT3_BGE  : std_logic_vector(FUNCT3_SIZE - 1 downto 0) := "101"; -- 101
    constant FUNCT3_BLTU : std_logic_vector(FUNCT3_SIZE - 1 downto 0) := "110";      -- 110
    constant FUNCT3_BGEU : std_logic_vector(FUNCT3_SIZE - 1 downto 0) := "111";     -- 111

    -- ImmSrc encodings
    constant IMMSRC_I : std_logic_vector(ImmSrc_size - 1 downto 0) := "000";
    constant IMMSRC_S : std_logic_vector(ImmSrc_size - 1 downto 0) := "001";
    constant IMMSRC_B : std_logic_vector(ImmSrc_size - 1 downto 0) := "010";
    constant IMMSRC_J : std_logic_vector(ImmSrc_size - 1 downto 0) := "011";
end package ISA_Config_Pkg;
