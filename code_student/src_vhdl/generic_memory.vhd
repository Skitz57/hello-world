--------------------------------------------------------------
-- Author: 	D. Guenot & M. Duverney
-- Creation: 	24.03.2017
-- Modification:24.03.2017
--------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity generic_memory is
	generic (
		DATASIZE : integer := 8;	-- default value is 8
		FIFOSIZE : integer := 8		-- default value is 8
	);
	
	port (
		clk_i	: in std_logic;
		wr_i	: in std_logic;
		rd_i	: in std_logic;
		addr_i	: in integer range FIFOSIZE-1 downto 0;
		data_i	: in std_logic_vector(DATASIZE-1 downto 0);
		data_o	: out std_logic_vector(DATASIZE-1 downto 0)
	);
end generic_memory;

architecture behavorial of generic_memory is
	type memory_type is array (FIFOSIZE-1 downto 0) of std_logic_vector(DATASIZE-1 downto 0);
	signal memory_s : memory_type;
begin
	process(clk_i)	
	begin
		if rising_edge(clk_i) then
			if (wr_i = '1') then
				memory_s(addr_i) <= data_i;
			end if;
			if (rd_i = '1') then
				data_o <= memory_s(addr_i);
			end if;
		end if;
	end process;
end behavorial;
