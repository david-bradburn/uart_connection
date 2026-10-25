
`timescale 1ns/1ns

module uart_tx_tb import uart_pkg::*;();


logic clk = 0;
logic resetn;

logic [7:0] data;
logic       valid;
logic       ready;
logic       tx;

always begin
  #10;
  clk <= ~clk;
end

initial begin
  $dumpfile("a.out");
  $dumpvars(0, uart_tx_tb);

end

uart_tx #(
  .CLKSPEED   (100000) // Hz
) u_uart_tx  (
  .clk    (clk),
  .resetn (resetn),

  .data   (data),
  .valid  (valid),
  .ready  (ready),

  .tx     (tx)
);

task wait_for_ready();
  wait(ready == 1'b1);
endtask

task send_data(
  input logic [7:0] data_i
);
  data <= data_i;
  @(posedge clk);
  valid <= 1'b1;
  wait_for_ready();
  @(posedge clk);
  valid <= 1'b0;
  @(posedge clk);
endtask


initial begin
  resetn <= 1'b0;
  data   <= '0;
  valid  <= 1'b0;
  repeat (5) begin
    @(posedge clk);
  end
  resetn <= 1'b1;
  repeat (5) begin
    @(posedge clk);
  end
  send_data(8'h12);
  send_data(8'h34);
  send_data(8'hFF);

  wait_for_ready();


  $finish;

end

endmodule