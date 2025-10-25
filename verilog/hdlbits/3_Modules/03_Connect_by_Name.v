module top_module ( 
    input a, 
    input b, 
    input c,
    input d,
    output out1,
    output out2
);
    mod_a(.out1(out1),.out2(out2),.in1(a),.in2(b),.in3(c),.in4(d));
endmodule

// helpful short video for explanation (start from 1:38) :)
// https://www.youtube.com/watch?v=0vtuCkwd-Tc&list=PLoZS1MH9uqWDYCf6fHLchYS2r1bQFcv3d&index=3
