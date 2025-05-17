import fsm_pkg::*;
import ni_pkg::*;
import apb_pkg::*;
task automatic test3();
  req_packet_s in_trans;
  // Initialize head flit
  in_trans.head_flit = '{
      number_of_flits: 3'b000,
      flag_bits: 2'b00,
      mode_bits: 3'b000,
      destination_addr: 4'h0,
      source_addr: 4'h0
  };
  in_trans.body_flit[0].data_bits[0] = 'd1;
  in_trans.body_flit[0].data_bits[14:1] = $urandom;
  // Initialize body flits
  for (int i = 1; i < ni_pkg::NUM_BODY_FLITS; i++) begin
    in_trans.body_flit[i] = '{data_bits: 15'h0000 + i * $urandom, flit_identifier: 1'b0};
  end
  apb_resp_signals.PREADY = 'd1;
  // Initialize tail flit
  in_trans.tail_flit = '{
      data_bits: 15'h0000,
      flit_identifier: 1'b1  // Typically tail flit has identifier set to 1
  };

  @(posedge clk)
  @(posedge clk)
  $display("==================================Input Transaction begin =====================================");
  print_data_flits (in_trans);
  send_flits_on_clock(in_trans);
  $display("==================================Input Transaction end =====================================");
  forever begin
    @(posedge clk)
    if (apb_req_signals.PENABLE == 1) begin
      // $display("Time=%0t:done --------------PENABLE: 0x%b", $time, apb_req_signals.PENABLE);
      break;
    end
  end
  if (apb_req_signals.PWDATA == get_data(in_trans)) begin
    $display("test3 :: [PASS] : Data match!");
    $display("Time=%0t: Expected data: 0x%h", $time, get_data(in_trans));
    $display("Time=%0t: Actual PWDATA: 0x%h", $time, apb_req_signals.PWDATA);
  end else begin
    $display("[FAIL] Time=%0t: Data mismatch!", $time);
    $display("Time=%0t: Expected data: 0x%h", $time, get_data(in_trans));
    $display("Time=%0t: Actual PWDATA: 0x%h", $time, apb_req_signals.PWDATA);
    $display("Time=%0t: XOR difference: 0x%h", $time, get_data(in_trans) ^ apb_req_signals.PWDATA);
  end
  $finish;
endtask
