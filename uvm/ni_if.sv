import fsm_pkg::*;
import ni_pkg::*;
import apb_pkg::*;

interface ni_if(input bit clk);
    logic                    resetn;
    // NI side (NoC interface)
    logic             [15:0] i_flit;
    logic                    enable;
    logic            [15:0] o_flit;
    logic                   ready;
    logic                   valid_out;
    // APB side
    apb_resp_s        apb_resp_signals;
    apb_req_s         apb_req_signals;
	/* logic rst, load, read_en, count_en; */
	/* logic [`DATA_WIDTH-1:0] data_in; */
	/* logic [`DATA_WIDTH-1:0] data_out; */

	clocking flit_drv_cb @(posedge clk);
		default input #1 output #1;
		output resetn;
		output i_flit;
		output enable;
	endclocking

	clocking flit_mon_cb @(posedge clk);
		default input #1 output #1;
		input resetn;
		input i_flit;
		input enable;
		// output signals monitor
		input o_flit;
		input ready;
		input valid_out;
	endclocking

	clocking apb_drv_cb @(posedge clk);
		default input #1 output #1;
		output apb_resp_signals;
	endclocking

	clocking apb_mon_cb @(posedge clk);
		default input #1 output #1;
		input apb_resp_signals;
		// apb output monitor
		input apb_req_signals;
	endclocking

	modport FL_D_MP (clocking flit_drv_cb);
	modport FL_M_MP (clocking flit_mon_cb);
	modport APB_D_MP (clocking apb_drv_cb);
	modport APB_M_MP (clocking apb_mon_cb);
	
endinterface

