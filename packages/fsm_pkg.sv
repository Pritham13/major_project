package fsm_pkg;
  
  // enums for request fsm 
  typedef enum {
    INITIAL_REQ_ST ,
    SAMPLE_DATA_REQ_ST,
    WRT_REQ_ST,
    WAIT_REQ_ST
    } req_states_e ;
    // enums for response fsm 
    typedef enum {
    INITIAL_RESP_ST,
    FIFO_RREQ_RESP_ST,
    FIFO_SAMPLE_DATA_ST,
    DRIVE_FLIT_OUT_ST
      } resp_states_e;
endpackage
