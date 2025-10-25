`default_nettype none     // Disable implicit nets. Reduces some types of bugs.
module top_module( 
    input wire [15:0] in,
    output wire [7:0] out_hi,
    output wire [7:0] out_lo );
    
    assign out_hi=in[15:8];
    assign out_lo=in[7:0];
    
endmodule

// helpful short video for explanation (start from 6:41):)
// https://www.youtube.com/watch?v=eA4O2BbNW2s&list=PL0E9jhuDlj9qxAfV9hFKNQeHLWimarJJm&index=4

