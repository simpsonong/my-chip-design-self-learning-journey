module top_module ( 
    input wire [2:0] vec,
    output wire [2:0] outv,
    output wire o2,
    output wire o1,
    output wire o0  ); // Module body starts after module declaration
    
    assign outv= vec;
    
    assign o0= vec [0];
    assign o1= vec [1];
    assign o2= vec [2];
     
endmodule

// helpful short video for explanation（0:30） :)
// https://www.youtube.com/watch?v=eA4O2BbNW2s&list=PL0E9jhuDlj9qxAfV9hFKNQeHLWimarJJm&index=4
