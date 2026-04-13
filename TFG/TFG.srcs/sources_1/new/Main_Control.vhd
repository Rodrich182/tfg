library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.System_Config_Pkg.ALL;
use work.ISA_Config_Pkg.ALL;

entity Main_Control is
    port (
        inst       : in  STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
        Branch     : out STD_LOGIC;
        Jump       : out STD_LOGIC;
        JumpReg    : out STD_LOGIC;
        Halt       : out STD_LOGIC;
        MemRead    : out STD_LOGIC;
        resultSrc  : out STD_LOGIC_VECTOR (RESULTSRC_SIZE - 1 downto 0);
        MemWrite   : out STD_LOGIC;
        ALUSrc     : out STD_LOGIC;
        SrcASelect : out STD_LOGIC_VECTOR (SRCASEL_SIZE - 1 downto 0);
        RegWrite   : out STD_LOGIC;
        AluOp      : out STD_LOGIC_VECTOR (ALUOP_SIZE - 1 downto 0);
        br_neg     : out STD_LOGIC;
        IsRType    : out STD_LOGIC;
        ImmSrc     : out STD_LOGIC_VECTOR (ImmSrc_size - 1 downto 0)
    );
end Main_Control;

architecture Behavioral of Main_Control is
    signal opCode : std_logic_vector(OPCODE_SIZE - 1 downto 0);
begin
    opCode <= inst(OPCODE_END downto OPCODE_INT);

    process (opCode, inst)
    begin
        Branch     <= '0';
        Jump       <= '0';
        JumpReg    <= '0';
        Halt       <= '0';
        MemRead    <= '0';
        resultSrc  <= RESULTSRC_ALU;
        ALUOp      <= ALUOP_ADD;
        MemWrite   <= '0';
        ALUSrc     <= '0';
        SrcASelect <= SRCASEL_RS1;
        RegWrite   <= '0';
        br_neg     <= '0';
        IsRType    <= '0';
        ImmSrc     <= IMMSRC_I;

        case opCode is
            when OPCODE_RTYPE =>
                RegWrite <= '1';
                IsRType  <= '1';
                AluOP    <= ALUOP_DECODE;

            when OPCODE_LOAD =>
                ALUSrc    <= '1';
                resultSrc <= RESULTSRC_MEM;
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
                AluOP  <= ALUOP_SUB;
                Branch <= '1';
                ImmSrc <= IMMSRC_B;

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

            when OPCODE_JAL =>
                Jump       <= '1';
                RegWrite   <= '1';
                resultSrc  <= RESULTSRC_PC4;
                ALUSrc     <= '1';
                SrcASelect <= SRCASEL_PC;
                AluOp      <= ALUOP_ADD;
                ImmSrc     <= IMMSRC_J;

            when OPCODE_JALR =>
                if inst(FUNCT3_END downto FUNCT3_INIT) = FUNCT3_JALR then
                    JumpReg    <= '1';
                    RegWrite   <= '1';
                    resultSrc  <= RESULTSRC_PC4;
                    ALUSrc     <= '1';
                    SrcASelect <= SRCASEL_RS1;
                    AluOp      <= ALUOP_ADD;
                    ImmSrc     <= IMMSRC_I;
                end if;

            when OPCODE_LUI =>
                RegWrite   <= '1';
                ALUSrc     <= '1';
                SrcASelect <= SRCASEL_ZERO;
                AluOp      <= ALUOP_ADD;
                ImmSrc     <= IMMSRC_U;

            when OPCODE_AUIPC =>
                RegWrite   <= '1';
                ALUSrc     <= '1';
                SrcASelect <= SRCASEL_PC;
                AluOp      <= ALUOP_ADD;
                ImmSrc     <= IMMSRC_U;

            when OPCODE_MISC_MEM =>
                null;

            when OPCODE_SYSTEM =>
                if (inst(FUNCT3_END downto FUNCT3_INIT) = FUNCT3_ECALL_EBREAK) and
                   ((inst(I_IMM_END downto I_IMM_INIT) = FUNCT12_ECALL) or
                    (inst(I_IMM_END downto I_IMM_INIT) = FUNCT12_EBREAK)) then
                    Halt <= '1';
                end if;

            when others =>
                null;
        end case;
    end process;
end Behavioral;

