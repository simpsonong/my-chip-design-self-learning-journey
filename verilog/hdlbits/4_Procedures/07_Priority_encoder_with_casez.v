// synthesis verilog_input_version verilog_2001
module top_module (
    input [7:0] in,
    output reg [2:0] pos );

    always@(*)
        begin
            casez(in)
                8'bzzzzzzz1:pos=3'd0;
                8'bzzzzzz10:pos=3'd1;
                8'bzzzzzz100:pos=3'd2;
                8'bzzzz1000:pos=3'd3;
                8'bzzz10000:pos=3'd4;
                8'bzz100000:pos=3'd5;
                8'bz1000000:pos=3'd6;
                8'b10000000:pos=3'd7;
                
                default:pos=3'd0;
            endcase
                
        end
    
endmodule

// helpful short video for explanation (start from 10:59) :)
// https://www.youtube.com/watch?v=9szifIP8VX4&list=PLoZS1MH9uqWDYCf6fHLchYS2r1bQFcv3d&index=5
