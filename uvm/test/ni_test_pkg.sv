package ni_test_pkg;

	import uvm_pkg::*;
	`include "uvm_macros.svh"
	`include "tb_defs.sv"
    `include "write_xtn.sv"
    `include "read_xtn.sv"
    `include "ni_wr_agt_config.sv"
    `include "ni_rd_agt_config.sv"
    `include "ni_env_config.sv"
    `include "ni_wr_drv.sv"
    `include "ni_wr_mon.sv"
    `include "ni_wr_sequencer.sv"
	`include "ni_wr_agent.sv"
    `include "ni_wr_seqs.sv"

    `include "ni_rd_drv.sv"
    `include "ni_rd_mon.sv"
    `include "ni_rd_sequencer.sv"
	`include "ni_rd_agent.sv"
    `include "ni_rd_seqs.sv"

	`include "ni_virtual_sequencer.sv"
	`include "ni_virtual_seqs.sv"
	`include "rd_ni_vseq.sv"
	`include "rd_load_vseq.sv"
	`include "ni_scoreboard.sv"
	`include "ni_env.sv"
	`include "ni_test.sv"
	`include "wr_load_test.sv"
	`include "rd_ni_test.sv"
endpackage

