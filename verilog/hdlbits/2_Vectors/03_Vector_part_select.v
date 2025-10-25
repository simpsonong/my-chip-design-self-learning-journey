module top_module( 
    input [31:0] in,
    output [31:0] out );//

    assign out={in[7:0],in[15:8],in[23:16],in[31:24]};

endmodule

// helpful short video for explanation(start from 0:56) :)
// https://www.youtube.com/watch?v=LI5N_0dtQ9A&list=PL0E9jhuDlj9qxAfV9hFKNQeHLWimarJJm&index=5
