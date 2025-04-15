package ni_pkg;
  // For 32-bit data
  parameter DATA_WIDTH = 32;
  parameter ADDR_WIDTH = 14;
  parameter NUM_DATA_FLITS = calc_num_flits(DATA_WIDTH);
  parameter NUM_ADDR_FLITS = calc_num_flits(ADDR_WIDTH);
  parameter NUM_BODY_FLITS = NUM_DATA_FLITS + NUM_ADDR_FLITS;
  parameter TOTAL_FLITS = NUM_BODY_FLITS + 2;
  parameter NUM_RESP_FLITS = NUM_BODY_FLITS + 1;
  parameter REMAINING_BEATS_LENGTH_REQ = $clog2(NUM_BODY_FLITS);
  parameter REMAINING_BEATS_LENGTH_RESP = $clog2(NUM_RESP_FLITS);

  // packed struct to represent head flit
  typedef struct packed {
    logic [2:0] number_of_flits;
    logic [1:0] flag_bits;
    logic [2:0] mode_bits;
    logic [3:0] destination_addr;
    logic [3:0] source_addr;
  } head_flit_s;

  // packed struct to represent body flit
  typedef struct packed {
    logic [14:0] data_bits;
    logic        flit_identifier;
  } body_flit_s;

  // packed struct to represent tail flit
  typedef struct packed {
    logic [14:0] data_bits;
    logic        flit_identifier;
  } tail_flit_s;

  //function to calculate the data flits
  function automatic int calc_num_flits(int data_width);
    int bits_per_flit = 15;
    int num_flits = (data_width + bits_per_flit - 1) / bits_per_flit;  // Ceiling division
    return num_flits;
  endfunction

  // packed struct to represent packet 
  typedef struct packed {
    head_flit_s head_flit;
    body_flit_s [NUM_BODY_FLITS-1:0] body_flit;
    tail_flit_s tail_flit;
  } req_packet_s;

  // packed struct to represent packet 
  typedef struct packed {
    head_flit_s head_flit;
    body_flit_s [NUM_DATA_FLITS-1:0] body_flit;
    tail_flit_s tail_flit;
  } resp_packet_s;

  // Function to calculate needed flits for data width
  function automatic logic [DATA_WIDTH-1:0] get_data(input req_packet_s packet);
    logic [DATA_WIDTH-1:0] result;
    result = {
      packet.body_flit[1].data_bits,
      packet.body_flit[2].data_bits,
      packet.body_flit[3].data_bits[14:13]
    };
    //int bits_per_flit = 15;  // Each body_flit has 15 data bits

    //result = '0;  // Initialize result to all zeros

    //// Concatenate all body flits to form the complete data word
    //for (int i = 0; i < NUM_BODY_FLITS; i++) begin
    //  int shift_amount = i * bits_per_flit;
    //  int upper_bound = (shift_amount + bits_per_flit) <= DATA_WIDTH ? bits_per_flit : (DATA_WIDTH - shift_amount);

    //  if (shift_amount < DATA_WIDTH) begin
    //    result[shift_amount+:upper_bound] = packet.body_flit[i].data_bits[upper_bound-1:0];
    //  end
    //end

    return result;
  endfunction
endpackage
