package apb_pkg;

  // packed struct to represent head flit
  typedef struct packed {
    logic [14:0] PADDR;
    logic PSELx;
    logic [32:0] PWDATA;
    logic PWRITE;
    logic PENABLE;
  } apb_req_s;

  typedef struct packed {
    logic [15:0] PRDATA;
    logic PREADY;  // similar to HREADY
    logic PSLVERR;  // indicates response 
  } apb_resp_s;

endpackage
