class rd_ni_test extends ni_base_test;
	`uvm_component_utils(rd_ni_test);
	
	rd_ni_vseq ni_vseqh;
	rd_load_vseq load_vseqh;
	// wr_rst_seq rst_seqh;
	// wr_ni_seq ni_seqh;
	// rd_read_en_seq read_seqh;

	function new(string name="rd_ni_test",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction

	task run_phase(uvm_phase phase);
		phase.raise_objection(this);

		ni_vseqh=rd_ni_vseq::type_id::create("ni_vseqh");
		ni_vseqh.start(envh.vseqrh);
		
		load_vseqh=rd_load_vseq::type_id::create("load_vseqh");
		load_vseqh.start(envh.vseqrh);

		phase.drop_objection(this);
	endtask
endclass

