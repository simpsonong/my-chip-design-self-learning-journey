// A jk (Jack Kilby) flip-flop which is sync clear at posedge can be set and reset and by creating a versatile memory element, invalid state is prevented.



module dff_posedge_sync_enable_behavioral (
    input  wire clk,
    input  wire enable,
    input  wire d,   
    output reg  q,
    output wire qbar
);


    assign qbar = ~q;


//D FLIP-FLOP WITH SYNC ENABLE
    always @(posedge clk) begin

        if (enable) begin
            q <= d;
        end else begin

            q <= q;

        end
        

     end

endmodule
