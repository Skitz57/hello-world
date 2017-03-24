-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- File         : hex_7_dec.vhd
-- Description  : Décodeur de chiffre hexadécimal codé sur 4 bits vers
--                affichage 7 segments (7 bits) avec enable.
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

entity hex_7_seg is
    port (
        value_i    : in  std_logic_vector(3 downto 0);
        enable_i   : in  std_logic;
        segments_o : out std_logic_vector(6 downto 0)
    );
end hex_7_seg;

architecture lut of hex_7_seg is
begin

    decoder_process : process(enable_i, value_i) is
    begin

        if enable_i = '1' then
            -- Table de vérité du décodeur
            case value_i is
                when "0000" => segments_o <= "0111111"; -- 0
		when "0001" => segments_o <= "0000110"; -- 1
		when "0010" => segments_o <= "1011011"; -- 2
		when "0011" => segments_o <= "1001111"; -- 3
		when "0100" => segments_o <= "1100110"; -- 4
		when "0101" => segments_o <= "1101101"; -- 5
		when "0110" => segments_o <= "1111101"; -- 6
		when "0111" => segments_o <= "0000111"; -- 7
		when "1000" => segments_o <= "1111111"; -- 8
		when "1001" => segments_o <= "1101111"; -- 9
		when "1010" => segments_o <= "1110111"; -- A
		when "1011" => segments_o <= "1111100"; -- b
		when "1100" => segments_o <= "1011000"; -- c
		when "1101" => segments_o <= "1011110"; -- d
		when "1110" => segments_o <= "1111001"; -- E
		when "1111" => segments_o <= "1110001"; -- F
                when others => segments_o <= "1010101";
            end case;
        else
            segments_o <= (others => '0');
        end if;

    end process decoder_process;

end lut;
