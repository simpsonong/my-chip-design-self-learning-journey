module top_module (
    input [7:0] in,
    output [31:0] out );//

    assign out={{24{in[7]}},in};

endmodule

// helpful short video for explanation （start from 15:18）:)
// https://www.youtube.com/watch?v=WYWBx-ETy2M&list=PL0E9jhuDlj9qxAfV9hFKNQeHLWimarJJm&index=6
