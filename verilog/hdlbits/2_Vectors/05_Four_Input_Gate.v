module top_module( 
    input [3:0] in,
    output out_and,
    output out_or,
    output out_xor
);
    assign out_and=in[0]&in[1]&in[2]&in[3];
    assign out_or=in[0]|in[1]|in[2]|in[3];
    assign out_xor=in[0]^in[1]^in[2]^in[3];
endmodule

// helpful short video for explanation (start from 17:46):)
// https://www.youtube.com/watch?v=LI5N_0dtQ9A&list=PL0E9jhuDlj9qxAfV9hFKNQeHLWimarJJm&index=5
