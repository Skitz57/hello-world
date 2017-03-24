library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fifo is
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


