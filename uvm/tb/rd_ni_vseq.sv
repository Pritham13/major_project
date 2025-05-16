class rd_ni_vseq extends ni_virtual_seqs;
	`uvm_object_utils(rd_ni_vseq);
	
	// wr_rst_seq rst_seqh;
	wr_ni_seq ni_seqh;
	rd_read_en_seq read_seqh;

	function new(string name="rd_ni_vseq");
		super.new(name);
	endfunction


	task body();
		super.body();
		// phase.raise_objection(this);
		ni_seqh=wr_ni_seq::type_id::create("ni_seqh");
		read_seqh=rd_read_en_seq::type_id::create("read_seqh");
		fork
			ni_seqh.start(this.wr_seqrh);
			read_seqh.start(this.rd_seqrh);
		join
		// phase.drop_objection(this);
	endtask
endclass

