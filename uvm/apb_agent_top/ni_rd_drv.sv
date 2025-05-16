class ni_rd_drv extends uvm_driver #(read_xtn);
	`uvm_component_utils(ni_rd_drv)

	virtual ni_if.R_D_MP vif;

	ni_rd_agt_config m_cfg;

	function new(string name="ni_rd_drv",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(ni_rd_agt_config)::get(this,"","ni_rd_agt_config",m_cfg))
			`uvm_fatal(get_type_name(),"couldnt get read agent config")
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		this.vif=m_cfg.vif;
	endfunction

	task run_phase(uvm_phase phase);
		forever begin
			seq_item_port.get_next_item(req);
			send_to_dut(req);
			seq_item_port.item_done();
		end
	endtask

	task send_to_dut(read_xtn xtn);
		// `uvm_info(get_type_name,$sformatf("printing in driver: \n %s",xtn.sprint()),UVM_LOW)

		repeat(2);
			@(vif.rd_drv_cb);

		vif.rd_drv_cb.read_en<= xtn.read_en;

		// repeat(2);
			@(vif.rd_drv_cb);
		// @(vif.rd_drv_cb);
        //
		vif.rd_drv_cb.read_en<= '0;

		
		m_cfg.drv_sent_ni++;
	endtask

	function void report_phase(uvm_phase phase);
		`uvm_info(get_type_name(),$sformatf("number of items driven=%0d",m_cfg.drv_sent_ni),UVM_LOW)
	endfunction

endclass

