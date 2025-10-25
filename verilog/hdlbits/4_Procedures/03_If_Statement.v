// synthesis verilog_input_version verilog_2001
module top_module(
    input a,
    input b,
    input sel_b1,
    input sel_b2,
    output wire out_assign,
    output reg out_always   ); 
    
    assign out_assign=(sel_b1&sel_b2)?b:a;
    
    always@(*)
        if (sel_b1&sel_b2)
            begin
                out_always=b;
            end
        else
            begin
                out_always=a;
            end
        
endmodule

// helpful short video for explanation (start from 0:50) :)
// https://www.youtube.com/watch?v=Z_kgoFi5ASg&list=PL0E9jhuDlj9qxAfV9hFKNQeHLWimarJJm&index=14
