`timescale 1ns/10ps

module tb_demultiplexer;

//VECTORS FOR DUT
reg Y;
reg[1:0] SEL;
wire A,B,C,D;

//VECTORS FOR TESTING

reg TICK;
integer FD, COUNT;
reg [8*31-1:0] COMMENT;
reg A_EXPECTED,B_EXPECTED,C_EXPECTED,D_EXPECTED;
reg [31:0] VECTORCOUNT, ERRORS;
int i;
reg [31:0] input_coverage [0:7];
reg eof;
reg [7:0]J;

//DUT INSTANTIATION

demultiplexer dut_demultiplexer (.y(Y), .sel(SEL), .a(A), .b(B), .c(C), .d(D));



//DUMP EVERYTHING INTO DUMPFILE

initial begin

$dumpfile ("tb_demultiplexer.vcd");
$dumpvars (0, tb_demultiplexer);

end

//TICKPERIOD

localparam TICKPERIOD = 20;

always begin

#(TICKPERIOD/2) TICK = ~TICK;

end



//TASKS

//task 1 initialize

task initialize; begin

FD = $fopen ("tb_demultiplexer.tv" , "r");
COUNT = $fscanf (FD, "%s", COMMENT);

COUNT = $fscanf (FD, "%s %b %b %b %b %b %b", COMMENT, Y, SEL, A_EXPECTED, B_EXPECTED, C_EXPECTED, D_EXPECTED);
TICK = 0;
VECTORCOUNT = 0;
ERRORS = 0;

for(i=0; i<8; i++)begin
input_coverage[i] = 0;
end

eof = 0;


$display ();
$display ("TEST_START-------------------------------------------------------------------------------------------------------------------------------------");
$display ();
$display ("                     | TIME | Y | SEL | A | B | C | D | A_EXPECTED | B_EXPECTED | C_EXPECTED | D_EXPECTED |");
$display ("-----------------------------------------------------------------------------------------------------------------------------------------------");



end
endtask


//task 3 scan_file

task scan_file; begin

COUNT = $fscanf (FD, "%s %b %b %b %b %b %b", COMMENT, Y, SEL, A_EXPECTED, B_EXPECTED, C_EXPECTED, D_EXPECTED);
eof = (COUNT == -1);

end
endtask

//task 4 random_in

task random_in; begin


Y =  $urandom %2;
SEL = (Y == 0)? 2'b00: $urandom %4;

COMMENT = "-";

# ($urandom_range(0.1,10));

end
endtask

//task5 OUT_EXP

task OUT_EXP; begin

case(SEL)
2'b00: begin
A_EXPECTED = Y; B_EXPECTED = 1'b0; C_EXPECTED = 1'b0; D_EXPECTED = 1'b0;
end
2'b01: begin
A_EXPECTED = 1'b0; B_EXPECTED = Y; C_EXPECTED = 1'b0; D_EXPECTED = 1'b0;
end
2'b10: begin
A_EXPECTED = 1'b0; B_EXPECTED = 1'b0; C_EXPECTED = Y; D_EXPECTED = 1'b0;
end
2'b11: begin
A_EXPECTED = 1'b0; B_EXPECTED = 1'b0; C_EXPECTED = 1'b0; D_EXPECTED = Y;
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

for (int j = 0; j < 8; j++ ) begin


if(input_coverage[j] == 0) begin
$display ("input Y = %b with SEL = %b has occured %d times ***ERROR***", j[2], j[1:0] , input_coverage[j]);
ERRORS = ERRORS + 1;
end

else if(j>0 && j<4) begin
$display ("input Y = %b with SEL = %b has occured %d times ***SAME LOGIC AS Y=1'b0 with SEL=2'b00*** ", j[2], j[1:0] , input_coverage[j]);
end


else begin
$display ("input Y = %b with SEL = %b has occured %d times ", j[2], j[1:0] , input_coverage[j]);
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

$display ("%10d %9s | %4d | %1b | %1b  | %1b | %1b | %1b | %1b | %5b      | %5b      | %5b      | %5b      |", VECTORCOUNT, COMMENT, $time, Y, SEL, A, B, C, D, A_EXPECTED, B_EXPECTED, C_EXPECTED, D_EXPECTED);

end
endtask

//task 8 coverage_update

task coverage_update; begin

input_coverage[{Y,SEL}]++;

if(Y == 1'b0 && SEL == 2'b00)begin
for(int j=1; j<4; j++)
input_coverage[j]++;
end

end
endtask




//task 9 errors_warnings_check

task errors_warnings_check; begin


if (A !== A_EXPECTED) begin

$display ("***ERROR: A = %b, A_expected = %b", A, A_EXPECTED);
ERRORS = ERRORS + 1;

end


if (B !== B_EXPECTED) begin

$display ("***ERROR: B = %b, B_expected = %b", B, B_EXPECTED);
ERRORS = ERRORS + 1;

end


if (C !== C_EXPECTED) begin

$display ("***ERROR: C = %b, C_expected = %b", C, C_EXPECTED);
ERRORS = ERRORS + 1;

end


if (D !== D_EXPECTED) begin

$display ("***ERROR: D = %b, D_expected = %b", D, D_EXPECTED);
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

OUT_EXP;
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


if (Y == 1'b1 && SEL == 3'b100)
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
