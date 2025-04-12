import fsm_pkg::*;
import ni_pkg::*;
import apb_pkg::*;
module apb_manager (
    input                 PCLK,
    input                 PRESETn,
    input apb_resp_s      resp_pkt_ip,
    output logic [15:0]   o_read_data,
    // transaction packet
    output apb_req_s      req_pkt_op,
    // inputs from fifo 
    input req_packet_s    fifo_din,  // Data input from FIFO (request packet structure)
    input fifo_full,  // FIFO full indicator
    input fifo_empty,  // FIFO empty indicator
    // outputs to fifo 
    output resp_packet_s  fifo_dout,  // Data output to FIFO (response packet structure)
    output logic          fifo_rreq,  // FIFO read request
    output logic           fifo_wreq  // FIFO write request
);

  apb_master_states_e p_state, n_state;


  assign PWDATA = (PWRITE & PSELx) ? i_write_data : 'd0;

  always @(posedge PCLK) begin
    if (!PRESETn) begin
      p_state <= IDLE_ST;
    end else begin
      p_state <= n_state;
    end
  end

  always_comb  begin
    n_state = p_state;
    case (p_state)
      IDLE_ST:  n_state =(fifo_empty)? SETUP_ST : IDLE_ST;

      SETUP_ST: n_state = ACCESS_ST;

      ACCESS_ST: begin
        if (!PREADY) begin
          n_state = ACCESS_ST;
        end else begin
          if ((PREADY & PSLVERR) == 0) begin
            n_state = DONE_ST;
          end else begin
            n_state = IDLE_ST;
          end
        end
      end

      DONE_ST: begin
        n_state = IDLE_ST;
      end

      default: n_state = IDLE_ST;
    endcase
  end

  always_comb  begin
    if (!PRESETn) begin
      PADDR = 8'd0;
      PSELx = 0;
      PWRITE = 0;
      PENABLE = 0;
      o_read_data = 16'd0;
    end else begin
      case (p_state)
        IDLE_ST: begin
          PADDR = PADDR;
          PSELx = PSELx;
          PWRITE = PWRITE;
          PENABLE = 0;
          o_read_data = o_read_data;
        end

        SETUP_ST: begin
          PADDR   = i_addr;
          PSELx   = 1;
          PENABLE = 0;
          PWRITE  = i_read_write_sel;
        end

        ACCESS_ST: begin
          PSELx   = 1;
          PENABLE = 1;
          if ((PREADY && !PWRITE) == 1) begin
            o_read_data = PRDATA;
          end
        end

        DONE_ST: begin
          PENABLE = 0;
          PSELx   = 0;
        end

        default: o_read_data = 'd0;
      endcase
    end
  end

endmodule
