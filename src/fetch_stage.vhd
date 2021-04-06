LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

LIBRARY tine_alpha;
USE tine_alpha.fetch_stage_const.ALL;

ENTITY fetch_stage IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        stall : IN STD_LOGIC;
        fetch_nop : IN STD_LOGIC;
        --
        ip_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);

        inst_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        ip_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        --
        imem_d_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);

        imem_rd : OUT STD_LOGIC;
        imem_addr : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END fetch_stage;

ARCHITECTURE behavioral OF fetch_stage IS

    SIGNAL rst_state : STD_LOGIC;

    SIGNAL ip_reg : STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN

    inst_out <= imem_d_in WHEN rst_state = '0' AND fetch_nop = '0'
        ELSE
        NOP_INST;

    ip_out <= ip_reg;

    imem_rd <= NOT stall;

    imem_addr <= ip_in;
    PROCESS (clk)
    BEGIN
        IF (rising_edge(clk)) THEN
            rst_state <= rst;
            IF (stall = '0') THEN
                ip_reg <= ip_in;
            END IF;
        END IF;
    END PROCESS;

END behavioral;