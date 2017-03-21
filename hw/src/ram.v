`default_nettype none

// 32-bit, 2^AWIDTH deep RAM, with byte-wise write enable
module ram #(parameter AWIDTH = 8)
   (
    input              HCLK_I,
    input              HRESET_N_I,

    input              HREADY_I,
    input              HSEL_I,
    input [2:0]        HSIZE_I,
    input              HWRITE_I,
    input [AWIDTH-1:0] HADDR_I,
    input [31:0]       HRDATA_I,
    output [31:0]      HWDATA_O,
    output             HRESP_O,
    output             HREADY_O
    );

   // the memory cells
   localparam COUNT = 2 ** (AWIDTH-2);
   reg [7:0]           mem0[0:COUNT-1];
   reg [7:0]           mem1[0:COUNT-1];
   reg [7:0]           mem2[0:COUNT-1];
   reg [7:0]           mem3[0:COUNT-1];

   // input registers
   reg [AWIDTH-1:0]    adr_d;
   reg [1:0]           size_d;
   reg                 write_d;
   reg                 enable_d;

   always @(posedge HCLK_I) begin
     adr_d <= HADDR_I;
     size_d <= HSIZE_I[1:0];
   end

   always @(posedge HCLK_I) begin
     if(!HRESET_N_I) begin
       write_d <= 0;
       enable_d <= 0;
     end else begin
       write_d <= HWRITE_I;
       enable_d <= HREADY_I & HSEL_I;
     end
   end


   // memory write
   wire [1:0]          adr_low_d = adr_d[1:0];
   wire [AWIDTH-3:0]   adr_hi_d = adr_d[AWIDTH-1:2];

   always @(posedge HCLK_I) begin
     if(write_d & enable_d) begin
       case({size_d, adr_low_d})
         // BYTE
         4'b00_00: mem0[adr_hi_d] <= HRDATA_I[7:0];
         4'b00_01: mem1[adr_hi_d] <= HRDATA_I[15:8];
         4'b00_10: mem2[adr_hi_d] <= HRDATA_I[23:16];
         4'b00_11: mem3[adr_hi_d] <= HRDATA_I[31:24];
         // WORD
         4'b01_00: begin
           mem0[adr_hi_d] <= HRDATA_I[7:0];
           mem1[adr_hi_d] <= HRDATA_I[15:8];
         end

         4'b01_10: begin
           mem2[adr_hi_d] <= HRDATA_I[23:16];
           mem3[adr_hi_d] <= HRDATA_I[31:24];
         end
         // DWORD
         4'b10_00: begin
           mem0[adr_hi_d] <= HRDATA_I[7:0];
           mem1[adr_hi_d] <= HRDATA_I[15:8];
           mem2[adr_hi_d] <= HRDATA_I[23:16];
           mem3[adr_hi_d] <= HRDATA_I[31:24];
         end
       endcase
     end
   end

   // read and output
   assign HWDATA_O = { mem3[adr_hi_d], mem2[adr_hi_d], mem1[adr_hi_d], mem0[adr_hi_d] };
   assign HREADY_O = enable_d;
   assign HRESP_O = 0;
endmodule
