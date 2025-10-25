 module top_module(
    input [31:0] a,
    input [31:0] b,
    input sub,
    output [31:0] sum
);
    wire[31:0]b_xor;
    wire add1_cout;
    
    assign b_xor={32{sub}}^b;
   
    
    add16 add1(.a(a[15:0]),.b(b_xor[15:0]),.sum(sum[15:0]),.cin(sub),.cout(add1_cout));
    add16 add2(.a(a[31:16]),.b(b_xor[31:16]),.sum(sum[31:16]),.cin(add1_cout));
    

endmodule

// helpful short video for explanation (start from 17:08) :)
// https://www.youtube.com/watch?v=0vtuCkwd-Tc&list=PLoZS1MH9uqWDYCf6fHLchYS2r1bQFcv3d&index=4
