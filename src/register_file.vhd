LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY tine_alpha;
USE tine_alpha.sim_data_types.ALL;

ENTITY register_file IS
    GENERIC (
        sim_en : BOOLEAN := false
    );
    PORT (
        clk : IN STD_LOGIC;
        --
        wr_en : IN STD_LOGIC;
        index : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        data_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);

        data_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        --
        sim : OUT refi_sim_data_type
    );
END register_file;

ARCHITECTURE behavioral OF register_file IS

    TYPE mem_array IS ARRAY (3 DOWNTO 0) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL reg_array : mem_array;

    SIGNAL sim_sig : refi_sim_data_type;

BEGIN

    data_out <= reg_array(to_integer(unsigned(index)));
    PROCESS (clk)
    BEGIN
        IF (rising_edge(clk)) THEN

            IF (wr_en = '1') THEN
                reg_array(to_integer(unsigned(index))) <= data_in;
            END IF;

        END IF;
    END PROCESS;
    sim_sig.wr_en <= wr_en;
    sim_sig.index <= index;

    sim_sig.r0_reg <= reg_array(0);
    sim_sig.r1_reg <= reg_array(1);
    sim_sig.r2_reg <= reg_array(2);
    sim_sig.r3_reg <= reg_array(3);

    sim_switch :
    IF (sim_en = true) GENERATE
        sim <= sim_sig;
    END GENERATE sim_switch;

END behavioral;