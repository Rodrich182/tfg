library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.System_Config_Pkg.ALL;

package ISA_Config_Pkg is
    -- ALUOp (Main Control -> ALU Decoder)
    constant ALUOP_SIZE : integer := 2;
    constant ALUOP_ADD : std_logic_vector(ALUOP_SIZE - 1 downto 0) := "00";
    constant ALUOP_SUB : std_logic_vector(ALUOP_SIZE - 1 downto 0) := "01";
    constant ALUOP_DECODE : std_logic_vector(ALUOP_SIZE - 1 downto 0) := "10";

    -- Writeback mux select
    constant RESULTSRC_SIZE : integer := 2;
    constant RESULTSRC_ALU : std_logic_vector(RESULTSRC_SIZE - 1 downto 0) := "00";
    constant RESULTSRC_MEM : std_logic_vector(RESULTSRC_SIZE - 1 downto 0) := "01";
    constant RESULTSRC_PC4 : std_logic_vector(RESULTSRC_SIZE - 1 downto 0) := "10";

    -- ALU source A select
    constant SRCASEL_SIZE : integer := 2;
    constant SRCASEL_RS1 : std_logic_vector(SRCASEL_SIZE - 1 downto 0) := "00";
    constant SRCASEL_PC : std_logic_vector(SRCASEL_SIZE - 1 downto 0) := "01";
    constant SRCASEL_ZERO : std_logic_vector(SRCASEL_SIZE - 1 downto 0) := "10";

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

    -- RV32I opcodes
    constant OPCODE_RTYPE : std_logic_vector(OPCODE_SIZE - 1 downto 0) := "0110011";
    constant OPCODE_LOAD : std_logic_vector(OPCODE_SIZE - 1 downto 0) := "0000011";
    constant OPCODE_STORE : std_logic_vector(OPCODE_SIZE - 1 downto 0) := "0100011";
    constant OPCODE_BRANCH : std_logic_vector(OPCODE_SIZE - 1 downto 0) := "1100011";
    constant OPCODE_ITYPE : std_logic_vector(OPCODE_SIZE - 1 downto 0) := "0010011";
    constant OPCODE_JALR : std_logic_vector(OPCODE_SIZE - 1 downto 0) := "1100111";
    constant OPCODE_JAL : std_logic_vector(OPCODE_SIZE - 1 downto 0) := "1101111";
    constant OPCODE_LUI : std_logic_vector(OPCODE_SIZE - 1 downto 0) := "0110111";
    constant OPCODE_AUIPC : std_logic_vector(OPCODE_SIZE - 1 downto 0) := "0010111";
    constant OPCODE_MISC_MEM : std_logic_vector(OPCODE_SIZE - 1 downto 0) := "0001111";
    constant OPCODE_SYSTEM : std_logic_vector(OPCODE_SIZE - 1 downto 0) := "1110011";

    -- Shared funct3 encodings
    constant FUNCT3_ADD_SUB : std_logic_vector(FUNCT3_SIZE - 1 downto 0) := "000";
    constant FUNCT3_SLL : std_logic_vector(FUNCT3_SIZE - 1 downto 0) := "001";
    constant FUNCT3_SLT : std_logic_vector(FUNCT3_SIZE - 1 downto 0) := "010";
    constant FUNCT3_SLTU : std_logic_vector(FUNCT3_SIZE - 1 downto 0) := "011";
    constant FUNCT3_XOR : std_logic_vector(FUNCT3_SIZE - 1 downto 0) := "100";
    constant FUNCT3_SRL_SRA : std_logic_vector(FUNCT3_SIZE - 1 downto 0) := "101";
    constant FUNCT3_OR : std_logic_vector(FUNCT3_SIZE - 1 downto 0) := "110";
    constant FUNCT3_AND : std_logic_vector(FUNCT3_SIZE - 1 downto 0) := "111";

    -- Load/store funct3 encodings
    constant FUNCT3_LB : std_logic_vector(FUNCT3_SIZE - 1 downto 0) := "000";
    constant FUNCT3_LH : std_logic_vector(FUNCT3_SIZE - 1 downto 0) := "001";
    constant FUNCT3_LW : std_logic_vector(FUNCT3_SIZE - 1 downto 0) := "010";
    constant FUNCT3_LBU : std_logic_vector(FUNCT3_SIZE - 1 downto 0) := "100";
    constant FUNCT3_LHU : std_logic_vector(FUNCT3_SIZE - 1 downto 0) := "101";
    constant FUNCT3_SB : std_logic_vector(FUNCT3_SIZE - 1 downto 0) := "000";
    constant FUNCT3_SH : std_logic_vector(FUNCT3_SIZE - 1 downto 0) := "001";
    constant FUNCT3_SW : std_logic_vector(FUNCT3_SIZE - 1 downto 0) := "010";
    constant FUNCT3_JALR : std_logic_vector(FUNCT3_SIZE - 1 downto 0) := "000";
    constant FUNCT3_ECALL_EBREAK : std_logic_vector(FUNCT3_SIZE - 1 downto 0) := "000";

    -- Branch funct3 encodings
    constant FUNCT3_BEQ : std_logic_vector(FUNCT3_SIZE - 1 downto 0) := "000";
    constant FUNCT3_BNE : std_logic_vector(FUNCT3_SIZE - 1 downto 0) := "001";
    constant FUNCT3_BLT : std_logic_vector(FUNCT3_SIZE - 1 downto 0) := "100";
    constant FUNCT3_BGE : std_logic_vector(FUNCT3_SIZE - 1 downto 0) := "101";
    constant FUNCT3_BLTU : std_logic_vector(FUNCT3_SIZE - 1 downto 0) := "110";
    constant FUNCT3_BGEU : std_logic_vector(FUNCT3_SIZE - 1 downto 0) := "111";

    -- SYSTEM funct12 encodings
    constant FUNCT12_ECALL : std_logic_vector(11 downto 0) := "000000000000";
    constant FUNCT12_EBREAK : std_logic_vector(11 downto 0) := "000000000001";

    -- ImmSrc encodings
    constant IMMSRC_I : std_logic_vector(ImmSrc_size - 1 downto 0) := "000";
    constant IMMSRC_S : std_logic_vector(ImmSrc_size - 1 downto 0) := "001";
    constant IMMSRC_B : std_logic_vector(ImmSrc_size - 1 downto 0) := "010";
    constant IMMSRC_J : std_logic_vector(ImmSrc_size - 1 downto 0) := "011";
    constant IMMSRC_U : std_logic_vector(ImmSrc_size - 1 downto 0) := "100";
end package ISA_Config_Pkg;
