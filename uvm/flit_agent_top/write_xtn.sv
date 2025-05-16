class write_xtn extends uvm_sequence_item;

	rand bit [`DATA_WIDTH-1:0] i_flit;
	rand bit [14:0] addr;
	rand bit resetn;
	rand bit enable;

	`uvm_object_utils_begin(write_xtn)
		`uvm_field_int(i_flit,UVM_ALL_ON)
		`uvm_field_int(addr,UVM_ALL_ON)
		`uvm_field_int(resetn,UVM_ALL_ON)
		`uvm_field_int(enable,UVM_ALL_ON)
	`uvm_object_utils_end
	
	constraint write_op{resetn dist {1'b1:=10, 1'b0:=90};
						enable dist {1'b1:=50, 1'b0:=50};
						addr inside {[0:255]};
						i_flit inside {[0:511]};}

	function new(string name="write_xtn");
		super.new(name);
	endfunction

	function void post_randomize();
		if(enable==1'b1)
			`uvm_info(get_type_name(),$sformatf("addr=%0h, i_flit=%0h",addr,i_flit),UVM_INFO)
	endfunction
endclass

