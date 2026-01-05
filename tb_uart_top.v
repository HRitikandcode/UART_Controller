`timescale 1ns/1ps

module uart_tb();
    reg clk;
    reg rst;
    reg wr_en;
    reg [7:0] data_in;
    reg rdy_clr;
    wire rx;
    wire tx;
    wire rdy;
    wire busy;
    wire [7:0] data_out;

    // Instantiate the Top Module
    uart_top uut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .data_in(data_in),
        .rdy_clr(rdy_clr),
        .rx(rx),
        .tx(tx),
        .rdy(rdy),
        .busy(busy),
        .data_out(data_out)
    );

    // External Loopback: Connect TX to RX
    assign rx = tx;

    // 1. Clock Generation: 100MHz (10ns period)
    always #5 clk = ~clk;

    // 2. Stimulus Process
    initial begin
        clk = 0;
        rst = 1;
        wr_en = 0;
        data_in = 8'h00;
        rdy_clr = 0;

        // Apply Reset
        #20 rst = 0;
        #20;

        // Test Case 1: Send 0xAB (10101011)
        wait(!busy);            // Ensure TX is not busy
        @(posedge clk);
        data_in = 8'hAB;
        wr_en = 1;              // Pulse Write Enable
        @(posedge clk);
        wr_en = 0;
        
        $display("Time: %t | Sent Data: %h", $time, data_in);

        // Wait for Receiver to finish (rdy goes high)
        wait(rdy);
        #10;
        if (data_out == 8'hAB)
            $display("Time: %t | SUCCESS: Received Correct Data: %h", $time, data_out);
        else
            $display("Time: %t | ERROR: Received: %h, Expected: AB", $time, data_out);

        // Clear Ready flag
        @(posedge clk);
        rdy_clr = 1;
        @(posedge clk);
        rdy_clr = 0;

        // Test Case 2: Send 0x55 (01010101)
        #1000; // Small gap between frames
        wait(!busy);
        @(posedge clk);
        data_in = 8'h55;
        wr_en = 1;
        @(posedge clk);
        wr_en = 0;
        $display("Time: %t | Sent Data: %h", $time, data_in);

        wait(rdy);
        #10;
        if (data_out == 8'h55)
            $display("Time: %t | SUCCESS: Received Correct Data: %h", $time, data_out);
        else
            $display("Time: %t | ERROR: Received: %h", $time, data_out);

        #100;
        $display("Simulation Finished");
        $stop;
    end

endmodule