--------------------------------------------------------------
-- Author: 	D. Guenot & M. Duverney	---------------------
-- Creation: 	23.03.2017		----------------------
-- Modification:24.03.2017		----------------------
--------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FIFO is
	generic (
		FIFOSIZE   : integer := 8;
		DATASIZE   : integer := 8
	);
	port (
		clk_i      : in    std_logic;
		rst_i      : in    std_logic;
		full_o     : out   std_logic;
		empty_o    : out   std_logic;
		wr_i       : in    std_logic;
		rd_i       : in    std_logic;
		data_i     : in    std_logic_vector(DATASIZE-1 downto 0);
		data_o     : out   std_logic_vector(DATASIZE-1 downto 0)
	);
end fifo;

architecture behavioral  of FIFO is
	----------------
	-- Components --
	----------------	
	component generic_memory -- generic memory --
		generic (
			DATASIZE : integer := 8;
			FIFOSIZE : integer := 8
		);
		port (
			clk_i	: in std_logic;
			wr_i	: in std_logic;
			rd_i	: in std_logic;
			addr_i	: in std_logic_vector(FIFOSIZE-1 downto 0);
			data_i	: in std_logic_vector(DATASIZE-1 downto 0);
			data_o	: in std_logic_vector(DATASIZE-1 downto 0)
		);
	end component;

	-------------
	-- Signals --
	-------------
	signal addr_s : std_logic_vector(FIFOSIZE-1 downto 0);
begin
	----- Components definitions -----
	memory1 : generic_memory	-- register 1
	generic map (
		DATASIZE => 8;
		FIFOSIZE => 8;
	)
	port map (
		-- inputs
		clk_i	=> clk_i
		wr_i	=> wr_i 
		rd_i	=> rd_i
		addr_i	=> addr_s
		data_i	=> data_i
		-- outputs
		data_o	=> data_o
	);

	process (clk_i)
		signal head_addr_s : integer range 0 to FIFOSIZE-1;
		signal tail_addr_s : integer range 0 to FIFOSIZE-1;
		signal counter_s   : integer range 0 to FIFOSIZE-1;
	begin
		if rising_edge(clk_i) then
			if (rst_i = '1') then
				head_addr_s 	:= 0;
				tail_addr_s 	:= 0;
				counter_s	:= 0;
				full_o 		<= '0';
				empty_o 	<= '1';
			elsif wr_i = '1' and  (counter_s /= FIFOSIZE-1) then
				addr_s := head_addr_s;
				counter_s := counter_s + 1;
				head_addr_s := head_addr_s + 1;
			elsif rd_i = '1' and (counter_s /= 0) then
				addr_s := tail_addr_s;
				counter_s := counter_s - 1;
				tail_addr_s := tail_addr_s + 1;
			end if;

			if counter_s = 0 then
				empty_o = '1';
			elsif counter_s = FIFOSIZE-1 then
				full_o = '1';
			else
				full_o = '0';
				empty_o = '0';
			end if;
		end if;
end behavorial;




		 










