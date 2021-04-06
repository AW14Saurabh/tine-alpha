LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY tine_alpha;
USE tine_alpha.address_stage_const.ALL;
USE tine_alpha.sim_data_types.ALL;

ENTITY address_stage IS
    GENERIC (
        sim_en : BOOLEAN := false
    );
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        stall : IN STD_LOGIC;

        jmp_ack : OUT STD_LOGIC;
        --
        jmp_en : IN STD_LOGIC;
        jmp_addr : IN STD_LOGIC_VECTOR(7 DOWNTO 0);

        ip_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        --
        sim : OUT adst_sim_data_type
    );
END address_stage;

ARCHITECTURE behavioral OF address_stage IS

    SIGNAL ip_reg : STD_LOGIC_VECTOR(7 DOWNTO 0);

    SIGNAL sim_sig : adst_sim_data_type;

BEGIN

    ip_out <= ip_reg;
    PROCESS (clk)
    BEGIN
        IF (rising_edge(clk)) THEN
            IF (rst = '1') THEN

                ip_reg <= RST_IP_REG;

            ELSIF (stall = '0') THEN

                jmp_ack <= jmp_en;

                IF (jmp_en = '1') THEN
                    ip_reg <= jmp_addr;
                ELSE
                    ip_reg <= STD_LOGIC_VECTOR(unsigned(ip_reg) + 1);
                END IF;

            END IF;
        END IF;
    END PROCESS;
    sim_sig.ip_reg <= ip_reg;

    sim_switch :
    IF (sim_en = true) GENERATE
        sim <= sim_sig;
    END GENERATE sim_switch;

END behavioral;