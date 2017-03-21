`default_nettype none

// 32 x 2^AWIDTH ROM.
// Memory contents is read from firmware hex file both during simulation
// and synthesis

module rom
  #( parameter AWIDTH = 8 )
   (
    input              HCLK_I,
    input              HRESET_N_I,

    input              HSEL_I,
    input [AWIDTH-1:0] HADDR_I,
    input              HREADY_I,
    output             HRESP_O,
    output [31:0]      HWDATA_O,
    output             HREADY_O
    );

   // the memory
   localparam FILENAME = "../build/rom.hex";
   localparam COUNT = 2 ** (AWIDTH-2);
   reg [31:0]       memory[0:COUNT-1];

   // input registers
   reg [AWIDTH-1:0]    adr_d;
   reg                 enable_d;

   always @(posedge HCLK_I)
     adr_d <= HADDR_I;

   always @(posedge HCLK_I)
     if(!HRESET_N_I)
       enable_d <= 0;
     else
       enable_d <= HSEL_I;

   // memory initialization
   initial begin
     $readmemh(FILENAME, memory);
   end

   // outputs
   assign HWDATA_O = enable_d ? memory[ adr_d[AWIDTH-1:2]] : 32'd0;
   assign HREADY_O = enable_d;
   assign HRESP_O = 0;

endmodule
