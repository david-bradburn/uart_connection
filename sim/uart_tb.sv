
`timescale 1ns/1ps

module uart_tb import uart_pkg::*;();

localparam CLKSPEED1 = 100000000;
localparam CLKSPEED2 = 200000000;
localparam N = 10;

logic clk1 = 0;
logic clk2 = 0;
logic resetn;

logic [7:0] data_in, data_out;
logic       valid_in;
logic       ready_in;
logic       valid_out;
logic       tx;

integer     transfer_cnt = 0;
logic [7:0] data_queue [$];

always begin
  #5;
  clk1 <= ~clk1;
end

always begin
  #2.5;
  clk2 <= ~clk2;
end

initial begin
  $dumpfile("a.out");
  $dumpvars(0, uart_tb);

end

uart_tx #(
  .CLKSPEED   (CLKSPEED1) // Hz
) u_uart_tx  (
  .clk    (clk1),
  .resetn (resetn),

  .data   (data_in),
  .valid  (valid_in),
  .ready  (ready_in),

  .tx     (tx)
);

uart_rx #(
  .CLKSPEED   (CLKSPEED2) // Hz
) u_uart_rx  (
  .clk    (clk2),
  .resetn (resetn),

  .data   (data_out),
  .valid  (valid_out),
  // .ready  (ready),

  .rx     (tx)
);

task wait_for_valid();
  wait(valid_out == 1'b1);
endtask

task wait_for_ready();
  wait(ready_in == 1'b1);
endtask

// task wait_for_reset_release(
//   input logic clk
// );
//   @(posedge clk);
//   wait(resetn);
//   @(posedge clk);
// endtask

task send_data(
  input logic [7:0] data_i
);
  data_in <= data_i;
  data_queue.push_back(data_i);
  @(posedge clk1);
  valid_in <= 1'b1;
  wait_for_ready();
  @(posedge clk1);
  valid_in <= 1'b0;
  @(posedge clk1);
endtask


logic [7:0] tmp;
task wait_for_data();
  @(posedge clk2) ;
  wait(valid_out == 1'b0);
  @(posedge clk2) ;
  wait_for_valid();
  // $display("Queue size is %0d",data_queue.size() );
  // foreach(data_queue[i]) $display("\tdata_queue[%0d] = %0h",i,data_queue[i]);
  tmp = data_queue.pop_front();
  transfer_cnt = transfer_cnt + 1'b1;
  $display("cnt %4d - s %2h ?= r %2h", transfer_cnt, tmp, data_out);
  assert(tmp == data_out) else $fatal(1, "cnt %0d - %0h != %0h", transfer_cnt, tmp, data_out);


endtask


initial begin
  resetn    <= 1'b0;
  data_in   <= '0;
  valid_in  <= 1'b0;
end

initial begin : input_side
  repeat (5) begin
    @(posedge clk1);
  end
  resetn <= 1'b1;
  repeat (5) begin
    @(posedge clk1);
  end
  for (integer i = 0; i < N; i = i + 1) begin
    send_data($random);
  end

end

initial begin
  // wait_for_reset_release(clk2);
  @(posedge clk2);
  wait(resetn);
  @(posedge clk2);
  for (integer i = 0; i < N; i = i + 1) begin
    wait_for_data();
  end

  $finish;
end

integer timeout_cnt=0;
localparam TIMEOUT = 10000000;
always_ff @( posedge clk1 ) begin
  timeout_cnt <= timeout_cnt + 1'b1;
end

initial begin
  wait(timeout_cnt == TIMEOUT);
  $fatal(1, "Sim timed out");
end



endmodule