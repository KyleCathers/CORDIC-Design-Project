
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Top is
    port(
        START_IN, RESET_IN, MODE_IN: in STD_LOGIC;
        CLOCK_IN: in STD_LOGIC;
        ITERATION_SELECT_IN: in STD_LOGIC_VECTOR(3 downto 0);
        DATA_SELECT_IN: in STD_LOGIC_VECTOR(1 downto 0);
        INIT_DATA_SELECTION: in STD_LOGIC_VECTOR(1 downto 0);
        ANODES: out STD_LOGIC_VECTOR (3 downto 0);
        CATHODES: out STD_LOGIC_VECTOR (6 downto 0);
        STATE_OUT: out STD_LOGIC_VECTOR(3 downto 0));
end Top;

architecture Behavioral of Top is
    component CORDIC is 
        port(
            START, MODE, RESET: in STD_LOGIC;
            CLOCK: in STD_LOGIC;
            x_0, y_0, z_0: in STD_LOGIC_VECTOR(15 downto 0);
            iteration_select: in STD_LOGIC_VECTOR(3 downto 0);
            x_i, y_i, z_i: out STD_LOGIC_VECTOR(15 downto 0);
            state_out: out STD_LOGIC_VECTOR(3 downto 0));
    end component;
    
    component hex_driver is
        port(
            clk, reset: in STD_LOGIC;
            hex3, hex2, hex1, hex0: in STD_LOGIC_VECTOR(3 downto 0);
            an: out STD_LOGIC_VECTOR(3 downto 0);
            sseg: out STD_LOGIC_VECTOR(6 downto 0)
        );
    end component;
    
    component debouncer is
        port(
            clk_100MHz: in STD_LOGIC;
            reset: in STD_LOGIC;
            PB_in: in STD_LOGIC;    -- the input PB that is bouncy
            PB_out: out STD_LOGIC);    -- the de-bounced output
    end component;

    -- signals
    signal reset_START, reset_RESET: STD_LOGIC;
    signal d_in_HEX: STD_LOGIC_VECTOR(15 downto 0);
    signal START_debounced: STD_LOGIC;
    signal RESET_debounced: STD_LOGIC;
    signal CORDIC_x_out, CORDIC_y_out, CORDIC_z_out: STD_LOGIC_VECTOR(15 downto 0);
    signal CORDIC_state_out: STD_LOGIC_VECTOR(3 downto 0);
    
    signal x_init: STD_LOGIC_VECTOR(15 downto 0);
    signal y_init: STD_LOGIC_VECTOR(15 downto 0);
    signal z_init: STD_LOGIC_VECTOR(15 downto 0);
    
begin
    CORDIC_processor: CORDIC port map(START => START_debounced, MODE => MODE_IN, RESET => RESET_debounced, CLOCK => CLOCK_IN,
            x_0 => x_init, y_0 => y_init, z_0 => z_init, iteration_select => ITERATION_SELECT_IN, x_i => CORDIC_x_out,
            y_i => CORDIC_y_out, z_i => CORDIC_z_out, state_out => CORDIC_state_out);
    hex_display: hex_driver port map(clk => CLOCK_IN, reset => '0', hex3 => d_in_HEX(15 downto 12), hex2 => d_in_HEX(11 downto 8),
            hex1 => d_in_HEX(7 downto 4), hex0 => d_in_HEX(3 downto 0), an => ANODES, sseg => CATHODES);
    START_debounce: debouncer port map(clk_100MHz => CLOCK_IN, reset => '0', PB_in => START_IN, PB_out => START_debounced);
    RESET_debounce: debouncer port map(clk_100MHz => CLOCK_IN, reset => '0', PB_in => RESET_IN, PB_out => RESET_debounced);
    
    STATE_OUT <= CORDIC_state_out;  -- feed CORDIC mode to LEDs
    
    process(data_select_in, CORDIC_x_out, CORDIC_y_out, CORDIC_z_out, RESET_debounced, CORDIC_state_out)
    begin
        case DATA_SELECT_IN is          -- display selected X/Y/Z data to display
            when "00" =>
                d_in_HEX <= CORDIC_x_out;
            when "01" =>
                d_in_HEX <= CORDIC_y_out;
            when "10" =>
                d_in_HEX <= CORDIC_z_out;
            when others =>
                d_in_HEX <= x"0000";
        end case;
    end process;
    
    process(MODE_IN, INIT_DATA_SELECTION)
    begin                               -- select inital data for x0, y0, z0
        if MODE_IN = '1' then   -- vectoring (y -> 0)
            case INIT_DATA_SELECTION is
                when "00" =>
                    x_init <= x"0000";  -- x = 0
                    y_init <= x"4000";  -- y = 1/2
                    z_init <= x"0000";  -- z = 0
                when "01" =>
                    x_init <= x"2000";  -- x = 1/4
                    y_init <= x"376D";  -- y = sqrt(3)/4
                    z_init <= x"0000";  -- z = 0
                when "10" =>
                    x_init <= x"2000";  -- x = 1/4
                    y_init <= x"2000";  -- y = 1/4
                    z_init <= x"0000";  -- z = 0
                when "11" =>
                    x_init <= x"376D";  -- x = sqrt(3)/4
                    y_init <= x"2000";  -- y = 1/4
                    z_init <= x"0000";  -- z = 0
                when others => NULL;
            end case;
        else                    -- rotation
            case INIT_DATA_SELECTION is
                when "00" =>
                    x_init <= x"4000";  -- x = 1/2
                    y_init <= x"0000";  -- y = 0
                    z_init <= x"2183";  -- z = 30 degrees (CCW)
                when "01" =>
                    x_init <= x"376D";  -- x = sqrt(3)/4
                    y_init <= x"2000";  -- y = 1/4
                    z_init <= x"10C1";  -- z = 15 degrees (CCW)
                when "10" =>
                    x_init <= x"2000";  -- x = 1/4
                    y_init <= x"376D";  -- y = sqrt(3)/4
                    z_init <= x"2183";  -- z = 30 degrees (CCW)
                when "11" =>
                    x_init <= x"2000";  -- x = 1/4
                    y_init <= x"376D";  -- y = sqrt(3)/4
                    z_init <= x"2183";  -- z = 30 degrees (CW)
                when others => NULL;
            end case;
        end if;
    end process;
end Behavioral;
