module top_module(
    input [31:0] a,
    input [31:0] b,
    output [31:0] sum
);

    wire[15:0] add1_cout,con2,add2_cout,add3_cout;


add16 add1(.a(a[15:0]),.b(b[15:0]),.sum(sum[15:0]),.cout(add1_cout));
    add16 set1(.a(a[31:16]),.b(b[31:16]),.sum(add2_cout),.cin(0));    
    add16 set2(.a(a[31:16]),.b(b[31:16]),.sum(add3_cout),.cin(1));

always @(add1_cout,add2_cout,add3_cout)
begin

case(add1_cout)

0:sum[31:16]=add2_cout;
1:sum[31:16]=add3_cout;
    
endcase

end
    
endmodule

// helpful short video for explanation (start from 12:25) :)
// https://www.youtube.com/watch?v=0vtuCkwd-Tc&list=PLoZS1MH9uqWDYCf6fHLchYS2r1bQFcv3d&index=4

