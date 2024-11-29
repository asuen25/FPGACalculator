`timescale 1ns / 1ps

module btn_led(
    input [1:0]btn,   // Button inputs
    output [1:0]led,
    input gclk,
    output pio01,
    output pio48
	  // Led outputs
    );
    
    reg d;
    reg e;
    reg [9:0] cnt;
    wire resetn;

    // Assign each btn to it's respective led
    //assign led = ~btn;
    assign resetn = ~btn;
    assign led[0] = (~btn[0] & ~btn[1]) + (btn[0] & btn[1]);
    assign led[1] = (~btn[0] & ~btn[1]) + (btn[0] & btn[1]);
    always @(posedge gclk or negedge resetn) begin
      if (~resetn) begin
        d <= 0;
      end else if (cnt == 999) begin
        d <= ~d;
      end
     end

     always @(posedge gclk or negedge resetn) begin
       if (~resetn) begin
         cnt <= 0;
       end else if (cnt == 999) begin
         cnt <= 0;
       end else begin
         cnt <= cnt + 1;
       end
     end
     always @(posedge d or negedge resetn) begin
      if (~resetn) begin
         e <= 0;
      end else begin
         e <= ~e;
     end
    end
     assign pio01 = d;
     assign pio48 = e;

      
endmodule
