/**
 * Package: ni_pkg
 * This package contains definitions and utilities for Network Interface (NI) implementation
 * including flit structures, packet formats, and helper functions.
 */
package ni_pkg;
  // Parameters for packet configuration
  /** Width of the data payload */
  parameter DATA_WIDTH = 32;
  /** Width of the address field */
  parameter ADDR_WIDTH = 14;
  /** Number of flits needed for data, calculated based on DATA_WIDTH */
  parameter NUM_DATA_FLITS = calc_num_flits(DATA_WIDTH);
  /** Number of flits needed for address, calculated based on ADDR_WIDTH */
  parameter NUM_ADDR_FLITS = calc_num_flits(ADDR_WIDTH);
  /** Total number of body flits (data + address) */
  parameter NUM_BODY_FLITS = NUM_DATA_FLITS + NUM_ADDR_FLITS;
  /** Total number of flits in a packet (body + head + tail) */
  parameter TOTAL_FLITS = NUM_BODY_FLITS + 2;
  /** Number of flits in a response packet */
  parameter NUM_RESP_FLITS = NUM_BODY_FLITS + 1;
  /** Bit width needed to represent remaining beats in request */
  parameter REMAINING_BEATS_LENGTH_REQ = $clog2(NUM_BODY_FLITS);
  /** Bit width needed to represent remaining beats in response */
  parameter REMAINING_BEATS_LENGTH_RESP = $clog2(NUM_RESP_FLITS);

  /**
   * Struct: head_flit_s
   * Represents the header flit of a packet
   * Fields:
   * - number_of_flits   : Total number of flits in the packet
   * - flag_bits        : Control flags for the packet
   * - mode_bits        : Operation mode indicators
   * - destination_addr : Target address for the packet
   * - source_addr      : Source address of the packet
   */
  typedef struct packed {
    logic [2:0] number_of_flits;
    logic [1:0] flag_bits;
    logic [2:0] mode_bits;
    logic [3:0] destination_addr;
    logic [3:0] source_addr;
  } head_flit_s;

  /**
   * Struct: body_flit_s
   * Represents a body flit carrying payload data
   * Fields:
   * - data_bits        : Actual payload data
   * - flit_identifier  : Identifier bit to distinguish flit type
   */
  typedef struct packed {
    logic [14:0] data_bits;
    logic        flit_identifier;
  } body_flit_s;

  /**
   * Struct: tail_flit_s
   * Represents the tail flit of a packet
   * Fields:
   * - data_bits        : Final payload data
   * - flit_identifier  : Identifier bit to distinguish flit type
   */
  typedef struct packed {
    logic [14:0] data_bits;
    logic        flit_identifier;
  } tail_flit_s;

  /**
   * Function: calc_num_flits
   * Calculates the number of flits needed for a given data width
   * 
   * Parameters:
   * - data_width : Width of data to be transmitted
   * 
   * Returns:
   * Number of 15-bit flits needed to transmit the data
   */
  function automatic int calc_num_flits(int data_width);
    int bits_per_flit = 15;
    int num_flits = (data_width + bits_per_flit - 1) / bits_per_flit;  // Ceiling division
    return num_flits;
  endfunction

  /**
   * Struct: req_packet_s
   * Represents a complete request packet
   * Fields:
   * - head_flit : Header flit containing control information
   * - body_flit : Array of body flits containing payload
   * - tail_flit : Tail flit marking end of packet
   */
  typedef struct packed {
    head_flit_s head_flit;
    body_flit_s [NUM_BODY_FLITS-1:0] body_flit;
    tail_flit_s tail_flit;
  } req_packet_s;

  /**
   * Struct: resp_packet_s
   * Represents a complete response packet
   * Fields:
   * - head_flit : Header flit containing control information
   * - body_flit : Array of body flits containing response data
   * - tail_flit : Tail flit marking end of packet
   */
  typedef struct packed {
    head_flit_s head_flit;
    body_flit_s [NUM_DATA_FLITS-1:0] body_flit;
    tail_flit_s tail_flit;
  } resp_packet_s;

  /**
   * Function: get_data
   * Extracts data from a request packet's body flits
   * 
   * Parameters:
   * - packet : Input request packet
   * 
   * Returns:
   * Concatenated data value from body flits
   */
  function automatic logic [DATA_WIDTH-1:0] get_data(input req_packet_s packet);
    logic [DATA_WIDTH-1:0] result;
    //result = {
    //  packet.body_flit[1].data_bits,
    //  packet.body_flit[2].data_bits,
    // packet.body_flit[3].data_bits[14:13]
    //};
    int bits_per_flit = 15;  // Each body_flit has 15 data bits

    result = '0;  // Initialize result to all zeros

    // Concatenate all body flits to form the complete data word
    for (int i = 0; i < NUM_BODY_FLITS - 1; i++) begin
      result = result | (packet.body_flit[i].data_bits << i * bits_per_flit);
    end

    return result;
  endfunction

  /**
   * Function: print_data_flits
   * Debug utility to print contents of data flits
   * 
   * Parameters:
   * - packet : Input request packet to analyze
   */
  function automatic void print_data_flits(input req_packet_s packet);
    logic [DATA_WIDTH-1:0] concatenated_data;
    int bits_per_flit = 15;  // Each body_flit has 15 data bits

    // Print individual flits
    $display("Time=%0t: === DATA FLITS BREAKDOWN ===", $time);
    for (int i = 0; i < NUM_BODY_FLITS; i++) begin
      $display("Time=%0t: Data Flit[%0d] = 0x%04h (data_bits = 0x%04h, flit_id = %0d)", $time, i,
               packet.body_flit[i], packet.body_flit[i].data_bits,
               packet.body_flit[i].flit_identifier);
    end

    // Calculate concatenated data (same as get_data function)
    concatenated_data = '0;  // Initialize result to all zeros
    for (int i = 0; i < NUM_BODY_FLITS; i++) begin
      concatenated_data = concatenated_data | (packet.body_flit[i].data_bits << (i*bits_per_flit));
    end

    // Print concatenated result
    $display("Time=%0t: === CONCATENATED DATA ===", $time);
    $display("Time=%0t: Full data value = 0x%08h (%0d bits)", $time, concatenated_data, DATA_WIDTH);
    $display("Time=%0t: =========================", $time);
  endfunction

  /**
   * Function: extract_resp_data_from_packet
   * Extracts 32-bit data from a response packet
   * 
   * Parameters:
   * - packet : Input response packet
   * 
   * Returns:
   * 32-bit extracted data value
   */
  function automatic logic [31:0] extract_resp_data_from_packet(resp_packet_s packet);
    logic [31:0] extracted_data;

    // Extract data from the body flits
    extracted_data[31:0] = {
      packet.body_flit[0],  // First portion from body_flit[0]
      packet.body_flit[1],  // Second portion from body_flit[1]
      {packet.body_flit[2].data_bits[14:13]}  // Higher bits from body_flit[2]
    };

    return extracted_data;
  endfunction

  /**
   * Function: extract_resp_from_packet
   * Extracts response bit from packet
   * 
   * Parameters:
   * - packet : Input response packet
   * 
   * Returns:
   * Single bit response indicator
   */
  function automatic logic extract_resp_from_packet(resp_packet_s packet);
    return packet.body_flit[2].data_bits[12];
  endfunction

  /**
   * Function: print_data_fields
   * Debug utility to print decoded 32-bit data fields
   * 
   * Parameters:
   * - data : 32-bit data value to decode and print
   */
  function automatic void print_data_fields(logic [31:0] data);
    // Extract individual fields based on the packing structure
    logic [ 7:0] body_flit_0 = data[31:16];
    logic [ 7:0] body_flit_1 = data[15:2];
    logic [15:0] body_flit_2 = data[1:0];  // All bits from body_flit[2]

    // Print the fields in a formatted way
    $display("Data Fields Breakdown (32-bit value: 0x%8h):", data);
    $display("  body_flit[0]                 = 0x%h", body_flit_0);
    $display("  body_flit[1]                 = 0x%h", body_flit_1);
    $display("  body_flit[2].data_bits[14:13] = 0x%h", body_flit_2);
    $display("----------------------------------------");
  endfunction

endpackage
