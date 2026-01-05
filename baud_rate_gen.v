`timescale 1ns/1ps

module baud_rate_genrator(
    input clock,
    input reset,
    output reg enb_tx,
    output reg enb_rx
);
    parameter clk_freq = 100000000; 
    parameter baud_rate = 9600; 

    // Use localparam for internal constants
    localparam divisor_tx = clk_freq / baud_rate;
    localparam divisor_rx = clk_freq / (16 * baud_rate);

    reg [15:0] counter_tx; 
    reg [15:0] counter_rx; 

    // SENDER CLOCK GENERATION LOGIC
    always @(posedge clock) begin    
        if (reset) begin
            counter_tx <= 0;
            enb_tx     <= 0;
        end else if (counter_tx == divisor_tx - 1) begin
            enb_tx     <= 1;
            counter_tx <= 0;
        end else begin
            counter_tx <= counter_tx + 1'b1;
            enb_tx     <= 0;
        end
    end
     
    // RECEIVER CLOCK GENERATION LOGIC
    always @(posedge clock) begin          
        if (reset) begin
            counter_rx <= 0;
            enb_rx     <= 0;
        end else if (counter_rx == divisor_rx - 1) begin
            counter_rx <= 0;
            enb_rx     <= 1;
        end else begin
            counter_rx <= counter_rx + 1'b1;
            enb_rx     <= 0;
        end
    end
        
endmodule