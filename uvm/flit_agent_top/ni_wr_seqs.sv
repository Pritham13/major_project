class ni_wr_base_seq extends uvm_sequence #(write_xtn);
	`uvm_object_utils(ni_wr_base_seq)

	function new(string name="ni_wr_base_seq");
		super.new(name);
	endfunction

endclass: ni_wr_base_seq

class wr_rst_seq extends ni_wr_base_seq;
	`uvm_object_utils(wr_rst_seq)

	function new(string name="wr_rst_seq");
		super.new(name);
	endfunction

	task body();
		repeat(10) begin
			req=write_xtn::type_id::create("req");
			// seq.start(req);
			start_item(req);
			assert(req.randomize() with {rst dist {1'b1:=8, 1'b0:=2};});
				// `uvm_fatal(get_type_name(),"not randomized")
			// `uvm_info(get_type_name(),$sformatf("printing seq: \n %s",req.sprint()),UVM_INFO)
			finish_item(req);
		end
	endtask
endclass

class wr_load_seq extends ni_wr_base_seq;
	`uvm_object_utils(wr_load_seq)
	bit xtn_num=1;

	function new(string name="wr_load_seq");
		super.new(name);
	endfunction

	task body();
		repeat(10) begin
			req=write_xtn::type_id::create("req");
			start_item(req);
			if(xtn_num==1) begin
				assert(req.randomize() with {rst==1;});
				xtn_num++;
			end
			else
				// assert(req.randomize() with {load dist {1'b1:=8, 1'b0:=2};});
				assert(req.randomize() with {load==1; count_en==0; rst dist {1'b1:=5, 1'b0:=5};});
				// assert(req.randomize() with {load==1;});
			finish_item(req);
		end
	endtask
endclass

class wr_ni_seq extends ni_wr_base_seq;
	`uvm_object_utils(wr_ni_seq)
	bit xtn_num=1;

	function new(string name="wr_ni_seq");
		super.new(name);
	endfunction

	task body();
		repeat(10) begin
			req=write_xtn::type_id::create("req");
			start_item(req);
			if(xtn_num==1) begin
				assert(req.randomize() with {rst==1;});
				xtn_num++;
			end
			else
				assert(req.randomize() with {load==0;count_en==1;});
			finish_item(req);
		end
	endtask
endclass


