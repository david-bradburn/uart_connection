

module baud_gen_tb ();

logic clk = 0;
logic resetn;
logic out;
always begin
  #10;
  clk <= ~clk;
end

initial begin
  $dumpfile("a.out");
  $dumpvars(0, baud_gen_tb);
end

logic start;
logic stop;
logic tick;

baud_gen #(
  .CLKSPEED (100000),
  .BAUD     (9600)
) u_baud_gen (
  .clk        (clk),
  .resetn     (resetn),

  .start      (start),
  .stop       (stop),
  .tick       (tick)
);


initial begin
  resetn <= 1'b0;
  start  <= 1'b0;
  stop   <= 1'b0;
  repeat (5) begin
    @(posedge clk);
  end
  resetn <= 1'b1;
  repeat (5) begin
    @(posedge clk);
  end
  start <= 1'b1;
  @(posedge clk);
  start <= 1'b0;
  repeat (100) begin
    @(posedge clk);
  end

  $finish;

end

endmodule