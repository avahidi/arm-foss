
module rom #(
    parameter AWIDTH = 8,
    parameter FILENAME = "romdata.bin" 
)
(
    input CLK_I,
    input RST_I,
    input [AWIDTH-1:0] ADR_I,
    input ENABLE_I,
    output [31:0] DATA_O,
    output READY_O
);

localparam COUNT = 2 ** (AWIDTH-2);

reg [31:0] memory[0:COUNT-1];

// input registers
reg [AWIDTH-1:0] adr_i_d;
reg enable_i_d;

always @(posedge CLK_I) begin
    adr_i_d <= ADR_I;
end

always @(posedge CLK_I or negedge RST_I) begin
    if(RST_I) begin
        enable_i_d <= 0;
    end else begin
        enable_i_d <= ENABLE_I;
    end
end


// memory read
assign DATA_O = enable_i_d ? memory[ adr_i_d[AWIDTH-1:2]] : 32'd0;
assign READY_O = enable_i_d;


// memory initialization
`ifndef SYNTHESIS

integer i, fd;
reg [31:0] data;

initial begin
    fd = $fopen(FILENAME, "rb");

    for(i = 0; i < COUNT; i = i + 1)
        memory[i] = 32'hdeadbeef;

    for(i = 0; i < COUNT && ($fread(data,fd) != -1); i = i + 1)
        memory[i] = {data[7:0], data[15:8], data[23:16], data[31:24]};

end
`endif

endmodule
