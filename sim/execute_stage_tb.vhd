LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY tine_alpha;
USE tine_alpha.fetch_stage_const.ALL;
USE tine_alpha.sim_data_types.ALL;

ENTITY execute_stage_tb IS
END execute_stage_tb;

ARCHITECTURE behavioral OF execute_stage_tb IS

    COMPONENT execute_stage IS
        GENERIC (
            sim_en : BOOLEAN := true
        );
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;

            skip_flag : OUT STD_LOGIC;
            lda_flag : OUT STD_LOGIC;
            jmp_flag : OUT STD_LOGIC;
            --
            inst_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            ip_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);

            alu_rslt : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            --
            dmem_d_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);

            dmem_wr : OUT STD_LOGIC;
            dmem_addr : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            dmem_d_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            --
            sim : OUT exst_sim_data_type
        );
    END COMPONENT;

    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL rst : STD_LOGIC := '0';

    SIGNAL skip_flag : STD_LOGIC;
    SIGNAL lda_flag : STD_LOGIC;
    SIGNAL jmp_flag : STD_LOGIC;
    --
    SIGNAL inst_in : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ip_in : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');

    SIGNAL alu_rslt : STD_LOGIC_VECTOR(7 DOWNTO 0);
    --
    SIGNAL dmem_d_in : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');

    SIGNAL dmem_wr : STD_LOGIC;
    SIGNAL dmem_addr : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL dmem_d_out : STD_LOGIC_VECTOR(7 DOWNTO 0);
    --
    SIGNAL sim : exst_sim_data_type;
    CONSTANT CLK_PERIOD : TIME := 10 ns;

BEGIN

    uut : execute_stage PORT MAP(
        clk => clk,
        rst => rst,

        skip_flag => skip_flag,
        lda_flag => lda_flag,
        jmp_flag => jmp_flag,
        --
        inst_in => inst_in,
        ip_in => ip_in,

        alu_rslt => alu_rslt,
        --
        dmem_d_in => dmem_d_in,

        dmem_wr => dmem_wr,
        dmem_addr => dmem_addr,
        dmem_d_out => dmem_d_out,
        --
        sim => sim
    );
    clk_proc : PROCESS
    BEGIN
        clk <= '0';
        WAIT FOR CLK_PERIOD/2;
        clk <= '1';
        WAIT FOR CLK_PERIOD/2;
    END PROCESS;
    stim_proc : PROCESS
    BEGIN
        rst <= '1';
        WAIT FOR CLK_PERIOD;

        rst <= '0';
        inst_in <= NOP_INST;
        ip_in <= "01010101";
        dmem_d_in <= "10101010";
        WAIT FOR CLK_PERIOD;

        inst_in <= "01101111";
        WAIT FOR CLK_PERIOD;

        inst_in <= "00011100";
        WAIT FOR CLK_PERIOD;

        inst_in <= "01111111";
        WAIT FOR CLK_PERIOD;

        inst_in <= "00100000";
        WAIT FOR CLK_PERIOD;

        inst_in <= "00110000";
        WAIT FOR CLK_PERIOD;

        inst_in <= "00000010";
        WAIT FOR CLK_PERIOD;

        inst_in <= "00000011";
        WAIT;
    END PROCESS;

END behavioral;