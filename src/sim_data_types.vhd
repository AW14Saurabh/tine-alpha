LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

LIBRARY tine_alpha;

PACKAGE sim_data_types IS

    TYPE adst_sim_data_type IS RECORD
        ip_reg : STD_LOGIC_VECTOR(7 DOWNTO 0);
    END RECORD;
    TYPE refi_sim_data_type IS RECORD
        wr_en : STD_LOGIC;
        index : STD_LOGIC_VECTOR(1 DOWNTO 0);

        r0_reg : STD_LOGIC_VECTOR(7 DOWNTO 0);
        r1_reg : STD_LOGIC_VECTOR(7 DOWNTO 0);
        r2_reg : STD_LOGIC_VECTOR(7 DOWNTO 0);
        r3_reg : STD_LOGIC_VECTOR(7 DOWNTO 0);
    END RECORD;
    TYPE exst_sim_data_type IS RECORD
        refi_sim : refi_sim_data_type;

        jmp_state : STD_LOGIC;
        jmp_link : STD_LOGIC;
        lda_state : STD_LOGIC;

        ir_reg : STD_LOGIC_VECTOR(7 DOWNTO 0);
        a_reg_wr : STD_LOGIC;
        a_reg : STD_LOGIC_VECTOR(7 DOWNTO 0);
    END RECORD;
    TYPE core_sim_data_type IS RECORD
        adst_sim : adst_sim_data_type;
        exst_sim : exst_sim_data_type;
    END RECORD;

END sim_data_types;