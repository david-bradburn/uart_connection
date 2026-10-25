

module baud_gen #(
  parameter CLKSPEED,
  parameter BAUD = 9600
)(
  input wire clk,
  input wire resetn,

  input wire start,
  input wire stop,
  output wire tick
);

localparam TICKRATE = CLKSPEED/BAUD;

logic [31:0] cnt, cnt_nxt;
logic start_q;

logic count_en;
assign count_en = start || start_q;
assign cnt_nxt = ((cnt == TICKRATE) || stop) ? 1'b0 : cnt + 1'b1;
assign tick    = (cnt == TICKRATE);

always_ff @(posedge clk or negedge resetn) begin
  if(!resetn) begin
    start_q <= 1'b0;
    cnt     <= '0;
  end else if (count_en) begin
    start_q <= !stop;
    cnt     <= cnt_nxt;
  end
end


endmodule