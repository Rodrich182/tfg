library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.System_Config_Pkg.ALL;
use work.ISA_Config_Pkg.ALL;

entity UC_core is
    port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        inst_i : in STD_LOGIC_VECTOR (31 downto 0);
        zero_i : in STD_LOGIC;
        lt_i   : in STD_LOGIC;
        ltu_i  : in STD_LOGIC;
        alu_res_i : in STD_LOGIC_VECTOR (31 downto 0);
        rs1_addr_o : out STD_LOGIC_VECTOR (4 downto 0);
        rs2_addr_o : out STD_LOGIC_VECTOR (4 downto 0);
        rd_addr_o  : out STD_LOGIC_VECTOR (4 downto 0);
        pc_o       : out STD_LOGIC_VECTOR (31 downto 0);
        imm_ext_o  : out STD_LOGIC_VECTOR (31 downto 0);
        mem_funct3_o : out STD_LOGIC_VECTOR (2 downto 0);
        resultSrc  : out STD_LOGIC_VECTOR (1 downto 0);
        MemWrite   : out STD_LOGIC;
        ALUControl : out STD_LOGIC_VECTOR (3 downto 0);
        ALUSrc     : out STD_LOGIC;
        SrcASelect : out STD_LOGIC_VECTOR (1 downto 0);
        RegWrite   : out STD_LOGIC
    );
end UC_core;

architecture Structural of UC_core is
    signal funct3_s   : STD_LOGIC_VECTOR (FUNCT3_SIZE - 1 downto 0);
    signal funct7_s   : STD_LOGIC_VECTOR (FUNCT7_SIZE - 1 downto 0);
    signal is_rtype_s : STD_LOGIC;

    signal branch_s    : STD_LOGIC;
    signal jump_s      : STD_LOGIC;
    signal jump_reg_s  : STD_LOGIC;
    signal halt_s      : STD_LOGIC;
    signal br_neg_s    : STD_LOGIC;
    signal resultsrc_s : STD_LOGIC_VECTOR (RESULTSRC_SIZE - 1 downto 0);
    signal memwrite_s  : STD_LOGIC;
    signal alusrc_s    : STD_LOGIC;
    signal srcasel_s   : STD_LOGIC_VECTOR (SRCASEL_SIZE - 1 downto 0);
    signal regwrite_s  : STD_LOGIC;
    signal aluop_s     : STD_LOGIC_VECTOR (ALUOP_SIZE - 1 downto 0);
    signal immsrc_s    : STD_LOGIC_VECTOR (ImmSrc_size - 1 downto 0);

    signal imm_ext_s     : STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
    signal pc_s          : STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
    signal pc_next_s     : STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
    signal pc_plus_imm_s : STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
    signal jalr_target_s : STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
    signal cond_base_s   : STD_LOGIC;
    signal branch_take_s : STD_LOGIC;
    signal pcsrc_s       : STD_LOGIC;
    signal pcen_s        : STD_LOGIC;
begin
    funct3_s <= inst_i(FUNCT3_END downto FUNCT3_INIT);
    funct7_s <= inst_i(FUNCT7_END downto FUNCT7_INIT);

    rs1_addr_o <= inst_i(RS1_END downto RS1_INIT);
    rs2_addr_o <= inst_i(RS2_END downto RS2_INIT);
    rd_addr_o  <= inst_i(RD_END downto RD_INIT);

    U_PC : entity work.PC
        port map (
            clk     => clk,
            reset   => rst,
            PCEn    => pcen_s,
            PCSrc   => pcsrc_s,
            Addrin  => pc_next_s,
            Addrout => pc_s
        );

    U_MAIN_CONTROL : entity work.Main_Control
        port map (
            inst       => inst_i,
            Branch     => branch_s,
            Jump       => jump_s,
            JumpReg    => jump_reg_s,
            Halt       => halt_s,
            MemRead    => open,
            resultSrc  => resultsrc_s,
            MemWrite   => memwrite_s,
            ALUSrc     => alusrc_s,
            SrcASelect => srcasel_s,
            RegWrite   => regwrite_s,
            AluOp      => aluop_s,
            br_neg     => br_neg_s,
            IsRType    => is_rtype_s,
            ImmSrc     => immsrc_s
        );

    U_ALU_DECOD : entity work.ALU_decod
        port map (
            ALU_OP  => aluop_s,
            IsRType => is_rtype_s,
            funct3  => funct3_s,
            funct7  => funct7_s,
            ALU_Sel => ALUControl
        );

    U_SIGN_EXTEND : entity work.sign_extend_Order
        port map (
            inst      => inst_i,
            ImmSrc    => immsrc_s,
            immediate => imm_ext_s
        );

    with funct3_s select
        cond_base_s <= zero_i when FUNCT3_BEQ,
                       zero_i when FUNCT3_BNE,
                       lt_i   when FUNCT3_BLT,
                       lt_i   when FUNCT3_BGE,
                       ltu_i  when FUNCT3_BLTU,
                       ltu_i  when FUNCT3_BGEU,
                       '0'    when others;

    branch_take_s <= branch_s and (cond_base_s xor br_neg_s);
    pc_plus_imm_s <= std_logic_vector(signed(pc_s) + signed(imm_ext_s));
    jalr_target_s <= alu_res_i(DATA_WIDTH - 1 downto 1) & '0';
    pcsrc_s       <= branch_take_s or jump_s or jump_reg_s;
    pc_next_s     <= jalr_target_s when jump_reg_s = '1' else pc_plus_imm_s;
    pcen_s        <= not halt_s;

    pc_o          <= pc_s;
    imm_ext_o     <= imm_ext_s;
    mem_funct3_o  <= funct3_s;
    resultSrc     <= resultsrc_s;
    MemWrite      <= memwrite_s;
    ALUSrc        <= alusrc_s;
    SrcASelect    <= srcasel_s;
    RegWrite      <= regwrite_s;
end Structural;
