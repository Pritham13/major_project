class ni_virtual_seqs extends uvm_sequence #(uvm_sequence_item);
	`uvm_object_utils(ni_virtual_seqs);

	ni_virtual_sequencer vseqrh;

	ni_wr_sequencer wr_seqrh;
	ni_rd_sequencer rd_seqrh;

	function new(string name="ni_virtual_seqs");
		super.new(name);
	endfunction

	task body();
		assert($cast(vseqrh,m_sequencer));

		this.wr_seqrh=vseqrh.wr_seqrh;
		this.rd_seqrh=vseqrh.rd_seqrh;
	endtask
endclass

