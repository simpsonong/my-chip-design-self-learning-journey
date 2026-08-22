`timescale 1ns/10ps

module tb_single_port_ram_synchronous;

//VECTORS FOR DUT
reg WE;
reg [ADDR_WIDTH-1:0] ADDR;
reg [DATA_WIDTH-1:0] DATA_IN;
wire [DATA_WIDTH-1:0] DATA_OUT;

//VECTORS FOR TESTING

reg TICK;
integer FD, COUNT;
reg [8*31-1:0] COMMENT;
reg [DATA_WIDTH-1:0]DATA_OUT_EXPECTED;
reg [31:0] VECTORCOUNT, ERRORS;
int i;
reg [31:0] input_coverage[0:5'b11111];
reg eof;
reg [4:0]INPUT;
reg [4:0]prev_INPUT;
reg [DATA_WIDTH:0] MEM [0:MEM_DEPTH];

parameter DATA_WIDTH = 8, ADDR_WIDTH = 4, MEM_DEPTH = 16;


//DUT INSTANTIATION

single_port_ram_synchronous dut_single_port_ram_synchronous (.clk(TICK), .we(WE), .addr(ADDR), .data_in(DATA_IN), .data_out(DATA_OUT));


//DUMP EVERYTHING INTO DUMPFILE

initial begin

$dumpfile ("tb_single_port_ram_synchronous.vcd");
$dumpvars (0, tb_single_port_ram_synchronous);

end


//TICKPERIOD

localparam TICKPERIOD = 20;

always begin

#(TICKPERIOD/2) TICK = ~TICK;

end


//TASKS

//task 1 initialize

task initialize; begin

FD = $fopen ("tb_single_port_ram_synchronous.tv" , "r");
COUNT = $fscanf (FD, "%s", COMMENT);

COUNT = $fscanf (FD, "%s %b %b %s %s", COMMENT, WE, ADDR, DATA_IN, DATA_OUT_EXPECTED);
TICK = 0;
VECTORCOUNT = 0;
ERRORS = 0;

for(i=0; i<=5'b11111; i++)begin
if(i<2 || i>5'b01111)begin
input_coverage[i] = 0;
end 
end

eof = 0;

$display ();
$display ("TEST_START-------------------------------------------------------------------------------------------------------------------------------------");
$display ();
$display ("                                | TIME | WE | ADDR | DATA_IN | DATA_OUT | DATA_OUT_EXPECTED |");
$display ("-----------------------------------------------------------------------------------------------------------------------------------------------");



end
endtask


//task 3 scan_file

task scan_file; begin
COUNT = $fscanf (FD, "%s %b %b %s %s", COMMENT, WE, ADDR, DATA_IN, DATA_OUT_EXPECTED);
eof = (COUNT == -1);

end
endtask

//task 4 random_in

task random_in; begin

WE =  $urandom %2;
ADDR = (WE == 0)?$urandom %2 : $urandom %16;
DATA_IN = $urandom_range(32,126);  ;

COMMENT = "-";

# ($urandom_range(0.1,10));

end
endtask





//task5 OUT_EXP

task OUT_EXP; begin

if(WE)begin
MEM[ADDR] <= DATA_IN;
DATA_OUT_EXPECTED <= DATA_IN; 
end

else begin
DATA_OUT_EXPECTED <= MEM[ADDR]; 
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
$display ("for WE==0, only test two input combinations as others combination has identical behavior");
$display ();
for (int j = 0; j < 5'b11111; j++ ) begin

if(j<2 || j>5'b01111) begin

if(input_coverage[j] == 0) begin
$display ("input WE = %b, ADDR = %b has occured %d times ***ERROR***", j[4], j[3:0], input_coverage[j]);
ERRORS = ERRORS + 1;
end


else begin
$display ("input WE = %b, ADDR = %b has occured %d times", j[4], j[3:0], input_coverage[j]);
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

task display_file; begin

$display ("%10d %9s | %4d | %2b | %4b | %4c    | %4c     | %9c         |", VECTORCOUNT, COMMENT, $time, WE, ADDR, DATA_IN, DATA_OUT, DATA_OUT_EXPECTED);

end
endtask

//task 8 in_coverage_update

task in_coverage_update; begin

input_coverage[INPUT]++;

end
endtask


//task 9 errors_warnings_check

task errors_warnings_check; begin


if (DATA_OUT !== DATA_OUT_EXPECTED) begin

$display ("***ERROR: DATA_OUT = %b, DATA_OUT_expected = %b", DATA_OUT, DATA_OUT_EXPECTED);
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

always @ (negedge TICK) begin
#9.9;
if (!eof) begin

scan_file;

end
end


//3 check file on posedge TICK

always  @ (posedge TICK) begin
INPUT = {WE,ADDR};
in_coverage_update;
prev_INPUT = INPUT;
OUT_EXP;

#0.1;
INPUT = {WE,ADDR};
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


if (WE == 1'b0 && ADDR == 5'b10000)
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
