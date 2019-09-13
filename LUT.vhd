library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity LUT is
    port(
        i_in: in STD_LOGIC_VECTOR(3 downto 0);
        theta_out: out STD_LOGIC_VECTOR(15 downto 0));
end LUT;

architecture behavioral of LUT is
begin   
    process(i_in)
    begin
        case i_in is
            when "0000" =>              -- i = 0, theta = 0.7854
                theta_out <= x"3244"; 
            when "0001" =>              -- i = 1, theta = 0.4636
                theta_out <= x"1DAC";
            when "0010" =>              -- i = 2, theta = 0.2450
                theta_out <= x"0FAE";
            when "0011" =>              -- i = 3, theta = 0.1244
                theta_out <= x"07F6";
            when "0100" =>              -- i = 4, theta = 0.0624
                theta_out <= x"03FF";
            when "0101" =>              -- i = 5, theta = 0.0312
                theta_out <= x"0200";
            when "0110" =>              -- i = 6, theta = 0.0156
                theta_out <= x"0100";
            when "0111" =>              -- i = 7, theta = 0.0078
                theta_out <= x"0080";
            when "1000" =>              -- i = 8, theta = 0.0039
                theta_out <= x"0040";
            when "1001" =>              -- i = 9, theta = 0.0020
                theta_out <= x"0020";
            when "1010" =>              -- i = 10, theta = 0.00098
                theta_out <= x"0010";
            when "1011" =>              -- i = 11, theta = 0.00049
                theta_out <= x"0008";
            when "1100" =>              -- i = 12, theta = 0.00024
                theta_out <= x"0004";
            when "1101" =>              -- i = 13, theta = 0.00012
                theta_out <= x"0002";
            when "1110" =>              -- i = 14, theta = 0.000061
                theta_out <= x"0001";
            when "1111" =>              -- i = 15, theta = 0.000031
                theta_out <= x"0001";
            when others => NULL;
        end case;
    end process;
end behavioral;
