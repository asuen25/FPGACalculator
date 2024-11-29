module lcdpluse(
    input clk,
    input resetn,
    input [7:0] data,
    input start,
    output sdao,
    output sclo,
    output reg done
); 
reg [3:0] state;
wire i2c_done;
reg [16:0] cnt;
wire i2c_start;
wire [7:0] i2c_data;
localparam IDLE = 0;
localparam DATA_START = 1;
localparam DATA_WAIT = 2;
localparam DATA_DELAY_START = 3;
localparam DATA_DELAY_WAIT = 4;
localparam ENABLE_START = 5;
localparam ENABLE_WAIT = 6;
localparam ENABLE_DELAY_START = 7;
localparam ENABLE_DELAY_WAIT = 8;
localparam DISABLE_START = 9;
localparam DISABLE_WAIT = 10;
localparam DISABLE_DELAY_START = 11;
localparam DISABLE_DELAY_WAIT = 12;
i2c_master i2c_master(.clk(clk), .resetn(resetn), .start(i2c_start), 
.data(i2c_data), .done(i2c_done), .sda(sdao), .scl(sclo));

always @(posedge clk or negedge resetn) begin
    if (~resetn) begin
        state <= IDLE;
        cnt <= 0;
        done <= 0;
    end
    else begin
        case (state)
            IDLE: begin
                done <= 0;
                if (start) begin
                    state <= DATA_START;
                end
            end
            DATA_START: begin
                state <= DATA_WAIT;
            end
            DATA_WAIT: begin
                if (i2c_done) begin
                    state <= DATA_DELAY_START;
                end
            end
            DATA_DELAY_START: begin
                state <= DATA_DELAY_WAIT;
            end
            DATA_DELAY_WAIT: begin
                if (cnt == 62499) begin
                    state <= ENABLE_START;
                    cnt <= 0;
                end else begin
                    cnt <= cnt + 1;    
                end
            end
            ENABLE_START: begin
                state <= ENABLE_WAIT;
            end
            ENABLE_WAIT: begin
                if (i2c_done) begin
                    state <= ENABLE_DELAY_START;
                end
            end
            ENABLE_DELAY_START: begin
                state <= ENABLE_DELAY_WAIT;
            end
            ENABLE_DELAY_WAIT: begin
                if (cnt == 62499) begin
                    state <= DISABLE_START;
                    cnt <= 0;
                end else begin
                    cnt <= cnt + 1;    
                end
            end
            DISABLE_START: begin
                state <= DISABLE_WAIT;
            end
            DISABLE_WAIT: begin
                if (i2c_done) begin
                    state <= DISABLE_DELAY_WAIT;
                end
            end
            DISABLE_DELAY_WAIT: begin
                state <= DISABLE_DELAY_START;
            end
            DISABLE_DELAY_START: begin
                if (cnt == 124999) begin
                    state <= IDLE;
                    done <= 1;
                    cnt <= 0;
                end else begin
                    cnt <= cnt + 1;    
                end
            end
        endcase
    end
end

assign i2c_start = (state == DATA_START || state == ENABLE_START || state == DISABLE_START);

assign i2c_data = (state == DATA_START || state == DATA_WAIT) ? data:
                    (state == ENABLE_START || state == ENABLE_WAIT) ? data | 8'h04:
                    (state == DISABLE_START || state == DISABLE_WAIT) ? data: 0; 











endmodule