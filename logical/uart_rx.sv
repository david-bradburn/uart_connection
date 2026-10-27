

module uart_rx
import uart_pkg::*;
#(
  parameter CLKSPEED,
  parameter BAUD = 9600, //bits per second
  parameter START_POLARITY = 0 //stop is inverse
)(
  input wire        clk,
  input wire        resetn,

  output wire [7:0] data,
  output wire       valid,
  // input  wire       ready,

  input  wire       rx
);

uart_states_e uart_state, uart_state_nxt;

logic start_rx;
logic stop_rx;
logic tick;
logic tick_mid;

logic rx_s, rx_q;
logic state_update_en;
logic bit_cnt_en;
logic [2:0] bit_cnt, bit_cnt_nxt;
logic n_bits_rx; // to track if we have recieved all the bits
logic [7:0] data_i, data_i_nxt;
logic rx_en;


assign start_rx  = (uart_state == IDLE) && !rx_s && rx_q;
assign state_update_en = tick || start_rx || stop_rx;
assign stop_rx = (uart_state == STOP) && tick_mid;
assign rx_en = (uart_state == DATA ) && tick_mid;

logic valid_i;
always_ff @(posedge clk or negedge resetn) begin
  if(!resetn) begin
    valid_i <= 1'b0;
  end else begin
    valid_i <= ((uart_state_nxt == STOP) && tick);
  end
end
assign valid = valid_i;

g2dff_1bit u_2dff_1b (
  .clk       (clk),
  .resetn    (resetn),

  .data      (rx),
  .data_s    (rx_s)
);

baud_gen #(
  .CLKSPEED (CLKSPEED),
  .BAUD     (BAUD)
) u_baud_gen (
  .clk      (clk),
  .resetn   (resetn),

  .start    (start_rx),
  .stop     (stop_rx),
  .tick     (tick),
  .tick_mid (tick_mid)
);

assign bit_cnt_en  = (uart_state == DATA ) && tick;
assign bit_cnt_nxt = !n_bits_rx ? bit_cnt + 1'b1 :
                                  3'b0;
assign n_bits_rx   = (bit_cnt == 3'd7);

always_ff @( posedge clk or negedge resetn ) begin
  if (!resetn) begin
    data_i_nxt <= '0;
  end else if (rx_en) begin
    data_i_nxt[bit_cnt] <= rx_q;
  end
end

assign data = data_i_nxt;

always_comb begin : uart_state_update
  case(uart_state)
    IDLE :   uart_state_nxt = uart_states_e'(start_rx          ? START : IDLE);
    START:   uart_state_nxt = uart_states_e'(tick              ? DATA  : START);
    DATA :   uart_state_nxt = uart_states_e'(n_bits_rx && tick ? STOP  : DATA);
    STOP :   uart_state_nxt = uart_states_e'(tick_mid          ? IDLE  : STOP);
    default: uart_state_nxt = uart_states_e'(3'bx);
  endcase
end : uart_state_update

always_ff @( posedge clk or negedge resetn ) begin
  if(!resetn) begin
    rx_q <= '0;
  end else begin
    rx_q <= rx_s;
  end
end

always_ff @( posedge clk or negedge resetn ) begin
  if(!resetn) begin
    uart_state <= IDLE;
  end else if (state_update_en) begin
    uart_state <= uart_state_nxt;
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