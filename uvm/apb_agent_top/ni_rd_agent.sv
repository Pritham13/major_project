class ni_rd_agent extends uvm_agent;
	`uvm_component_utils(ni_rd_agent)

	// declare handles for drv, mon, seqr
	ni_rd_drv drvh;
	ni_rd_mon monh;
	ni_rd_sequencer seqrh;
	
	ni_rd_agt_config m_cfg;

	function new(string name="ni_rd_agent",uvm_component parent=null);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(ni_rd_agt_config)::get(this,"","ni_rd_agt_config",m_cfg))
			`uvm_fatal(get_type_name(),"couldnt get agent config")

		monh=ni_rd_mon::type_id::create("monh",this);
		
		if(m_cfg.is_active==UVM_ACTIVE) begin
			drvh=ni_rd_drv::type_id::create("drvh",this);
			seqrh=ni_rd_sequencer::type_id::create("seqrh",this);
		end
	endfunction: build_phase

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		if(m_cfg.is_active==UVM_ACTIVE)	begin
			drvh.seq_item_port.connect(seqrh.seq_item_export);
		end
	endfunction: connect_phase
endclass

