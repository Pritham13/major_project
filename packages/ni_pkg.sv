package ni_pkg;
      // For 32-bit data
    parameter DATA_WIDTH = 32;
    parameter NUM_BODY_FLITS = calc_num_flits(DATA_WIDTH);
    parameter TOTAL_FLITS = NUM_BODY_FLITS + 2;
    parameter NUM_RESP_FLITS = NUM_BODY_FLITS + 1;
    parameter REMAINING_BEATS_LENGTH_REQ = $clog2(NUM_BODY_FLITS);
    parameter REMAINING_BEATS_LENGTH_RESP = $clog2(NUM_RESP_FLITS);

  // packed struct to represent head flit
    typedef struct packed {
        logic [2:0]  number_of_flits; 
        logic [1:0]  flag_bits;       
        logic [2:0]  mode_bits;       
        logic [3:0]  destination_addr;
        logic [3:0]  source_addr;     
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
        // Function to calculate needed flits for data width
    function automatic int calc_num_flits(int data_width);
        int bits_per_flit = 14; 
        int num_flits = (data_width + bits_per_flit - 1) / bits_per_flit; // Ceiling division
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
        body_flit_s [NUM_BODY_FLITS-1:0] body_flit;
        tail_flit_s tail_flit;
    } resp_packet_s;
endpackage
