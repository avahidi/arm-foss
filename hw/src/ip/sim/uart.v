
`ifndef SYNTHESIS

module uart(
    input CLK_I,
    input RST_I,
    input [11:0] ADR_I,
    input [31:0] DATA_I,
    input WRITE_I,
    output READY_O
);


// input registers
reg [11:0] adr_i_d;
reg write_i_d;


always @(posedge CLK_I)
    adr_i_d <= ADR_I;

assign READY_O = write_i_d;
assign DATA_O = 16'h0000;

always @(posedge CLK_I or negedge RST_I)
    if(RST_I)
        write_i_d <= 0;
    else
        write_i_d <= WRITE_I;

always @(posedge CLK_I) begin
    if(write_i_d) begin
        case(adr_i_d)
            16'h000: $write("%c", DATA_I[7:0]);
        endcase
    end
end

endmodule

`endif
