`include "defs.vh"
`include "sim0.vh"

module stim_uart
  (
   input  CLK_I,
   input  RST_I,
   input  RX_I,
   output TX_O
   );

   localparam BITRATE = 115200;
   localparam T = 1000000000 / BITRATE; // bitrate in ns


   reg    TX_O;
   integer i, n;
   initial begin
     TX_O = 1;
     # (T * 20)

     for(n = 48; n < 58 ; n = n + 1) begin // '0' to '9'
       // start bit
       TX_O = 0;
       # (T);

       // data b
       for(i = 0; i < 8; i = i + 1) begin
         if(n & (1 << i))
           TX_O = 1;
         else
           TX_O = 0;

         # (T);
       end

       TX_O = 1;
       # (T * 4);

     end
   end


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
