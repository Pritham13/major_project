class ni_wr_mon extends uvm_monitor; 
	`uvm_component_utils(ni_wr_mon);

	virtual ni_if.FL_M_MP vif;

	ni_wr_agt_config m_cfg;

	uvm_analysis_port #(write_xtn) monitor_port;

	function new(string name="ni_wr_mon",uvm_component parent);
		super.new(name,parent);
		monitor_port=new("monitor_port",this);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(ni_wr_agt_config)::get(this,"","ni_wr_agt_config",m_cfg))
			`uvm_fatal(get_type_name(),"couldnt get write agent config");
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		this.vif=m_cfg.vif;
	endfunction

	task run_phase(uvm_phase phase);
		@(vif.wr_mon_cb);
		forever begin
			collect_data();
		end
	endtask

	task collect_data();
		write_xtn data_recv;
		data_recv=write_xtn::type_id::create("data_recv");
		
		// sampling resetn at every clk edge
		// sampling i_flit only when enable is high

		@(vif.wr_mon_cb);
		#1;
		data_recv.rst=vif.wr_mon_cb.rst;
		data_recv.load=vif.wr_mon_cb.load;
		data_recv.data_in=vif.wr_mon_cb.data_in;
		data_recv.count_en=vif.wr_mon_cb.count_en;
		
		// `uvm_info(get_type_name(),$sformatf("printing in monitor: \n %s",data_recv.sprint()),UVM_LOW)

		monitor_port.write(data_recv);

		m_cfg.mon_rcvd_ni++;
	endtask

	function void report_phase(uvm_phase phase);
		`uvm_info(get_type_name(),$sformatf("number of items monitor recieved=%0d",m_cfg.mon_rcvd_ni),UVM_LOW)
	endfunction
endclass

