
`timescale 1ns/1ns

module uart_tb import uart_pkg::*;();


logic clk = 0;
logic resetn;

logic [7:0] value;
logic       valid;
always begin
  #10;
  clk <= ~clk;
end

initial begin
  $dumpfile("a.out");
  $dumpvars(0, uart_tb);

end

uart_tx #(
  .CLKSPEED   (100000) // Hz
) u_uart_tx  (
  .clk    (clk),
  .resetn (resetn),

  .value  (value),
  .valid  (valid)
);


initial begin
  resetn <= 1'b0;
  value  <= '0;
  valid  <= 1'b0;
  repeat (5) begin
    @(posedge clk);
  end
  resetn <= 1'b1;
  repeat (5) begin
    @(posedge clk);
  end
  value <= 8'h12;
  @(posedge clk);
  valid <= 1'b1;
  @(posedge clk);
  valid <= 1'b0;

  repeat (200) begin
    @(posedge clk);
  end


  $finish;

end

endmodule