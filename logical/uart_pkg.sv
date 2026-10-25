

package uart_pkg;

typedef enum logic [2:0] {
  IDLE   = 3'd0,
  START  = 3'd1,
  DATA   = 3'd2,
  PARITY = 3'd3,
  STOP   = 3'd4
} uart_states_e;

endpackage