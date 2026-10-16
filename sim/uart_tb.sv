
`timescale 1ns/1ns

module uart_tb();


logic clk = 0;
logic resetn;
logic out;
always begin
  #10;
  clk <= ~clk;
end

initial begin
  $dumpfile("a.out");
  $dumpvars(0, uart_tb);

end

uart_tx u_uart_tx (
  .clk    (clk),
  .resetn (resetn),

  .out    (out)
);


initial begin
  resetn <= 1'b0;
  repeat (5) begin
    @(posedge clk);
  end
  resetn <= 1'b1;
  repeat (5) begin
    @(posedge clk);
  end



  $finish;

end

endmodule