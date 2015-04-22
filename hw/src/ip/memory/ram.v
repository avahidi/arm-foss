
module ram #(parameter AWIDTH = 8)
(
    input CLK_I,
    input RST_I,
    input [AWIDTH-1:0] ADR_I,
    input [31:0] DATA_I,
    input [1:0] SIZE_I,
    input ENABLE_I,
    input WRITE_I,

    output [31:0] DATA_O,
    output READY_O
);

localparam COUNT = 2 ** (AWIDTH-2);

reg [31:0] memory[0:COUNT-1];

// input registers
reg [AWIDTH-1:0] adr_i_d;
reg [1:0] size_i_d;
reg write_i_d;
reg enable_i_d;

always @(posedge CLK_I) begin
    adr_i_d <= ADR_I;
    size_i_d <= SIZE_I;
end

always @(posedge CLK_I or negedge RST_I) begin
    if(RST_I) begin
        write_i_d <= 0;
        enable_i_d <= 0;
    end else begin
        write_i_d <= WRITE_I;
        enable_i_d <= ENABLE_I;
    end
end

// memory read
assign DATA_O = enable_i_d ? memory[ adr_i_d[AWIDTH-1:2] ] : 32'd0;
assign READY_O = enable_i_d;

// memory write

reg [31:0] tmp;
always @(posedge CLK_I) begin
    if(write_i_d & enable_i_d) begin
        tmp = memory[ adr_i_d[AWIDTH-1:2]  ];

        case({size_i_d, adr_i_d[1:0]})
            4'b00_00: tmp[7:0] = DATA_I[7:0];
            4'b00_01: tmp[15:8] = DATA_I[15:8];
            4'b00_10: tmp[23:16] = DATA_I[23:16];
            4'b00_11: tmp[31:24] = DATA_I[31:24];

            4'b01_00: tmp[15:0] = DATA_I[15:0];
            4'b01_10: tmp[31:16] = DATA_I[31:16];

            4'b10_00: tmp[31:0] = DATA_I[31:0];

        endcase

        memory[ adr_i_d[AWIDTH-1:2]] <= tmp;

    end
end





// memory initialization
`ifndef SYNTHESIS

integer i;
initial begin
    for(i = 0; i < COUNT; i = i + 1)
        memory[i] = 32'hcafef00d;
end
`endif


endmodule
