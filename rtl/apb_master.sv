import fsm_pkg::*;
import ni_pkg::*;
import apb_pkg::*;
module apb_manager (
    input                PCLK,
    input                PRESETn,
    input  apb_resp_s    in_apb_sigs,
    // transaction packet
    output apb_req_s     op_apb_sigs,
    // inputs from fifo 
    input  req_packet_s  in_trans_pkt,   // Data input from FIFO (request packet structure)
    input                fifo_full,      // FIFO full indicator
    input                fifo_empty,     // FIFO empty indicator
    // outputs to fifo 
    output resp_packet_s out_trans_pkt,  // Data output to FIFO (response packet structure)
    output logic         fifo_rreq,      // FIFO read request
    output logic         fifo_wreq       // FIFO write request
);

  apb_master_states_req_e p_state, n_state;
  apb_resp_s apb_resp_buff;

  read_write_apb_enum rw_sig_ip_pkt;

  logic rcv_done;
  logic resp_done;

  assign rw_sig_ip_pkt = in_trans_pkt.body_flit[0].data_bits[0] ? APB_WRITE : APB_READ;

  //assign op_apb_sigs.PWDATA = (op_apb_sigs.PWRITE & op_apb_sigs.PSELx) ? i_write_data : 'd0;

  always @(posedge PCLK) begin
    if (!PRESETn) begin
      p_state <= IDLE_ST;
    end else begin
      p_state <= n_state;
    end
  end

  always_comb begin
    n_state = p_state;
    case (p_state)
      IDLE_ST: n_state = (!fifo_empty) ? FIFO_RREQ_ST : IDLE_ST;

      FIFO_RREQ_ST: n_state = SETUP_ST;

      SETUP_ST: n_state = ACCESS_ST;

      ACCESS_ST: begin
        if (!in_apb_sigs.PREADY) begin
          n_state = ACCESS_ST;
        end else begin
          if ((in_apb_sigs.PREADY & in_apb_sigs.PSLVERR) == 0) begin
            n_state = DONE_ST;
          end else begin
            n_state = IDLE_ST;
          end
        end
      end

      DONE_ST: begin
        n_state = (resp_done) ? IDLE_ST : DONE_ST;
      end

      default: n_state = IDLE_ST;
    endcase
  end

  always_comb begin
    if (!PRESETn) begin
      fifo_rreq = 0;
      op_apb_sigs.PADDR = 8'd0;
      op_apb_sigs.PSELx = 0;
      op_apb_sigs.PWRITE = rw_sig_ip_pkt;
      op_apb_sigs.PENABLE = 0;
      op_apb_sigs.PWDATA = 0;
      rcv_done = 0;
    end else begin
      case (p_state)
        IDLE_ST: begin
          fifo_rreq             = 0;
          apb_resp_buff.PRDATA  = apb_resp_buff.PRDATA;
          apb_resp_buff.PSLVERR = apb_resp_buff.PSLVERR;
          op_apb_sigs.PADDR     = op_apb_sigs.PADDR;  // Hold current value
          op_apb_sigs.PSELx     = op_apb_sigs.PSELx;
          op_apb_sigs.PWRITE    = op_apb_sigs.PWRITE;
          op_apb_sigs.PENABLE   = 0;
          op_apb_sigs.PWDATA    = 0;
          rcv_done              = 0;
        end

        FIFO_RREQ_ST: begin
          fifo_rreq             = 1;
          apb_resp_buff.PRDATA  = apb_resp_buff.PRDATA;
          apb_resp_buff.PSLVERR = apb_resp_buff.PSLVERR;
          op_apb_sigs.PADDR     = op_apb_sigs.PADDR;  // Hold current value
          op_apb_sigs.PSELx     = op_apb_sigs.PSELx;
          op_apb_sigs.PWRITE    = op_apb_sigs.PWRITE;
          op_apb_sigs.PENABLE   = 0;
          op_apb_sigs.PWDATA    = 0;
          rcv_done              = 0;

        end

        SETUP_ST: begin
          fifo_rreq             = 0;
          apb_resp_buff.PRDATA  = apb_resp_buff.PRDATA;
          apb_resp_buff.PSLVERR = apb_resp_buff.PSLVERR;
          op_apb_sigs.PADDR     = in_trans_pkt.body_flit[0].data_bits[14:1];
          op_apb_sigs.PSELx     = 1;
          op_apb_sigs.PWRITE    = op_apb_sigs.PWRITE;
          op_apb_sigs.PENABLE   = 0;
          op_apb_sigs.PWDATA    = 0;  // TODO: to be cross checked with spec
          rcv_done              = 0;
        end

        ACCESS_ST: begin
          fifo_rreq = 0;
          op_apb_sigs.PADDR = op_apb_sigs.PADDR;  // Hold previous address
          apb_resp_buff.PRDATA = in_apb_sigs.PRDATA;
          apb_resp_buff.PSLVERR = in_apb_sigs.PSLVERR;
          op_apb_sigs.PSELx = 1;
          op_apb_sigs.PWRITE = op_apb_sigs.PWRITE;
          op_apb_sigs.PENABLE = 1;
          op_apb_sigs.PWDATA = get_data(in_trans_pkt);  // TODO: to be cross checked with spec
          rcv_done = 0;
        end

        DONE_ST: begin
          fifo_rreq             = 0;
          apb_resp_buff.PRDATA  = apb_resp_buff.PRDATA;
          apb_resp_buff.PSLVERR = apb_resp_buff.PSLVERR;
          op_apb_sigs.PADDR     = op_apb_sigs.PADDR;
          op_apb_sigs.PSELx     = 0;
          op_apb_sigs.PWRITE    = op_apb_sigs.PWRITE;
          op_apb_sigs.PENABLE   = 0;
          rcv_done              = 1;
        end

        default: begin
          fifo_rreq           = 0;
          op_apb_sigs.PADDR   = 'd0;
          op_apb_sigs.PSELx   = 0;
          op_apb_sigs.PWRITE  = APB_READ;
          op_apb_sigs.PENABLE = 0;
          rcv_done            = 1;
        end
      endcase
    end
  end
  apb_master_states_resp_e curr_resp_st, next_resp_st;

  always_ff @(PCLK, PRESETn) begin
    curr_resp_st <= next_resp_st;
  end

  always_comb begin
    case (curr_resp_st)
      FIFO_WR_INIT_ST: begin
        next_resp_st = (rcv_done) ? FIFO_CHK_FULL : FIFO_WR_INIT_ST;
      end
      FIFO_CHK_FULL: begin
        next_resp_st = (!fifo_full) ? FIFO_PUSH_ST : FIFO_CHK_FULL;
      end
      FIFO_PUSH_ST: begin
        next_resp_st = FIFO_WR_INIT_ST;
      end
    endcase

    case (curr_resp_st)
      FIFO_WR_INIT_ST: begin
        resp_done = 0;
        fifo_wreq = 0;
        out_trans_pkt = 'd0;
      end
      FIFO_CHK_FULL: begin
        resp_done = 0;
        fifo_wreq = 0;
        out_trans_pkt = 'd0;
      end

      FIFO_PUSH_ST: begin
        resp_done = 1;
        fifo_wreq = 1;
        {out_trans_pkt.body_flit[0],
          out_trans_pkt.body_flit[1],
          out_trans_pkt.body_flit[2].data_bits[14:13]
          } =  apb_resp_buff.PRDATA;
        out_trans_pkt.body_flit[2].data_bits[12] = apb_resp_buff.PSLVERR;
      end
    endcase
  end
endmodule
