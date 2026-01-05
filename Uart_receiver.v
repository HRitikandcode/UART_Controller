module uart_reciever(
    input clk, rst, rx, rdy_clr, clken,
    output reg rdy,
    output reg [7:0] data_out
);

    parameter RX_STATE_START    = 2'b00;
    parameter RX_STATE_DATA     = 2'b01;
    parameter RX_STATE_STOP     = 2'b10;

    reg [1:0] state;
    reg [3:0] sample;
    reg [3:0] index;
    reg [7:0] temp;

    always @(posedge clk) begin
        if (rst) begin
            state    <= RX_STATE_START;
            sample   <= 0;
            index    <= 0;
            rdy      <= 0;
            data_out <= 0;
            temp     <= 0;
        end else begin
            if (rdy_clr) rdy <= 0;

            if (clken) begin
                case (state)
                    RX_STATE_START: begin
                        if (!rx || sample != 0)
                            sample <= sample + 1;
                        
                        // Noise filtering: check middle of start bit 
                        if (sample == 7 && rx == 1) begin
                            sample <= 0; 
                        end

                        if (sample == 15) begin
                            state  <= RX_STATE_DATA;
                            sample <= 0;
                            index  <= 0;
                        end
                    end

                    RX_STATE_DATA: begin
                        sample <= sample + 1;
                        if (sample == 7) begin 
                            temp[index] <= rx;
                        end
                        if (sample == 15) begin
                            sample <= 0;
                            if (index == 7)
                                state <= RX_STATE_STOP;
                            else
                                index <= index + 1;
                        end
                    end

                    RX_STATE_STOP: begin
                        sample <= sample + 1;
                        if (sample == 15) begin
                            state    <= RX_STATE_START;
                            data_out <= temp;
                            rdy      <= 1;
                            sample   <= 0;
                        end
                    end
                    
                    default: state <= RX_STATE_START;
                endcase
            end
        end
    end
endmodule