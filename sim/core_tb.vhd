LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY tine_alpha;
USE tine_alpha.sim_data_types.ALL;

ENTITY core_tb IS
END core_tb;

ARCHITECTURE behavioral OF core_tb IS

    COMPONENT core IS
        GENERIC (
            sim_en : BOOLEAN := true
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
    END COMPONENT;

    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL rst : STD_LOGIC := '0';
    --
    SIGNAL imem_d_in : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');

    SIGNAL imem_rd : STD_LOGIC;
    SIGNAL imem_addr : STD_LOGIC_VECTOR(7 DOWNTO 0);
    --
    SIGNAL dmem_d_in : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');

    SIGNAL dmem_wr : STD_LOGIC;
    SIGNAL dmem_addr : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL dmem_d_out : STD_LOGIC_VECTOR(7 DOWNTO 0);
    --
    SIGNAL sim : core_sim_data_type;
    COMPONENT imem IS
        PORT (
            clk : IN STD_LOGIC;
            --
            rd_en : IN STD_LOGIC;
            addr : IN STD_LOGIC_VECTOR(7 DOWNTO 0);

            d_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT;
    COMPONENT rwm_generic IS
        GENERIC (
            ADDR_BIT_WIDTH : NATURAL := 8;
            DATA_BIT_WIDTH : POSITIVE := 8
        );
        PORT (
            clk : IN STD_LOGIC;
            --
            wr_en : IN STD_LOGIC;
            rd_en : IN STD_LOGIC;
            addr : IN STD_LOGIC_VECTOR(ADDR_BIT_WIDTH - 1 DOWNTO 0);
            d_in : IN STD_LOGIC_VECTOR(DATA_BIT_WIDTH - 1 DOWNTO 0);

            d_out : OUT STD_LOGIC_VECTOR(DATA_BIT_WIDTH - 1 DOWNTO 0)
        );
    END COMPONENT;
    CONSTANT CLK_PERIOD : TIME := 10 ns;

BEGIN

    uut : core PORT MAP(
        clk => clk,
        rst => rst,
        --
        imem_d_in => imem_d_in,

        imem_rd => imem_rd,
        imem_addr => imem_addr,
        --
        dmem_d_in => dmem_d_in,

        dmem_wr => dmem_wr,
        dmem_addr => dmem_addr,
        dmem_d_out => dmem_d_out,
        --
        sim => sim
    );
    imem_0 : imem PORT MAP(
        clk => clk,
        --
        rd_en => imem_rd,
        addr => imem_addr,

        d_out => imem_d_in
    );
    dmem_0 : rwm_generic PORT MAP(
        clk => clk,
        --
        wr_en => dmem_wr,
        rd_en => '1',
        addr => dmem_addr,
        d_in => dmem_d_out,

        d_out => dmem_d_in
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
        WAIT;
    END PROCESS;

END behavioral;