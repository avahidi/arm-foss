`default_nettype none

/*
 * This is a relatively small UART implementation that is also
 * somewhat intelligent and flexible
 */

module uart
  (
   input        CLK_I,
   input        RESET_N_I,
   // config
   input [10:0] ADD_I,
   // RX
   input        RX_I,
   output [7:0] RX_DATA_O,
   output reg   RX_VALID_O,
   output reg   RX_ERROR_O,
   // TX
   output       TX_O,
   output       TX_BUSY_O,
   input [7:0]  TX_DATA_I,
   input        TX_VALID_I
   );


   //
   // UART tick generation
   //

   // 16x tick
   reg [12:0]   acc1;
   wire         tick16 = acc1[12];
   always @(posedge CLK_I)
     if(!RESET_N_I) begin
	   acc1 <= 0;
     end else begin
	   acc1 <= acc1[11:0] + ADD_I;
     end

   // 1x tick for TX, starts with tx_working
   reg [3:0]  acc2;
   reg 	      tx_tick;
   always @(posedge CLK_I) begin
     tx_tick <= 0;
     if(!tx_working)
	   acc2 <= 0;
     else if(tick16) begin
	   {tx_tick, acc2} <= acc2 + 1;
     end
   end

   // 1x tick for RX, starts 8/16 after incoming start bit
   reg [3:0]  acc3;
   reg        rx_tick;
   always @(posedge CLK_I) begin
     rx_tick <= tick16 & ~|acc3;
     if(tick16) begin
       if(rx_state) begin
	     acc3 <= acc3 + 1;
       end else
	     acc3 <= 9;
     end
   end


   //
   // transmit
   //

   // tx FSM
   reg [8:0]  tx_data;
   reg 	      tx_working;
   reg [3:0]  tx_cnt;
   assign       TX_BUSY_O = tx_working;
   assign       TX_O = tx_data[0];

   always @(posedge CLK_I)
     if(!RESET_N_I) begin
       // these initial values forces TX to wait a while before accepting input
	   tx_working <= 1;
	   tx_cnt <= 0;
	   tx_data <= -1;
     end else begin
	   if(!tx_working) begin
	     tx_cnt <= 0;
	     tx_data[0] <= 1;
	     if(TX_VALID_I) begin
		   tx_working <= 1;
		   tx_data <= {TX_DATA_I, 1'b0 };
	     end
	   end else if(tx_tick) begin
	     tx_cnt <= tx_cnt + 1;
	     tx_data <= {1'b1, tx_data[8:1]};
	     if(tx_cnt == 9) // last one is the stop bit
	       tx_working <= 0;
	   end
     end


   //
   // receive
   //

   // rx input sync & filter
   reg [3:0]  rxs;
   always @(posedge CLK_I)
     rxs <= {rxs[2:0], RX_I };

   reg        rx;
   always@(posedge CLK_I) begin
     if(!RESET_N_I)
       rx <= 1;
     else begin
       case(rxs[2:0])
         3'b000: rx <= 0;
         3'b111: rx <= 1;
       endcase
     end
   end

   // rx FSM
   reg [3:0]  rx_state;
   reg [7:0]  rx_data;
   assign RX_DATA_O = rx_data;

   always @(posedge CLK_I)
     if(!RESET_N_I) begin
	   rx_state <= 0;
	   RX_VALID_O <= 0;
       RX_ERROR_O <= 0;
     end else begin
	   RX_VALID_O <= 0;
       RX_ERROR_O <= 0;

	   case (rx_state)
	     // start bit:
	     0:
           if(tick16 & !rx)
             rx_state <= 1;

         // check for glicths under after half T
	     1:
	       if(tick16 & rx) begin // see if start bit is still 0
		     rx_state <= 0;
             RX_ERROR_O <= 0;
	       end else if(rx_tick) // half bit length
		     rx_state <= rx_state + 1;

	     // 8 data bits
	     2, 3, 4, 5, 6, 7, 8, 9:
	       if(rx_tick) begin
		     rx_data <= {rx, rx_data[7:1] };
		     rx_state <= rx_state + 1;
		     if(rx_state == 9)
		       RX_VALID_O <= 1;
	       end

         // check stop bit
	     10:
	       if(rx_tick) begin
		     if(!rx)
               RX_ERROR_O <= 1;
             else
               rx_state <= 0;
	       end

	     default:
	       rx_state <= 0;
	   endcase // case (rx_state)
     end
endmodule
