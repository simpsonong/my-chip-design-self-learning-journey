module top_module( 
    input [7:0] in,
    output [7:0] out
);
    assign out={in[0],in[1],in[2],in[3],in[4],in[5],in[6],in[7]};
endmodule

// helpful short video for explanation (start from 11:45) :)
// https://www.youtube.com/watch?v=WYWBx-ETy2M&list=PL0E9jhuDlj9qxAfV9hFKNQeHLWimarJJm&index=6
