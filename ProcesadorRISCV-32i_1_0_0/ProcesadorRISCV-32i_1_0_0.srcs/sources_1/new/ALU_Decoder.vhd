----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 30.01.2026 02:19:26
-- Design Name: 
-- Module Name: ALU_decod - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.System_Config_Pkg.ALL;
use work.ISA_Config_Pkg.ALL;

entity ALU_decod is
    Port (
        ALU_OP  : in  STD_LOGIC_VECTOR (ALUOP_SIZE - 1 downto 0);
        IsRType : in  STD_LOGIC;
        funct3  : in  STD_LOGIC_VECTOR (FUNCT3_SIZE - 1 downto 0);
        funct7  : in  STD_LOGIC_VECTOR (FUNCT7_SIZE - 1 downto 0);
        ALU_Sel : out STD_LOGIC_VECTOR (ALUCTRL_SIZE - 1 downto 0)
    );
end ALU_decod;

architecture Behavioral of ALU_decod is
begin
    process (ALU_OP, IsRType, funct3, funct7)
    begin
        ALU_Sel <= ALUCTRL_ADD; -- Default ADD

        case ALU_OP is
            when ALUOP_ADD =>
                ALU_Sel <= ALUCTRL_ADD; -- LW/SW -> ADD

            when ALUOP_SUB =>
                ALU_Sel <= ALUCTRL_SUB; -- Branch compare base

            when ALUOP_DECODE =>
                case funct3 is
                    when FUNCT3_ADD_SUB => -- ADD/SUB
                        -- SUB solo existe en R-type; en I-type funct7 bits son parte del inmediato.
                        if (IsRType = '1') and (funct7(FUNCT7_ALT_BIT) = '1') then
                            ALU_Sel <= ALUCTRL_SUB; -- SUB
                        else
                            ALU_Sel <= ALUCTRL_ADD; -- ADD
                        end if;

                    when FUNCT3_SLL =>
                        ALU_Sel <= ALUCTRL_SLL;

                    when FUNCT3_SLT =>
                        ALU_Sel <= ALUCTRL_SLT;

                    when FUNCT3_SLTU =>
                        ALU_Sel <= ALUCTRL_SLTU;

                    when FUNCT3_XOR =>
                        ALU_Sel <= ALUCTRL_XOR;

                    when FUNCT3_SRL_SRA =>
                        if funct7(FUNCT7_ALT_BIT) = '1' then
                            ALU_Sel <= ALUCTRL_SRA;
                        else
                            ALU_Sel <= ALUCTRL_SRL;
                        end if;

                    when FUNCT3_OR =>
                        ALU_Sel <= ALUCTRL_OR;

                    when FUNCT3_AND =>
                        ALU_Sel <= ALUCTRL_AND;

                    when others =>
                        ALU_Sel <= ALUCTRL_ADD;
                end case;

            when others =>
                ALU_Sel <= ALUCTRL_ADD;
        end case;
    end process;
end Behavioral;