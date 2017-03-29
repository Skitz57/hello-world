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
		FIFOSIZE   : integer ;
		DATASIZE   : integer 
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
			DATASIZE : integer ;
			FIFOSIZE : integer 
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
	signal head_addr_s : integer range 0 to FIFOSIZE-1;
	signal tail_addr_s : integer range 0 to FIFOSIZE-1;
	signal counter_s   : integer range 0 to FIFOSIZE-1;

begin
	----- Components definitions -----
	memory1 : generic_memory	-- register 1
	generic map (
		DATASIZE => 8,
		FIFOSIZE => 8
	)
	port map (
		-- inputs
		clk_i	=> clk_i,
		wr_i	=> wr_i, 
		rd_i	=> rd_i,
		addr_i	=> addr_s,
		data_i	=> data_i,
		-- outputs
		data_o	=> data_o
	);

	process (clk_i)
	
	begin
		if rising_edge(clk_i) then
			if (rst_i = '1') then
				head_addr_s 	<= 0;
				tail_addr_s 	<= 0;
				counter_s	<= 0;
				full_o 		<= '0';
				empty_o 	<= '1';
			elsif wr_i = '1' and  (counter_s /= FIFOSIZE-1) then
				addr_s <= std_logic_vector(to_unsigned(head_addr_s, addr_s'length)) ;
				counter_s <= counter_s + 1;
				if(head_addr_s = FIFOSIZE-1) then
					head_addr_s <= 0;
				else
					head_addr_s <= head_addr_s + 1;
				end if;
					
			elsif rd_i = '1' and (counter_s /= 0) then
				addr_s <=  std_logic_vector(to_unsigned(tail_addr_s, addr_s'length));
				counter_s <= counter_s - 1;
				tail_addr_s <= tail_addr_s + 1;
				if(tail_addr_s = FIFOSIZE-1) then
					tail_addr_s <= 0;
				else
					tail_addr_s <= tail_addr_s + 1;
				end if;
			end if;

			if counter_s = 0 then
				empty_o <= '1';
			elsif counter_s = FIFOSIZE-1 then
				full_o <= '1';
			else
				full_o <= '0';
				empty_o <= '0';
			end if;
		end if;
	end process;
end behavioral;




		 










