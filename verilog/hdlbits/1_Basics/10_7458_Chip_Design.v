module top_module ( 
    input p1a, p1b, p1c, p1d, p1e, p1f,
    output p1y,
    input p2a, p2b, p2c, p2d,
    output p2y );

wire out_p1ap1bp1c;
    assign out_p1ap1bp1c=p1a&p1b&p1c;
    
wire out_p1dp1ep1f;
    assign out_p1dp1ep1f=p1d&p1e&p1f;
    
assign p1y=out_p1ap1bp1c|out_p1dp1ep1f;
    
    
wire out_p2ap2b;
    assign out_p2ap2b=p2a&p2b;
    
wire out_p2cp2d;
    assign out_p2cp2d=p2c&p2d;
    
assign p2y=out_p2ap2b|out_p2cp2d;
    
    
endmodule

// helpful short video for explanation（start from 7:09） :)
// https://www.youtube.com/watch?v=1rUEctIsPlg&list=PL0E9jhuDlj9qxAfV9hFKNQeHLWimarJJm&index=3
