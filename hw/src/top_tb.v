
module top_tb();

// clock and reset
reg tb_clk, tb_rst_n;
wire tb_rst = ~tb_rst_n;



// the CPU
wire [31:0] cpu_adr_o, cpu_data_o, cpu_data_i;
wire [2:0] cpu_burst_o, cpu_size_o;
wire [3:0] cpu_prot_o;
wire [1:0] cpu_trans_o;
wire cpu_ready_i, cpu_resp_i;
wire cpu_write_o;

wire cpu_nmi_i = 0;
wire [15:0] cpu_irq_i = 0;

wire cpu_rxev_i = 0;
wire cpu_txev_o;
wire cpu_lockup_o, cpu_rst_req_o, cpu_sleeping_o;

// the cpu
CORTEXM0DS u_cortexm0ds (
    .HCLK (tb_clk),
    .HRESETn (tb_rst_n),
    .HADDR (cpu_adr_o),
    .HBURST (cpu_burst_o),
    .HMASTLOCK (),
    .HPROT (cpu_prot_o),
    .HSIZE (cpu_size_o),
    .HTRANS (cpu_trans_o),
    .HWDATA (cpu_data_o),
    .HWRITE (cpu_write_o),
    .HRDATA (cpu_data_i),
    .HREADY (cpu_ready_i),
    .HRESP (cpu_resp_i),
    .NMI(cpu_nmi_i),
    .IRQ(cpu_irq_i),
    .TXEV (cpu_txev_o),
    .RXEV (cpu_rxev_i),
    .LOCKUP(cpu_lockup_o),
    .SYSRESETREQ (cpu_rst_req_o),
    .SLEEPING(cpu_sleeping_o)
);

// bus decoder
wire select_rom = (cpu_adr_o[31:16] == 16'h0000);
wire select_ram = (cpu_adr_o[31:16] == 16'h0001);
wire select_uart = (cpu_adr_o[31:16] == 16'h4000);
wire select_sim = (cpu_adr_o[31:16] == 16'h4001);

reg select_rom_d, select_ram_d, select_uart_d, select_sim_d;
always @(posedge tb_clk) begin
    select_rom_d <= select_rom;
    select_ram_d <= select_ram;
    select_uart_d <= select_uart;
    select_sim_d <= select_sim;
end


// program ROM
wire rom_enable_i = select_rom & !cpu_write_o;
wire [31:0] rom_data_o;
wire rom_ready_o;

rom #( .FILENAME("rom.bin"), .AWIDTH(16) ) rom0
(
    .CLK_I(tb_clk),
    .RST_I(tb_rst),
    .ENABLE_I(rom_enable_i),
    .ADR_I(cpu_adr_o[15:0]),
    .DATA_O(rom_data_o),
    .READY_O(rom_ready_o)
);

// RAM
wire [1:0] ram_size_i = cpu_size_o[1:0];
wire ram_write_i = cpu_write_o;
wire ram_enable_i = select_ram;
wire [31:0] ram_data_o;
wire ram_ready_o;

ram #(.AWIDTH(16) ) ram0 (
    .CLK_I(tb_clk),
    .RST_I(tb_rst),
    .ENABLE_I(ram_enable_i),
    .ADR_I(cpu_adr_o[15:0]),
    .DATA_I(cpu_data_o),
    .DATA_O(ram_data_o),
    .SIZE_I(ram_size_i),
    .WRITE_I(ram_write_i),
    .READY_O(ram_ready_o)
);


// sim
wire sim_write_i = select_sim & cpu_write_o;
wire sim_ready_o;
sim sim0 (
    .CLK_I(tb_clk),
    .RST_I(tb_rst),
    .ADR_I(cpu_adr_o[11:0]),
    .DATA_I(cpu_data_o),
    .WRITE_I(sim_write_i),
    .READY_O(sim_ready_o)
);

// uart
wire uart_write_i = select_uart & cpu_write_o;
wire uart_ready_o;
uart uart0 (
    .CLK_I(tb_clk),
    .RST_I(tb_rst),
    .ADR_I(cpu_adr_o[11:0]),
    .DATA_I(cpu_data_o),
    .WRITE_I(uart_write_i),
    .READY_O(uart_ready_o)
);


// mux CPU
assign cpu_ready_i = rom_ready_o | ram_ready_o | uart_ready_o | sim_ready_o;
assign cpu_resp_i = 0;
assign cpu_data_i = // this only works for single cycles r/w
    (select_rom_d ? rom_data_o : 0) |
    (select_ram_d ? ram_data_o : 0) |
    0;


// clock and reset
initial begin
  #0 tb_clk = 0;
  #0 tb_rst_n = 0;
  #30 tb_rst_n = 1;
end

always @(tb_clk)
  #5 tb_clk <= ~tb_clk;

// simulation
initial begin
    $dumpfile("waveform.vcd");
    $dumpvars;

    // this will stop simulation at some point
    #80000 $finish(0);
end


// kill simulation when CPU dies
always @(tb_clk)
    if(cpu_lockup_o) begin
        $write("Existing due to cpu lockup\n");
        # 100 $finish(20);
    end

endmodule
