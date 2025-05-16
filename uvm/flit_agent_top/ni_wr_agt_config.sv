class ni_wr_agt_config extends uvm_object;
	`uvm_object_utils(ni_wr_agt_config);

	uvm_active_passive_enum is_active=UVM_ACTIVE;

	virtual ni_if vif;

	static int drv_sent_cnt;
	static int mon_rcvd_cnt;

	function new(string name="ni_wr_agt_config");
		super.new(name);
	endfunction: new

endclass: ni_wr_agt_config

