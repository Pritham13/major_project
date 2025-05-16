class ni_base_test extends uvm_test;

	`uvm_component_utils(ni_base_test)

	ni_env envh;
	ni_env_config m_cfg;

	function new(string name="ni_base_test",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void config_ni();
		if(m_cfg.has_rd_agent) begin
			if(!uvm_config_db #(virtual ni_if)::get(this,"","vif",m_cfg.rd_m_cfg.vif))
				`uvm_fatal(get_type_name(),"couldnt get vif for read")
		end

		if(m_cfg.has_wr_agent) begin
			if(!uvm_config_db #(virtual ni_if)::get(this,"","vif",m_cfg.wr_m_cfg.vif))
				`uvm_fatal(get_type_name(),"couldnt get vif for read")
		end

		m_cfg.has_vsequencer=1;
		uvm_config_db #(ni_env_config)::set(this,"*","ni_env_config",m_cfg);
	endfunction

	function void build_phase(uvm_phase phase);
		m_cfg=ni_env_config::type_id::create("m_cfg");

		config_ni();

		super.build_phase(phase);

		envh=ni_env::type_id::create("envh",this);
	endfunction

endclass

// class wr_rst_test extends ni_base_test;
// 	`uvm_component_utils(wr_rst_test);
// 	
// 	wr_rst_seq rst_seqh;
//
// 	function new(string name="wr_rst_test",uvm_component parent);
// 		super.new(name,parent);
// 	endfunction
//
// 	function void build_phase(uvm_phase phase);
// 		super.build_phase(phase);
// 	endfunction
//
// 	task run_phase(uvm_phase phase);
// 		phase.raise_objection(this);
// 		rst_seqh=wr_rst_seq::type_id::create("rst_seqh");
// 		rst_seqh.start(envh.agth.seqrh);
// 		phase.drop_objection(this);
// 	endtask
// endclass

