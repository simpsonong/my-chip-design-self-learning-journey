`timescale 1ns/10ps

module tb_jkff_posedge_sync_clear;

//VECTORS FOR DUT
reg J, K;
wire Q_beh, QBAR_beh;

//VECTORS FOR TESTING

reg TICK;
integer FD, COUNT;
reg [8*9-1:0] COMMENT;
reg [8*9-1:0] COMMENT1;
reg [8*9-1:0] COMMENT2;
reg QEXPECTED, QBAREXPECTED;
reg [31:0] VECTORCOUNT, ERRORS;
int i;
reg [31:0] input_coverage[0:15];
reg eof;
reg [1:0] prev_JK;
reg prev_Qbeh;
reg prev_Qbarbeh;
reg prev_QEx;
reg prev_QExbar;
reg CLRBAR;


//DUT INSTANTIATION

jkff_posedge_sync_clear_behavioral dut_jkff_posedge_sync_clear_behavioral (.j(J), .k(K), .q(Q_beh),.qbar(QBAR_beh), .clk(TICK), .clrbar(CLRBAR));



//DUMP EVERYTHING INTO DUMPFILE

initial begin

$dumpfile ("tb_jkff_posedge_sync_clear.vcd");
$dumpvars (0, tb_jkff_posedge_sync_clear);

end

//TICKPERIOD

localparam TICKPERIOD = 20;

always begin

#(TICKPERIOD/2) TICK = ~TICK;

end

//TICK 2

always begin

# (TICKPERIOD) CLRBAR = ~CLRBAR;

end


//TASKS

//task 1 initialize

task initialize; begin

FD = $fopen ("tb_jkff_posedge_sync_clear.tv" , "r");
COUNT = $fscanf (FD, "%s", COMMENT);

COUNT = $fscanf (FD, "%s %b %b %s %s", COMMENT, J, K, COMMENT1, COMMENT2);
TICK = 0;
VECTORCOUNT = 0;
ERRORS = 0;

for ( i = 0 ; i < 16 ; i++ ) begin
input_coverage[i] = 0;
end

eof = 0;
CLRBAR = 1;

$display ();
$display ("TEST_START------------------------------------------------------------------------------------------------------------------------");
$display ();
$display ("                     | TIME | J | K | Q_beh   | QEXPECTED | QBAREXPECTED | CLRBAR |");
$display ("----------------------------------------------------------------------------------------------------------------------------------");



end
endtask

//task2 force_release

task force_release; begin

#0.11;

force Q_beh = 1'b0;
force QBAR_beh = 1'b1;

#10;

release Q_beh;
release QBAR_beh;

end
endtask

//task 3 scan_file

task scan_file; begin


COUNT = $fscanf (FD,"%s %b %b %b %b", COMMENT, J, K, QEXPECTED, QBAREXPECTED);
eof = (COUNT == -1);

end
endtask

//task 4 random_in

task random_in; begin


J =  $urandom %2 ;
K =  $urandom %2 ;

case ({J,K})
2'b00: COMMENT = ((({prev_Qbeh,prev_Qbarbeh}) == 2'b11) || (({prev_Qbeh,prev_Qbarbeh}) == 2'b00))? "ILLEGAL":"NO_CHANGE";
2'b01: COMMENT = "RESET";
2'b10: COMMENT = "SET";
2'b11: COMMENT = ((({prev_Qbeh,prev_Qbarbeh}) == 2'b11) || (({prev_Qbeh,prev_Qbarbeh}) == 2'b00))? "ILLEGAL": "REVERSE";



endcase

#($urandom_range (0.1,10));

end
endtask

//task 5 QEXP

task QEXP; begin

if (((({prev_Qbeh,prev_Qbarbeh}) == 2'b11) || (({prev_Qbeh,prev_Qbarbeh}) == 2'b00))&& (({J,K} == 2'b00)||({J,K} == 2'b11)) && CLRBAR) begin

QEXPECTED = 1'bx;
QBAREXPECTED = 1'bx;

end


else begin

case ({J,K,CLRBAR})
  3'b001: begin
QEXPECTED = prev_QEx;
QBAREXPECTED = prev_QExbar;
end
  3'b011: begin
QEXPECTED = 1'b0;
QBAREXPECTED = 1'b1;
end
  3'b101: begin
QEXPECTED = 1'b1;
QBAREXPECTED = 1'b0;
end
  3'b111: begin
QEXPECTED = ~prev_QEx;
QBAREXPECTED = ~prev_QExbar;
end

default: begin
QEXPECTED = 1'b0;
QBAREXPECTED = 1'b1;
end

endcase
end



end
endtask



//task 6 close

task close; begin

#10;
$fclose (FD);

$display ();
$display ("COVERAGE_REPORT");

for ( i = 0; i < 16; i++ ) begin

if(input_coverage[i] == 0) begin

$display ("input %b to input %b has occured %d times (***ERROR***)",i[3:2], i[1:0], input_coverage[i]);
ERRORS = ERRORS +1;

end

else begin

$display ("input %b to input %b has occured %d times",i[3:2], i[1:0], input_coverage[i]);

end

end

$display ();
$display ("VECTORCOUNT = %d", VECTORCOUNT);
$display ("ERRORS = %15d", ERRORS);
$display ();
$display ("TEST_END--------------------------------------------------------------------------------------------------------------------------");
$display ();

$finish;

end
endtask

//task 7 vectorcount

task vectorcount; begin

VECTORCOUNT = VECTORCOUNT + 1;

end
endtask


//task 8 display_file

task display_file; begin

$display ("%10d %9s | %4d | %1d | %1d | %4d    | %5d     | %6d       | %4d   |", VECTORCOUNT, COMMENT, $time, J, K, Q_beh, QEXPECTED, QBAREXPECTED, CLRBAR);

end
endtask

//task 9 coverage_update

task coverage_update; begin

input_coverage[{prev_JK, J, K}]++;

end
endtask

//task 10 errors_check

task errors_check; begin


if  ((({prev_Qbeh,prev_Qbarbeh}) == 2'b00) && (({J,K} == 2'b00)||({J,K} == 2'b11))) begin

$display ("***ERROR: ILLEGAL CONDITION,RACING CONDITION");
ERRORS = ERRORS + 1;

end

if  ((({prev_Qbeh,prev_Qbarbeh}) == 2'b11) && (({J,K} == 2'b11)||({J,K} == 2'b00))) begin

$display ("***ERROR: ILLEGAL CONDITION, q = %b and qbar = %b", QEXPECTED, QBAREXPECTED );
ERRORS = ERRORS + 1;

end


if (Q_beh !== QEXPECTED) begin

$display ("***ERROR: Q_behavioral = %b, Q_expected = %b", Q_beh, QEXPECTED);
ERRORS = ERRORS + 1;

end

if ({J,K}!=prev_JK) begin

$display ("***ERROR: Racing Condition Occur");
ERRORS = ERRORS + 1;

end


end
endtask



//DRIVE

//0 initialize

initial begin

initialize;

@(posedge TICK);
force_release;

end


//2 scan file on negedge TICK

always @ (negedge TICK) begin


#5;

if (!eof) begin



scan_file;

end
end



//3 check file on posedge TICK

always  @ (posedge TICK) begin

coverage_update;
prev_JK = ({J,K});

#0.1;

QEXP;
display_file;
errors_check;
vectorcount;

#0.02;
prev_Qbeh = Q_beh;
prev_Qbarbeh = QBAR_beh;
prev_QEx = QEXPECTED;
prev_QExbar = QBAREXPECTED;

end



// eof

initial begin

wait (eof);

$display ();
$display("%13s ***time = %0d,eof ***","",$time);
$display ();

for (i = 0; i < 50; i++) begin


if (J == 1 && K == 2)
begin

vectorcount;
close;

end

else begin


random_in;



end

end

close;

end


endmodule
