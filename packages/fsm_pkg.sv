package fsm_pkg;

  // enums for request fsm 
  typedef enum {
    INITIAL_REQ_ST,
    SAMPLE_DATA_REQ_ST,
    WRT_REQ_ST,
    WAIT_REQ_ST
  } ni_req_states_e;
  // enums for response fsm 
  typedef enum {
    INITIAL_RESP_ST,
    FIFO_RREQ_RESP_ST,
    FIFO_SAMPLE_DATA_ST,
    DRIVE_FLIT_OUT_ST
  } ni_resp_states_e;

  typedef enum {
    IDLE_ST,
    SETUP_ST,
    ACCESS_ST,
    DONE_ST
  } apb_master_states_e;
endpackage
