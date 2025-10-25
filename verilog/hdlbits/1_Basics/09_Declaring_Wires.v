`default_nettype none
module top_module(
    input a,
    input b,
    input c,
    input d,
    output out,
    output out_n   ); 
    
wire out_ab;
    assign out_ab=a&b;
    
wire out_cd;
    assign out_cd=c&d;
    
assign out=out_ab|out_cd;
assign out_n=~out;  
    
endmodule

// helpful short video for explanation(start from 0:38) :)
// https://www.youtube.com/watch?v=1rUEctIsPlg&list=PL0E9jhuDlj9qxAfV9hFKNQeHLWimarJJm&index=3

