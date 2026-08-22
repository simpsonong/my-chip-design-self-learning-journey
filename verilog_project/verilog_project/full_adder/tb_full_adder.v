`timescale 1ns/10ps

module tb_full_adder;

//VECTORS FOR DUT
reg A, B, CIN;
wire SUM_gate, COUT_gate;
wire SUM_data, COUT_data;
wire SUM_beh, COUT_beh;

//VECTORS FOR TESTING

reg TICK;
integer FD, COUNT;
reg [8*9-1:0] COMMENT;
reg SUM_EXPECTED, COUT_EXPECTED;
reg [31:0] VECTORCOUNT, ERRORS;
int i;
reg [31:0] input_coverage [0:7];
reg eof;



//DUT INSTANTIATION

full_adder_gate dut_full_adder_gate (.a(A), .b(B), .cin(CIN), .sum(SUM_gate), .cout(COUT_gate));
full_adder_dataflow dut_full_adder_dataflow (.a(A), .b(B), .cin(CIN), .sum(SUM_data), .cout(COUT_data));
full_adder_behavioral dut_full_adder_behavioral (.a(A), .b(B), .cin(CIN), .sum(SUM_beh), .cout(COUT_beh));



//DUMP EVERYTHING INTO DUMPFILE

initial begin

$dumpfile ("tb_full_adder.vcd");
$dumpvars (0, tb_full_adder);

end

//TICKPERIOD

localparam TICKPERIOD = 20;

always begin

#(TICKPERIOD/2) TICK = ~TICK;

end



//TASKS

//task 1 initialize

task initialize; begin

FD = $fopen ("tb_full_adder.tv" , "r");
COUNT = $fscanf (FD, "%s", COMMENT);

COUNT = $fscanf (FD, "%s %b %b %b %b %b", COMMENT, A, B, CIN, SUM_EXPECTED, COUT_EXPECTED);
TICK = 0;
VECTORCOUNT = 0;
ERRORS = 0;

for ( i = 0 ; i < 7 ; i++ ) begin
input_coverage[i] = 0;
end

eof = 0;

$display ();
$display ("TEST_START-------------------------------------------------------------------------------------------------------------------------------------");
$display ();
$display ("                     | TIME | A | B | CIN  | COUT_gate | SUM_gate | COUT_data | SUM_data | COUT_beh | SUM_beh | COUT_EXPECTED | SUM_EXPECTED |");
$display ("-----------------------------------------------------------------------------------------------------------------------------------------------");



end
endtask


//task 3 scan_file

task scan_file; begin

COUNT = $fscanf (FD, "%s %b %b %b %b %b", COMMENT, A, B, CIN, SUM_EXPECTED, COUT_EXPECTED);
eof = (COUNT == -1);

end
endtask

//task 4 random_in

task random_in; begin


A =  $urandom %2 ;
B =  $urandom %2 ;
CIN =  $urandom %2 ;

COMMENT = "-";

#($urandom_range (0.1,10));

end
endtask

//task5 SUM_EXP

task SUM_EXP; begin

SUM_EXPECTED = A ^ B ^ CIN;

end
endtask


//task6 COUT_EXP

task COUT_EXP; begin

COUT_EXPECTED = (A&B) | ((A^B) & CIN);

end
endtask


//task 5 close

task close; begin

#10;
$fclose (FD);

$display ();
$display ("COVERAGE_REPORT");

for ( i = 0; i < 7; i++ ) begin

if(input_coverage[i] == 0) begin

$display ("input A = %b & B = %b & Cin = %b has occured %d times (***ERROR***)",i[2], i[1], i[0], input_coverage[i]);
ERRORS = ERRORS +1;

end

else begin

$display ("input A = %b & B = %b & Cin = %b has occured %d times",i[2], i[1], i[0], input_coverage[i]);

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


//task 6 vectorcount

task vectorcount; begin

VECTORCOUNT = VECTORCOUNT + 1;

end
endtask


//task 7 display_file

task display_file; begin

$display ("%10d %9s | %4d | %1d | %1d | %2d   | %5d     | %5d    | %5d     | %5d    | %4d     | %4d    | %7d       | %6d       |", VECTORCOUNT, COMMENT, $time, A, B, CIN, COUT_gate, SUM_gate, COUT_data, SUM_data, COUT_beh, SUM_beh, COUT_EXPECTED, SUM_EXPECTED);

end
endtask

//task 8 coverage_update

task coverage_update; begin

input_coverage[{A,B,CIN}]++;

end
endtask

//task 9 errors_warnings_check

task errors_warnings_check; begin



if (COUT_gate !== COUT_EXPECTED) begin

$display ("***ERROR: COUT_gate = %b, COUT_expected = %b", COUT_gate, COUT_EXPECTED);
ERRORS = ERRORS + 1;

end

if (SUM_gate !== SUM_EXPECTED) begin

$display ("***ERROR: SUM_gate = %b, SUM_expected = %b", SUM_gate, SUM_EXPECTED);
ERRORS = ERRORS + 1;

end


if (COUT_data !== COUT_EXPECTED) begin

$display ("***ERROR: COUT_data = %b, COUT_expected = %b", COUT_data, COUT_EXPECTED);
ERRORS = ERRORS + 1;

end

if (SUM_data !== SUM_EXPECTED) begin

$display ("***ERROR: SUM_data = %b, SUM_expected = %b", SUM_data, SUM_EXPECTED);
ERRORS = ERRORS + 1;

end


if (COUT_beh !== COUT_EXPECTED) begin

$display ("***ERROR: COUT_beh = %b, COUT_expected = %b", COUT_beh, COUT_EXPECTED);
ERRORS = ERRORS + 1;

end

if (SUM_beh !== SUM_EXPECTED) begin

$display ("***ERROR: SUM_beh = %b, SUM_expected = %b", SUM_beh, SUM_EXPECTED);
ERRORS = ERRORS + 1;

end



end
endtask



//DRIVE

//0 initialize

initial begin

initialize;


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

#0.1;

COUT_EXP;
SUM_EXP;
display_file;
errors_warnings_check;
vectorcount;

end



// eof

initial begin

wait (eof);

$display ();
$display("%13s ***time = %0d,eof ***","",$time);
$display ();

for (i = 0; i < 50; i++) begin


if (A == 1 && B == 2 && CIN == 1)
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
