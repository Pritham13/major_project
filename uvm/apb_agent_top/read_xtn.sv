class read_xtn extends uvm_sequence_item;

	rand bit read_en;
	rand bit [`DATA_WIDTH-1:0]data_out;

	`uvm_object_utils_begin(read_xtn)
		`uvm_field_int(read_en,UVM_ALL_ON)
		`uvm_field_int(data_out,UVM_ALL_ON)
	`uvm_object_utils_end
	
	constraint READ_EN_OP{read_en dist {1'b1:=50, 1'b0:=50};}
						

	function new(string name="read_xtn");
		super.new(name);
	endfunction

	// function void post_randomize();
	// 	if(load==1'b1)
	// 		`uvm_info(get_type_name(),$sformatf("loading data=%0d",data_in),UVM_INFO)
	// endfunction
endclass

