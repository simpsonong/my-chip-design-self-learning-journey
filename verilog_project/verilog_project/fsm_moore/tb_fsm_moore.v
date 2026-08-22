`timescale 1ns/10ps

module tb_fsm_moore;

//VECTORS FOR DUT
reg RST, IN;
wire FOUND;

//VECTORS FOR TESTING

reg TICK;
integer FD, COUNT;
reg [8*31-1:0] COMMENT;
reg COUT_EXPECTED;
reg FOUND_EXPECTED;
reg FOUND_EXPECTED1;
reg [31:0] VECTORCOUNT, ERRORS;
int i;
reg [31:0] input_coverage[0:3];
reg [31:0] state_coverage[0:11];
reg eof;
reg [1:0]INPUT;
reg [1:0]prev_INPUT;
reg [2:0]STATE,NEXT_STATE;

parameter [2:0] START = 3'b000, ZERO1 = 3'b001, ZERO2 = 3'b010, ONE1 = 3'b011, ONE2 = 3'b100, MATCH = 3'b101;


//DUT INSTANTIATION

fsm_moore dut_fsm_moore (.clk(TICK), .rst(RST), .in(IN), .found(FOUND));


//DUMP EVERYTHING INTO DUMPFILE

initial begin

$dumpfile ("tb_fsm_moore.vcd");
$dumpvars (0, tb_fsm_moore);

end


//TICKPERIOD

localparam TICKPERIOD = 20;

always begin

#(TICKPERIOD/2) TICK = ~TICK;

end

//FUNCTION
//function 1 state_names;begin

function [8*32-1:0] cmt;
input RST;
input[2:0] STATE,NEXT_STATE;
begin

if(RST)begin
cmt = "RST_to_START";
end

else begin
case({STATE,NEXT_STATE})
{START,ZERO1}: cmt = "START_to_ZERO1";
{START,START}: cmt = "START_to_START";
{ZERO1,ZERO2}: cmt = "ZERO1_to_ZERO2";
{ZERO1,START}: cmt = "ZERO1_to_START";
{ZERO2,ONE1} : cmt = "ZERO2_to_ONE1";
{ZERO2,ZERO2}: cmt = "ZERO2_to_ZERO2";
{ONE1,ONE2}  : cmt = "ONE1_to_ONE2";
{ONE1,ZERO1} : cmt = "ONE1_to_ZERO1";
{ONE2,MATCH} : cmt = "ONE2_to_MATCH";
{ONE2,START} : cmt = "ONE2_to_START";
{MATCH,START}: cmt = "MATCH_to_START";
{MATCH,ZERO2}: cmt = "MATCH_to_ZERO2";
default: cmt = "xxx";
endcase
end

end
endfunction

//function 2 cmt for input_coverage;
function [8*15-1:0] cmt1;
input [3:0] j;
begin

case(j)
4'd0: cmt1 = "START_to_ZERO1";
4'd1: cmt1 = "START_to_START";
4'd2: cmt1 = "ZERO1_to_ZERO2";
4'd3: cmt1 = "ZERO1_to_START";
4'd4: cmt1 = "ZERO2_to_ONE1";
4'd5: cmt1 = "ZERO2_to_ZERO2";
4'd6: cmt1 = "ONE1_to_ONE2";
4'd7: cmt1 = "ONE1_to_ZERO1";
4'd8: cmt1 = "ONE2_to_MATCH";
4'd9: cmt1 = "ONE2_to_START";
4'd10: cmt1 = "MATCH_to_START";
4'd11: cmt1 = "MATCH_to_ZERO2";
default: cmt1 = "xxx";
endcase

end
endfunction

//function 3 next_state

function [2:0] next_state; 
input [2:0]STATE;
input IN;
begin

case(STATE)

START: begin

if(IN == 0)begin
next_state = ZERO1;
end

else begin
next_state = START;
end
end


ZERO1: begin

if(IN == 0)begin
next_state = ZERO2;
end

else begin
next_state = START;
end
end

ZERO2: begin

if(IN == 1)begin
next_state = ONE1;
end

else begin
next_state = ZERO2;
end
end

ONE1: begin

if(IN == 1)begin
next_state = ONE2;
end


else begin
next_state = ZERO1;
end
end

ONE2: begin

if(IN == 0)begin
next_state = MATCH;
end


else begin
next_state = START;
end
end

MATCH: begin

if(IN == 1) begin
next_state = START;
end

else begin
next_state = ZERO2;
end
end

endcase


end
endfunction


//TASKS

//task 1 initialize

task initialize; begin

FD = $fopen ("tb_fsm_moore.tv" , "r");
COUNT = $fscanf (FD, "%s", COMMENT);

COUNT = $fscanf (FD, "%s %b %b %b", COMMENT, RST, IN, FOUND_EXPECTED1);
TICK = 0;
VECTORCOUNT = 0;
ERRORS = 0;

for(i=0; i<4; i++)begin
input_coverage[i] = 0;
end


for(i=0; i<12; i++)begin
state_coverage[i] = 0;
end

eof = 0;

$display ();
$display ("TEST_START-------------------------------------------------------------------------------------------------------------------------------------");
$display ();
$display ("                                | TIME | RST | IN | FOUND | FOUND_EXPECTED |");
$display ("-----------------------------------------------------------------------------------------------------------------------------------------------");



end
endtask


//task 3 scan_file

task scan_file; begin

COUNT = $fscanf (FD, "%s %b %b %b", COMMENT, RST, IN, FOUND_EXPECTED);
eof = (COUNT == -1);

end
endtask

//task 4 random_in

task random_in; begin

RST =  $urandom %2;
IN = (RST == 1'b1)? 0: $urandom %2;


# ($urandom_range(0.1,10));

end
endtask





//task5 OUT_EXP

task OUT_EXP; begin

if(RST)begin
STATE = START;
COMMENT = cmt(RST, STATE, NEXT_STATE);
end
else begin
COMMENT = cmt(RST, STATE, NEXT_STATE);
STATE = NEXT_STATE;
end

NEXT_STATE = next_state(STATE,IN);


FOUND_EXPECTED = MATCH;

end
endtask



//task 5 close

task close; begin

#10;

$fclose (FD);

$display ();
$display ("COVERAGE_REPORT");

for (int j = 0; j < 4; j++ ) begin

if(input_coverage[j] == 0) begin
$display ("input RST = %b, IN = %b has occured %d times ***ERROR***", j[1], j[0], input_coverage[j]);
ERRORS = ERRORS + 1;
end

else if(j == 3) begin
$display ("input RST = %b, IN = %b has occured %d times ***same logic as above while RST = 1***", j[1], j[0], input_coverage[j]);
end

else begin
$display ("input RST = %b, IN = %b has occured %d times", j[1], j[0], input_coverage[j]);
end

end


for (int j = 0; j < 12; j++ ) begin

if(state_coverage[j] == 0) begin
$display ("state = %-16s has occured %d times ***ERROR***",cmt1(j), state_coverage[j]);
ERRORS = ERRORS + 1;
end

else begin
$display ("state = %-16s has occured %d times",cmt1(j), state_coverage[j]);
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

$display ("%10d %-20s | %4d | %2b  | %1b  | %3b   | %7b        |", VECTORCOUNT, COMMENT, $time, RST, IN, FOUND, FOUND_EXPECTED);

end
endtask

//task 8 in_coverage_update

task in_coverage_update; begin


input_coverage[INPUT]++;

if(INPUT == 2'b10)begin
for(int j=3; j<4; j++)
input_coverage[j]++;
end


end
endtask

//task 8 state_coverage_update

task state_coverage_update; begin

case({STATE,NEXT_STATE})
{START,ZERO1}: state_coverage[0]++;
{START,START}: state_coverage[1]++;
{ZERO1,ZERO2}: state_coverage[2]++;
{ZERO1,START}: state_coverage[3]++;
{ZERO2,ONE1} : state_coverage[4]++;
{ZERO2,ZERO2}: state_coverage[5]++;
{ONE1,ONE2}  : state_coverage[6]++;
{ONE1,ZERO1} : state_coverage[7]++;
{ONE2,MATCH} : state_coverage[8]++;
{ONE2,START} : state_coverage[9]++;
{MATCH,START}: state_coverage[10]++;
{MATCH,ZERO2}: state_coverage[11]++;
endcase

end
endtask


//task 9 errors_warnings_check

task errors_warnings_check; begin


if (FOUND !== FOUND_EXPECTED) begin

$display ("***ERROR: FOUND = %b, FOUND_expected = %b", FOUND, FOUND_EXPECTED);
ERRORS = ERRORS + 1;

end

if (INPUT !== prev_INPUT) begin

$display ("***ERROR: RACING CONDITION OCCUR");
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

always @ (posedge TICK) begin

if (!eof) begin

scan_file;

end

INPUT = {RST,IN};
in_coverage_update;
prev_INPUT = INPUT;


end


//3 check file on posedge TICK

always  @ (posedge TICK) begin
OUT_EXP;
state_coverage_update;


#0.1;
IN = {RST,IN};
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


if (IN == 2'b00 && STATE == 4'b1000)
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
