 	class ni_env extends uvm_env;
	`uvm_component_utils(ni_env)

	ni_env_config m_cfg;

	ni_wr_agent wr_agth;
	ni_rd_agent rd_agth;

	ni_virtual_sequencer vseqrh;

	ni_scoreboard sb_h;

	function new(string name, uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db #(ni_env_config)::get(this,"","ni_env_config",m_cfg))
			`uvm_fatal(get_type_name(),"couldnt get env config")

		if(m_cfg.has_wr_agent) begin
			uvm_config_db #(ni_wr_agt_config)::set(this,"*","ni_wr_agt_config",m_cfg.wr_m_cfg);
			wr_agth=ni_wr_agent::type_id::create("wr_agth",this);
		end

		if(m_cfg.has_rd_agent) begin
			uvm_config_db #(ni_rd_agt_config)::set(this,"*","ni_rd_agt_config",m_cfg.rd_m_cfg);
			rd_agth=ni_rd_agent::type_id::create("rd_agth",this);
		end

		if(m_cfg.has_vsequencer) 
			vseqrh=ni_virtual_sequencer::type_id::create("vseqrh",this);

		if(m_cfg.has_scoreboard)
			sb_h=ni_scoreboard::type_id::create("sb_h",this);

		super.build_phase(phase);
	endfunction

	function void connect_phase(uvm_phase phase);
		if(m_cfg.has_vsequencer)  begin
			if(m_cfg.has_wr_agent) begin
				vseqrh.wr_seqrh=wr_agth.seqrh;

				if(m_cfg.has_scoreboard)
					wr_agth.monh.monitor_port.connect(sb_h.wr_mon_fifo.analysis_export);
			end
			
			if(m_cfg.has_rd_agent) begin
				vseqrh.rd_seqrh=rd_agth.seqrh;

				if(m_cfg.has_scoreboard)
					rd_agth.monh.monitor_port.connect(sb_h.rd_mon_fifo.analysis_export);
			end
		end

		super.connect_phase(phase);

	endfunction
endclass

