`include "defs.vh"

module top
  (
   input        CLK_I,
   input        RESET_I,
   input        RX_I,
   output       TX_O,

   input [7:0]  PORT_I,
   output [7:0] PORT_O,
   output [7:0] DIR_O
   );


   // reset generation
   wire         rst;
   wire         rst_n;
   rstgen rstgen0
     (
      .CLK_I(CLK_I),
      .RESET_I(RESET_I),
      .RESET_O(rst),
      .RESET_N_O(rst_n)
      );

   // the CPU
   wire [31:0] cpu_adr_o, cpu_data_o, cpu_data_i;
   wire [2:0]  cpu_burst_o, cpu_size_o;
   wire [3:0]  cpu_prot_o;
   wire [1:0]  cpu_trans_o;
   wire        cpu_ready_i, cpu_resp_i;
   wire        cpu_write_o;

   wire        cpu_nmi_i = 0;
   wire [15:0] cpu_irq_i = {15'b0, uart_irq };

   wire        cpu_rxev_i = 0;
   wire        cpu_txev_o;
   wire        cpu_lockup_o, cpu_rst_req_o, cpu_sleeping_o;

   // the cpu
   CORTEXM0DS u_cortexm0ds
     (
      .HCLK(CLK_I),
      .HRESETn(rst_n),
      .HADDR(cpu_adr_o),
      .HBURST(cpu_burst_o),
      .HMASTLOCK(),
      .HPROT(cpu_prot_o),
      .HSIZE(cpu_size_o),
      .HTRANS(cpu_trans_o),
      .HWDATA(cpu_data_o),
      .HWRITE(cpu_write_o),
      .HRDATA(cpu_data_i),
      .HREADY(cpu_ready_i),
      .HRESP(cpu_resp_i),
      .NMI(cpu_nmi_i),
      .IRQ(cpu_irq_i),
      .TXEV(cpu_txev_o),
      .RXEV(cpu_rxev_i),
      .LOCKUP(cpu_lockup_o),
      .SYSRESETREQ(cpu_rst_req_o),
      .SLEEPING(cpu_sleeping_o)
      );


   // bus address encoder
   reg [2:0]   adrsel;
   always @(*) begin
     casez(cpu_adr_o[31:12])
       20'h0000?: adrsel = 3'd1; // ROM
       20'h0001?: adrsel = 3'd2; // RAM
       20'ha0000: adrsel = 3'd3; // UART
       20'ha0001: adrsel = 3'd4; // ctrl
       20'ha0002: adrsel = 3'd5; // gpio
       20'ha0003: adrsel = 3'd6; // ???
       20'ha0004: adrsel = 3'd7; // ???
       default: adrsel = 3'd0;
     endcase
   end

   // AHB mux
   wire [7:1] ahb_sel;
   ahb_mux ahb_mux0
     (
      .HCLK_I(CLK_I),
      .HRESET_N_I(rst_n),

      // master signals
      .M_SEL_I(adrsel),
      .M_HTRANS_I(cpu_trans_o),
      .M_HREADY_I(cpu_ready_i),

      .M_HREADY_O(cpu_ready_i),
      .M_HRESP_O(cpu_resp_i),
      .M_HRDATA_O(cpu_data_i),

      // slave signals
      .S_SEL_O(ahb_sel),
      .S_HREADY_I( {2'b00, gpio_ready, ctrl_ready, uart_ready, ram_ready, rom_ready }),
      .S_HRESP_I( {2'b00, gpio_resp, ctrl_resp, uart_resp, ram_resp, rom_resp }),
      .S1_HRDATA_I(rom_data_o),
      .S2_HRDATA_I(ram_data_o),
      .S3_HRDATA_I(uart_data_o),
      .S4_HRDATA_I(ctrl_data_o),
      .S5_HRDATA_I(gpio_data_o),
      .S6_HRDATA_I(0),
      .S7_HRDATA_I(0)
      );

   // ROM
   wire [31:0]    rom_data_o;
   wire           rom_ready;
   wire           rom_resp;

   rom #( .AWIDTH(12) ) rom0
     (
      .HCLK_I(CLK_I),
      .HRESET_N_I(rst_n),
      .HSEL_I(ahb_sel[1]),
      .HADDR_I(cpu_adr_o[11:0]),
      .HWDATA_O(rom_data_o),
      .HRESP_O(rom_resp),
      .HREADY_O(rom_ready),
      .HREADY_I(cpu_ready_i)
      );

   // RAM
   wire [31:0]    ram_data_o;
   wire           ram_resp;
   wire           ram_ready;
   ram #(.AWIDTH(12) ) ram0
     (
      .HCLK_I(CLK_I),
      .HRESET_N_I(rst_n),

      .HSEL_I(ahb_sel[2]),
      .HSIZE_I(cpu_size_o),
      .HWRITE_I(cpu_write_o),
      .HADDR_I(cpu_adr_o[11:0]),
      .HRDATA_I(cpu_data_o),
      .HWDATA_O(ram_data_o),
      .HRESP_O(ram_resp),
      .HREADY_O(ram_ready),
      .HREADY_I(cpu_ready_i)
      );


   // UART
   wire [31:0]    uart_data_o;
   wire           uart_resp;
   wire           uart_ready;
   wire           uart_irq;
   ahb_uart ahb_uart0
     (
      .HCLK_I(CLK_I),
      .HRESET_N_I(rst_n),
      .RX_I(RX_I),
      .TX_O(TX_O),
      .IRQ_O(uart_irq),
      .HSEL_I(ahb_sel[3]),
      .HSIZE_I(cpu_size_o),
      .HWRITE_I(cpu_write_o),
      .HADDR_I(cpu_adr_o[11:0]),
      .HRDATA_I(cpu_data_o),
      .HWDATA_O(uart_data_o),
      .HRESP_O(uart_resp),
      .HREADY_O(uart_ready),
      .HREADY_I(cpu_ready_i)
      );



   // CTRL
   wire [31:0]    ctrl_data_o;
   wire           ctrl_resp;
   wire           ctrl_ready;

   ahb_ctrl ahb_ctrl0
     (
      .HCLK_I(CLK_I),
      .HRESET_N_I(rst_n),

      .HSEL_I(ahb_sel[4]),
      .HSIZE_I(cpu_size_o),
      .HWRITE_I(cpu_write_o),
      .HADDR_I(cpu_adr_o[11:0]),
      .HRDATA_I(cpu_data_o),
      .HWDATA_O(ctrl_data_o),
      .HRESP_O(ctrl_resp),
      .HREADY_O(ctrl_ready),
      .HREADY_I(cpu_ready_i)
      );


   // GPIO
   wire [31:0]    gpio_data_o;
   wire           gpio_resp;
   wire           gpio_ready;

   ahb_gpio ahb_gpio0
     (
      .HCLK_I(CLK_I),
      .HRESET_N_I(rst_n),

      .PORT_I(PORT_I),
      .PORT_O(PORT_O),
      .DIR_O(DIR_O),

      .HSEL_I(ahb_sel[5]),
      .HSIZE_I(cpu_size_o),
      .HWRITE_I(cpu_write_o),
      .HADDR_I(cpu_adr_o[11:0]),
      .HRDATA_I(cpu_data_o),
      .HWDATA_O(gpio_data_o),
      .HRESP_O(gpio_resp),
      .HREADY_O(gpio_ready),
      .HREADY_I(cpu_ready_i)
      );
endmodule
