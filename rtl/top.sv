import fsm_pkg::*;
import ni_pkg::*;
import apb_pkg::*;
module top_module (
    input                    clk,
    input                    resetn,
    // NI side (NoC interface)
    input             [15:0] i_flit,
    input                    enable,
    output            [15:0] o_flit,
    output                   ready,
    // APB side
    input  apb_resp_s        apb_resp_signals,
    output apb_req_s         apb_req_signals
);

  // Intermediate signals for request FIFO (NI -> APB Manager)
  logic         req_fifo_full;
  logic         req_fifo_empty;
  logic         ni_req_fifo_wreq;  // NI write request to req FIFO
  logic         apb_req_fifo_rreq;  // APB read request from req FIFO
  req_packet_s  ni_req_fifo_din;  // Data from NI to req FIFO
  req_packet_s  req_fifo_dout;  // Data from req FIFO to APB

  // Intermediate signals for response FIFO (APB Manager -> NI)
  logic         resp_fifo_full;
  logic         resp_fifo_empty;
  logic         apb_resp_fifo_wreq;  // APB write request to resp FIFO
  logic         ni_resp_fifo_rreq;  // NI read request from resp FIFO
  resp_packet_s apb_resp_fifo_din;  // Data from APB to resp FIFO
  resp_packet_s resp_fifo_dout;  // Data from resp FIFO to NI

  // Instantiate the NI module with corrected interface
  ni ni_inst (
      .clk(clk),
      .resetn(resetn),
      // NoC interface
      .i_flit(i_flit),
      .enable(enable),
      .o_flit(o_flit),
      .ready(ready),

      // FIFO interfaces - UPDATED based on new NI module definition
      .fifo_din(resp_fifo_dout),  // Response data from resp FIFO to NI
      .fifo_full(req_fifo_full),  // Request FIFO full flag
      .fifo_empty(resp_fifo_empty),  // Response FIFO empty flag
      .fifo_dout(ni_req_fifo_din),  // Request data from NI to req FIFO
      .fifo_rreq(ni_resp_fifo_rreq),  // NI read request to resp FIFO
      .fifo_wreq(ni_req_fifo_wreq)  // NI write request to req FIFO
  );

  // Instantiate the Request FIFO (NI -> APB Manager)
  sync_fifo #(
      .DEPTH(8),
      .DTYPE(req_packet_s)
  ) req_fifo (
      .rstn     (resetn),
      .clk      (clk),
      .fifo_wreq(ni_req_fifo_wreq),   // Write request from NI
      .fifo_rreq(apb_req_fifo_rreq),  // Read request from APB manager
      .din      (ni_req_fifo_din),    // Data input from NI
      .dout     (req_fifo_dout),      // Data output to APB manager
      .empty    (req_fifo_empty),
      .full     (req_fifo_full)
  );

  // Instantiate the Response FIFO (APB Manager -> NI)
  sync_fifo #(
      .DEPTH(8),
      .DTYPE(resp_packet_s)
  ) resp_fifo (
      .rstn     (resetn),
      .clk      (clk),
      .fifo_wreq(apb_resp_fifo_wreq),  // Write request from APB manager
      .fifo_rreq(ni_resp_fifo_rreq),   // Read request from NI
      .din      (apb_resp_fifo_din),   // Data input from APB manager
      .dout     (resp_fifo_dout),      // Data output to NI
      .empty    (resp_fifo_empty),
      .full     (resp_fifo_full)
  );

  // Instantiate the APB Manager
  apb_manager apb_mgr (
      .PCLK         (clk),
      .PRESETn      (resetn),
      // APB interface
      .in_apb_sigs  (apb_resp_signals),
      .op_apb_sigs  (apb_req_signals),
      // FIFO interfaces
      .in_trans_pkt (req_fifo_dout),      // Data from req FIFO to APB manager
      .fifo_full    (resp_fifo_full),     // Response FIFO full flag
      .fifo_empty   (req_fifo_empty),     // Request FIFO empty flag
      .out_trans_pkt(apb_resp_fifo_din),  // Data from APB manager to resp FIFO
      .fifo_rreq    (apb_req_fifo_rreq),  // APB read request to req FIFO
      .fifo_wreq    (apb_resp_fifo_wreq)  // APB write request to resp FIFO
  );

endmodule
