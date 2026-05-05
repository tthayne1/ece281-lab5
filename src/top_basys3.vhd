--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity top_basys3 is
    port(
        clk     :   in std_logic;
        sw      :   in std_logic_vector(7 downto 0);
        btnU    :   in std_logic;
        btnC    :   in std_logic;
        
        led :   out std_logic_vector(15 downto 0);
        seg :   out std_logic_vector(6 downto 0);
        an  :   out std_logic_vector(3 downto 0)
    );
end top_basys3;

architecture top_basys3_arch of top_basys3 is 
  
	-- declare components and signals

    component controller_fsm is
        Port ( i_reset : in STD_LOGIC;
               i_adv : in STD_LOGIC;
               o_cycle : out STD_LOGIC_VECTOR (3 downto 0));
    end component;

    component ALU is
        Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
               i_B : in STD_LOGIC_VECTOR (7 downto 0);
               i_op : in STD_LOGIC_VECTOR (2 downto 0);
               o_result : out STD_LOGIC_VECTOR (7 downto 0);
               o_flags : out STD_LOGIC_VECTOR (3 downto 0));
    end component;

    component clock_divider is
        generic ( constant k_DIV : natural := 2 );
        port (  i_clk    : in std_logic;
                i_reset  : in std_logic;
                o_clk    : out std_logic);
    end component;

    component button_debounce is
        Port ( i_clk   : in  STD_LOGIC;
               i_reset : in  STD_LOGIC;
               i_btn   : in  STD_LOGIC;
               o_btn   : out STD_LOGIC);
    end component;

    component twos_comp is
        port (
            i_bin: in std_logic_vector(7 downto 0);
            o_sign: out std_logic;
            o_hund: out std_logic_vector(3 downto 0);
            o_tens: out std_logic_vector(3 downto 0);
            o_ones: out std_logic_vector(3 downto 0)
        );
    end component;

    component TDM4 is
        generic ( constant k_WIDTH : natural := 4);
        Port ( i_clk		: in  STD_LOGIC;
               i_reset		: in  STD_LOGIC;
               i_D3 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
               i_D2 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
               i_D1 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
               i_D0 		: in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
               o_data		: out STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
               o_sel		: out STD_LOGIC_VECTOR (3 downto 0)
        );
    end component;

    component sevenseg_decoder is
        Port (
            i_Hex   : in  STD_LOGIC_VECTOR(3 downto 0);
            o_seg_n : out STD_LOGIC_VECTOR(6 downto 0)
        );
    end component;

    signal w_cycle      : std_logic_vector(3 downto 0);
    signal w_btnC_db    : std_logic;
    signal w_slow_clk   : std_logic;

    signal f_A          : std_logic_vector(7 downto 0) := (others => '0');
    signal f_B          : std_logic_vector(7 downto 0) := (others => '0');

    signal w_result     : std_logic_vector(7 downto 0);
    signal w_flags      : std_logic_vector(3 downto 0);

    signal w_display    : std_logic_vector(7 downto 0);

    signal w_sign       : std_logic;
    signal w_hund       : std_logic_vector(3 downto 0);
    signal w_tens       : std_logic_vector(3 downto 0);
    signal w_ones       : std_logic_vector(3 downto 0);

    signal w_tdm_data   : std_logic_vector(3 downto 0);
    signal w_tdm_sel    : std_logic_vector(3 downto 0);

    signal w_sign_digit : std_logic_vector(3 downto 0);

  
begin
	-- PORT MAPS ----------------------------------------

    u_db : button_debounce
        port map (
            i_clk => clk,
            i_reset => btnU,
            i_btn => btnC,
            o_btn => w_btnC_db
        );

    u_fsm : controller_fsm
        port map (
            i_reset => btnU,
            i_adv => w_btnC_db,
            o_cycle => w_cycle
        );

    u_alu : ALU
        port map (
            i_A => f_A,
            i_B => f_B,
            i_op => sw(2 downto 0),
            o_result => w_result,
            o_flags => w_flags
        );

    u_clk : clock_divider
        generic map (k_DIV => 50000)
        port map (
            i_clk => clk,
            i_reset => btnU,
            o_clk => w_slow_clk
        );

    u_twos : twos_comp
        port map (
            i_bin => w_display,
            o_sign => w_sign,
            o_hund => w_hund,
            o_tens => w_tens,
            o_ones => w_ones
        );

    u_tdm : TDM4
        port map (
            i_clk => w_slow_clk,
            i_reset => btnU,
            i_D3 => w_sign_digit,
            i_D2 => w_hund,
            i_D1 => w_tens,
            i_D0 => w_ones,
            o_data => w_tdm_data,
            o_sel => w_tdm_sel
        );

    u_seg : sevenseg_decoder
        port map (
            i_Hex => w_tdm_data,
            o_seg_n => seg
        );

	
	
	-- CONCURRENT STATEMENTS ----------------------------

    process(w_btnC_db)
    begin
        if rising_edge(w_btnC_db) then
            if btnU = '1' then
                f_A <= (others => '0');
                f_B <= (others => '0');
            else
                if w_cycle = "0010" then
                    f_A <= sw;
                elsif w_cycle = "0100" then
                    f_B <= sw;
                end if;
            end if;
        end if;
    end process;

    with w_cycle select
        w_display <= f_A      when "0010",
                     f_B      when "0100",
                     w_result when "1000",
                     (others => '0') when others;

    w_sign_digit <= "1111" when w_sign = '1' else "0000";

    an <= w_tdm_sel;
    led(3 downto 0) <= w_cycle;
    led(15 downto 12) <= w_flags;
    led(11 downto 4) <= (others => '0');
	
	
	
end top_basys3_arch;