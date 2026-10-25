

module uart_tx
import uart_pkg::*;
#(
  parameter CLKSPEED,
  parameter BAUD = 9600, //bits per second
  parameter START_POLARITY = 0 //stop is inverse
) (
  input wire       clk,
  input wire       resetn,

  input wire [7:0] value,
  input wire       valid,

  output wire      tx
);

uart_states_e uart_state, uart_state_nxt;

logic start_baud;
logic stop_baud;
logic tick;
logic [2:0] bit_cnt, bit_cnt_nxt;
logic n_bits_sent;
logic [7:0] value_q;

always_ff @( posedge clk or negedge resetn ) begin : blockName
  if(!resetn) begin
    value_q <= '0;
  end else if (valid) begin
    value_q <= value;
  end
end

logic tx_i;
assign tx = tx_i;

assign start_baud  = (uart_state == IDLE) && valid;
assign stop_baud   = (uart_state == STOP) && tick;
assign bit_cnt_nxt = (uart_state == DATA ) && !n_bits_sent ? bit_cnt + 1'b1 : 3'b0;
assign n_bits_sent = (bit_cnt == 3'd7);

baud_gen #(
  .CLKSPEED (CLKSPEED),
  .BAUD     (BAUD)
) u_baud_gen (
  .clk      (clk),
  .resetn   (resetn),

  .start    (start_baud),
  .stop     (stop_baud),
  .tick     (tick)
);

always_comb begin : uart_state_update
  case(uart_state)
    IDLE : uart_state_nxt = uart_states_e'(valid == 1'b1                        ? START : IDLE);
    START: uart_state_nxt = uart_states_e'(tick == 1'b1                         ? DATA  : START);
    DATA : uart_state_nxt = uart_states_e'(n_bits_sent == 1'b1 && tick == 1'b1  ? STOP  : DATA);
    STOP : uart_state_nxt = uart_states_e'(tick == 1'b1                         ? IDLE  : STOP);
    default: uart_state_nxt = uart_states_e'(3'bx);
  endcase
end : uart_state_update

always_comb begin
  case(uart_state)
    IDLE, STOP:  tx_i = !START_POLARITY;
    START: tx_i = START_POLARITY;
    DATA : tx_i = value[bit_cnt];
    default : tx_i = 1'bx;
  endcase
end

always_ff @( posedge clk or negedge resetn ) begin
  if(!resetn) begin
    uart_state <= IDLE;
  end else begin
    uart_state <= uart_state_nxt;
  end
end

always_ff @( posedge clk or negedge resetn ) begin : bit_counter
  if (!resetn) begin
    bit_cnt <= '0;
  end else if (tick && !n_bits_sent) begin
    bit_cnt <= bit_cnt_nxt;
  end
end : bit_counter

endmodule