----------------------------------------------------------------------------------
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
    Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
           i_B : in STD_LOGIC_VECTOR (7 downto 0);
           i_op : in STD_LOGIC_VECTOR (2 downto 0);
           o_result : out STD_LOGIC_VECTOR (7 downto 0);
           o_flags : out STD_LOGIC_VECTOR (3 downto 0));
end ALU;

architecture Behavioral of ALU is

    signal w_result : STD_LOGIC_VECTOR (7 downto 0);
    signal w_carry  : STD_LOGIC;
    signal w_overflow : STD_LOGIC;

begin

    process(i_A, i_B, i_op)
        variable v_temp : unsigned(8 downto 0);
    begin
        w_carry <= '0';
        w_overflow <= '0';

        case i_op is
            when "000" =>
                v_temp := ('0' & unsigned(i_A)) + ('0' & unsigned(i_B));
                w_result <= std_logic_vector(v_temp(7 downto 0));
                w_carry <= v_temp(8);

            when "001" =>
                v_temp := ('0' & unsigned(i_A)) - ('0' & unsigned(i_B));
                w_result <= std_logic_vector(v_temp(7 downto 0));

                if unsigned(i_A) >= unsigned(i_B) then
                    w_carry <= '1';
                else
                    w_carry <= '0';
                end if;

            when "010" =>
                w_result <= i_A and i_B;

            when "011" =>
                w_result <= i_A or i_B;

            when others =>
                w_result <= (others => '0');
        end case;
    end process;

    o_result <= w_result;

    -- Flags: [3]=Negative, [2]=Zero, [1]=Carry, [0]=Overflow
    o_flags(3) <= w_result(7);
    o_flags(2) <= '1' when w_result = "00000000" else '0';
    o_flags(1) <= w_carry;
    o_flags(0) <= w_overflow;

end Behavioral;