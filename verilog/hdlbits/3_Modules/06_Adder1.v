module top_module(
    input [31:0] a,
    input [31:0] b,
    output [31:0] sum
);

    
    wire a1_cout;
    
    add16 a1(.a(a[15:0]),.b(b[15:0]),.sum(sum[15:0]),.cout(a1_cout));
    add16 a2(.a(a[31:16]),.b(b[31:16]),.sum(sum[31:16]),.cin(a1_cout));
    
   
    endmodule

// helpful short video for explanation (start from 0:33) :)
// https://www.youtube.com/watch?v=vK7-qPU8Xps&list=PL0E9jhuDlj9qxAfV9hFKNQeHLWimarJJm&index=10
