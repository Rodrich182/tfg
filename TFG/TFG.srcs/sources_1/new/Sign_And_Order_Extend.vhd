library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.System_Config_Pkg.ALL;
use work.ISA_Config_Pkg.ALL;

entity sign_extend_Order is
    port (
        inst      : in  STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0);
        ImmSrc    : in  STD_LOGIC_VECTOR (ImmSrc_size - 1 downto 0);
        immediate : out STD_LOGIC_VECTOR (DATA_WIDTH - 1 downto 0)
    );
end sign_extend_Order;

architecture Behavioral of sign_extend_Order is
begin
    process (inst, ImmSrc)
    begin
        case ImmSrc is
            when IMMSRC_I =>
                immediate <= std_logic_vector(resize(signed(inst(I_IMM_END downto I_IMM_INIT)), DATA_WIDTH));

            when IMMSRC_S =>
                immediate <= std_logic_vector(
                    resize(
                        signed(inst(SB1_IMM_END downto SB1_IMM_INIT) & inst(SB2_IMM_END downto SB2_IMM_INIT)),
                        DATA_WIDTH
                    )
                );

            when IMMSRC_B =>
                immediate <= std_logic_vector(
                    resize(
                        signed(
                            inst(B_SIGN_BIT) &
                            inst(B_BIT11) &
                            inst(B_HIGH_END downto B_HIGH_INIT) &
                            inst(B_LOW_END downto B_LOW_INIT) &
                            "0"
                        ),
                        DATA_WIDTH
                    )
                );

            when IMMSRC_J =>
                immediate <= std_logic_vector(
                    resize(
                        signed(
                            inst(J_SIGN_BIT) &
                            inst(J_MID_END downto J_MID_INIT) &
                            inst(J_BIT11) &
                            inst(J_LOW_END downto J_LOW_INIT) &
                            "0"
                        ),
                        DATA_WIDTH
                    )
                );

            when IMMSRC_U =>
                immediate <= inst(DATA_WIDTH - 1 downto 12) & "000000000000";

            when others =>
                immediate <= (others => '0');
        end case;
    end process;
end Behavioral;
