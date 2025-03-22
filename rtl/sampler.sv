import fsm_pkg::*;
import ni_pkg::*;

module sampler (
    input          clk,
    input          resetn,
    // inputs from NoC
    input [15:0]   i_flit,
    input          enable,

    // outputs to NoC
    output [15:0]   o_flit,
    output logic    ready,

    // inputs from fifo 
    input req_packet_s fifo_din,
    input          fifo_full,
    input          fifo_empty,

    // outputs to fifo 
    output resp_packet_s fifo_dout,
    output logic    fifo_rreq,
    output logic    fifo_wreq

);

  req_states_e req_curr_state, req_next_state;
  logic [REMAINING_BEATS_LENGTH_REQ-1:0] remaining_beats;
  req_packet_s req_buffer;

  // indicates transfer completed
  logic trans_done ;

  always_ff @(posedge clk, negedge resetn) begin
    if (!resetn) begin
      req_curr_state <= INITIAL_ST;
    end else req_curr_state <= req_next_state;
  end

  always_comb begin
    case (req_curr_state)
      INITIAL_ST: begin
        if (enable) begin
          req_next_state = SAMPLE_DATA_ST ;
        end
        else begin
          req_next_state = INITIAL_ST;
        end
      end
      SAMPLE_DATA_ST : begin
        if (remaining_beats > 0 ) begin
          req_next_state = SAMPLE_DATA_ST;
        end
        else begin
          req_next_state = WRT_REQ_ST ;
        end
      end

      WRT_REQ_ST : begin
        if (!fifo_full)
          req_next_state = WAIT_ST;
        else 
          req_next_state = WRT_REQ_ST;
      end
      WAIT_ST : begin
        req_next_state = (trans_done) ? INITIAL_ST : WAIT_ST ;
      end
    endcase
  end

  always_comb begin
    case (req_curr_state)
      INITIAL_ST : begin
        ready      = 1;
        trans_done = 0;
        fifo_wreq  = 0;
        remaining_beats = TOTAL_FLITS-1;
      end

      SAMPLE_DATA_ST : begin
        ready = 0;
        trans_done = 0;
        fifo_wreq  = 0;

        if (remaining_beats == (TOTAL_FLITS - 1)) begin
          req_buffer.head_flit = i_flit; 
        end
        else if (remaining_beats == 0) begin 
          req_buffer.tail_flit = i_flit;
        end
        else begin
          req_buffer.body_flit[remaining_beats] = 0;
        end
        remaining_beats = remaining_beats - 1;
      end

      WRT_REQ_ST : begin
        ready = 0;
        trans_done = 0;
        fifo_wreq  = 1;
        fifo_dout = req_buffer ;
      end

    endcase
  end

endmodule
