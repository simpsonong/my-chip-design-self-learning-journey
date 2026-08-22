`timescale 1ns/10ps

module tb_dual_port_ram_asynchronous;

//VECTORS FOR DUT
reg WE_A, WE_B;
reg [ADDR_WIDTH-1:0] ADDR_A, ADDR_B;
reg [DATA_WIDTH-1:0] DATA_IN_A, DATA_IN_B;
wire [DATA_WIDTH-1:0] DATA_OUT_A, DATA_OUT_B;

//VECTORS FOR TESTING

reg TICK, TICK_A, TICK_B;
integer FD, COUNT;
reg [8*31-1:0] COMMENT;
reg [DATA_WIDTH-1:0]DATA_OUT_A_EXPECTED,DATA_OUT_B_EXPECTED;
reg [31:0] VECTORCOUNT, ERRORS;
int i;
reg [31:0] input_coverage_TICKA[0:1];
reg [31:0] input_coverage_TICKB[0:1];
reg [31:0] input_coverage_a[0:5'b11111];
reg [31:0] input_coverage_b[0:5'b11111];
reg eof;
reg [4:0]prev_INPUT_A;
reg [4:0]prev_INPUT_B;
reg [DATA_WIDTH-1:0] MEM [0:MEM_DEPTH-1];

parameter DATA_WIDTH = 8, ADDR_WIDTH = 4, MEM_DEPTH = 16;


//DUT INSTANTIATION

dual_port_ram_asynchronous dut_dual_port_ram_asynchronous (.clk_a(TICK_A), .we_a(WE_A), .addr_a(ADDR_A), .data_in_a(DATA_IN_A), .data_out_a(DATA_OUT_A), .clk_b(TICK_B), .we_b(WE_B), .addr_b(ADDR_B), .data_in_b(DATA_IN_B), .data_out_b(DATA_OUT_B));


//DUMP EVERYTHING INTO DUMPFILE

initial begin

$dumpfile ("tb_dual_port_ram_asynchronous.vcd");
$dumpvars (0, tb_dual_port_ram_asynchronous);

end


//TICKPERIOD

localparam TICKPERIOD = 20;

always begin
#(TICKPERIOD/2) TICK <= ~TICK;
end

always begin
#(TICKPERIOD/2) TICK_A <= ~TICK_A;
end

always begin
#(TICKPERIOD) TICK_B <= ~TICK_B;
end

//TASKS

//task 1 initialize

task initialize; begin

FD = $fopen ("tb_dual_port_ram_asynchronous.tv" , "r");
COUNT = $fscanf (FD, "%s", COMMENT);

COUNT = $fscanf (FD, "%s %b %b %s %b %b %s ", COMMENT, WE_A, ADDR_A, DATA_IN_A, WE_B, ADDR_B, DATA_IN_B);
TICK = 0;
TICK_A = 0;
TICK_B = 0;
VECTORCOUNT = 0;
ERRORS = 0;

for(i=0; i<2; i++)begin
input_coverage_TICKA[i] = 0;
input_coverage_TICKB[i] = 0;
end

for(i=0; i<=5'b11111; i++)begin
if(i<2 || i>5'b01111)begin
input_coverage_a[i] = 0;
end
end


for(i=0; i<=5'b11111; i++)begin
if(i<2 || i>5'b01111)begin
input_coverage_b[i] = 0;
end
end


eof = 0;

$display ();
$display ("TEST_START--------------------------------------------------------------------------------------------------------------------------------------------------------------------");
$display ();
$display ("                     | TIME | TICK_A | WE_A | ADDR_A | DATA_IN_A | DATA_OUT_A | DATA_OUT_A_EXPECTED | TICK_B | WE_B | ADDR_B | DATA_IN_B | DATA_OUT_B | DATA_OUT_B_EXPECTED |");
$display ("------------------------------------------------------------------------------------------------------------------------------------------------------------------------------");

#10;
force TICK_A = 0;
#20;
release TICK_A;

end
endtask


//task 3 scan_file

task scan_file; begin

COUNT = $fscanf (FD, "%s %b %b %s %b %b %s", COMMENT, WE_A, ADDR_A, DATA_IN_A, WE_B, ADDR_B, DATA_IN_B);
eof = (COUNT == -1);

end
endtask

//task 4 random_in

task random_in; begin
reg[DATA_WIDTH-1:0] temp;

WE_A =  $urandom %2;
ADDR_A = (WE_A == 0)?$urandom %2 : $urandom %16;
DATA_IN_A = $urandom_range(32,126);

WE_B =  $urandom %2;
temp = (WE_B == 0)?$urandom %2 : $urandom %16;
DATA_IN_B = $urandom_range(32,126);

if(temp == ADDR_A)begin
if($urandom%2)begin
ADDR_B = (temp == MEM_DEPTH-1)? temp-1: temp+1;
end
else begin
ADDR_B = (temp == 0)? temp+1: temp-1;
end
end

else
ADDR_B = temp;

COMMENT = "-";

# ($urandom_range(0.1,10));

end
endtask



//task5 OUT_EXP

task OUT_EXP_A; begin

if(WE_A)begin
MEM[ADDR_A] <= DATA_IN_A;
DATA_OUT_A_EXPECTED <= MEM[ADDR_A];
end

else begin
DATA_OUT_A_EXPECTED <= MEM[ADDR_A];
end

end
endtask

task OUT_EXP_B; begin

if(WE_B)begin
MEM[ADDR_B] <= DATA_IN_B;
DATA_OUT_B_EXPECTED <= MEM[ADDR_B];
end

else begin
DATA_OUT_B_EXPECTED <= MEM[ADDR_B];
end


end
endtask



//task 5 close

task close; begin

#10;

$fclose (FD);

$display ();
$display ("COVERAGE_REPORT");
$display ();
$display ("1.for WE_A==0 and WE_B==0, only test two input combinations as others combination has identical behavior");
$display ();

for (int j = 0; j < 2; j++ ) begin

if(input_coverage_TICKA[j] == 0) begin
$display ("input TICK_A = %b has occured %22s%-2d times ***ERROR***", j[0],"", input_coverage_TICKA[j]);
ERRORS = ERRORS + 1;
end


else begin
$display ("input TICK_A = %b has occured %22s%-2d times", j[0],"", input_coverage_TICKA[j]);
end

end


for (int j = 0; j < 5'b11111; j++ ) begin

if(j<2 || j>5'b01111) begin

if(input_coverage_a[j] < 2) begin            // data in need to at least come across same address for 2 times to ensure data in is successfully written into the address 
$display ("input WE_A = %b, ADDR_A = %b has occured %9s%-2d times ***ERROR***", j[4], j[3:0],"", input_coverage_a[j]);
ERRORS = ERRORS + 1;
end


else begin
$display ("input WE_A = %b, ADDR_A = %b has occured %9s%-2d times", j[4], j[3:0],"", input_coverage_a[j]);
end
end

else begin
//NOTHING
end
end


for (int j = 0; j < 2; j++ ) begin

if(input_coverage_TICKB[j] == 0) begin
$display ("input TICK_B = %b has occured %22s%-2d times ***ERROR***", j[0],"", input_coverage_TICKB[j]);
ERRORS = ERRORS + 1;
end


else begin
$display ("input TICK_B = %b has occured %22s%-2d times", j[0],"", input_coverage_TICKB[j]);
end

end


for (int j = 0; j < 5'b11111; j++ ) begin

if(j<2 || j>5'b01111) begin

if(input_coverage_b[j] < 2) begin
$display ("input WE_B = %b, ADDR_B = %b has occured %9s%-2d times ***ERROR***", j[4], j[3:0],"", input_coverage_b[j]);
ERRORS = ERRORS + 1;
end


else begin
$display ("input WE_B = %b, ADDR_B = %b has occured %9s%-2d times", j[4], j[3:0],"", input_coverage_b[j]);
end
end

else begin
//NOTHING
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

task display_file_A; begin

$display ("_____________________________________________________________________________________________________");
$display ("%10d %9s | %4d | %3b    | %2b   | %5b  | %5c     | %5c      | %10c          |", VECTORCOUNT, COMMENT, $time, TICK_A, WE_A, ADDR_A, DATA_IN_A, DATA_OUT_A, DATA_OUT_A_EXPECTED);
$display ("-----------------------------------------------------------------------------------------------------");

end
endtask


task display_file_B; begin


$display ("%100s__________________________________________________________________________","");
$display ("%10d %9s | %4d |%70s | %3b    | %2b   | %5b  | %5c     | %5c      | %10c          |", VECTORCOUNT, COMMENT, $time, "", TICK_B, WE_B, ADDR_B, DATA_IN_B, DATA_OUT_B, DATA_OUT_B_EXPECTED);
$display ("%100s--------------------------------------------------------------------------","");

end
endtask

//task 8 in_coverage_update

task in_coverage_update; begin

input_coverage_TICKA[{TICK_A}]++;
input_coverage_TICKB[{TICK_B}]++;
input_coverage_a[{WE_A,ADDR_A}]++;
input_coverage_b[{WE_B,ADDR_B}]++;

end
endtask


//task 9 errors_warnings_check

task errors_warnings_check_A; begin


if (DATA_OUT_A !== DATA_OUT_A_EXPECTED) begin

$display ("***ERROR: DATA_OUT_A = %b, DATA_OUT_A_expected = %b", DATA_OUT_A, DATA_OUT_A_EXPECTED);
ERRORS = ERRORS + 1;

end

if (({WE_A,ADDR_A} !== prev_INPUT_A) && TICK_A) begin

$display ("***ERROR: INPUT_A - RACING CONDITION OCCUR");
ERRORS = ERRORS + 1;

end

end
endtask

task errors_warnings_check_B; begin

if (DATA_OUT_B !== DATA_OUT_B_EXPECTED) begin

$display ("***ERROR: DATA_OUT_B = %b, DATA_OUT_B_expected = %b", DATA_OUT_B, DATA_OUT_B_EXPECTED);
ERRORS = ERRORS + 1;

end

if ({WE_B,ADDR_B} !== prev_INPUT_B && TICK_B) begin

$display ("***ERROR: INPUT_B - RACING CONDITION OCCUR");
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
#9.9;
if (!eof) begin

scan_file;

end
end


//3 check file on posedge TICK

always  @ (posedge TICK_A) begin
prev_INPUT_A = {WE_A,ADDR_A};
in_coverage_update;
OUT_EXP_A;

#0.1;
display_file_A;
errors_warnings_check_A;
vectorcount;


end


always  @ (posedge TICK_B) begin
prev_INPUT_B = {WE_B,ADDR_B};
in_coverage_update;
OUT_EXP_B;

#0.1;
display_file_B;
errors_warnings_check_B;
vectorcount;


end



// eof

initial begin

wait (eof);

$display ();
$display("%13s ***time = %0d,eof ***","",$time);
$display ();

for (i = 0; i < 50; i++) begin


if (TICK_A == 1'b1 && WE_A == 1'b0 && ADDR_A == 5'b10000 || TICK_B == 1'b1 && WE_B == 1'b0 && ADDR_B == 5'b10000)
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

