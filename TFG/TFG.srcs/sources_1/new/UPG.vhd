library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.System_Config_Pkg.ALL;
use work.ISA_Config_Pkg.ALL;

entity UPG is
    port (
        clk        : in  STD_LOGIC;
        rst        : in  STD_LOGIC;
        pc_i       : in  STD_LOGIC_VECTOR (31 downto 0);
        rs1_addr_i : in  STD_LOGIC_VECTOR (4 downto 0);
        rs2_addr_i : in  STD_LOGIC_VECTOR (4 downto 0);
        rd_addr_i  : in  STD_LOGIC_VECTOR (4 downto 0);
        imm_ext_i  : in  STD_LOGIC_VECTOR (31 downto 0);
        mem_funct3_i : in  STD_LOGIC_VECTOR (2 downto 0);
        ALUControl : in  STD_LOGIC_VECTOR (3 downto 0);
        resultSrc  : in  STD_LOGIC_VECTOR (1 downto 0);
        MemWrite   : in  STD_LOGIC;
        ALUSrc     : in  STD_LOGIC;
        SrcASelect : in  STD_LOGIC_VECTOR (1 downto 0);
        RegWrite   : in  STD_LOGIC;
        alu_res_o  : out STD_LOGIC_VECTOR (31 downto 0);
        store_data_dbg_o : out STD_LOGIC_VECTOR (31 downto 0);
        zero_o     : out STD_LOGIC;
        lt_o       : out STD_LOGIC;
        ltu_o      : out STD_LOGIC
    );
end UPG;

architecture Structural of UPG is
    signal rd1_s       : STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
    signal rd2_s       : STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
    signal alu_in1_s   : STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
    signal alu_in2_s   : STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
    signal alu_res_s   : STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
    signal mem_word_s  : STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
    signal load_data_s : STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
    signal pc_plus4_s  : STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
    signal wb_data_s   : STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
begin
    with SrcASelect select
        alu_in1_s <= rd1_s when SRCASEL_RS1,
                     pc_i when SRCASEL_PC,
                     (others => '0') when SRCASEL_ZERO,
                     rd1_s when others;

    alu_in2_s <= imm_ext_i when ALUSrc = '1' else rd2_s;
    pc_plus4_s <= std_logic_vector(unsigned(pc_i) + to_unsigned(PC_STEP, DATA_WIDTH));

    U_REG_BANK : entity work.Banco_Registros
        port map (
            clk => clk,
            rst => rst,
            a1  => rs1_addr_i,
            a2  => rs2_addr_i,
            a3  => rd_addr_i,
            wd3 => wb_data_s,
            we3 => RegWrite,
            rd1 => rd1_s,
            rd2 => rd2_s
        );

    U_ALU : entity work.ALU
        port map (
            in1  => alu_in1_s,
            in2  => alu_in2_s,
            op   => ALUControl,
            res  => alu_res_s,
            zero => zero_o,
            lt   => lt_o,
            ltu  => ltu_o
        );

    U_DATA_MEM : entity work.Data_memory
        port map (
            clk     => clk,
            we      => MemWrite,
            funct3  => mem_funct3_i,
            Result  => mem_word_s,
            addr    => alu_res_s,
            data_in => rd2_s
        );

    process (mem_word_s, mem_funct3_i, alu_res_s)
        variable byte_v : std_logic_vector(7 downto 0);
        variable half_v : std_logic_vector(15 downto 0);
    begin
        case alu_res_s(1 downto 0) is
            when "00" =>
                byte_v := mem_word_s(7 downto 0);
            when "01" =>
                byte_v := mem_word_s(15 downto 8);
            when "10" =>
                byte_v := mem_word_s(23 downto 16);
            when others =>
                byte_v := mem_word_s(31 downto 24);
        end case;

        if alu_res_s(1) = '0' then
            half_v := mem_word_s(15 downto 0);
        else
            half_v := mem_word_s(31 downto 16);
        end if;

        case mem_funct3_i is
            when FUNCT3_LB =>
                load_data_s <= std_logic_vector(resize(signed(byte_v), DATA_WIDTH));
            when FUNCT3_LH =>
                load_data_s <= std_logic_vector(resize(signed(half_v), DATA_WIDTH));
            when FUNCT3_LW =>
                load_data_s <= mem_word_s;
            when FUNCT3_LBU =>
                load_data_s <= std_logic_vector(resize(unsigned(byte_v), DATA_WIDTH));
            when FUNCT3_LHU =>
                load_data_s <= std_logic_vector(resize(unsigned(half_v), DATA_WIDTH));
            when others =>
                load_data_s <= mem_word_s;
        end case;
    end process;

    with resultSrc select
        wb_data_s <= load_data_s when RESULTSRC_MEM,
                     pc_plus4_s when RESULTSRC_PC4,
                     alu_res_s when others;

    alu_res_o        <= alu_res_s;
    store_data_dbg_o <= rd2_s;
end Structural;
