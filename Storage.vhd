library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Storage is
    port(
        x_in, y_in, z_in: in STD_LOGIC_VECTOR(15 downto 0);
        done: in STD_LOGIC; -- if done = 0 => write mode, if done = 1 => read mode
        clock: in STD_LOGIC;
        i_read: in STD_LOGIC_VECTOR(3 downto 0);
        i_write: in STD_LOGIC_VECTOR(3 downto 0);
        reset: in STD_LOGIC;
        x_out, y_out, z_out: out STD_LOGIC_VECTOR(15 downto 0));
end Storage;

architecture behavioral of Storage is
    -- 16 16-bit vectors for x, y, and z data
    type x_data is array (15 downto 0) of STD_LOGIC_VECTOR(15 downto 0);
    type y_data is array (15 downto 0) of STD_LOGIC_VECTOR(15 downto 0);
    type z_data is array (15 downto 0) of STD_LOGIC_VECTOR(15 downto 0);
    
    -- initialize data to 0's
    signal x_array: x_data := (others => (others => '0')); 
    signal y_array: y_data := (others => (others => '0'));
    signal z_array: z_data := (others => (others => '0'));

begin
    process (clock, x_in, y_in, z_in, done, i_read, i_write, x_array, y_array, z_array, reset)
    begin
        if reset = '1' then                                 -- reset data to 0's
            x_array <= (others => (others => '0'));
            y_array <= (others => (others => '0'));
            z_array <= (others => (others => '0'));
            
        else
            if FALLING_EDGE(clock) AND (done = '0') then    -- write mode
                x_array(TO_INTEGER(UNSIGNED(i_write))) <= x_in;
                y_array(TO_INTEGER(UNSIGNED(i_write))) <= y_in;
                z_array(TO_INTEGER(UNSIGNED(i_write))) <= z_in;
            end if;
            
            if done = '1' then                              -- read mode
                x_out <= x_array(TO_INTEGER(UNSIGNED(i_read)));
                y_out <= y_array(TO_INTEGER(UNSIGNED(i_read)));
                z_out <= z_array(TO_INTEGER(UNSIGNED(i_read)));
            end if;
        end if;
    end process;
end behavioral;
