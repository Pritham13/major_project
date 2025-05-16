module top();

import fsm_pkg::*;
import ni_pkg::*;
import apb_pkg::*;
import ni_test_pkg::*;

import uvm_pkg::*;

`include "uvm_macros.svh"

bit clk=1;

always #5 clk=~clk;

ni_if in(clk);

counter DUT(
	 .clk(in.clk),
	 .rst(in.rst),
	 .load(in.load), 
	 .read_en(in.read_en),
	 .count_en(in.count_en),
	 .data_in(in.data_in),
	 .data_out(in.data_out)
);

initial begin
	`ifdef VCS
		$fsdbDumpvars(0,top);
	`endif

	uvm_config_db #(virtual ni_if)::set(null,"*","vif",in);
	run_test();
end
endmodule

