class ni_wr_drv extends uvm_driver #(write_xtn);
	`uvm_component_utils(ni_wr_drv)

	virtual ni_if.FL_D_MP flit_vif;
	virtual ni_if.APB_D_MP flit_vif;

	ni_wr_agt_config m_cfg;

	function new(string name="ni_wr_drv",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db #(ni_wr_agt_config)::get(this,"","ni_wr_agt_config",m_cfg))
			`uvm_fatal(get_type_name(),"couldnt get write agent config")
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		this.flit_vif=m_cfg.flit_vif;
	endfunction

	task run_phase(uvm_phase phase);
		forever begin
			seq_item_port.get_next_item(req);
			send_to_dut(req);
			seq_item_port.item_done();
		end
	endtask

	task send_to_dut(write_xtn xtn);

		// `uvm_info(get_type_name,$sformatf("printing in driver: \n %s",xtn.sprint()),UVM_LOW)
		req_packet_s in_trans;

		  in_trans.head_flit = '{
			  number_of_flits: 3'b000,
			  flag_bits: 2'b00,
			  mode_bits: 3'b000,
			  destination_addr: 4'h0,
			  source_addr: 4'h0
		  };

		  in_trans.body_flit[0].flit_identifier = 'd0;
		  in_trans.body_flit[0].data_bits = xtn.addr;
		  // Initialize body flits
		  for (int i = 1; i < ni_pkg::NUM_BODY_FLITS; i++) begin
			in_trans.body_flit[i] = '{data_bits: 15'h0000 + i * xtn.i_flit[15:1], flit_identifier: 1'b0};
		  end
		  /* apb_resp_signals.PREADY = 'd1; */

		  // Initialize tail flit
		  in_trans.tail_flit = '{
			  data_bits: 15'h0000,
			  flit_identifier: 1'b1  // Typically tail flit has identifier set to 1
		  };

		repeat(2);
			@(flit_vif.flit_drv_cb);
		
		// asserting reset
		flit_vif.flit_drv_cb.resetn <= xtn.resetn;

      flit_vif.flit_drv_cb.enable <= xtn.enable;

      // Send each flit one by one on consecutive clock cycles
      for (int i = 0; i < TOTAL_FLITS; i++) begin
        @(posedge clk);
        if (i == 0) begin
          flit_vif.flit_drv_cb.i_flit <= input_trans.head_flit;  // Output the head flit
          $display("Time=%0t: Sending HEADER flit[%0d] = 0x%04h with enable=1", $time, i,
                   input_trans.head_flit);
        end else if (i == TOTAL_FLITS - 1) begin
          flit_vif.flit_drv_cb.i_flit <= input_trans.tail_flit;  // Output the tail flit
          $display("Time=%0t: Sending TAIL flit[%0d] = 0x%04h with enable=1", $time, i,
                   input_trans.tail_flit);
        end else begin
          flit_vif.flit_drv_cb.i_flit <= input_trans.body_flit[i-1];  // Output body flits
          $display("Time=%0t: Sending BODY flit[%0d] = 0x%04h with enable=1", $time, i,
                   input_trans.body_flit[i-1]);
        end
      end

      flit_vif.flit_drv_cb.enable <= 1'b0;

      $display("Time=%0t: Completed sending %0d flits", $time, TOTAL_FLITS);

		repeat(2);
			@(flit_vif.flit_drv_cb);

		flit_vif.flit_drv_cb.i_flit <= 16'd0;

		  // de-assert body flits
		  /* for (int i = 0; i < ni_pkg::NUM_BODY_FLITS; i++) begin */
			/* in_trans.body_flit[i] = '{data_bits: 15'h0000, flit_identifier: 1'b0}; */
		  /* end */

		/* flit_vif.wr_drv_cb.rst <= xtn.rst; */
		/* flit_vif.wr_drv_cb.load <= xtn.load; */
		/* flit_vif.wr_drv_cb.count_en <= xtn.count_en; */
		/* flit_vif.wr_drv_cb.data_in <= xtn.data_in; */

		// @(flit_vif.wr_drv_cb);

		// repeat(2);
			// @(flit_vif.wr_drv_cb);

		// flit_vif.wr_drv_cb.rst <= 'd0;
		// flit_vif.wr_drv_cb.load <= 'd0;
		// // flit_vif.wr_drv_cb.count_en <= 'd0;
		// flit_vif.wr_drv_cb.data_in <= 'd0;

		
		m_cfg.drv_sent_cnt++;
	endtask

	function void report_phase(uvm_phase phase);
		`uvm_info(get_type_name(),$sformatf("number of items driven=%0d",m_cfg.drv_sent_cnt),UVM_LOW)
	endfunction

endclass

