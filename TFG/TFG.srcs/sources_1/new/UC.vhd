library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.System_Config_Pkg.ALL;
use work.ISA_Config_Pkg.ALL;

entity UC is
    port (
        -- Clock / reset
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;

        -- Comparator flags from datapath
        zero_i : in STD_LOGIC;
        lt_i   : in STD_LOGIC;
        ltu_i  : in STD_LOGIC;

        -- Register-bank addresses (decoded from instruction)
        rs1_addr_o : out STD_LOGIC_VECTOR (ADDR_LENGTH - 1 downto 0);
        rs2_addr_o : out STD_LOGIC_VECTOR (ADDR_LENGTH - 1 downto 0);
        rd_addr_o  : out STD_LOGIC_VECTOR (ADDR_LENGTH - 1 downto 0);

        -- Outputs
        imm_ext_o : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);

        -- Control outputs
        
        resultSrc  : out STD_LOGIC;
        MemWrite   : out STD_LOGIC;
        ALUControl : out STD_LOGIC_VECTOR (OPP_SIZE - 1 downto 0);
        ALUSrc     : out STD_LOGIC;
        RegWrite   : out STD_LOGIC
    );
end UC;

architecture Structural of UC is
    -- Instruction fetch / decode
    signal inst_s     : STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
    signal funct3_s   : STD_LOGIC_VECTOR (FUNCT3_SIZE - 1 downto 0);
    signal funct7_s   : STD_LOGIC_VECTOR (FUNCT7_SIZE - 1 downto 0);
    signal is_rtype_s : STD_LOGIC;

    -- Main control outputs
    signal branch_s    : STD_LOGIC;
    signal br_neg_s    : STD_LOGIC;
    signal resultsrc_s : STD_LOGIC;
    signal memwrite_s  : STD_LOGIC;
    signal alusrc_s    : STD_LOGIC;
    signal regwrite_s  : STD_LOGIC;
    signal aluop_s     : STD_LOGIC_VECTOR (ALUOP_SIZE - 1 downto 0);
    signal immsrc_s    : STD_LOGIC_VECTOR (ImmSrc_size - 1 downto 0);

    -- Immediate / PC path
    signal imm_ext_s     : STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
    signal pc_s          : STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
    signal pc_branch_s   : STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
    signal cond_base_s   : STD_LOGIC;
    signal branch_take_s : STD_LOGIC;
begin
    funct3_s <= inst_s(FUNCT3_END downto FUNCT3_INIT);
    funct7_s <= inst_s(FUNCT7_END downto FUNCT7_INIT);

    -- Export register addresses to datapath
    rs1_addr_o <= inst_s(RS1_END downto RS1_INIT);
    rs2_addr_o <= inst_s(RS2_END downto RS2_INIT);
    rd_addr_o  <= inst_s(RD_END downto RD_INIT);

    U_PC : entity work.PC
        port map (
            clk     => clk,
            reset   => rst,
            PCSrc   => branch_take_s,
            Addrin  => pc_branch_s,
            Addrout => pc_s
        );

    U_INSTR_MEM : entity work.rom_instrucciones_2
        port map (
            addr => pc_s,
            inst => inst_s
        );

    U_MAIN_CONTROL : entity work.Main_Control
        port map (
            inst      => inst_s,
            Branch    => branch_s,
            MemRead   => open,
            resultSrc => resultsrc_s,
            MemWrite  => memwrite_s,
            ALUSrc    => alusrc_s,
            RegWrite  => regwrite_s,
            AluOp     => aluop_s,
            br_neg    => br_neg_s,
            IsRType   => is_rtype_s,
            ImmSrc    => immsrc_s
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
            inst      => inst_s,
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
    pc_branch_s   <= std_logic_vector(signed(pc_s) + signed(imm_ext_s));
    imm_ext_o  <= imm_ext_s;
    resultSrc  <= resultsrc_s;
    MemWrite   <= memwrite_s;
    ALUSrc     <= alusrc_s;
    RegWrite   <= regwrite_s;
end Structural;