

module uart_tx #(
  BAUD = 9600 //bits per second
) (
  input wire clk,
  input wire resetn,

  output wire out
);

// import uart_pkg::*;
typedef enum logic [2:0] {
  IDLE,
  START,
  DATA,
  PARITY,
  STOP
} uart_states_e;
uart_states_e tmp;
logic unassigned;

logic out_i;

always_ff @( posedge clk or negedge resetn ) begin
  if(!resetn) begin
    out_i <= 1'b0;
  end else begin
    out_i <= ~out_i;
    // tmp <= START;
  end
end

assign out = out_i;

endmodule