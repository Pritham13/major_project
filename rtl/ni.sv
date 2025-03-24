import fsm_pkg::*;  // Package containing FSM state definitions
import ni_pkg::*;  // Package containing Network Interface definitions

module ni (
    input               clk,     // Clock signal
    input               resetn,  // Active-low reset signal
    // inputs from NoC (Network on Chip)
    input        [15:0] i_flit,  // Input flit (data packet) from NoC
    input               enable,  // Enable signal for data sampling
    // outputs to NoC
    output logic [15:0] o_flit,  // Output flit to NoC
    output logic        ready,   // Ready signal indicating sampler is ready to receive

    // inputs from fifo 
    input req_packet_s fifo_din,   // Data input from FIFO (request packet structure)
    input              fifo_full,  // FIFO full indicator
    input              fifo_empty, // FIFO empty indicator

    // outputs to fifo 
    output resp_packet_s fifo_dout,  // Data output to FIFO (response packet structure)
    output logic         fifo_rreq,  // FIFO read request
    output logic         fifo_wreq   // FIFO write request
);

  // State variables for request and response state machines
  req_states_e req_curr_state, req_next_state;  // Request state machine current and next states
  logic [REMAINING_BEATS_LENGTH_REQ-1:0] remaining_beats_req;  // Counter for remaining data beats in request
  logic [REMAINING_BEATS_LENGTH_REQ-1:0] remaining_beats_resp; // Counter for remaining data beats in response
  req_packet_s req_buffer;  // Buffer to store incoming request packet
  resp_packet_s resp_buffer;  // Buffer to store outgoing response packet

  // Flag indicating when a transfer is complete
  logic trans_done;

  //////////////// REQUEST STATE MACHINE ////////////
  // Sequential logic for request state transitions
  always_ff @(posedge clk, negedge resetn) begin
    if (!resetn) begin
      // Reset to initial state when resetn is asserted (active low)
      req_curr_state <= INITIAL_REQ_ST;
    end else req_curr_state <= req_next_state;
  end

  // Combinational logic for request next state determination
  always_comb begin
    case (req_curr_state)
      INITIAL_REQ_ST: begin
        if (enable) begin
          // When enabled, start sampling data
          req_next_state = SAMPLE_DATA_REQ_ST;
        end else begin
          // Stay in initial state until enabled
          req_next_state = INITIAL_REQ_ST;
        end
      end
      SAMPLE_DATA_REQ_ST: begin
        if (remaining_beats_req > 0) begin
          // Continue sampling until all data beats are collected
          req_next_state = SAMPLE_DATA_REQ_ST;
        end else begin
          // When all data is collected, proceed to write to FIFO
          req_next_state = WRT_REQ_ST;
        end
      end

      WRT_REQ_ST: begin
        if (!fifo_full) req_next_state = WAIT_REQ_ST;  // If FIFO has space, go to wait state
        else req_next_state = WRT_REQ_ST;  // If FIFO is full, keep trying
      end
      WAIT_REQ_ST: begin
        req_next_state = (trans_done) ? INITIAL_REQ_ST : WAIT_REQ_ST; // Wait until transaction is done
      end
    endcase
  end

  // Combinational logic for request state machine outputs
  always_comb begin
    case (req_curr_state)
      INITIAL_REQ_ST: begin
        ready                = 1;  // Ready to receive data
        fifo_wreq            = 0;  // No FIFO write request
        remaining_beats_req  = TOTAL_FLITS - 2;  // Initialize counter for data beats
        req_buffer.head_flit = i_flit;  // Store the header flit
      end

      SAMPLE_DATA_REQ_ST: begin
        ready     = 0;  // Not ready to receive more data while sampling
        fifo_wreq = 0;  // No FIFO write request yet

        if (remaining_beats_req == 0) begin
          req_buffer.tail_flit = i_flit;  // Store the tail flit
        end else begin
          req_buffer.body_flit[remaining_beats_req-1] = i_flit;  // Store body flits
        end
        remaining_beats_req = remaining_beats_req - 1;  // Decrement counter
      end

      WRT_REQ_ST: begin
        ready     = 0;  // Not ready during write operation
        fifo_wreq = 1;  // Assert FIFO write request
        fifo_dout = req_buffer;  // Output the request buffer to FIFO
      end

    endcase
  end

  //////////////// RESPONSE STATE MACHINE ////////////
  resp_states_e resp_curr_state, resp_next_state;  // Response state machine current and next states

  // Sequential logic for response state transitions
  always_ff @(posedge clk, negedge resetn) begin
    if (!resetn) begin
      // Reset to initial state when resetn is asserted (active low)
      resp_curr_state <= INITIAL_RESP_ST;
    end else begin
      resp_curr_state <= resp_next_state;
    end
  end

  // Combinational logic for response next state determination
  always_comb begin
    case (resp_curr_state)
      INITIAL_RESP_ST: begin
        // If FIFO has data, start reading process, otherwise stay in initial state
        resp_next_state = (!fifo_empty) ? FIFO_RREQ_RESP_ST : INITIAL_RESP_ST;
      end

      FIFO_RREQ_RESP_ST: begin
        // After issuing read request, move to sample data state
        resp_next_state = FIFO_SAMPLE_DATA_ST;
      end

      FIFO_SAMPLE_DATA_ST: begin
        // After sampling data, move to drive output state
        resp_next_state = DRIVE_FLIT_OUT_ST;
      end

      DRIVE_FLIT_OUT_ST: begin
        // Continue driving flits until all are sent, then return to initial state
        resp_next_state = (remaining_beats_resp > 0) ? DRIVE_FLIT_OUT_ST : INITIAL_RESP_ST;
      end
    endcase
  end

  // Combinational logic for response state machine outputs
  always_comb begin
    case (resp_next_state)
      INITIAL_RESP_ST: begin
        trans_done           = 0;  // Reset transaction done flag
        remaining_beats_resp = TOTAL_FLITS - 1;  // Initialize counter for response flits
        fifo_rreq            = 0;  // No FIFO read request
      end

      FIFO_RREQ_RESP_ST: begin
        trans_done           = 0;  // Transaction not done yet
        remaining_beats_resp = TOTAL_FLITS - 1;  // Initialize counter for response flits
        fifo_rreq            = 1;  // Assert FIFO read request
      end

      FIFO_SAMPLE_DATA_ST: begin
        trans_done           = 0;  // Transaction not done yet
        remaining_beats_resp = TOTAL_FLITS - 1;  // Initialize counter for response flits
        fifo_rreq            = 0;  // De-assert FIFO read request
      end

      DRIVE_FLIT_OUT_ST: begin
        fifo_rreq = 0;  // No FIFO read request during output
        if (remaining_beats_resp == TOTAL_FLITS - 1) begin
          o_flit = resp_buffer.head_flit;  // Output the head flit
        end else if (remaining_beats_resp == 0) begin 
          o_flit = resp_buffer.tail_flit;  // Output the tail flit
        end else begin
          o_flit = resp_buffer.body_flit[remaining_beats_resp-1];  // Output body flits
        end
        remaining_beats_resp = remaining_beats_resp - 1;  // Decrement counter
      end

    endcase
  end
endmodule

