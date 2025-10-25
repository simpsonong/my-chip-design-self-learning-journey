// synthesis verilog_input_version verilog_2001
module top_module(
    input clk,
    input a,
    input b,
    output wire out_assign,
    output reg out_always_comb,
    output reg out_always_ff   );

    assign out_assign=a^b;
    
    always@(*)
        out_always_comb=a^b;
    
    always@(posedge clk)
        out_always_ff<=a^b;
endmodule

// helpful short video for explanation (start from 0:56):)
// https://www.youtube.com/watch?v=_7ibdMJIg28&list=PL0E9jhuDlj9qxAfV9hFKNQeHLWimarJJm&index=13
