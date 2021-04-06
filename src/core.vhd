LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

LIBRARY tine_alpha;
USE tine_alpha.sim_data_types.ALL;

ENTITY core IS
    GENERIC (
        sim_en : BOOLEAN := false
    );
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        --
        imem_d_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);

        imem_rd : OUT STD_LOGIC;
        imem_addr : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        --
        dmem_d_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);

        dmem_wr : OUT STD_LOGIC;
        dmem_addr : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        dmem_d_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        --
        sim : OUT core_sim_data_type
    );
END core;

ARCHITECTURE behavioral OF core IS

    COMPONENT address_stage IS
        GENERIC (
            sim_en : BOOLEAN := sim_en
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
    END COMPONENT;

    SIGNAL adst_jmp_ack : STD_LOGIC;
    --
    SIGNAL adst_ip_out : STD_LOGIC_VECTOR(7 DOWNTO 0);
    COMPONENT fetch_stage IS
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
    END COMPONENT;

    SIGNAL fest_inst_out : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL fest_ip_out : STD_LOGIC_VECTOR(7 DOWNTO 0);
    COMPONENT execute_stage IS
        GENERIC (
            sim_en : BOOLEAN := sim_en
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

            result : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            --
            dmem_d_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);

            dmem_wr : OUT STD_LOGIC;
            dmem_addr : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            dmem_d_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            --
            sim : OUT exst_sim_data_type
        );
    END COMPONENT;

    SIGNAL exst_skip_flag : STD_LOGIC;
    SIGNAL exst_lda_flag : STD_LOGIC;
    SIGNAL exst_jmp_flag : STD_LOGIC;
    --
    SIGNAL exst_result : STD_LOGIC_VECTOR(7 DOWNTO 0);
    COMPONENT hazard_unit IS
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
    END COMPONENT;

    SIGNAL haun_fetch_nop : STD_LOGIC;
    SIGNAL haun_stall_sig : STD_LOGIC;
    SIGNAL sim_sig : core_sim_data_type;

BEGIN

    address_stage_0 : address_stage PORT MAP(
        clk => clk,
        rst => rst,
        stall => haun_stall_sig,

        jmp_ack => adst_jmp_ack,
        --
        jmp_en => exst_jmp_flag,
        jmp_addr => exst_result,

        ip_out => adst_ip_out,
        --
        sim => sim_sig.adst_sim
    );
    fetch_stage_0 : fetch_stage PORT MAP(
        clk => clk,
        rst => rst,
        stall => haun_stall_sig,
        fetch_nop => haun_fetch_nop,
        --
        ip_in => adst_ip_out,

        inst_out => fest_inst_out,
        ip_out => fest_ip_out,
        --
        imem_d_in => imem_d_in,

        imem_rd => imem_rd,
        imem_addr => imem_addr
    );
    execute_stage_0 : execute_stage PORT MAP(
        clk => clk,
        rst => rst,

        skip_flag => exst_skip_flag,
        lda_flag => exst_lda_flag,
        jmp_flag => exst_jmp_flag,
        --
        inst_in => fest_inst_out,
        ip_in => fest_ip_out,

        result => exst_result,
        --
        dmem_d_in => dmem_d_in,

        dmem_wr => dmem_wr,
        dmem_addr => dmem_addr,
        dmem_d_out => dmem_d_out,
        --
        sim => sim_sig.exst_sim
    );
    hazard_unit_0 : hazard_unit PORT MAP(
        clk => clk,
        rst => rst,
        --
        skip_ack => exst_skip_flag,
        lda_ack => exst_lda_flag,
        jmp_start => exst_jmp_flag,
        jmp_cmplt => adst_jmp_ack,

        fetch_nop => haun_fetch_nop,
        stall_sig => haun_stall_sig
    );
    sim_switch :
    IF (sim_en = true) GENERATE
        sim <= sim_sig;
    END GENERATE sim_switch;

END behavioral;