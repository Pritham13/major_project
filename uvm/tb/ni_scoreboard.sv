class ni_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(ni_scoreboard)

	uvm_tlm_analysis_fifo #(write_xtn) wr_mon_fifo;
	uvm_tlm_analysis_fifo #(read_xtn) rd_mon_fifo;

	write_xtn wr_m_pkt;
	write_xtn cov_wr_pkt;
	read_xtn rd_m_pkt;
	read_xtn cov_rd_pkt;

	int wr_mon_pkt_ni=0;
	int rd_mon_pkt_ni=0;
	
	// covergroup ni_wr_cov;
	// 	RST_CV : coverpoint  cov_wr_pkt.rst{ 
	// 										bins b_rst={1};
	// 									   }
	// 	LOAD_DV : coverpoint 									   
	// endgroup
	function new(string name="ni_scoreboard", uvm_component parent);
		super.new(name,parent);
		wr_mon_fifo=new("wr_mon_fifo",this);
		rd_mon_fifo=new("rd_mon_fifo",this);
		// ni_wr_cov=new();
	endfunction

	task run_phase(uvm_phase phase);
		forever begin
			wr_mon_fifo.get(wr_m_pkt);
			wr_mon_pkt_ni++;
			// `uvm_info(get_type_name(),$sformatf("sb got wr pkt: \n %s",wr_m_pkt.sprint()),UVM_MEDIUM)

			rd_mon_fifo.get(rd_m_pkt);
			rd_mon_pkt_ni++;
			`uvm_info(get_type_name(),$sformatf("sb got rd pkt: \n %s",rd_m_pkt.sprint()),UVM_MEDIUM)
		end
	endtask

	function void report_phase(uvm_phase phase);
		`uvm_info(get_type_name(),$sformatf("number of items driven=%0d",wr_mon_pkt_ni),UVM_LOW)
	endfunction
endclass

