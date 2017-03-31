--------------------------------------------------------------
-- Author: 	D. Guenot & M. Duverney
-- Creation: 	29.03.2017
-- Modification:29.03.2017
--------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram is
	generic (
		DATASIZE : integer := 8;	-- default value is 8
		MEMSIZE : integer := 8		-- default value is 8
	);
	
	port (
		-- inputs
		data_i		: in std_logic_vector(DATASIZE-1 downto 0);
		wr_addr_i 	: in integer range MEMSIZE-1 downto 0;
		rd_addr_i 	: in integer range MEMSIZE-1 downto 0;
		we_i		: in std_logic;
		clk_i		: in std_logic;
		-- outputs
		data_o		: out std_logic_vector(DATASIZE-1 downto 0)
	);
end ram;

architecture behavorial of ram is
	type memory_type is array (MEMSIZE-1 downto 0) of std_logic_vector(DATASIZE-1 downto 0);
	signal memory_s : memory_type;
	signal read_addr_s : integer range MEMSIZE-1 downto 0;
begin
	process(clk_i)	
	begin
		if rising_edge(clk_i) then
			if (we_i = '1') then
				memory_s(wr_addr_i) <= data_i;
			end if;
			data_o <= memory_s(rd_addr_i);
		end if;
	end process;
	
end behavorial;
