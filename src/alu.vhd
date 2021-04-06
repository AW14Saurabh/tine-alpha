LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY tine_alpha;
USE tine_alpha.alu_const.ALL;

ENTITY alu IS
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
END alu;

ARCHITECTURE behavioral OF alu IS

    SIGNAL sub_add_sw : STD_LOGIC;
    SIGNAL adder_result : STD_LOGIC_VECTOR(8 DOWNTO 0);

    SIGNAL unsigned_bt_less : STD_LOGIC;
    SIGNAL signed_bt_less : STD_LOGIC;
    SIGNAL bt_equal : STD_LOGIC;

    SIGNAL skip_flag_prep : STD_LOGIC;
    SIGNAL result_prep : STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN

    sub_add_sw <= '0' WHEN op_code = AO_ADD
        ELSE
        '1';

    adder_result <= STD_LOGIC_VECTOR(
        unsigned('0' & (operand_t XOR (7 DOWNTO 0 => sub_add_sw))) +
        unsigned('0' & operand_b) + unsigned'(0 => sub_add_sw)
        );

    unsigned_bt_less <= NOT adder_result(8);

    signed_bt_less <= NOT adder_result(8) WHEN operand_t(7) = operand_b(7) ELSE
        NOT operand_t(7) AND operand_b(7);

    bt_equal <= '1' WHEN operand_t = operand_b
        ELSE
        '0';

    WITH op_code SELECT skip_flag_prep <=
        NOT unsigned_bt_less WHEN AO_SKGE,
        NOT unsigned_bt_less AND NOT bt_equal WHEN AO_SKG,
        unsigned_bt_less OR bt_equal WHEN AO_SKLE,
        unsigned_bt_less WHEN AO_SKL,
        bt_equal WHEN AO_SKE,
        NOT bt_equal WHEN AO_SKNE,
        '1' WHEN AO_SKIP,
        '0' WHEN OTHERS;

    skip_flag <= skip_flag_prep WHEN stream_b = '0' AND stream_t = '0'
        ELSE
        '0';

    WITH op_code SELECT result_prep <=
        adder_result(7 DOWNTO 0) WHEN AO_ADD,
        adder_result(7 DOWNTO 0) WHEN AO_SUB,
        (0 => signed_bt_less, OTHERS => '0') WHEN AO_SL,
        (0 => unsigned_bt_less, OTHERS => '0') WHEN AO_SLU,
        STD_LOGIC_VECTOR(shift_right(unsigned(operand_b), to_integer(unsigned(operand_t(2 DOWNTO 0))))) WHEN AO_SRL,
        STD_LOGIC_VECTOR(shift_left(unsigned(operand_b), to_integer(unsigned(operand_t(2 DOWNTO 0))))) WHEN AO_SLL,
        operand_t NOR operand_b WHEN AO_NOR,
        operand_t AND operand_b WHEN OTHERS;

    result <= operand_t WHEN stream_t = '1' ELSE
        operand_b WHEN stream_b = '1'
        ELSE
        result_prep;

END behavioral;