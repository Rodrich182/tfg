library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.System_Config_Pkg.ALL;
use work.ISA_Config_Pkg.ALL;

entity Main_Control is
    port (
        inst      : in  STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
        Branch    : out STD_LOGIC;
        MemRead   : out STD_LOGIC;
        resultSrc : out STD_LOGIC;
        MemWrite  : out STD_LOGIC;
        ALUSrc    : out STD_LOGIC; -- '0' registro, '1' inmediato
        RegWrite  : out STD_LOGIC;
        AluOp     : out STD_LOGIC_VECTOR (ALUOP_SIZE - 1 downto 0);
        br_neg    : out STD_LOGIC;
        IsRType   : out STD_LOGIC;
        ImmSrc    : out STD_LOGIC_VECTOR (ImmSrc_size - 1 downto 0)
    );
end Main_Control;

architecture Behavioral of Main_Control is
    signal opCode : std_logic_vector(OPCODE_SIZE - 1 downto 0);
begin
    opCode <= inst(OPCODE_END downto OPCODE_INT);

    process (opCode, inst)
    begin
        Branch    <= '0';
        MemRead   <= '0';
        resultSrc <= '0';
        ALUOp     <= ALUOP_ADD;
        MemWrite  <= '0';
        ALUSrc    <= '0';
        RegWrite  <= '0';
        br_neg    <= '0';
        IsRType   <= '0';
        ImmSrc    <= IMMSRC_I;

        case opCode is
            when OPCODE_RTYPE =>
                RegWrite <= '1';
                IsRType  <= '1';
                AluOP    <= ALUOP_DECODE;
                ALUSrc   <= '0';

            when OPCODE_LOAD =>
                ALUSrc    <= '1';
                resultSrc <= '1';
                RegWrite  <= '1';
                MemRead   <= '1';
                AluOp     <= ALUOP_ADD;
                ImmSrc    <= IMMSRC_I;

            when OPCODE_STORE =>
                ALUSrc   <= '1';
                AluOp    <= ALUOP_ADD;
                MemWrite <= '1';
                ImmSrc   <= IMMSRC_S;

            when OPCODE_BRANCH =>
                RegWrite <= '0';
                AluOP    <= ALUOP_SUB;
                Branch   <= '1';
                ALUSrc   <= '0';
                ImmSrc   <= IMMSRC_B;

                case inst(FUNCT3_END downto FUNCT3_INIT) is
                    when FUNCT3_BEQ  => br_neg <= '0';
                    when FUNCT3_BNE  => br_neg <= '1';
                    when FUNCT3_BLT  => br_neg <= '0';
                    when FUNCT3_BGE  => br_neg <= '1';
                    when FUNCT3_BLTU => br_neg <= '0';
                    when FUNCT3_BGEU => br_neg <= '1';
                    when others      => br_neg <= '0';
                end case;

            when OPCODE_ITYPE =>
                ALUSrc   <= '1';
                RegWrite <= '1';
                AluOP    <= ALUOP_DECODE;
                ImmSrc   <= IMMSRC_I;

            when others =>
                null;
        end case;
    end process;
end Behavioral;