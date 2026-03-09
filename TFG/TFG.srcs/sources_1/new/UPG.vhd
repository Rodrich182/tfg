library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.System_Config_Pkg.ALL;
use work.ISA_Config_Pkg.ALL;

entity UPG is
    port (
        clk        : in  STD_LOGIC;
        rst        : in  STD_LOGIC;
        rs1_addr_i : in  STD_LOGIC_VECTOR (ADDR_LENGTH - 1 downto 0);
        rs2_addr_i : in  STD_LOGIC_VECTOR (ADDR_LENGTH - 1 downto 0);
        rd_addr_i  : in  STD_LOGIC_VECTOR (ADDR_LENGTH - 1 downto 0);
        imm_ext_i  : in  STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
        ALUControl : in  STD_LOGIC_VECTOR (OPP_SIZE - 1 downto 0);
        resultSrc  : in  STD_LOGIC;
        MemWrite   : in  STD_LOGIC;
        ALUSrc     : in  STD_LOGIC;
        RegWrite   : in  STD_LOGIC;
        zero_o     : out STD_LOGIC;
        lt_o       : out STD_LOGIC;
        ltu_o      : out STD_LOGIC
    );
end UPG;

architecture Structural of UPG is
    signal rd1_s      : STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
    signal rd2_s      : STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
    signal alu_in2_s  : STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
    signal alu_res_s  : STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
    signal mem_out_s  : STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
    signal wb_data_s  : STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
begin
    alu_in2_s <= imm_ext_i when ALUSrc = '1' else rd2_s;

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
            in1  => rd1_s,
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
            Result  => mem_out_s,
            addr    => alu_res_s,
            data_in => rd2_s
        );

    wb_data_s <= mem_out_s when resultSrc = '1' else alu_res_s;
end Structural;