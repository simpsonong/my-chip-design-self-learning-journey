// synthesis verilog_input_version verilog_2001
module top_module(
    input a, 
    input b,
    output wire out_assign,
    output reg out_alwaysblock
);

    assign out_assign=a&b;
    
    always@(*)
        begin
         out_alwaysblock=a&b;
        end
endmodule

// helpful short video for explanation (start from 0:18) :)
// https://www.youtube.com/watch?v=eG9Gr0gYcQA&list=PL0E9jhuDlj9qxAfV9hFKNQeHLWimarJJm&index=12
