class ni_rd_mon extends uvm_monitor; 
	`uvm_component_utils(ni_rd_mon);

	virtual ni_if.R_M_MP vif;

	ni_rd_agt_config m_cfg;

	uvm_analysis_port #(read_xtn) monitor_port;

	function new(string name="ni_rd_mon",uvm_component parent);
		super.new(name,parent);
		monitor_port=new("monitor_port",this);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(ni_rd_agt_config)::get(this,"","ni_rd_agt_config",m_cfg))
			`uvm_fatal(get_type_name(),"couldnt get read agent config");
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		this.vif=m_cfg.vif;
	endfunction

	task run_phase(uvm_phase phase);
		forever begin
			collect_data();
		end
	endtask

	task collect_data();
		read_xtn data_recv;
		data_recv=read_xtn::type_id::create("data_recv");
		
		// @(vif.rd_mon_cb);
		@(vif.rd_mon_cb);
		
		data_recv.read_en=vif.rd_mon_cb.read_en;
		// data_recv.load=vif.rd_mon_cb.load;
		// data_recv.data_in=vif.rd_mon_cb.data_in;
		
		// repeat(2) 
			@(vif.rd_mon_cb);

		data_recv.data_out=vif.rd_mon_cb.data_out;
			
		`uvm_info(get_type_name(),$sformatf("printing in monitor: \n %s",data_recv.sprint()),UVM_LOW)

		monitor_port.write(data_recv);

		m_cfg.mon_rcvd_ni++;
	endtask

	function void report_phase(uvm_phase phase);
		`uvm_info(get_type_name(),$sformatf("number of items monitor recieved=%0d",m_cfg.mon_rcvd_ni),UVM_LOW)
	endfunction
endclass

