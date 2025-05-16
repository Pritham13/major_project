class wr_load_test extends ni_base_test;
	`uvm_component_utils(wr_load_test);
	
	// wr_rst_seq rst_seqh;
	wr_load_seq load_seqh;
	rd_read_en_seq read_seqh;

	function new(string name="wr_load_test",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction

	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		load_seqh=wr_load_seq::type_id::create("load_seqh");
		read_seqh=rd_read_en_seq::type_id::create("read_seqh");
		fork
			load_seqh.start(envh.wr_agth.seqrh);
			read_seqh.start(envh.rd_agth.seqrh);
		join
		phase.drop_objection(this);
	endtask
endclass

