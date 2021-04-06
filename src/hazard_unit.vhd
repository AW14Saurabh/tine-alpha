LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

LIBRARY tine_alpha;
USE tine_alpha.address_stage_const.ALL;

ENTITY hazard_unit IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        --
        skip_ack : IN STD_LOGIC;
        lda_ack : IN STD_LOGIC;
        jmp_start : IN STD_LOGIC;
        jmp_cmplt : IN STD_LOGIC;

        fetch_nop : OUT STD_LOGIC;
        stall_sig : OUT STD_LOGIC
    );
END hazard_unit;

ARCHITECTURE behavioral OF hazard_unit IS

    SIGNAL jmp_state : STD_LOGIC;

BEGIN

    fetch_nop <= skip_ack OR lda_ack OR jmp_start OR jmp_state;

    stall_sig <= lda_ack;
    PROCESS (clk)
    BEGIN
        IF (rising_edge(clk)) THEN
            IF (rst = '1') THEN
                jmp_state <= '0';
            ELSE
                IF (jmp_cmplt = '1') THEN
                    jmp_state <= '0';
                ELSIF (jmp_start = '1') THEN
                    jmp_state <= '1';
                END IF;
            END IF;
        END IF;
    END PROCESS;

END behavioral;