class ni_virtual_sequencer extends uvm_sequencer #(uvm_sequence_item);
	`uvm_component_utils(ni_virtual_sequencer)

	ni_wr_sequencer wr_seqrh;
	ni_rd_sequencer rd_seqrh;

	function new(string name="ni_virtual_sequencer", uvm_component parent);
		super.new(name,parent);
	endfunction
endclass

