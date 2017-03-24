-------------------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : fifo_tb.vhd
--
-- Description  : Ce banc de test vérifie le bon fonctionnement d'un simple
--                FIFO. Il s'agit d'une version relativement simple, ne
--                stressant pas particulièrement le design
--
-- Auteur       : Yann Thoma, Rick Wertenbroek
-- Date         : 12.03.2015
-- Version      : 2.0
--
-- Utilise      :
--              :
--
--| Modifications |------------------------------------------------------------
-- Version   Auteur      Date               Description
-- 1.0       YTA         see header         First version.
-- 2.0       RWE         15.03.17           TLMVM Version
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library tlmvm;
context tlmvm.tlmvm_context;

use work.RNG.all;

------------
-- Entity --
------------
entity fifo_tb is
    generic (FIFOSIZE  : integer := 8;
             DATAWIDTH : integer := 8);
end fifo_tb;

------------------
-- Architecture --
------------------
architecture test_bench of fifo_tb is

    -- Create a specialized FIFO package with the same data width for holding
    -- the transaction (requests and responses) they are of the same type.
    package my_tlm_pkg is new tlm_unbounded_fifo_pkg
        generic map (element_type => std_logic_vector(DATAWIDTH-1 downto 0));

    ---------------
    -- Constants --
    ---------------
    constant CLK_PERIOD : time := 10 ns;
    constant NUMBER_OF_TRANSACTIONS : integer := 100;

    ----------------
    -- Components --
    ----------------
    component fifo
        generic (
            FIFOSIZE : integer := 8;
            DATASIZE : integer := 8
            );
        port (
            clk_i   : in  std_logic;
            rst_i   : in  std_logic;
            full_o  : out std_logic;
            empty_o : out std_logic;
            wr_i    : in  std_logic;
            rd_i    : in  std_logic;
            data_i  : in  std_logic_vector(DATASIZE-1 downto 0);
            data_o  : out std_logic_vector(DATASIZE-1 downto 0)
            );
    end component;

    ----------------------
    -- Shared Variables --
    ---------------------- -- May be accessed by more than one process at the time
    shared variable fifo_sti : my_tlm_pkg.tlm_fifo_type; -- Stimuli transactions
    shared variable fifo_obs : my_tlm_pkg.tlm_fifo_type; -- Responses
    shared variable fifo_ref : my_tlm_pkg.tlm_fifo_type; -- Reference

    -------------
    -- Signals --
    -------------
    signal clk_sti      : std_logic;
    signal rst_sti      : std_logic;
    signal full_obs     : std_logic;
    signal empty_obs    : std_logic;
    signal wr_sti       : std_logic;
    signal rd_sti       : std_logic;
    signal data_in_sti  : std_logic_vector(DATAWIDTH-1 downto 0);
    signal data_out_obs : std_logic_vector(DATAWIDTH-1 downto 0);

    signal reader_start_s : std_logic;

    ----------------
    -- Procedures --
    ----------------
    procedure rep(status : finish_status_t) is
    begin
        report "End of simulation";
    end rep;


begin

    -- Simulation monitor
    monitor : simulation_monitor
    generic map (
        drain_time => 2000 ns, -- Timeout (objections)
        beat_time => 2000 ns, -- Timeout (heart beat)
        final_reporting => rep
    );

    -- Clock generation
    clock_generator(clk_sti, CLK_PERIOD);

    -- Reset generation
    simple_startup_reset(rst_sti, CLK_PERIOD * 10);

    -- Device under test
    DUT : fifo
    generic map(
        FIFOSIZE => FIFOSIZE,
        DATASIZE => DATAWIDTH
    )
    port map(
        clk_i   => clk_sti,
        rst_i   => rst_sti,
        full_o  => full_obs,
        empty_o => empty_obs,
        wr_i    => wr_sti,
        rd_i    => rd_sti,
        data_i  => data_in_sti,
        data_o  => data_out_obs
    );

    -- Driver process : will take transactions from the stimulation FIFO and
    -- administer them to the DUT
    driver_process : process is
        variable data_v : std_logic_vector(DATAWIDTH-1 downto 0);
    begin
        wait until falling_edge(rst_sti);

        loop
            wr_sti <= '0';

            -- Get a word from the stimuli FIFO
            my_tlm_pkg.blocking_get(fifo_sti, data_v);

            wait until falling_edge(clk_sti);
            -- If the DUT if full, wait
            if full_obs = '1' then
                wait until full_obs = '0';
            end if;
            -- Write to DUT
            data_in_sti <= data_v;
            wr_sti <= '1';
            wait until rising_edge(clk_sti);
        end loop;
    end process driver_process;

    -- Reader process : Once the DUT is full this process will read from the DUT
    -- forever, if the DUT is not empty this process will put the word read in
    -- the obs FIFO for review by the verification process
    reader_process : process is
        --                                      Seed, Mean, Var
        variable rnd_100 : Uniform := InitUniform(7, 0.0, 3.0);
        variable ok : boolean;
    begin
        rd_sti <= '0';
        wait until full_obs = '1';

        loop
            -- Random wait
            GenRnd(rnd_100);
            wait for (integer(rnd_100.rnd))*CLK_PERIOD;

            wait until falling_edge(clk_sti);

            -- Send the result back if there is one
            if empty_obs = '0' then
                fifo_obs.put(data_out_obs, ok);
            end if;

            rd_sti <= '1'; -- Will also try to read when the DUT is empty this
                           -- is intended to check how the DUT behaves
            wait until rising_edge(clk_sti);
            rd_sti <= '0';

        end loop;
    end process reader_process;

    -- Stimulation process : This will generate data to the stimuli and
    -- reference FIFOs for the Driver to send to the DUT and for the
    -- verification process as a reference
    stimulation_process : process is
    begin
        -- This will send a given number of data packets to the driver and the
        -- reference FIFO (for verification)

        for i in 1 to NUMBER_OF_TRANSACTIONS loop
            raise_objection; -- Check usage of objections
            my_tlm_pkg.blocking_put(fifo_sti, std_logic_vector(to_unsigned(i, DATAWIDTH)));
            drop_objection; -- Check usage of objections
            my_tlm_pkg.blocking_put(fifo_ref, std_logic_vector(to_unsigned(i, DATAWIDTH)));
        end loop;

        wait;
    end process stimulation_process;

    -- Verification process : This will check the data reader from the DUT by
    -- the reader process and compare them in contents to the reference, this
    -- will also warn if more data has been read as expected, If the simulation
    -- ends without showing the message that all data was read there is a problem
    verification_process : process is
        variable data_obs_v  : std_logic_vector(DATAWIDTH-1 downto 0);
        variable data_ref_v  : std_logic_vector(DATAWIDTH-1 downto 0);
        variable read_data_v : integer := 0;
    begin
        -- This will check the data from the reader against the reference data

        loop
            my_tlm_pkg.blocking_get(fifo_obs, data_obs_v);
            read_data_v := read_data_v + 1;

            if read_data_v = NUMBER_OF_TRANSACTIONS then
                report "All data was read" severity note;
            end if;

            if read_data_v > NUMBER_OF_TRANSACTIONS then
                -- Problem !
                report "More data was read than expected !" severity error;
            end if;

            my_tlm_pkg.blocking_get(fifo_ref, data_ref_v);

            if data_obs_v /= data_ref_v then
                -- Problem !
                report "Unexpected data ! Expected : " & to_hstring(data_ref_v) & " But got : " & to_hstring(data_obs_v) severity error;
            end if;
        end loop;

    end process verification_process;

end test_bench;
