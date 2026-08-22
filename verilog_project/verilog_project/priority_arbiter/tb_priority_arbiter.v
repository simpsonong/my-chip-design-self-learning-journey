`timescale 1ns/10ps

module tb_priority_arbiter;

//VECTORS FOR DUT
reg RST;
reg [3:0]REQ;
wire [3:0]GNT;

//VECTORS FOR TESTING

reg TICK;
integer FD, COUNT;
reg [8*31-1:0] COMMENT;
reg [3:0] GNT_EXPECTED;
reg [31:0] VECTORCOUNT, ERRORS;
int i;
reg [31:0] input_coverage[0:18];
reg eof;
reg[4:0] J;
reg[4:0] prev_RSTREQ;

//DUT INSTANTIATION

priority_arbiter dut_priority_arbiter (.clk(TICK), .rst(RST), .req(REQ), .gnt(GNT));


//DUMP EVERYTHING INTO DUMPFILE

initial begin

$dumpfile ("tb_priority_arbiter.vcd");
$dumpvars (0, tb_priority_arbiter);

end

//TICKPERIOD

localparam TICKPERIOD = 20;

always begin

#(TICKPERIOD/2) TICK = ~TICK;

end



//TASKS

//task 1 initialize

task initialize; begin

FD = $fopen ("tb_priority_arbiter.tv" , "r");
COUNT = $fscanf (FD, "%s", COMMENT);

COUNT = $fscanf (FD, "%s %b %b %b", COMMENT, RST, REQ, GNT_EXPECTED);
TICK = 0;
VECTORCOUNT = 0;
ERRORS = 0;

for(i=0; i<18; i++)begin
input_coverage[i] = 0;
end

eof = 0;

$display ();
$display ("TEST_START-------------------------------------------------------------------------------------------------------------------------------------");
$display ();
$display ("                     | TIME | RST | REQ  | GNT  | GNT_EXPECTED |");
$display ("-----------------------------------------------------------------------------------------------------------------------------------------------");



end
endtask


//task 3 scan_file

task scan_file; begin
COUNT = $fscanf (FD, "%s %b %b %b", COMMENT, RST, REQ, GNT_EXPECTED);
eof = (COUNT == -1);

end
endtask

//task 4 random_in

task random_in; begin

RST =  $urandom %2;
REQ =  (RST == 1'b1)?$urandom %2: $urandom %16;

COMMENT = "-";

# ($urandom_range(0.1,10));

end
endtask

//task5 OUT_EXP

task OUT_EXP; begin

if(RST) begin
GNT_EXPECTED <= 4'b0000;
end

else if(REQ[3])begin
GNT_EXPECTED <= 4'b1000;
end

else if(REQ[2])begin
GNT_EXPECTED <= 4'b0100;
end

else if(REQ[1])begin
GNT_EXPECTED <= 4'b0010;
end

else if(REQ[0])begin
GNT_EXPECTED <= 4'b0001;
end

else begin
GNT_EXPECTED <= 4'b0000;
end

end
endtask



//task 5 close

task close; begin

#10;

$fclose (FD);

$display ();
$display ("COVERAGE_REPORT");

for (int j = 0; j < 18; j++ ) begin

if(input_coverage[j] == 0) begin
$display ("input reset = %b, g[3] = %b, g[2] = %b, g[1] = %b, g[0] = %b has occured %d times ***ERROR***", j[4], j[3], j[2], j[1], j[0], input_coverage[j]);
ERRORS = ERRORS + 1;
end

else begin
$display ("input reset = %b, g[3] = %b, g[2] = %b, g[1] = %b, g[0] = %b has occured %d times", j[4], j[3], j[2], j[1], j[0], input_coverage[j]);
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

$display ("%10d %9s | %4d | %2b  | %4b | %4b | %9b    |", VECTORCOUNT, COMMENT, $time, RST, REQ, GNT, GNT_EXPECTED);

end
endtask

//task 8 coverage_update

task coverage_update; begin


input_coverage[{RST,REQ}]++;


end
endtask




//task 9 errors_warnings_check

task errors_warnings_check; begin


if (GNT !== GNT_EXPECTED) begin

$display ("***ERROR: GNT = %b, GNT_expected = %b", GNT, GNT_EXPECTED);
ERRORS = ERRORS + 1;

end



if ({RST,REQ} !== prev_RSTREQ) begin

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

#1.2;

if (!eof) begin

scan_file;

end
end

//posedge reset
always  @ (posedge TICK or posedge RST) begin

OUT_EXP;

end

//3 check file on posedge TICK

always  @ (posedge TICK) begin

coverage_update;
prev_RSTREQ = {RST,REQ};

#0.1;
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


if ({RST,REQ} == 6'b100000)
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

