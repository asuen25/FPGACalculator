module calculator(
    input gclk, 
    input [1:0] btn,
    output [1:0] led,
    output pio01,

    input pio41,
    input pio42,
    input pio43,
    input pio40,
    output pio47,
    output pio46,
    output pio45,
    output pio44,
    output pio48
);

wire sdao;
wire sclo;
wire done;
reg [15:0] a;
reg [15:0] b;
reg [7:0] opi;
wire start;
wire keystart;
wire keypress;
reg [2:0] equation_state;
wire [7:0] keyresult;
reg [7:0] data;
reg [3:0] state;
reg [4:0] commandcnt;
reg [21:0] cnt;
reg [15:0] divisor;
reg [15:0] number;
reg [3:0] digit; 
reg first_marker;
reg [15:0] result;
localparam IDLE = 0;
localparam LCD_START = 1;
localparam LCD_WAIT = 2;
localparam KEY_BLANK = 3;
localparam KEY_START = 4;
localparam KEY_WAIT = 5;
localparam ROW2SETUP = 6;
localparam ROW2LOOP = 7;
localparam ROW1SETUP = 8;
localparam ROW1LOOP = 9;
assign pio01 = sdao ? 1'hz : 1'h0;
assign pio48 = sclo ? 1'hz : 1'h0;
assign led[1] = btn[1];


lcdpluse lcdpluse(.clk(gclk), .resetn(~btn[0]), .start(start), 
.data(data), .done(done), .sdao(sdao), .sclo(sclo)); 

assign start = (state == LCD_START);
assign keystart = (state == KEY_START);
always @(posedge gclk or posedge btn[0]) begin
    if (btn[0]) begin
        state <= IDLE;
        commandcnt <= 0;
        cnt <= 0;
        equation_state <= 0;
        result <= 0;
        a <= 0;
        b <= 0;
        first_marker <= 0;
        divisor <= 0;
        number <= 0;
        digit <= 0;
        opi <= 0;
    end else begin
        case (state)
            IDLE: begin
                state <= LCD_START;
                commandcnt <= 0;
                cnt <= 0;
                equation_state <= 0;
                result <= 0;
                a <= 0;
                b <= 0;
                first_marker <= 0;
                divisor <= 0;
                number <= 0;
                digit <= 0;
                opi <= 0;
            end
            LCD_START: begin
                state <= LCD_WAIT;
            end 
            LCD_WAIT: begin
                if (done == 1) begin
                    if (equation_state == 0) begin
                        if (commandcnt == 17 || commandcnt == 15) begin
                            state <= KEY_BLANK;
                        end else begin
                            commandcnt <= commandcnt + 1;
                            state <= LCD_START;
                        end
                    end else if (equation_state == 1) begin
                        if (commandcnt == 17) begin
                            state <= KEY_BLANK;
                        end else begin
                            state <= LCD_START;
                            commandcnt <= commandcnt + 1;
                        end
                    end else if (equation_state == 2) begin
                        if (commandcnt == 21) begin
                            state <= ROW2SETUP;
                        end else begin
                            commandcnt <= commandcnt + 1;
                            state <= LCD_START;
                        end
                    end else if (equation_state == 3) begin
                        if (commandcnt == 25 || commandcnt == 23) begin
                            state <= ROW2LOOP;
                        end else begin
                            commandcnt <= commandcnt + 1;
                            state <= LCD_START;
                        end
                    end else if (equation_state == 4) begin
                        if (commandcnt == 29) begin
                            state <= ROW1SETUP;
                        end else begin
                            state <= LCD_START;
                            commandcnt <= commandcnt + 1;
                        end
                    end else if (equation_state == 5) begin
                        if (commandcnt == 31) begin
                            state <= ROW1LOOP;
                        end else begin
                            state <= LCD_START;
                            commandcnt = commandcnt + 1;
                        end
                    end
                end
            end
            KEY_BLANK: begin
                if (cnt == 3599999) begin
                    state <= KEY_START;
                    cnt <= 0;
                end else begin
                    cnt <= cnt + 1;
                end
            end
            KEY_START: begin
                state <= KEY_WAIT;
            end
            KEY_WAIT: begin
                if (keypress == 1) begin
                    if (equation_state == 0) begin
                        if (keyresult >= 8'h31 && keyresult <= 8'h39) begin
                            a <= a*10 + keyresult[3:0];
                            commandcnt <= 16;
                            state <= LCD_START;
                        end else if (keyresult == 8'h3d || keyresult == 8'h2e || keyresult == 8'h2f) begin
                            state <= IDLE;
                        end else begin
                            commandcnt <= 16;
                            opi <= keyresult;
                            state <= LCD_START;
                            equation_state <= 1;
                        end
                    end else if (equation_state == 1) begin
                        if (keyresult >= 8'h31 && keyresult <= 8'h39) begin
                            b <= b*10 + keyresult[3:0];
                            commandcnt <= 16;
                            state <= LCD_START;
                        end else if (keyresult == 8'h3d) begin
                            case (opi)
                                8'h2b: result <= a + b;
                                8'h2d: result <= a - b;
                                8'h2a: result <= a * b;
                                default: result <= a + b;
                            endcase 
                            state <= LCD_START;
                            equation_state <= 2;
                            commandcnt <= 18;
                        end else begin
                            state <= IDLE;
                        end
                    end
                end
            end
            ROW2SETUP: begin
                divisor <= 10000;
                number <= result;
                first_marker <= 0;
                state <= ROW2LOOP;
                equation_state <= 3;
            end
            ROW2LOOP: begin
                if (divisor != 0) begin
                    if (divisor <= number) begin
                        digit <= number / divisor;
                        number <= number % divisor;
                        first_marker <= 1;
                        commandcnt <= 24;
                        state <= LCD_START;
                    end else begin
                        if (first_marker == 0) begin
                            commandcnt <= 22;
                            state <= LCD_START;
                        end else begin
                            digit <= 0;
                            commandcnt <= 24;
                            state <= LCD_START;
                        end
                    end
                    divisor <= divisor / 10;
                end else begin
                    equation_state <= 4;
                    state <= LCD_START;
                    commandcnt <= 26;
                end
            end
            ROW1SETUP: begin
                divisor <= 10000;
                number <= result;
                first_marker <= 0;
                state <= ROW1LOOP;
                equation_state <= 5;
            end
            ROW1LOOP: begin
                if (divisor != 0) begin
                    if (divisor <= number) begin
                        digit <= number / divisor;
                        number <= number % divisor;
                        first_marker <= 1;
                        commandcnt <= 30;
                        state <= LCD_START;
                    end else begin
                        if (first_marker == 1) begin
                            digit <= 0;
                            commandcnt <= 30;
                            state <= LCD_START;
                        end
                    end
                    divisor <= divisor / 10;
                end else begin
                    equation_state <= 0;
                    a <= result;
                    b <= 0;
                    state <= KEY_START;
                end
            end
        endcase
    end
end

always @(*) begin
    case (commandcnt)
        0: data = 8'h38;
        1: data = 8'h38;
        2: data = 8'h38;
        3: data = 8'h28;
        4: data = 8'h28;
        5: data = 8'he8;
        6: data = 8'h08;
        7: data = 8'hf8;
        8: data = 8'h08;
        9: data = 8'h18;
        10: data = 8'h08;
        11: data = 8'h68; 
        12: data = 8'h08;
        13: data = 8'h28;
        14: data = 8'h88;
        15: data = 8'h08;
        16: data = {keyresult[7:4], 4'h9};
        17: data = {keyresult[3:0], 4'h9};
        18: data = 8'h08;
        19: data = 8'h18;
        20: data = 8'hc8;
        21: data = 8'hb8;
        22: data = 8'h29;
        23: data = 8'h09;
        24: data = 8'h39;
        25: data = {digit[3:0], 4'h9};
        26: data = 8'h08;
        27: data = 8'h28;
        28: data = 8'h88;
        29: data = 8'h08;
        30: data = 8'h39;
        31: data = {digit[3:0], 4'h9};
    endcase
end


keyscan keyscan(.clk(gclk), .reset(btn[0]), .start(keystart), 
.R1(pio47), .R2(pio46), .R3(pio45), .R4(pio44), 
.C1(pio43), .C2(pio42), .C3(pio41), .C4(pio40), 
.pressed(keypress), .result(keyresult));

endmodule