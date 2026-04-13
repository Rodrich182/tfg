library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library std;
use std.env.all;
use work.System_Config_Pkg.ALL;
use work.ISA_Config_Pkg.ALL;

entity tb_fibonacci_processor_rtl is
end tb_fibonacci_processor_rtl;

architecture sim of tb_fibonacci_processor_rtl is
    constant CLK_PERIOD : time := 10 ns;
    constant EXPECTED_FIB10 : std_logic_vector(DATA_WIDTH - 1 downto 0) := x"00000037";
    constant EXPECTED_HALT_PC : std_logic_vector(DATA_WIDTH - 1 downto 0) := x"0000002C";

    function clog2(n : natural) return natural is
        variable bit_count : natural := 0;
        variable pow2      : natural := 1;
    begin
        while pow2 < n loop
            pow2      := pow2 * 2;
            bit_count := bit_count + 1;
        end loop;
        return bit_count;
    end function;

    constant ROM_IDX_WIDTH : natural := clog2(INSTRUCTION_NUMBER);

    type rom_type is array (0 to INSTRUCTION_NUMBER - 1)
        of std_logic_vector(DATA_WIDTH - 1 downto 0);

    constant FIB_ROM : rom_type := (
        0  => x"00A00093", -- addi x1, x0, 10
        1  => x"00000113", -- addi x2, x0, 0
        2  => x"00100193", -- addi x3, x0, 1
        3  => x"00000213", -- addi x4, x0, 0
        4  => x"00120C63", -- beq  x4, x1, done
        5  => x"003102B3", -- add  x5, x2, x3
        6  => x"00018133", -- add  x2, x3, x0
        7  => x"000281B3", -- add  x3, x5, x0
        8  => x"00120213", -- addi x4, x4, 1
        9  => x"FEDFF06F", -- jal  x0, loop
        10 => x"00202023", -- sw   x2, 0(x0)
        11 => x"00000073", -- ecall
        others => x"00000013" -- nop
    );

    signal clk   : std_logic := '0';
    signal rst   : std_logic := '0';

    signal inst_s       : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal rs1_addr_s   : std_logic_vector(ADDR_LENGTH - 1 downto 0);
    signal rs2_addr_s   : std_logic_vector(ADDR_LENGTH - 1 downto 0);
    signal rd_addr_s    : std_logic_vector(ADDR_LENGTH - 1 downto 0);
    signal pc_s         : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal imm_ext_s    : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal mem_funct3_s : std_logic_vector(FUNCT3_SIZE - 1 downto 0);
    signal resultSrc_s  : std_logic_vector(RESULTSRC_SIZE - 1 downto 0);
    signal MemWrite_s   : std_logic;
    signal ALUControl_s : std_logic_vector(OPP_SIZE - 1 downto 0);
    signal ALUSrc_s     : std_logic;
    signal SrcASelect_s : std_logic_vector(SRCASEL_SIZE - 1 downto 0);
    signal RegWrite_s   : std_logic;

    signal rd1_s       : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal rd2_s       : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal alu_in1_s   : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal alu_in2_s   : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal alu_res_s   : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal mem_word_s  : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal load_data_s : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal pc_plus4_s  : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal wb_data_s   : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal zero_s      : std_logic;
    signal lt_s        : std_logic;
    signal ltu_s       : std_logic;

    signal store_count_s : natural := 0;

    procedure wait_cycles(signal clk_i : in std_logic; constant n : natural) is
    begin
        for i in 1 to n loop
            wait until rising_edge(clk_i);
        end loop;
    end procedure;
begin
    inst_s <= FIB_ROM(
        to_integer(unsigned(pc_s(WORD_ADDR_LSB + ROM_IDX_WIDTH - 1 downto WORD_ADDR_LSB)))
    );

    with SrcASelect_s select
        alu_in1_s <= rd1_s when SRCASEL_RS1,
                     pc_s when SRCASEL_PC,
                     (others => '0') when SRCASEL_ZERO,
                     rd1_s when others;

    alu_in2_s  <= imm_ext_s when ALUSrc_s = '1' else rd2_s;
    pc_plus4_s <= std_logic_vector(unsigned(pc_s) + to_unsigned(PC_STEP, DATA_WIDTH));

    DUT_UC : entity work.UC_core
        port map (
            clk        => clk,
            rst        => rst,
            inst_i     => inst_s,
            zero_i     => zero_s,
            lt_i       => lt_s,
            ltu_i      => ltu_s,
            alu_res_i  => alu_res_s,
            rs1_addr_o => rs1_addr_s,
            rs2_addr_o => rs2_addr_s,
            rd_addr_o  => rd_addr_s,
            pc_o       => pc_s,
            imm_ext_o  => imm_ext_s,
            mem_funct3_o => mem_funct3_s,
            resultSrc  => resultSrc_s,
            MemWrite   => MemWrite_s,
            ALUControl => ALUControl_s,
            ALUSrc     => ALUSrc_s,
            SrcASelect => SrcASelect_s,
            RegWrite   => RegWrite_s
        );

    DUT_REG_BANK : entity work.Banco_Registros
        port map (
            clk => clk,
            rst => rst,
            a1  => rs1_addr_s,
            a2  => rs2_addr_s,
            a3  => rd_addr_s,
            wd3 => wb_data_s,
            we3 => RegWrite_s,
            rd1 => rd1_s,
            rd2 => rd2_s
        );

    DUT_ALU : entity work.ALU
        port map (
            in1  => alu_in1_s,
            in2  => alu_in2_s,
            op   => ALUControl_s,
            res  => alu_res_s,
            zero => zero_s,
            lt   => lt_s,
            ltu  => ltu_s
        );

    DUT_DATA_MEM : entity work.Data_memory
        port map (
            clk     => clk,
            we      => MemWrite_s,
            funct3  => mem_funct3_s,
            Result  => mem_word_s,
            addr    => alu_res_s,
            data_in => rd2_s
        );

    process (mem_word_s, mem_funct3_s, alu_res_s)
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

        case mem_funct3_s is
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

    with resultSrc_s select
        wb_data_s <= load_data_s when RESULTSRC_MEM,
                     pc_plus4_s when RESULTSRC_PC4,
                     alu_res_s when others;

    clk_gen : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    monitor_proc : process (clk)
    begin
        if rising_edge(clk) then
            if rst = '0' and MemWrite_s = '1' then
                store_count_s <= store_count_s + 1;
                assert mem_funct3_s = FUNCT3_SW
                    report "Fibonacci store should use sw"
                    severity failure;
                assert alu_res_s = x"00000000"
                    report "Fibonacci result should be stored at address 0"
                    severity failure;
                assert rd2_s = EXPECTED_FIB10
                    report "Unexpected stored Fibonacci value"
                    severity failure;
            end if;
        end if;
    end process;

    stim_proc : process
    begin
        rst <= '1';
        wait_cycles(clk, 5);

        rst <= '0';

        wait until store_count_s = 1;
        report "Fibonacci RTL result = " &
               integer'image(to_integer(unsigned(rd2_s))) &
               " (0x" & to_hstring(rd2_s) & ")"
            severity note;
        wait_cycles(clk, 6);

        assert store_count_s = 1
            report "Expected exactly one Fibonacci store"
            severity failure;
        assert pc_s = EXPECTED_HALT_PC
            report "PC did not halt on ecall at the expected address"
            severity failure;
        assert MemWrite_s = '0'
            report "Unexpected memory write after Fibonacci store"
            severity failure;

        report "Fibonacci RTL test passed" severity note;
        finish;
        wait;
    end process;
end sim;
