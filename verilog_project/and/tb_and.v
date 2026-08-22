`timescale 1ns/10ps

module tb_and;

//VECTORS FOR DUT
reg A,B;
wire Q_gate, Q_data, Q_beh;

//VECTORS FOR TESTING

reg TICK;
integer FD, COUNT;
reg [8*9-1:0] COMMENT;
reg QEXPECTED;
reg [31:0] VECTORCOUNT, ERRORS;
int i;
reg [31:0] input_coverage [0:15];
reg eof;
reg[1:0] prev_AB;
reg prev_QEx;
reg prev_QExbar;


//DUT INSTANTIATION

and_gate dut_and_gate (.a(A), .b(B), .q(Q_gate));
and_dataflow dut_and_dataflow (.a(A), .b(B), .q(Q_data));
and_behavioral dut_and_behavioral (.a(A), .b(B), .q(Q_beh));



//DUMP EVERYTHING INTO DUMPFILE

initial begin

$dumpfile ("tb_and.vcd");
$dumpvars (0, tb_and);

end

//TICKPERIOD

localparam TICKPERIOD = 20;

always begin

#(TICKPERIOD/2) TICK = ~TICK;

end



//TASKS

//task 1 initialize

task initialize; begin

FD = $fopen ("tb_and.tv" , "r");
COUNT = $fscanf (FD, "%s", COMMENT);

COUNT = $fscanf (FD, "%s %b %b %b", COMMENT, A, B, QEXPECTED);
TICK = 0;
VECTORCOUNT = 0;
ERRORS = 0;

for ( i = 0 ; i < 16 ; i++ ) begin
input_coverage[i] = 0;
end

eof = 0;

$display ();
$display ("TEST_START------------------------------------------------------------------------------------------------------------------------");
$display ();
$display ("                     | TIME | A | B |  Q_gate  |  Q_data  |  Q_beh  | QEXPECTED |");
$display ("----------------------------------------------------------------------------------------------------------------------------------");



end
endtask



//task 2 scan_file

task scan_file; begin


COUNT = $fscanf (FD,"%s %s %b %b", COMMENT, A, B, QEXPECTED);
eof = (COUNT == -1);

end
endtask

//task 3 random_in

task random_in; begin

A =  $urandom %2 ;
B =  $urandom %2 ;

case ({A,B})
2'b00: COMMENT = "LOW";
2'b01: COMMENT = "LOW";
2'b10: COMMENT = "LOW";
2'b11: COMMENT = "HIGH";

endcase

#($urandom_range (0.1,10));

end
endtask

//task 4 QEXP

task QEXP; begin


case ( {A,B} )
 
 2'b00: begin
QEXPECTED = 1'b0;
end
 2'b01: begin
QEXPECTED = 1'b0;
end
 2'b10: begin
QEXPECTED = 1'b0;
end
 2'b11: begin
QEXPECTED = 1'b1;
end


endcase



end
endtask



//task 5 close

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

//task 6 vectorcount

task vectorcount; begin

VECTORCOUNT = VECTORCOUNT + 1;

end
endtask


//task 7 display_file

task display_file; begin

$display ("%10d %9s | %4d | %1d | %1d | %4d     | %4d     | %4d    | %5d     |", VECTORCOUNT, COMMENT, $time, A, B, Q_gate, Q_data, Q_beh, QEXPECTED);

end
endtask

//task 8 coverage_update

task coverage_update; begin

input_coverage[{prev_AB, A, B}]++;

end
endtask

//task 9 errors_check

task errors_check; begin


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
prev_AB = {A,B};

#0.1;

QEXP;
display_file;
errors_check;
vectorcount;

#0.02;

prev_QEx = QEXPECTED;



end



// eof

initial begin

wait (eof);

$display ();
$display("%13s ***time = %0d,eof ***","",$time);
$display ();

for (i = 0; i < 50; i++) begin


if ( A == 1 && B == 2)
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
