`include "defs.vh"

/*
 * minimal AHB lite mux.  M_SEL_I=000 means not resolved.
 * assumes a M0 master and a world where Murphy's law doesn't exist.
 */

module ahb_mux
(
 input         HCLK_I,
 input         HRESET_N_I,

 // master signals
 input [2:0]   M_SEL_I,
 input [1:0]   M_HTRANS_I,
 input         M_HREADY_I,

 output        M_HREADY_O,
 output        M_HRESP_O,
 output [31:0] M_HRDATA_O,

 // slave signals, note absence of 0
 output [7:1]   S_SEL_O,
 input [7:1]   S_HREADY_I,
 input [7:1]   S_HRESP_I,

 input [31:0]  S1_HRDATA_I,
 input [31:0]  S2_HRDATA_I,
 input [31:0]  S3_HRDATA_I,
 input [31:0]  S4_HRDATA_I,
 input [31:0]  S5_HRDATA_I,
 input [31:0]  S6_HRDATA_I,
 input [31:0]  S7_HRDATA_I
 );

   // current state: (idle, process)
   reg         state;
   always @(posedge HCLK_I)
     if(!HRESET_N_I)
       state <= 0;
     else
       state <= M_HREADY_I & M_HTRANS_I[1];


   // selector reg
   reg [2:0] sel_d;
   always @(posedge HCLK_I)
     if(!HRESET_N_I)
       sel_d <= 3'b000;
     else if(M_HREADY_I & M_HTRANS_I[1])
       sel_d <= M_SEL_I;


   // data read mux
   assign M_HRDATA_O = (sel_d == 3'd1) ? S1_HRDATA_I :
                       (sel_d == 3'd2) ? S2_HRDATA_I :
                       (sel_d == 3'd3) ? S3_HRDATA_I :
                       (sel_d == 3'd4) ? S4_HRDATA_I :
                       (sel_d == 3'd5) ? S5_HRDATA_I :
                       (sel_d == 3'd6) ? S6_HRDATA_I :
                       (sel_d == 3'd7) ? S7_HRDATA_I :
                       32'dx;


   // ready and resp muxes
   wire [7:0] mask = 8'h01 << M_SEL_I;
   wire [7:0] mask_d = 8'h01 << sel_d;

   assign S_SEL_O = mask[7:1];
   assign M_HREADY_O = ~state | |(mask_d[7:1] & S_HREADY_I);
   assign M_HRESP_O = |(~mask_d[7:1] & S_HRESP_I);
endmodule
