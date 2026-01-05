`timescale 1ns / 1ps

module uart_top (
    input clk,
    input rst,
    input wr_en,
    input [7:0] data_in,
    input rdy_clr,
    input rx,           
    output tx,          
    output rdy,
    output busy,
    output [7:0] data_out
);

    wire rx_clk_en; 
    wire tx_clk_en; 

    wire rx_wire = rx; 

    // 1. Baud Rate Generator Instance
    baud_rate_genrator bg (
        .clock(clk),
        .reset(rst),
        .enb_tx(tx_clk_en),
        .enb_rx(rx_clk_en)
    );

    // 2. UART Sender (Transmitter) Instance
    uart_sender us (
        .clk(clk),
        .wr_en(wr_en),
        .enb(tx_clk_en),
        .rst(rst),
        .data_in(data_in),
        .tx(tx),         
        .tx_busy(busy)
    );

    // 3. UART Receiver Instance
    uart_reciever ur (
        .clk(clk),
        .rst(rst),
        .rx(rx_wire),    
        .rdy_clr(rdy_clr),
        .clken(rx_clk_en),
        .rdy(rdy),
        .data_out(data_out)
    );

endmodule
