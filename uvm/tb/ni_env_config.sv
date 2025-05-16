class ni_env_config extends uvm_object;
	`uvm_object_utils(ni_env_config)

	bit has_wr_agent=1;
	bit has_rd_agent=1;
	bit has_vsequencer=1;
	bit has_scoreboard=1;

	ni_rd_agt_config rd_m_cfg;
	ni_wr_agt_config wr_m_cfg;

	function new(string name="ni_env_config");
		super.new(name);
		rd_m_cfg=ni_rd_agt_config::type_id::create("rd_m_cfg");
		wr_m_cfg=ni_wr_agt_config::type_id::create("wr_m_cfg");
	endfunction
endclass

