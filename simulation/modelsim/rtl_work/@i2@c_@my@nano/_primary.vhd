library verilog;
use verilog.vl_types.all;
entity I2C_MyNano is
    port(
        CLOCK_50        : in     vl_logic;
        LED             : out    vl_logic_vector(7 downto 0);
        KEY             : in     vl_logic_vector(1 downto 0);
        SW              : in     vl_logic_vector(3 downto 0);
        I2C_SCL         : out    vl_logic;
        I2C_SDA         : inout  vl_logic;
        COUNT           : out    vl_logic_vector(9 downto 0);
        SD_COUNTER      : out    vl_logic_vector(6 downto 0)
    );
end I2C_MyNano;
