

module uart_tx
import uart_pkg::*;
#(
  parameter CLKSPEED,
  parameter BAUD = 9600, //bits per second
  parameter START_POLARITY = 0 //stop is inverse
) (
  input wire       clk,
  input wire       resetn,

  input wire [7:0] data,
  input wire       valid,
  output wire      ready,

  output wire      tx
);

uart_states_e uart_state, uart_state_nxt;

logic start_baud;
logic stop_baud;
logic tick;

logic [2:0] bit_cnt, bit_cnt_nxt;
logic n_bits_sent;
logic [7:0] data_q;
logic tx_i_nxt, tx_i;
logic ready_i;
logic state_update_en;
logic tx_en;
logic bit_cnt_en;

assign ready_i = uart_state == IDLE;
assign ready   = ready_i;

// Flops the data so it remains stable
always_ff @( posedge clk or negedge resetn ) begin : data_flopper
  if(!resetn) begin
    data_q <= '0;
  end else if (valid && ready_i) begin
    data_q <= data;
  end
end

assign tx = tx_i;

assign start_baud  = (uart_state == IDLE) && valid;
assign stop_baud   = (uart_state == STOP) && tick;

assign bit_cnt_en = (uart_state == DATA ) && tick;
assign bit_cnt_nxt = (uart_state_nxt == DATA) && (uart_state != DATA) ? 3'b0           :
                                                         !n_bits_sent ? bit_cnt + 1'b1 :
                                                                        3'b0;
assign n_bits_sent = (bit_cnt == 3'd7);

assign state_update_en = tick || (valid && ready_i);
assign tx_en = tick || (valid && ready_i);

baud_gen #(
  .CLKSPEED (CLKSPEED),
  .BAUD     (BAUD)
) u_baud_gen (
  .clk      (clk),
  .resetn   (resetn),

  .start    (start_baud),
  .stop     (stop_baud),
  .tick     (tick),
  .tick_mid (/*unused*/)
);

always_comb begin : uart_state_update
  case(uart_state)
    IDLE : uart_state_nxt = uart_states_e'(valid               ? START : IDLE);
    START: uart_state_nxt = uart_states_e'(tick                ? DATA  : START);
    DATA : uart_state_nxt = uart_states_e'(n_bits_sent && tick ? STOP  : DATA);
    STOP : uart_state_nxt = uart_states_e'(tick                ? IDLE  : STOP);
    default: uart_state_nxt = uart_states_e'(3'bx);
  endcase
end : uart_state_update

always_comb begin
  case(uart_state_nxt)
    IDLE, STOP:  tx_i_nxt = !START_POLARITY;
    START: tx_i_nxt = START_POLARITY;
    DATA : tx_i_nxt = data_q[bit_cnt_nxt];
    default : tx_i_nxt = 1'bx;
  endcase
end

always_ff @( posedge clk or negedge resetn ) begin
  if(!resetn) begin
    uart_state <= IDLE;
  end else if (state_update_en) begin
    uart_state <= uart_state_nxt;
  end
end

always_ff @( posedge clk or negedge resetn ) begin
  if(!resetn) begin
    tx_i       <= !START_POLARITY;
  end else if (tx_en) begin
    tx_i       <= tx_i_nxt;
  end
end

always_ff @( posedge clk or negedge resetn ) begin : bit_counter
  if (!resetn) begin
    bit_cnt <= '0;
  end else if (bit_cnt_en) begin
    bit_cnt <= bit_cnt_nxt;
  end
end : bit_counter

endmodule