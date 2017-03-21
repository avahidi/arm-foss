
module ahb_ctrl
  (
   input         HCLK_I,
   input         HRESET_N_I,

   input         HREADY_I,
   input         HSEL_I,
   input [2:0]   HSIZE_I,
   input         HWRITE_I,
   input [11:0]  HADDR_I,
   input [31:0]  HRDATA_I,
   output [31:0] HWDATA_O,
   output        HRESP_O,
   output        HREADY_O
   );

   assign HRESP_O = 0;
   assign HREADY_O = write_d;

`ifndef SYNTHESIS
   assign HWDATA_O = 32'd1;
`else
   assign HWDATA_O = 32'd0;
`endif

   // input registers
   wire [2:0]    adr = HADDR_I[4:2];
   reg [2:0]     adr_d;
   always @(posedge HCLK_I) begin
     adr_d <= adr;
   end

   reg           write_d;
   always @(posedge HCLK_I /* , negedge HRESET_N_I */)
     if(!HRESET_N_I)
       write_d <= 0;
     else
       write_d <= HWRITE_I & HSEL_I;


   always @(posedge HCLK_I)
     if(write_d) begin
       case(adr_d)

`ifndef SYNTHESIS
         3'd1:
           $write("%c", HRDATA_I[7:0]);

         3'd2: begin
           $write("Existing by user request, code = %08x\n", HRDATA_I);
           $finish(0);
         end
`endif

       endcase
     end

endmodule
