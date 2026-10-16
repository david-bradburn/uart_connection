

package uart_pkg;

typedef enum logic [2:0] {
  IDLE,
  START,
  DATA,
  PARITY,
  STOP
} uart_states_e;

endpackage