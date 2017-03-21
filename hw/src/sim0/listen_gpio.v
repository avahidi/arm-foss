`timescale 1ns/1ps

module listen_gpio
  (
   input       CLK_I,
   input       RST_I,

   input [7:0] IN_I,
   input [7:0] OUT_I,
   input [7:0] DIR_I
   );

   reg [7:0]   old_in;
   reg [7:0]   old_out;
   reg [7:0]   old_dir;

   always @(CLK_I) begin
     old_in <= IN_I;
     old_out <= OUT_I;
     old_dir <= DIR_I;

     if(old_in != IN_I)
       $write("GPIO input updated: %x -> %x\n", old_in, IN_I);

     if(old_out != OUT_I)
       $write("GPIO output updated: %x -> %x\n", old_out, OUT_I);

     if(old_dir != DIR_I)
       $write("GPIO direction updated: %x -> %x\n", old_dir, DIR_I);
   end

endmodule
