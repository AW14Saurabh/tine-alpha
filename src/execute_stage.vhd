LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

LIBRARY tine_alpha;
USE tine_alpha.alu_const.ALL;
USE tine_alpha.fetch_stage_const.ALL;
USE tine_alpha.sim_data_types.ALL;

ENTITY execute_stage IS
    GENERIC (
        sim_en : BOOLEAN := false
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
END execute_stage;

ARCHITECTURE behavioral OF execute_stage IS

    COMPONENT register_file IS
        GENERIC (
            sim_en : BOOLEAN := sim_en
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
    END COMPONENT;

    SIGNAL refi_wr_en : STD_LOGIC;

    SIGNAL refi_data_out : STD_LOGIC_VECTOR(7 DOWNTO 0);
    COMPONENT alu IS
        PORT (
            stream_t : IN STD_LOGIC;
            stream_b : IN STD_LOGIC;
            --
            op_code : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            operand_t : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            operand_b : IN STD_LOGIC_VECTOR(7 DOWNTO 0);

            skip_flag : OUT STD_LOGIC;
            result : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL alu_stream_t : STD_LOGIC;
    SIGNAL alu_stream_b : STD_LOGIC;
    --
    SIGNAL alu_op_code : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL alu_operand_t : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL alu_operand_b : STD_LOGIC_VECTOR(7 DOWNTO 0);

    SIGNAL alu_skip_flag : STD_LOGIC;
    SIGNAL alu_result : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL jmp_state : STD_LOGIC;
    SIGNAL jmp_link : STD_LOGIC;
    SIGNAL lda_state : STD_LOGIC;

    SIGNAL ir_reg : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL ip_reg : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL a_reg : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL a_reg_wr : STD_LOGIC;

    SIGNAL copy_inst : STD_LOGIC;
    SIGNAL dmem_inst : STD_LOGIC;
    SIGNAL li_inst : STD_LOGIC;
    SIGNAL jmp_inst : STD_LOGIC;
    SIGNAL jmpa_inst : STD_LOGIC;

    SIGNAL sign_ext_imm : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL li_imm : STD_LOGIC_VECTOR(7 DOWNTO 0);

    SIGNAL jmp_flag_sig : STD_LOGIC;
    SIGNAL lda_flag_sig : STD_LOGIC;

    SIGNAL sim_sig : exst_sim_data_type;

BEGIN

    skip_flag <= alu_skip_flag;

    dmem_inst <= '1' WHEN ir_reg(7 DOWNTO 3) = "00010"
        ELSE
        '0';

    lda_flag_sig <= '1' WHEN dmem_inst = '1' AND ir_reg(2) = '0'
        ELSE
        '0';

    lda_flag <= lda_flag_sig;

    jmp_inst <= '1' WHEN ir_reg(7 DOWNTO 5) = "010"
        ELSE
        '0';

    jmpa_inst <= '1' WHEN ir_reg(7 DOWNTO 1) = "0000111"
        ELSE
        '0';

    jmp_flag_sig <= jmp_inst OR jmpa_inst;

    jmp_flag <= jmp_flag_sig;
    --
    result <= alu_result;
    --
    dmem_wr <= '1' WHEN dmem_inst = '1' AND ir_reg(2) = '1'
        ELSE
        '0';

    dmem_addr <= refi_data_out;

    dmem_d_out <= a_reg;
    register_file_0 : register_file PORT MAP(
        clk => clk,
        --
        wr_en => refi_wr_en,
        index => ir_reg(1 DOWNTO 0),
        data_in => alu_result,

        data_out => refi_data_out,
        --
        sim => sim_sig.refi_sim
    );

    copy_inst <= '1' WHEN ir_reg(7 DOWNTO 3) = "00011"
        ELSE
        '0';

    refi_wr_en <= '1' WHEN copy_inst = '1' AND ir_reg(2) = '1'
        ELSE
        '0';
    alu_0 : alu PORT MAP(
        stream_t => alu_stream_t,
        stream_b => alu_stream_b,
        --
        op_code => alu_op_code,
        operand_t => alu_operand_t,
        operand_b => alu_operand_b,

        skip_flag => alu_skip_flag,
        result => alu_result
    );

    li_inst <= '1' WHEN ir_reg(7 DOWNTO 5) = "011"
        ELSE
        '0';

    alu_stream_t <= '1' WHEN li_inst = '1' OR (copy_inst = '1' AND ir_reg(2) = '0')
        ELSE
        '0';

    alu_stream_b <= '1' WHEN
        (copy_inst = '1' AND ir_reg(2) = '1') OR
        jmpa_inst = '1' OR (jmp_state = '1' AND jmp_link = '1')
        ELSE
        '0';

    alu_op_code <=
        ir_reg(7 DOWNTO 4) WHEN ir_reg(7) = '1' ELSE
        ir_reg(5 DOWNTO 2) WHEN ir_reg(7 DOWNTO 5) = "001" ELSE
        ir_reg(3 DOWNTO 0) WHEN ir_reg(7 DOWNTO 3) = "00000"
        ELSE
        AO_ADD;

    li_imm <= (3 DOWNTO 0 => '0') & ir_reg(3 DOWNTO 0) WHEN ir_reg(4) = '0'
        ELSE
        ir_reg(3 DOWNTO 0) & (3 DOWNTO 0 => '0');

    sign_ext_imm <= li_imm WHEN li_inst = '1'
        ELSE
        (3 DOWNTO 0 => ir_reg(3)) & ir_reg(3 DOWNTO 0);

    alu_operand_t <=
        refi_data_out WHEN ir_reg(7 DOWNTO 6) = "00" AND (ir_reg(5) = '1' OR ir_reg(4 DOWNTO 2) = "110") ELSE
        "00000000" WHEN ir_reg(7 DOWNTO 3) = "00000"
        ELSE
        sign_ext_imm;

    alu_operand_b <= ip_reg WHEN jmp_inst = '1' OR (jmp_state = '1' AND jmp_link = '1')
        ELSE
        a_reg;
    a_reg_wr <= '1' WHEN
        ir_reg(7) = '1' OR ir_reg(7 DOWNTO 5) = "011" OR
        ir_reg(7 DOWNTO 5) = "001" OR ir_reg(7 DOWNTO 2) = "000110" OR
        (jmp_state = '1' AND jmp_link = '1') OR lda_state = '1'
        ELSE
        '0';

    PROCESS (clk)
    BEGIN
        IF (rising_edge(clk)) THEN
            IF (rst = '1') THEN

                jmp_state <= '0';
                lda_state <= '0';
                ir_reg <= NOP_INST;

            ELSE

                ip_reg <= ip_in;
                ir_reg <= inst_in;

                IF (a_reg_wr = '1') THEN
                    IF (lda_state = '1') THEN
                        a_reg <= dmem_d_in;
                    ELSE
                        a_reg <= alu_result;
                    END IF;
                END IF;

                IF (jmp_state = '1') THEN
                    jmp_state <= '0';
                ELSIF (jmp_flag_sig = '1') THEN
                    jmp_state <= '1';
                    IF (jmp_inst = '1') THEN
                        jmp_link <= NOT ir_reg(4);
                    ELSE
                        jmp_link <= NOT ir_reg(0);
                    END IF;
                END IF;

                IF (lda_state = '1') THEN
                    lda_state <= '0';
                ELSIF (lda_flag_sig = '1') THEN
                    lda_state <= '1';
                END IF;

            END IF;
        END IF;
    END PROCESS;
    sim_sig.jmp_state <= jmp_state;
    sim_sig.jmp_link <= jmp_link;
    sim_sig.lda_state <= lda_state;

    sim_sig.ir_reg <= ir_reg;
    sim_sig.a_reg_wr <= a_reg_wr;
    sim_sig.a_reg <= a_reg;

    sim_switch :
    IF (sim_en = true) GENERATE
        sim <= sim_sig;
    END GENERATE sim_switch;

END behavioral;