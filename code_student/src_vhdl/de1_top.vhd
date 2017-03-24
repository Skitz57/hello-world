-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- File         : de1_top.vhd
-- Description  : TOP pour le test du laboratoire 2 de CSF - FIFO sur carte
--                réelle - DE1_SoC
--
-- Author       : Rick Wertenbroek
-- Date         : 10.02.17
-- Version      : 0.0
--
-- Dependencies :
--
--| Modifications |------------------------------------------------------------
-- Version   Author Date               Description
-- 0.0       RWE    10.02.17           Creation
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity de1_top is
    port (
        -- Entrées
        clk_i          : in std_logic;
        switches_i     : in std_logic_vector(9 downto 0); -- 1 quand en haut
        push_buttons_i : in std_logic_vector(3 downto 0); -- 0 quand appuyé

        -- Sorties

        -- Segments (anode commune)
        segments_0_o   : out std_logic_vector(6 downto 0);
        segments_1_o   : out std_logic_vector(6 downto 0);
        segments_2_o   : out std_logic_vector(6 downto 0);
        segments_3_o   : out std_logic_vector(6 downto 0);
        segments_4_o   : out std_logic_vector(6 downto 0);
        segments_5_o   : out std_logic_vector(6 downto 0);

        -- LEDs
        leds_o         : out std_logic_vector(9 downto 0)
    );
end de1_top;

architecture struct of de1_top is
    ----------------
    -- Constantes --
    ----------------
    constant FIFOSIZE : integer := 512; -- Profondeur de la FIFO instanciée

    -----------
    -- Types --
    -----------
    subtype segment        is std_logic_vector(6 downto 0);
    subtype eight_bit_word is std_logic_vector(7 downto 0);
    type segment_array     is array (5 downto 0) of segment;

    ---------------
    -- Registres --
    ---------------
    signal read_request_s      : std_logic;
    signal write_request_s     : std_logic;

    -------------
    -- Signaux --
    -------------
    signal rst_s               : std_logic;
    signal fifo_full_s         : std_logic;
    signal fifo_empty_s        : std_logic;
    signal read_button_regs_s  : std_logic_vector(1 downto 0);
    signal write_button_regs_s : std_logic_vector(1 downto 0);
    signal segments_s          : segment_array := (others => (others => '0'));

begin

    -- Câblage (boutons actifs bas)
    rst_s <= not push_buttons_i(0);

    -- Câblage de la FIFO
    fifo_1 : entity work.fifo
        generic map (
            FIFOSIZE => FIFOSIZE,
            DATASIZE => eight_bit_word'length
        )
        port map (
            clk_i    => clk_i,
            rst_i    => rst_s,
            full_o   => fifo_full_s,
            empty_o  => fifo_empty_s,
            wr_i     => write_request_s,
            rd_i     => read_request_s,
            data_i   => switches_i(eight_bit_word'range),
            data_o   => leds_o(eight_bit_word'range)
        );

    -- Read / Write request process
    read_write_req_process : process(clk_i) is
    begin

        -- Détection d'une demande de lecture / écriture :
        -- On veut émettre une lecture / écriture à la FIFO lors de l'appui du
        -- bouton correspondant.
        --
        -- Premièrement on synchronise les entrées au clock dans le registre
        -- 0 correspondant, le registre 1 est branché à la sortie du registre 0
        -- ce qui donne les signaux synchrones suivants lors de la pression
        -- d'un bouton.
        -- Deuxièmement on crée une pulse d'un coup de clock qui représente la
        -- demande de l'action correspondant au bouton.
        --                            __________
        -- read_button_regs_s(0) : __|          |____
        --                              __________
        -- read_button_regs_s(1) : ____|          |__
        --                            _
        -- read_request_s        : __| |_____________
        --                     Pulse de 1 coup de clock
        --
        -- Note : Les boutons poussoirs sont "déboucés" cf. page 23 du manuel
        -- du DE1-SoC

        if rising_edge(clk_i) then
            if rst_s = '1' then
                read_button_regs_s  <= (others => '0');
                write_button_regs_s <= (others => '0');
            else
                read_button_regs_s(0)  <= not push_buttons_i(2);
                write_button_regs_s(0) <= not push_buttons_i(3);
                read_button_regs_s(1)  <= read_button_regs_s(0);
                write_button_regs_s(1) <= write_button_regs_s(0);
            end if;
        end if;

    end process read_write_req_process;

    read_request_s  <= read_button_regs_s(0)  and not read_button_regs_s(1);
    write_request_s <= write_button_regs_s(0) and not write_button_regs_s(1);

    -----------------------------------
    -- Affichage Flags Empty et Full --
    -----------------------------------
    seven_seg_empty : entity work.hex_7_seg
        port map (
            value_i    => "1110", -- E
            enable_i   => fifo_empty_s,
            segments_o => segments_s(0)
        );

    seven_seg_full : entity work.hex_7_seg
        port map (
            value_i    => "1111", -- F
            enable_i   => fifo_full_s,
            segments_o => segments_s(1)
        );

    -----------------------------
    -- Assignation des sorties --
    -----------------------------

    -- Anode commune, allumé à l'état bas
    segments_0_o <= not segments_s(0); -- Empty
    segments_1_o <= not segments_s(1); -- Full
    segments_2_o <= not segments_s(2);
    segments_3_o <= not segments_s(3);
    segments_4_o <= not segments_s(4);
    segments_5_o <= not segments_s(5);

    leds_o(9 downto 8) <= (others => '0'); -- Off

end struct;
