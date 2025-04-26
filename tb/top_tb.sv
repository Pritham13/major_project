/**
 * Module: top_tb
 * This testbench verifies the functionality of the Network Interface (NI) to APB bridge.
 * It simulates both the NoC and APB interfaces to validate data transmission and protocol conversion.
 */
import fsm_pkg::*;
import ni_pkg::*;
import apb_pkg::*;

module top_tb;
  /** Clock signal for system timing */
  logic clk;
  /** Active-low reset signal */
  logic resetn;

  // NI/NoC Interface signals
  /** Input flit data from NoC */
  logic [15:0] i_flit;
  /** Enable signal for data reception */
  logic enable;
  /** Output flit data to NoC */
  logic [15:0] o_flit;
  /** Ready signal indicating NoC can accept data */
  logic ready;
  /** Valid signal indicating output data is valid */
  logic valid_out;

  // APB interface signals
  /** APB response signals bundle */
  apb_resp_s apb_resp_signals;
  /** APB request signals bundle */
  apb_req_s apb_req_signals;

  /**
   * Clock Generation
   * Generates a 100MHz clock (10ns period)
   */
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  /**
   * Reset Generation
   * Generates an active-low reset pulse
   */
  initial begin
    resetn = 0;  // Assert reset (active low)
    #10 resetn = 1;  // De-assert reset after 20ns
  end

  /**
   * VCD Dump Configuration
   * Sets up waveform dumping for simulation analysis
   */
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end

  /**
   * DUT Instantiation
   * Instantiates the top-level design under test with all interface connections
   */
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

  /**
   * Task: send_flits_on_clock
   * Sends a complete packet of flits synchronized to clock edges
   * 
   * Parameters:
   * - input_trans : Input transaction packet to be transmitted
   * 
   * The task handles:
   * 1. Header flit transmission
   * 2. Body flits transmission
   * 3. Tail flit transmission
   * All transmissions are synchronized to clock edges and include debug messages
   */
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

  // Test case includes
  `include "test1.sv"
  `include "test2.sv"

  /**
   * Test Execution
   * Initiates the test sequence
   */
  initial begin
    test1();
  end

endmodule
