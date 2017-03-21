`timescale 1ns/1ps

module listen_uart
  (
   input  CLK_I,
   input  RST_I,
   input  RX_I,
   output TX_O
   );

   localparam BITRATE = 115200;
   localparam T = 1000000000 / BITRATE;

   assign TX_O = 1;

   // clock & reset
   reg [7:0] rx_data;


   initial begin
     forever begin

       // wait for start bit
       @(negedge RX_I);
       #(T / 2);

       // read data bits
       repeat(8) begin
         #(T);
         rx_data = {RX_I, rx_data[7:1]};
       end

       // wait for stop bit
       @(posedge RX_I);

       // print captured byte
       $write("%c", rx_data);

     end
   end


endmodule
