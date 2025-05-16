class rd_load_vseq extends ni_virtual_seqs;
	`uvm_object_utils(rd_load_vseq)

	wr_load_seq load_seqh;
	rd_read_en_seq read_seqh;

	function new(string name="rd_load_vseq");
		super.new(name);
	endfunction

	task body();
		super.body();
		load_seqh=wr_load_seq::type_id::create("load_seqh");
		read_seqh=rd_read_en_seq::type_id::create("read_seqh");

		fork
			load_seqh.start(this.wr_seqrh);
			read_seqh.start(this.rd_seqrh);
		join
	endtask
endclass

