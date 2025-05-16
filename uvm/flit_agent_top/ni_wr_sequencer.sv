class ni_wr_sequencer extends uvm_sequencer #(write_xtn);
	`uvm_component_utils(ni_wr_sequencer);

	function new(string name="ni_wr_sequencer", uvm_component parent);
		super.new(name,parent);
	endfunction
endclass

