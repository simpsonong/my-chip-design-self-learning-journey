module top_module (
    input a, b, c, d, e,
    output [24:0] out );//

    assign out=~{{5{a}},{5{b}},{5{c}},{5{d}},{5{e}}}^{5{a,b,c,d,e}};
endmodule

// helpful short video for explanation (start from 9:01) :)
// https://www.youtube.com/watch?v=4G9HtklI4rE&list=PLoZS1MH9uqWDYCf6fHLchYS2r1bQFcv3d&index=2
