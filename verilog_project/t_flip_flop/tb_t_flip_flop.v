`timescale 1ns/10ps

module tb_t_flip_flop;

//VECTORS FOR DUT
reg T;
wire Q_gate, Q_data, Q_beh, QBAR_gate, QBAR_data, QBAR_beh;

//VECTORS FOR TESTING

reg TICK;
integer FD, COUNT;
reg [8*9-1:0] COMMENT;
reg [8*9-1:0] COMMENT1;
reg [8*9-1:0] COMMENT2;
reg QEXPECTED, QBAREXPECTED;
reg [31:0] VECTORCOUNT, ERRORS;
int i;
reg [31:0] input_coverage[0:3];
reg eof;
reg prev_T;
reg prev_QEx;
reg prev_QExbar;
reg prev_Qgate;
reg prev_Qbargate;
reg prev_Qdata;
reg prev_Qbardata;
reg prev_Qbeh;
reg prev_Qbarbeh;

//DUT INSTANTIATION

t_flip_flop_gate dut_t_flip_flop_gate (.t(T), .q(Q_gate), .qbar(QBAR_gate), .clk(TICK));
t_flip_flop_dataflow dut_t_flip_flop_dataflow (.t(T), .q(Q_data), .qbar(QBAR_data), .clk(TICK));
t_flip_flop_behavioral dut_t_flip_flop_behavioral (.t(T), .q(Q_beh), .qbar(QBAR_beh), .clk(TICK));



//DUMP EVERYTHING INTO DUMPFILE

initial begin

$dumpfile ("tb_t_flip_flop.vcd");
$dumpvars (0, tb_t_flip_flop);

end

//TICKPERIOD

localparam TICKPERIOD = 20;

always begin

#(TICKPERIOD/2) TICK = ~TICK;

end



//TASKS

//task 1 initialize

task initialize; begin

FD = $fopen ("tb_t_flip_flop.tv" , "r");
COUNT = $fscanf (FD, "%s", COMMENT);

COUNT = $fscanf (FD, "%s %b %s %s", COMMENT, T, COMMENT1, COMMENT2);
TICK = 0;
VECTORCOUNT = 0;
ERRORS = 0;

for ( i = 0 ; i < 4 ; i++ ) begin
input_coverage[i] = 0;
end

eof = 0;

$display ();
$display ("TEST_START------------------------------------------------------------------------------------------------------------------------");
$display ();
$display ("                     | TIME | T |  Q_gate  |  Q_data  |  Q_beh  | QBAR_gate | QBAR_data | QEXPECTED | QBAREXPECTED |");
$display ("----------------------------------------------------------------------------------------------------------------------------------");



end
endtask

//task2 force_release

task force_release; begin

#0.11;

force Q_gate = 1'b0;
force QBAR_gate = 1'b1;
force Q_data = 1'b0;
force QBAR_data = 1'b1;
force Q_beh = 1'b0;
force QBAR_beh = 1'b1;
force QEXPECTED = 1'b0;
force QBAREXPECTED = 1'b1;

#10;

release Q_gate;
release QBAR_gate;
release Q_data;
release QBAR_data;
release QEXPECTED;
release QBAREXPECTED;

@(posedge TICK)
#0.1
release Q_beh;
release QBAR_beh;

end
endtask



//task 3 scan_file

task scan_file; begin


COUNT = $fscanf (FD,"%s %b %b %b", COMMENT, T, QEXPECTED, QBAREXPECTED);
eof = (COUNT == -1);

end
endtask

//task 4 random_in

task random_in; begin

T =  $urandom %2 ;

case (T)
1'b0: COMMENT =  (((({prev_Qgate,prev_Qbargate})== 2'b11) || (({prev_Qdata,prev_Qbardata})== 2'b11) || (({prev_Qbeh,prev_Qbarbeh})== 2'b11)) || ((({prev_Qgate,prev_Qbargate})== 2'b00)||(({prev_Qdata,prev_Qbardata})== 2'b00) || (({prev_Qbeh,prev_Qbarbeh})== 2'b00)))? "ILLEGAL":"HOLD";
1'b1: COMMENT =  (((({prev_Qgate,prev_Qbargate})== 2'b11) || (({prev_Qdata,prev_Qbardata})== 2'b11) || (({prev_Qbeh,prev_Qbarbeh})== 2'b11)) || ((({prev_Qgate,prev_Qbargate})== 2'b00)||(({prev_Qdata,prev_Qbardata})== 2'b00) || (({prev_Qbeh,prev_Qbarbeh})== 2'b00)))?"ILLEGAL":"TOGGLE";

endcase

#($urandom_range (0.1,10));

end
endtask

//task 5 QEXP

task QEXP; begin

if (((({prev_Qgate,prev_Qbargate})== 2'b11) || (({prev_Qdata,prev_Qbardata})== 2'b11) || (({prev_Qbeh,prev_Qbarbeh})== 2'b11)) || ((({prev_Qgate,prev_Qbargate})== 2'b00)||(({prev_Qdata,prev_Qbardata})== 2'b00) || (({prev_Qbeh,prev_Qbarbeh})== 2'b00)) && (( T == 1'b0)||( T == 1'b1))) begin

QEXPECTED = 1'bx;
QBAREXPECTED = 1'bx;

end

else begin

case ( T )
  1'b0: begin
QEXPECTED = prev_QEx;
QBAREXPECTED = prev_QExbar;
end
  1'b1: begin
QEXPECTED = ~prev_QEx;
QBAREXPECTED = ~prev_QExbar;
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

for ( i = 0; i < 4; i++ ) begin

if(input_coverage[i] == 0) begin

$display ("input %b to input %b has occured %d times (***ERROR***)",i[1], i[0], input_coverage[i]);
ERRORS = ERRORS +1;

end

else begin

$display ("input %b to input %b has occured %d times",i[1], i[0], input_coverage[i]);

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

$display ("%10d %9s | %4d | %1d | %4d     | %4d     | %4d    | %5d     | %5d     | %5d     | %6d       |", VECTORCOUNT, COMMENT, $time, T, Q_gate, Q_data, Q_beh, QBAR_gate, QBAR_data, QEXPECTED, QBAREXPECTED);

end
endtask

//task 9 coverage_update

task coverage_update; begin

input_coverage[{prev_T, T}]++;

end
endtask

//task 10 errors_check

task errors_check; begin


if  (((({prev_Qgate,prev_Qbargate})== 2'b00) || (({prev_Qdata,prev_Qbardata})== 2'b00) || (({prev_Qbeh,prev_Qbarbeh})== 2'b00)) && (( T == 1'b0)||( T == 1'b1))) begin

$display ("***ERROR: ILLEGAL CONDITION,RACING CONDITION");
ERRORS = ERRORS + 1;

end

if  (((({prev_Qgate,prev_Qbargate})== 2'b11) || (({prev_Qdata,prev_Qbardata})== 2'b11) || (({prev_Qbeh,prev_Qbarbeh})== 2'b11)) && (( T == 1'b0)||( T == 1'b1))) begin

$display ("***ERROR: ILLEGAL CONDITION, q = %b and qbar = %b", QEXPECTED, QBAREXPECTED );
ERRORS = ERRORS + 1;

end



if (Q_gate !== QEXPECTED) begin

$display ("***ERROR: Q_gate = %b, Q_expected = %b", Q_gate, QEXPECTED);
ERRORS = ERRORS + 1;

end

if (Q_data !== QEXPECTED) begin

$display ("***ERROR: Q_dataflow = %b, Q_expected = %b", Q_data, QEXPECTED);
ERRORS = ERRORS + 1;

end

if (Q_beh !== QEXPECTED) begin

$display ("***ERROR: Q_behavioral = %b, Q_expected = %b", Q_beh, QEXPECTED);
ERRORS = ERRORS + 1;

end

if (QBAR_gate !== QBAREXPECTED) begin

$display ("***ERROR: QBAR_gate = %b, QBAR_expected = %b", QBAR_gate, QBAREXPECTED);
ERRORS = ERRORS + 1;

end

if (QBAR_data !== QBAREXPECTED) begin

$display ("***ERROR: QBAR_dataflow = %b, QBAR_expected = %b", QBAR_data, QBAREXPECTED);
ERRORS = ERRORS + 1;

end

if ( T !== prev_T ) begin

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


#1.2;

if (!eof) begin



scan_file;

end
end



//3 check file on posedge TICK

always  @ (posedge TICK) begin

coverage_update;
prev_T = T;

#0.1;

QEXP;
display_file;
errors_check;
vectorcount;

#0.02;


prev_Qgate    = Q_gate;
prev_Qbargate = QBAR_gate;
prev_Qdata    = Q_data;
prev_Qbardata = QBAR_data;
prev_Qbeh     = Q_beh;
prev_Qbarbeh  = QBAR_beh;
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


if ( T == 2)
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
