module keyscan(
    input clk,
    input reset,
    input start,
    output reg R1,
    output reg R2,
    output reg R3,
    output reg R4,
    input C1,
    input C2,
    input C3,
    input C4,
    output reg pressed,
    output reg [7:0] result
);
wire resetn;
reg [3:0] result_int;
assign resetn = ~reset;
reg [18:0] cnt;
always @(*) begin
    case(result_int)
        0: result = 8'h31;
        1: result = 8'h32; 
        2: result = 8'h33; 
        3: result = 8'h2b; 
        4: result = 8'h34; 
        5: result = 8'h35; 
        6: result = 8'h36; 
        7: result = 8'h2d; 
        8: result = 8'h37; 
        9: result = 8'h38; 
        10: result = 8'h39; 
        11: result = 8'h2a; 
        12: result = 8'h2e; 
        13: result = 8'h30; 
        14: result = 8'h3d; 
        15: result = 8'h2f; 
    endcase
end
always @(posedge clk or negedge resetn) begin
    if (~resetn) begin
        cnt <= 0;
    end else if (start == 1) begin
        cnt <= cnt + 1;
    end else if (cnt == 480000) begin
        cnt <= 1;
    end else if (cnt > 0 && pressed == 0) begin
        cnt <= cnt + 1;
    end else if (pressed == 1) begin
        cnt <= 0;
    end
end




always @(posedge clk or negedge resetn) begin
    if (~resetn) begin
        R1 <= 0;
    end else if (cnt == 1) begin
        R1 <= 1;
    end else if (cnt == 120000 || start == 1) begin
        R1 <= 0;
    end
end

always @(posedge clk or negedge resetn) begin
    if (~resetn) begin
        R2 <= 0;
    end else if (cnt == 120001) begin
        R2 <= 1;
    end else if (cnt == 240000 || start == 1) begin
        R2 <= 0;
    end
end

always @(posedge clk or negedge resetn) begin
    if (~resetn) begin
        R3 <= 0;
    end else if (cnt == 240001) begin
        R3 <= 1;
    end else if (cnt == 360000 || start == 1) begin
        R3 <= 0;
    end
end

always @(posedge clk or negedge resetn) begin
    if (~resetn) begin
        R4 <= 0;
    end else if (cnt == 360001) begin
        R4 <= 1;
    end else if (cnt == 480000 || start == 1) begin
        R4 <= 0;
    end
end

always @(posedge clk or negedge resetn) begin
    if (~resetn) begin
        result_int <= 0;
    end else if (cnt > 100 && cnt < 120000) begin
        if (C1 == 1) begin
            result_int <= 0;
        end else if (C2 == 1) begin
            result_int <= 1;
        end else if (C3 == 1) begin
            result_int <= 2;
        end else if (C4 == 1) begin
            result_int <= 3;
        end
    end else if (cnt > 120100 && cnt < 240000) begin
        if (C1 == 1) begin
            result_int <= 4;
        end else if (C2 == 1) begin
            result_int <= 5;
        end else if (C3 == 1) begin
            result_int <= 6;
        end else if (C4 == 1) begin
            result_int <= 7;
        end
    end else if (cnt > 240100 && cnt < 360000) begin
        if (C1 == 1) begin
            result_int <= 8;
        end else if (C2 == 1) begin
            result_int <= 9;
        end else if (C3 == 1) begin
            result_int <= 10;
        end else if (C4 == 1) begin
            result_int <= 11;
        end
    end else if (cnt > 360100 && cnt < 480000) begin
        if (C1 == 1) begin
            result_int <= 12;
        end else if (C2 == 1) begin
            result_int <= 13;
        end else if (C3 == 1) begin
            result_int <= 14;
        end else if (C4 == 1) begin
            result_int <= 15;
        end
    end
end

always @(posedge clk or negedge resetn)begin
    if (~resetn) begin
        pressed <= 0;
    end else if ((cnt > 100 && cnt < 120000) 
    || (cnt > 120100 && cnt < 240000) 
    || (cnt > 240100 && cnt < 360000) 
    || (cnt > 360100 && cnt < 480000)) begin
        if (C1 == 1 || C2 == 1 || C3 == 1 || C4 == 1) begin
            pressed <= 1;
        end
    end else if (start == 1) begin
        pressed <= 0;
    end
end
endmodule
