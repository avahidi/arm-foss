
`timescale 1ns/1ps

module top_tb();

   localparam FREQ = 12; // in MHZ


   reg tb_clk, tb_rst;
   wire uart_rx, uart_tx;

   wire [7:0] gpio_in;
   wire [7:0] gpio_out;
   wire [7:0] gpio_dir;

   // dummy gpio reading
   assign gpio_in = (gpio_dir & gpio_out) | (~gpio_dir & 8'hAA);

   // the DUT
   top dut
     (
      .CLK_I(tb_clk),
      .RESET_I(tb_rst),
      .RX_I(uart_rx),
      .TX_O(uart_tx),

      .PORT_I(gpio_in),
      .PORT_O(gpio_out),
      .DIR_O(gpio_dir)
      );


   // uart listener:
   listen_uart listen_uart0
     (
      .CLK_I(tb_clk),
      .RST_I(tb_rst),
      .RX_I(uart_tx),
      .TX_O(uart_rx)
      );

   // gpio listener:
   listen_gpio listen_gpio0
     (
      .CLK_I(tb_clk),
      .RST_I(tb_rst),

      .IN_I(gpio_in),
      .OUT_I(gpio_out),
      .DIR_I(gpio_dir)
      );


   // clock & reset
   initial begin
     #0 tb_clk = 0;
     #0 tb_rst = 1;
     #100 tb_rst = 0;

     forever
       tb_clk = #(1000 / (FREQ * 2)) !tb_clk;
   end


   // simulation helpers
   initial begin
     $dumpfile("build/waveform0.vcd");
     $dumpvars;

     // this will stop simulation at some point
     #800000 $finish(0);
   end

   // kill simulation when CPU dies
   always @(tb_clk)
     if(dut.cpu_lockup_o) begin
       $write("Existing due to cpu lockup\n");
       # 100 $finish(20);
     end

endmodule
