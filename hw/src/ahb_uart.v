
`default_nettype none

/*
 * AHB wrapper for our UART that also implements interrupts
 */
module ahb_uart
(
 input             HCLK_I,
 input             HRESET_N_I,

 input             RX_I,
 output            TX_O,
 output            IRQ_O,

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

   localparam REG_DATA = 2'b00;
   localparam REG_CTRL = 2'b01;
   localparam REG_STATUS = 2'b10;
   localparam REG_CLOCK = 2'b11;

   // interrupt signal
   assign IRQ_O = (status_rx_valid & ctrl_irq_rx) |
                  (status_rx_error & ctrl_irq_error) |
                  (ctrl_irq_tx & ~uart_tx_busy);

   // the uart itself
   reg [10:0]      uart_add;
   wire            uart_rx_valid;
   wire            uart_rx_error;
   wire [7:0]      uart_rx_data;
   wire            uart_tx_busy;
   reg             uart_tx_valid;
   reg [7:0]       uart_tx_data;

   uart uart0
     (
      .CLK_I(HCLK_I),
      .RESET_N_I(HRESET_N_I),
      .RX_I(RX_I),
      .TX_O(TX_O),
      .ADD_I(uart_add),
      .RX_DATA_O(uart_rx_data),
      .RX_VALID_O(uart_rx_valid),
      .RX_ERROR_O(uart_rx_error),
      .TX_BUSY_O(uart_tx_busy),
      .TX_DATA_I(uart_tx_data),
      .TX_VALID_I(uart_tx_valid)
      );



   // AHB interface and uart registers
   assign HRESP_O = 0;
   assign HREADY_O = enable_d;

   // enabled?
   wire        enable = HSEL_I;
   reg         enable_d;
   always @(posedge HCLK_I)
     if(!HRESET_N_I)
       enable_d <= 0;
     else
       enable_d <= enable;


   // input registers
   wire [1:0]  adr = HADDR_I[3:2];
   reg [1:0]   adr_d;
   reg         write_d;
   always @(posedge HCLK_I) begin
     adr_d <= adr;
     write_d <= HWRITE_I;
   end




   // register I/O
   reg status_rx_valid, status_rx_error;
   reg ctrl_irq_error, ctrl_irq_rx, ctrl_irq_tx;
   reg [7:0] saved_rx_data;


   // read output update
   always @(posedge HCLK_I)
     if(enable & !HWRITE_I) begin
       case(adr)
         REG_DATA: HWDATA_O <= { 24'd0, saved_rx_data };
         REG_STATUS: HWDATA_O <= { 29'd0,  uart_tx_busy,
                                   status_rx_valid, status_rx_error };
         REG_CTRL : HWDATA_O <= { 29'd0, ctrl_irq_tx, ctrl_irq_rx, ctrl_irq_error};
         REG_CLOCK: HWDATA_O <= { 21'd0, uart_add };
         default: HWDATA_O <= 32'dx;
       endcase // case (adr_d)
     end



   always @(posedge HCLK_I /* , negedge HRESET_N_I */) begin
     if(!HRESET_N_I) begin
       uart_add <= 11'd629;
       status_rx_valid <= 0;
       status_rx_error <= 0;

       ctrl_irq_error <= 0;
       ctrl_irq_rx <= 0;
       ctrl_irq_tx <= 0;

       uart_tx_valid <= 0;
       saved_rx_data <= 0;
       uart_tx_data <= 0;
     end else begin
       uart_tx_valid <= 0;

       // write data and register update
       if (enable_d & write_d) begin
         case(adr_d)

           REG_DATA:
             if(!uart_tx_busy) begin
               uart_tx_data <= HRDATA_I[7:0];
               uart_tx_valid <= 1;
             end

           REG_CTRL:  begin
             ctrl_irq_error <= HRDATA_I[0];
             ctrl_irq_rx <= HRDATA_I[1];
             ctrl_irq_tx <= HRDATA_I[2];
           end

           REG_CLOCK:
             uart_add = HRDATA_I[10:0];

           REG_STATUS: begin
             status_rx_error = status_rx_error & ~HRDATA_I[0];
           end
         endcase
       end

       // read flag updates
       if(enable & !HWRITE_I) begin
         case(adr_d)
           REG_DATA:
             status_rx_valid <= 0;
         endcase
       end

       if(uart_rx_error)
         status_rx_error <= 1;

       if(uart_rx_valid & !status_rx_valid) begin
         status_rx_valid <= 1;
         saved_rx_data <= uart_rx_data;
       end

     end // else: !if(!HRESET_N_I)
   end

endmodule
