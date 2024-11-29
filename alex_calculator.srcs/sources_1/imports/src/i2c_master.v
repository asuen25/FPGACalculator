module i2c_master(
    input clk,
    input resetn,
    input start,
    input [7:0] data,
    output reg done,
    output reg sda,
    output reg scl
);
reg [6:0] cnt;
reg [4:0] bitcnt;
wire [7:0] address = 8'h4e;
always @(posedge clk or negedge resetn) begin
    if (~resetn) begin
        cnt <= 0;
    end
    else if (cnt == 119) begin
        cnt <= 0;
    end
    else if (cnt == 0 && (start == 1 || bitcnt > 0)) begin
        cnt <= 1;
    end
    else if (cnt > 0) begin
        cnt <= cnt + 1;
    end
end

always @(posedge clk or negedge resetn) begin
    if (~resetn) begin
        bitcnt <= 0;
    end
    else if (cnt == 119 && bitcnt < 19) begin
        bitcnt <= bitcnt + 1;
    end
    else if (cnt == 119 && bitcnt == 19) begin
        bitcnt <= 0;
    end
end


always @(posedge clk or negedge resetn) begin
    if (~resetn) begin
        sda <= 0;
    end
    else if (bitcnt == 19) begin
        if (cnt >= 0 && cnt <= 79) begin
            sda <= 0;
        end
        else if (cnt >= 80 && cnt <= 119) begin
            sda <= 1;
        end
    end
    else if (bitcnt >= 1 && bitcnt <= 8) begin
        sda = address[8-bitcnt];
    end
    else if (bitcnt >= 10 && bitcnt <= 17) begin
        sda <= data[17-bitcnt];
    end
    else if (bitcnt == 9 || bitcnt == 18) begin
        sda <= 1;
    end 
    else if (bitcnt == 0) begin
        if (cnt >= 0 && cnt <= 39) begin
            sda <= 1;
        end
        else if (cnt >= 40) begin
            sda <= 0;
        end
    end
end

always @(posedge clk or negedge resetn) begin
    if (~resetn) begin
        scl <= 0;
    end
    else if (bitcnt == 0) begin
        if (cnt >= 0 && cnt <= 79) begin
            scl <= 1;
        end
        else if (cnt >= 80) begin
            scl <= 0;
        end
    end
    else if (bitcnt >= 1 && bitcnt <= 18) begin
        if ((cnt >= 0 && cnt <= 39) || (cnt >= 80 && cnt <= 119)) begin
            scl <= 0;
        end
        else begin
            scl <= 1;
        end
    end
    else if (bitcnt == 19) begin
        if (cnt >= 0 && cnt <= 39) begin
            scl <= 0;
        end
        else if (cnt >= 40 && cnt <= 119) begin
            scl <= 1;
        end
    end
end

always @(posedge clk or negedge resetn) begin
    if (~resetn) begin
        done <= 0;
    end
    else if (start == 1) begin
        done <= 0;
    end
    else if (bitcnt == 19 && cnt == 119) begin
        done <= 1;
    end
end

endmodule