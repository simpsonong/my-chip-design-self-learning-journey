module top_module (
    input [31:0] a,
    input [31:0] b,
    output [31:0] sum
);
    wire add1_carry;
    add16 add1(.a(a[15:0]),.b(b[15:0]),.sum(sum[15:0]),.cout(add1_carry));
    add16 add2(.a(a[31:16]),.b(b[31:16]),.sum(sum[31:16]),.cin(add1_carry));
endmodule

module add1 ( input a, input b, input cin,   output sum, output cout );

assign sum=a^b^cin;
assign cout=a&b | cin & (a^b);
    
endmodule    

// helpful short video for explanation (start from 0:25) :)
// https://www.youtube.com/watch?v=iVqoWHWcOi0&list=PL0E9jhuDlj9qxAfV9hFKNQeHLWimarJJm&index=11
