-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2025 02:50:18 PM
-- Design Name: 
-- Module Name: ALU - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

entity ALU is
    Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
           i_B : in STD_LOGIC_VECTOR (7 downto 0);
           i_op : in STD_LOGIC_VECTOR (2 downto 0);
           o_result : out STD_LOGIC_VECTOR (7 downto 0);
           o_flags : out STD_LOGIC_VECTOR (3 downto 0));
end ALU;

architecture Behavioral of ALU is

begin

    process(i_A, i_B, i_op)
        variable v_temp : unsigned(8 downto 0);
        variable v_result : STD_LOGIC_VECTOR(7 downto 0);
        variable v_N : STD_LOGIC;
        variable v_Z : STD_LOGIC;
        variable v_C : STD_LOGIC;
        variable v_V : STD_LOGIC;
    begin
        v_result := (others => '0');
        v_N := '0';
        v_Z := '0';
        v_C := '0';
        v_V := '0';

        case i_op is
            when "000" =>
                v_temp := resize(unsigned(i_A), 9) + resize(unsigned(i_B), 9);
                v_result := std_logic_vector(v_temp(7 downto 0));
                v_C := v_temp(8);

                if (i_A(7) = i_B(7)) and (v_result(7) /= i_A(7)) then
                    v_V := '1';
                end if;

            when "001" =>
                v_temp := resize(unsigned(i_A), 9) - resize(unsigned(i_B), 9);
                v_result := std_logic_vector(v_temp(7 downto 0));

                if unsigned(i_A) >= unsigned(i_B) then
                    v_C := '1';
                else
                    v_C := '0';
                end if;

                if (i_A(7) /= i_B(7)) and (v_result(7) /= i_A(7)) then
                    v_V := '1';
                end if;

            when "010" =>
                v_result := i_A and i_B;

            when "011" =>
                v_result := i_A or i_B;

            when others =>
                v_result := (others => '0');
        end case;

        v_N := v_result(7);

        if v_result = "00000000" then
            v_Z := '1';
        else
            v_Z := '0';
        end if;

        o_result <= v_result;
        o_flags(3) <= v_N;
        o_flags(2) <= v_Z;
        o_flags(1) <= v_C;
        o_flags(0) <= v_V;
    end process;

end Behavioral;