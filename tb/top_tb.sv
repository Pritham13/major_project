import fsm_pkg::*;
import ni_pkg::*;
import apb_pkg::*;
module top_tb;
  // First, declare all necessary signals
  // Clock and reset
  logic clk;
  logic resetn;

  // NI/NoC Interface signals
  logic [15:0] i_flit;
  logic enable;
  logic [15:0] o_flit;
  logic ready;
  logic valid_out;

  // APB interface signals
  apb_resp_s apb_resp_signals;
  apb_req_s apb_req_signals;
  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;  // 10ns period (100MHz) clock
  end

  // Reset generation (negative edge reset)
  initial begin
    // resetn = 1;
     resetn = 0;  // Assert reset (active low)
    #10 resetn = 1;  // De-assert reset after 20ns
  end
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
  // Instantiate the top_module
  top top_inst (
      .clk             (clk),               // System clock
      .resetn          (resetn),            // Active-low reset
      // NI side (NoC interface)
      .i_flit          (i_flit),            // Input flit from NoC
      .enable          (enable),            // Enable signal for data reception
      .o_flit          (o_flit),            // Output flit to NoC
      .ready           (ready),             // Ready signal to NoC
      .valid_out       (valid_out),         // Ready signal to NoC
      // APB side
      .apb_resp_signals(apb_resp_signals),  // APB response signals structure
      .apb_req_signals (apb_req_signals)    // APB request signals structure
  );

  task automatic send_flits_on_clock(input req_packet_s input_trans);
    begin
      // Send each flit one by one on consecutive clock cycles
      enable = 1;
      for (int i = 0; i < TOTAL_FLITS; i++) begin
        @(posedge clk);
        if (i == 0) begin
          i_flit = input_trans.head_flit;  // Output the head flit
          $display("Time=%0t: Sending HEADER flit[%0d] = 0x%04h with enable=1", $time, i,
                   input_trans.head_flit);
        end else if (i == TOTAL_FLITS - 1) begin
          i_flit = input_trans.tail_flit;  // Output the tail flit
          $display("Time=%0t: Sending TAIL flit[%0d] = 0x%04h with enable=1", $time, i,
                   input_trans.tail_flit);
        end else begin
          i_flit = input_trans.body_flit[i-1];  // Output body flits
          $display("Time=%0t: Sending BODY flit[%0d] = 0x%04h with enable=1", $time, i,
                   input_trans.body_flit[i-1]);
        end
      end
      enable = 0;
      $display("Time=%0t: Completed sending %0d flits", $time, TOTAL_FLITS);
    end
  endtask

  `include "test1.sv"
  initial begin
    test1();
  end
endmodule
