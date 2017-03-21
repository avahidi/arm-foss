
`default_nettype none

/* Reset generator */

module rstgen
(
 input             CLK_I,
 input             RESET_I,
 output            RESET_O,
 output            RESET_N_O
 );

   reg [3:0]       rstv = 4'b1111;

   always @(posedge CLK_I, posedge RESET_I)
     if(RESET_I)
       rstv <= 4'b1111;
     else
       rstv <= rstv >> 1;

   reg             rst = 1'b1;
   reg             rst_n = 1'b0;

   always @(posedge CLK_I) begin
     rst <= rstv[0];
     rst_n <= ~rstv[0];
   end

   assign RESET_O = rst;
   assign RESET_N_O = rst_n;

endmodule
