module top_module ( input clk, input d, output q );

wire d1_out,d2_out;


    my_dff d1(.clk(clk),.d(d),.q(d1_out));



    my_dff d2(.clk(clk),.d(d1_out),.q(d2_out));
    
    my_dff d3(.clk(clk),.d(d2_out),.q(q));

    
endmodule

// helpful short video for explanation (start from 0:28) :)
// https://www.youtube.com/watch?v=sAQ1Rdn8glI&list=PL0E9jhuDlj9qxAfV9hFKNQeHLWimarJJm&index=8
