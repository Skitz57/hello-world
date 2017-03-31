--------------------------------------------------------------
-- Author: 	D. Guenot & M. Duverney	---------------------
-- Creation: 	23.03.2017		----------------------
-- Modification:31.03.2017		----------------------
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
	component ram -- generic memory --
		generic (
			DATASIZE : integer;
			MEMSIZE : integer
		);
		port (
			-- inputs
			data_i		: in std_logic_vector(DATASIZE-1 downto 0);
			wr_addr_i	: in integer range MEMSIZE-1 downto 0;
			rd_addr_i	: in integer range MEMSIZE-1 downto 0;
			we_i		: in std_logic;
			clk_i		: in std_logic;
			-- outputs
			data_o	: out std_logic_vector(DATASIZE-1 downto 0)
		);
	end component;

	-------------
	-- Signals --
	-------------
	signal we_s 		: std_logic;
	signal re_s 		: std_logic;

	signal wr_addr_s 	: integer range FIFOSIZE-1 downto 0;
	signal rd_addr_s	: integer range FIFOSIZE-1 downto 0;
	signal wr_addr_fut_s 	: integer range FIFOSIZE-1 downto 0;
	signal rd_addr_fut_s 	: integer range FIFOSIZE-1 downto 0;

	signal empty_s		: std_logic;
	signal full_s		: std_logic;
	signal empty_fut_s	: std_logic;
	signal full_fut_s	: std_logic;

	signal last_op_s	: std_logic_vector(1 downto 0); -- 1->write / 0->read
begin
	----- Components definitions -----
	memory1 : ram	-- memory 1
	generic map (
		DATASIZE => DATASIZE,
		MEMSIZE => FIFOSIZE
	)
	port map (
		-- inputs
		data_i		=> data_i,
		wr_addr_i	=> wr_addr_s,
		rd_addr_i	=> rd_addr_fut_s,
		we_i		=> we_s,
		clk_i		=> clk_i,
		-- outputs
		data_o	=> data_o
	);

	-- Sync process
	process (clk_i)
	begin
		if rising_edge(clk_i) then
			-- Reset
			if (rst_i = '1') then
				wr_addr_s 	<= 0;
				rd_addr_s 	<= 0;
				last_op_s	<= "00";
				full_s 		<= '0';
				empty_s		<= '1';
			else
				-- Write
				if we_s = '1' then
					last_op_s <= "01";
				end if;
				wr_addr_s <= wr_addr_fut_s;
				-- Read
				if  re_s = '1' then
					last_op_s <= "10";
				end if;
				if we_s = '1' and re_s = '1' then
					last_op_s <= "11";
				end if;
				if we_s = '0' and re_s = '0' then
					last_op_s <= "00";
				end if;

				full_s <= full_fut_s;
				empty_s <= empty_fut_s;
				rd_addr_s <= rd_addr_fut_s;
			end if;
		end if;
	end process;


	--------------------------------------------
	-- TURFU process -> wr and rd fut address --
	--------------------------------------------
	process (wr_addr_s, rd_addr_s, we_s, re_s)
	begin
		if we_s = '1' then
			if wr_addr_s = FIFOSIZE-1 then
				wr_addr_fut_s <= 0;
			else
				wr_addr_fut_s <= wr_addr_s + 1;
			end if;
		else
			wr_addr_fut_s <= wr_addr_s;
		end if;

		if re_s = '1' then
			if rd_addr_s = FIFOSIZE-1 then
				rd_addr_fut_s <= 0;
			else
				rd_addr_fut_s <= rd_addr_s + 1;
			end if;
		else
			rd_addr_fut_s <= rd_addr_s; -- Maintien
		end if;
	end process;


	-----------------------------------------
	-- TURFU process -> full_s and empty_s --
	-----------------------------------------
	process (clk_i, wr_addr_fut_s, rd_addr_fut_s, last_op_s)
	begin
		-- If memory address looped...
		if wr_addr_fut_s = rd_addr_fut_s then
			-- ...with a WRITE operation -> memory is full
			if last_op_s = "01" then
				full_fut_s <= '1';
				empty_fut_s <= '0';
			-- ...with a READ operation -> memory is empty
			elsif last_op_s = "10" then
				full_fut_s <= '0';
				empty_fut_s <= '1';
			else -- If memory address not looped -> neither full nor empty
				full_fut_s <= full_s;
				empty_fut_s <= empty_s;
			end if;
		else
		full_fut_s <= '0';
		empty_fut_s <= '0';
		end if;

	end process;

	-----------------------------------------------
	-- TURFU process -> last_op_fut and we_s --
	-----------------------------------------------
	process (wr_i, rd_i, full_s, empty_s)
	begin
		-- Write
		if full_s = '0' and wr_i = '1' then
			we_s <= '1';
		else
			we_s <= '0';
		end if;
		-- Read
		if empty_fut_s = '0' and rd_i = '1' then
			re_s <= '1';
		else
			re_s <= '0';
		end if;
	end process;

	full_o <= full_s;
	empty_o <= empty_s;

end behavioral;
