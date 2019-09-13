library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
    port(
        x_in, y_in, z_in, theta_i: in STD_LOGIC_VECTOR(15 downto 0);
        i_in: in STD_LOGIC_VECTOR(3 downto 0);
        mu_i: in STD_LOGIC;
        x_out, y_out, z_out: out STD_LOGIC_VECTOR(15 downto 0));
end ALU;

architecture behavioral of ALU is
begin
    process(x_in, y_in, z_in, theta_i, mu_i, i_in)
    begin
        if mu_i = '1' then      -- clockwise rotation
            -- x_i+1 = x_i - y_i * 2^-i
            x_out <= STD_LOGIC_VECTOR(SIGNED(x_in) - SHIFT_RIGHT(SIGNED(y_in), TO_INTEGER(UNSIGNED(i_in))));
            -- y_i+1 = y_i + x_i * 2^-i
            y_out <= STD_LOGIC_VECTOR(SIGNED(y_in) + SHIFT_RIGHT(SIGNED(x_in), TO_INTEGER(UNSIGNED(i_in))));
            -- z_i+1 = z_i - theta_i
            z_out <= STD_LOGIC_VECTOR(SIGNED(z_in) - SIGNED(theta_i));
        else                    -- counterclockwise rotation
            -- x_i+1 = x_i + y_i * 2^-i
            x_out <= STD_LOGIC_VECTOR(SIGNED(x_in) + SHIFT_RIGHT(SIGNED(y_in), TO_INTEGER(UNSIGNED(i_in))));
            -- y_i+1 = y_i - x_i * 2^-i
            y_out <= STD_LOGIC_VECTOR(SIGNED(y_in) - SHIFT_RIGHT(SIGNED(x_in), TO_INTEGER(UNSIGNED(i_in))));
            -- z_i+1 = z_i + theta_i
            z_out <= STD_LOGIC_VECTOR(SIGNED(z_in) + SIGNED(theta_i));
        end if;
    end process;
end behavioral;
