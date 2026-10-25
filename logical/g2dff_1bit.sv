
module g2dff_1bit (
  input wire clk,
  input wire resetn,

  input wire  data,
  output wire data_s
);

logic q;
logic qq;

always_ff @( posedge clk or negedge resetn ) begin
  if(!resetn) begin
    q  <= '0;
    qq <= '0;
  end else begin
    q  <= data;
    qq <= q;
  end
end

assign data_s = qq;

endmodule