

`default_nettype none
`timescale 1ns/1ps

module top_sim1();

   localparam FREQ = 12; // in MHZ

   // clock
   reg clk;
   initial begin
     #0 clk = 0;
     forever clk = #(1000 / (FREQ * 2)) !clk;
   end

   // reset
   reg rst;
   initial begin
     #0 rst = 1;
     #100 rst = 0;
   end


   // dut
   wire [7:0]leds;
   wire      tx;
   top_syn dut
     (
      .CLK_I(clk),
      .LED_IO(leds),
      .UART_RTS_N_I(rst),
      .UART_RX_I(1),
      .UART_TX_O(tx)
      );


   // simulation
   initial begin
     $dumpfile("build/waveform1.vcd");
     $dumpvars;

     // this will stop simulation at some point
     #800000 $finish(0);
   end

endmodule
