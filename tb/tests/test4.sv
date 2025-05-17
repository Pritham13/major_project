/**
 * Test: test4
 * Verifies the NoC to APB bridge functionality with randomized data
 * Tests packet transmission, APB protocol handling, and data integrity
 */
import fsm_pkg::*;
import ni_pkg::*;
import apb_pkg::*;

/**
 * Task: test4
 * Performs end-to-end testing of the NoC-APB bridge with following steps:
 * 1. Creates and sends a request packet with random data
 * 2. Monitors APB interface signals
 * 3. Captures response packet
 * 4. Verifies data integrity between input and output
 */
task automatic test4();
  /** Counter for flit indexing */
  int i = 0;
  /** Input transaction packet */
  req_packet_s in_trans;
  /** Output response packet */
  resp_packet_s out_trans;

  // Initialize head flit with default values
  in_trans.head_flit = '{
      number_of_flits: 3'b000,    // Number of flits in packet
      flag_bits: 2'b00,           // Control flags
      mode_bits: 3'b000,          // Operation mode
      destination_addr: 4'h0,      // Target address
      source_addr: 4'h0           // Source address
  };

  // Initialize first body flit with random data
  in_trans.body_flit[0].data_bits[0] = 'd0;
  in_trans.body_flit[0].data_bits[14:1] = $urandom;

  /** 
   * Initialize remaining body flits with random data
   * Each flit gets a unique random value based on index
   */
  for (int i = 1; i < ni_pkg::NUM_BODY_FLITS; i++) begin
    in_trans.body_flit[i] = '{
        data_bits: 15'h0000 + i * $urandom, 
        flit_identifier: 1'b0
    };
  end

  // Set APB response signals
  apb_resp_signals.PREADY = 'd1;
  apb_resp_signals.PSLVERR = 'd1;

  // Initialize tail flit
  in_trans.tail_flit = '{
      data_bits: 15'h0000,
      flit_identifier: 1'b1  // Tail flit identifier
  };

  // Generate random APB response data
  apb_resp_signals.PRDATA = $urandom;

  /**
   * Test Sequence:
   * 1. Wait for clock synchronization
   * 2. Display and send input transaction
   * 3. Wait for APB enable
   * 4. Capture response packet
   * 5. Verify data integrity
   */
  @(posedge clk)
    @(posedge clk)
      // Print input transaction details
      $display("==================================Input Transaction begin =====================================");
      print_data_flits(in_trans);
      send_flits_on_clock(in_trans);
      $display("==================================Input Transaction end =====================================");
      $display("================================== PRDATA is 0x%h  =====================================",
               apb_resp_signals.PRDATA);
      print_data_fields(apb_resp_signals.PRDATA);

  // Wait for APB enable assertion
  forever begin
    @(posedge clk)
    if (apb_req_signals.PENABLE == 1) break;
  end

  /**
   * Response Capture Loop
   * Captures response packet flits on valid output
   */
  forever begin
    @(posedge clk) begin
      if (valid_out == 1) begin
        // Capture head flit, body flits, or tail flit based on counter
        if (i == 0) begin
          out_trans.head_flit <= o_flit;
          $display("time = %0t :sampling head :: Head value :: %h", $time,out_trans.head_flit);
        end else if (i == 4) begin
          out_trans.tail_flit <= o_flit;
          $display("time = %0t :sampling tail :: Tail value :: %h " , $time,out_trans.tail_flit);
          break;
        end else begin
          out_trans.body_flit[i-1] <= o_flit;
          $display("time = %0t :sampling body :: body_flit[%d] :: %h", $time,i,out_trans.body_flit);
        end
        i = i + 1;
      end
    end
  end

  // Clock synchronization delays
  @(posedge clk) 
  @(posedge clk) 
  @(posedge clk) 

  /**
   * Response Verification
   * Checks:
   * 1. Header flit match
   * 2. Tail flit match
   * 3. Response data match
   * 4. Response bit validation
   */
  if ((out_trans.head_flit == in_trans.head_flit) &&
      (out_trans.tail_flit == in_trans.tail_flit) &&
      apb_resp_signals.PRDATA == extract_resp_data_from_packet(out_trans) && 
      extract_resp_from_packet(out_trans)) begin
    // Success case reporting
    $display("test4 :: [PASS] : Data match!");
    $display("Time=%0t: Expected data: 0x%h", $time, (apb_resp_signals.PRDATA));
    $display("Time=%0t: Actual extracted data: 0x%h", $time, extract_resp_data_from_packet(
             out_trans));
  end else begin
    // Failure case reporting
    $display("[FAIL] Time=%0t: Data mismatch!", $time);
    $display("Time=%0t: Expected data: 0x%h", $time, (apb_resp_signals.PRDATA));
    $display("Time=%0t: Actual extracted data: 0x%h", $time, extract_resp_data_from_packet(
             out_trans));
  end
  
  $finish;
endtask
