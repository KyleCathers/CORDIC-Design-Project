
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CORDIC is 
    port(
        START, MODE, RESET: in STD_LOGIC;
        CLOCK: in STD_LOGIC;
        x_0, y_0, z_0: in STD_LOGIC_VECTOR(15 downto 0);
        iteration_select: in STD_LOGIC_VECTOR(3 downto 0);
        x_i, y_i, z_i: out STD_LOGIC_VECTOR(15 downto 0);
        state_out: out STD_LOGIC_VECTOR(3 downto 0));
end CORDIC;

architecture behavioral of CORDIC is
    component ALU is
        port(
            x_in, y_in, z_in, theta_i: in STD_LOGIC_VECTOR(15 downto 0);
            i_in: in STD_LOGIC_VECTOR(3 downto 0);
            mu_i: in STD_LOGIC;
            x_out, y_out, z_out: out STD_LOGIC_VECTOR(15 downto 0));
    end component;
    
    component LUT is
        port(
            i_in: in STD_LOGIC_VECTOR(3 downto 0);
            theta_out: out STD_LOGIC_VECTOR(15 downto 0));
    end component;
    
    component Storage is
        port(
            x_in, y_in, z_in: in STD_LOGIC_VECTOR(15 downto 0);
            done: in STD_LOGIC; -- if done = 0 => write mode, if done = 1 => read mode
            clock: in STD_LOGIC;
            i_read: in STD_LOGIC_VECTOR(3 downto 0);
            i_write: in STD_LOGIC_VECTOR(3 downto 0);
            reset: in STD_LOGIC;
            x_out, y_out, z_out: out STD_LOGIC_VECTOR(15 downto 0));
    end component;
    
    -- signals
    signal x_in_ALU, y_in_ALU, z_in_ALU: STD_LOGIC_VECTOR(15 downto 0);
    signal i_in_ALU: STD_LOGIC_VECTOR(3 downto 0) := x"0";
    signal i_in_Storage: STD_LOGIC_VECTOR(3 downto 0);
    signal mu_i_ALU: STD_LOGIC;
    signal x_out_ALU, y_out_ALU, z_out_ALU: STD_LOGIC_VECTOR(15 downto 0);
    
    signal theta_out_LUT: STD_LOGIC_VECTOR(15 downto 0);
    
    signal x_in_Storage, y_in_Storage, z_in_Storage: STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal reset_Storage: STD_LOGIC;
    signal x_out_Storage, y_out_Storage, z_out_Storage: STD_LOGIC_VECTOR(15 downto 0);
    signal done_Storage: STD_LOGIC := '0';
    
    -- 4 modes for finite state machine
    type state_modes is (mode_wait, mode_start, mode_iterate, mode_display);
    signal state: state_modes := mode_wait;
    
begin
    CORDIC_ALU: ALU port map(x_in => x_in_ALU, y_in => y_in_ALU, z_in => z_in_ALU, theta_i => theta_out_LUT,
            i_in => i_in_ALU, mu_i => mu_i_ALU, x_out => x_out_ALU, y_out => y_out_ALU, z_out => z_out_ALU);
    CORDIC_LUT: LUT port map(i_in => i_in_ALU, theta_out => theta_out_LUT);
    CORDIC_Storage: Storage port map(x_in => x_in_Storage, y_in => y_in_Storage, z_in => z_in_Storage,
            done => done_Storage, clock => CLOCK, i_read => iteration_select, i_write => i_in_ALU, reset => reset_Storage,
            x_out => x_out_Storage, y_out => y_out_Storage, z_out => z_out_Storage);
    
    reset_Storage <= RESET; -- if reset button is pressed, set storage data to 0's

    process(START, RESET, CLOCK, x_0, y_0, z_0, iteration_select, x_out_ALU, y_out_ALU, z_out_ALU, state,
            x_out_Storage, y_out_Storage, z_out_Storage, done_Storage)
    begin  
        if RISING_EDGE(CLOCK) then
            if RESET = '1' then
                state <= mode_wait;
            elsif START = '1' and state = mode_wait then
                state <= mode_start;
            end if;

            case state is
                when mode_wait =>   -- idle
                    state_out <= "0001";
                    done_Storage <= '0';
                    i_in_ALU <= x"0";

                when mode_start =>  -- initalization, i=0
                    state_out <= "0010";
                    
                    -- write initial data to slot 0 in storage arrays
                    x_in_Storage <= x_0;
                    y_in_Storage <= y_0;
                    z_in_Storage <= z_0;

                    -- feed initial data to ALU for first iteration
                    x_in_ALU <= x_0;
                    y_in_ALU <= y_0;
                    z_in_ALU <= z_0;

                    if MODE = '1' then  -- vectoring mode (y -> 0)
                        if y_0(15) = '0' then               -- y > 0
                            mu_i_ALU <= '0';
                        else                                -- y < 0
                            mu_i_ALU <= '1';
                        end if;
                    else                -- rotation mode (z -> 0)
                        if z_0(15) = '0' then               -- z > 0
                            mu_i_ALU <= '1';
                        else                                -- z < 0
                            mu_i_ALU <= '0';
                        end if;
                    end if;

                    state <= mode_iterate;  -- switch to iterate mode next clock cycle

                when mode_iterate =>    -- iterate from i=1->15
                    state_out <= "0100";
                    i_in_ALU <= STD_LOGIC_VECTOR(UNSIGNED(i_in_ALU) + "1");
                    
                    -- feed previous iteration results to ALU
                    x_in_ALU <= x_out_ALU;
                    y_in_ALU <= y_out_ALU;
                    z_in_ALU <= z_out_ALU;
                    
                    if MODE = '1' then  -- vectoring mode (y -> 0)
                        if y_out_ALU(15) = '0' then          -- y > 0
                            mu_i_ALU <= '0';
                        else                                 -- y < 0
                            mu_i_ALU <= '1';
                        end if;
                    else                -- rotation mode (z -> 0)
                        if z_out_ALU(15) = '0' then          -- z > 0
                            mu_i_ALU <= '1';
                        else                                 -- z < 0
                            mu_i_ALU <= '0';
                        end if;
                    end if;
                    
                    -- write values to storage(i)
                    x_in_Storage <= x_out_ALU;
                    y_in_Storage <= y_out_ALU;
                    z_in_Storage <= z_out_ALU;
                    
                    if i_in_ALU = x"F" then     -- finished iterations at i = 15
                        state <= mode_display;
                        done_Storage <= '1';
                    end if;
                    
                when mode_display =>    -- done iteration, send data to display
                    state_out <= "1000";
                    x_i <= x_out_storage;
                    y_i <= y_out_storage;
                    z_i <= z_out_storage;
                    
                when others =>          -- error state
                    state_out <= "0000";
            end case;
        end if;
    end process;
end behavioral;