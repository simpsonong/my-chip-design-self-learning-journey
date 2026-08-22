`timescale 1ns/100ps
module tb_sr_flip_flop;

reg S,R,TICK;
wire Q_gate,Q_data,Q_beh,QBAR_gate,QBAR_data,QBAR_beh;
integer VECTORCOUNT,ERRORS,i,gap;
reg [1:0] prev_SR;
reg prev_Q;
reg QEXPECTED,QBAREXPECTED;

localparam TICKPERIOD=20;
initial TICK=0;
always #(TICKPERIOD/2) TICK = ~TICK;

task random_in;
begin
    S = $urandom % 2;
    R = $urandom % 2;
    case({S,R})
        2'b00: QEXPECTED=prev_Q; QBAREXPECTED=~prev_Q;
        2'b01: QEXPECTED=1'b0; QBAREXPECTED=1'b1;
        2'b10: QEXPECTED=1'b1; QBAREXPECTED=1'b0;
        2'b11: QEXPECTED=1'bx; QBAREXPECTED=1'bx;
    endcase
end
endtask

initial begin
    VECTORCOUNT = 0;
    ERRORS = 0;
    prev_Q = 0;
    prev_SR = 2'b00;

    $display("TEST START");

    for (i=0;i<10;i=i+1) begin
        random_in;

        // Display
        $display("Cycle %0d: S=%b R=%b Q_expected=%b QBAR_expected=%b",$time,S,R,QEXPECTED,QBAREXPECTED);

        VECTORCOUNT = VECTORCOUNT + 1;

        prev_Q = QEXPECTED;
        prev_SR = {S,R};

        // 随机间隔 1~5 个 posedge TICK
        gap = $urandom_range(1,5);
        repeat(gap) @(posedge TICK);
    end

    $display("TEST END. VECTORCOUNT=%0d ERRORS=%0d",VECTORCOUNT,ERRORS);
    $finish;
end

endmodule
