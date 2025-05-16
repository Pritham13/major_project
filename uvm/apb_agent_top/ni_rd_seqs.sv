class ni_rd_base_seq extends uvm_sequence #(read_xtn);
	`uvm_object_utils(ni_rd_base_seq)

	function new(string name="ni_rd_base_seq");
		super.new(name);
	endfunction

endclass: ni_rd_base_seq

class rd_read_en_seq extends ni_rd_base_seq;
	`uvm_object_utils(rd_read_en_seq);

	function new(string name="rd_read_en_seq");
		super.new(name);
	endfunction

	task body();
		repeat(10) begin
			req=read_xtn::type_id::create("req");
			start_item(req);
			assert(req.randomize() with {read_en==1;});
			finish_item(req);
		end
	endtask
endclass

