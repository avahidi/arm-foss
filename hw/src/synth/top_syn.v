`default_nettype none


module top_syn
  (
   input        CLK_I,
   // inout [7:0] LED_IO,
   output [7:0] LED_IO,

   input        UART_RTS_N_I, // 0 when uart is connected
   input        UART_RX_I,
   output       UART_TX_O
   );


   // output drivers
   wire [7:0]   data_in;
   wire [7:0]   data_out;
   wire [7:0]   dir;
   assign data_in = LED_IO;


   /* arachne and yosys can't handle bidirectional this way yet:
   assign LED_IO[0] = dir[0] ? data_out[0] : 1'bz;
   assign LED_IO[1] = dir[1] ? data_out[1] : 1'bz;
   assign LED_IO[2] = dir[2] ? data_out[2] : 1'bz;
   assign LED_IO[3] = dir[3] ? data_out[3] : 1'bz;
   assign LED_IO[4] = dir[4] ? data_out[4] : 1'bz;
   assign LED_IO[5] = dir[5] ? data_out[5] : 1'bz;
   assign LED_IO[6] = dir[6] ? data_out[6] : 1'bz;
   assign LED_IO[7] = dir[7] ? data_out[7] : 1'bz;
    */

   assign LED_IO = dir & data_out;

   top top0
     (
      .CLK_I(CLK_I),
      .RESET_I(UART_RTS_N_I),

      .RX_I(UART_RX_I),
      .TX_O(UART_TX_O),

      .PORT_I(data_in),
      .PORT_O(data_out),
      .DIR_O(dir)
      );

endmodule // top_syn
