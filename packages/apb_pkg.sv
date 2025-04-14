package apb_pkg;

  parameter ADDR_WIDTH = 14;
  parameter DATA_WIDTH = 32;
  ///////////////// enums /////////////
  typedef enum {
    APB_READ,
    APB_WRITE
  } read_write_apb_enum;

  ////////////// Structs  ////////// 
  // packed struct to represent head flit
  typedef struct packed {
    logic [ADDR_WIDTH -1:0] PADDR;
    logic PSELx;
    logic [DATA_WIDTH-1:0] PWDATA;
    logic PSTRB;
    read_write_apb_enum PWRITE;
    logic PENABLE;
  } apb_req_s;

  typedef struct packed {
    logic [DATA_WIDTH-1:0] PRDATA;
    logic PREADY;  // similar to HREADY
    logic PSLVERR;  // indicates response 
  } apb_resp_s;

endpackage
