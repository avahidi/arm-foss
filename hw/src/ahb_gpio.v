`include "defs.vh"

module ahb_gpio
(
 input             HCLK_I,
 input             HRESET_N_I,

 input [7:0]       PORT_I,
 output [7:0]      PORT_O,
 output [7:0]      DIR_O,

 input             HREADY_I,
 input             HSEL_I,
 input [2:0]       HSIZE_I,
 input             HWRITE_I,
 input [11:0]      HADDR_I,
 input [31:0]      HRDATA_I,
 output reg [31:0] HWDATA_O,
 output            HRESP_O,
 output            HREADY_O
 );

   localparam REG_DATA = 1'b0;
   localparam REG_DIR =  1'b1;

   assign PORT_O = data;
   assign DIR_O = dir;


   // AHB interface and gpio registers
   assign HRESP_O = 0;
   assign HREADY_O = enable_d;
   wire        enable = HSEL_I;


   // AHB input registers
   wire [0:0]  adr = HADDR_I[2:2];
   reg [0:0]   adr_d;
   reg         enable_d;
   reg         write_d;

   always @(posedge HCLK_I) begin
     adr_d <= adr;
     write_d <= HWRITE_I;
   end

   always @(posedge HCLK_I /* , negedge HRESET_N_I */)
     if(!HRESET_N_I)
       enable_d <= 0;
     else
       enable_d <= enable;

   // Write registers update
   reg [7:0]       dir;
   reg [7:0]       data;
   always @(posedge HCLK_I /* , negedge HRESET_N_I */) begin
     if(!HRESET_N_I) begin
       dir <= 8'd0;
     end else begin

       // write data and register update
       if (enable_d & write_d) begin
         case(adr_d)
           REG_DATA: data <= HRDATA_I[7:0];
           REG_DIR: dir <= HRDATA_I[7:0];
         endcase
       end
     end
   end

   // read output update
   always @(posedge HCLK_I)
     if(enable & !HWRITE_I) begin
       case(adr)
         REG_DATA: HWDATA_O <= { 24'd0,  (PORT_I & ~dir) | (data & dir)};
         REG_DIR: HWDATA_O <= { 24'd0, dir };
         default: HWDATA_O <= 32'dx;
       endcase // case (adr_d)
     end
endmodule
