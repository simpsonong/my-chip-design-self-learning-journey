`timescale 1ns/10ps

module tb_decoder;

//VECTORS FOR DUT
reg[2:0] IN;
wire[7:0] OUT;
wire[7:0] OUT_fast;
//VECTORS FOR TESTING

reg TICK;
integer FD, COUNT;
reg [8*31-1:0] COMMENT;
reg [7:0] OUT_EXPECTED;
reg [31:0] VECTORCOUNT, ERRORS;
int i;
reg [31:0] input_coverage [0:7];
reg eof;
reg [7:0]J;

//DUT INSTANTIATION

decoder dut_decoder (.in(IN), .out(OUT));
decoder_fast dut_decoder_fast (.in(IN), .out(OUT_fast));



//DUMP EVERYTHING INTO DUMPFILE

initial begin

$dumpfile ("tb_decoder.vcd");
$dumpvars (0, tb_decoder);

end

//TICKPERIOD

localparam TICKPERIOD = 20;

always begin

#(TICKPERIOD/2) TICK = ~TICK;

end



//TASKS

//task 1 initialize

task initialize; begin

FD = $fopen ("tb_decoder.tv" , "r");
COUNT = $fscanf (FD, "%s", COMMENT);

COUNT = $fscanf (FD, "%s %b %b", COMMENT, IN, OUT_EXPECTED);
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
$display ("                     | TIME | IN  |   OUT    | OUT_fast | OUT_EXPECTED |");
$display ("-----------------------------------------------------------------------------------------------------------------------------------------------");



end
endtask


//task 3 scan_file

task scan_file; begin

COUNT = $fscanf (FD, "%s %b %b", COMMENT, IN, OUT_EXPECTED);
eof = (COUNT == -1);

end
endtask

//task 4 random_in

task random_in; begin


IN =  $urandom %8;
COMMENT = "-";

# ($urandom_range(0.1,10));

end
endtask

//task5 OUT_EXP

task OUT_EXP; begin

reg found;
    found = 1'b0;   // 标记是否已经找到第一个1
     
    
    for (int j = 0; j < 8; j++) begin

     J=8'b0;
     J[j]=1'b1;
    
     if (!found && IN == j[2:0]) begin
            OUT_EXPECTED = J;
            found = 1'b1;  // 找到后再也不更新 out
        end
    end


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
$display ("input IN = %b has occured %d times ***ERROR***", j[2:0], input_coverage[j]);
ERRORS = ERRORS + 1;
end

else begin
$display ("input IN = %b has occured %d times", j[2:0], input_coverage[j]);
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

$display ("%10d %9s | %3d | %2b  | %8b | %8b | %10b   |", VECTORCOUNT, COMMENT, $time, IN, OUT, OUT_fast, OUT_EXPECTED);

end
endtask

//task 8 coverage_update

task coverage_update; begin

input_coverage[IN]++;

end
endtask




//task 9 errors_warnings_check

task errors_warnings_check; begin


if (OUT !== OUT_EXPECTED) begin

$display ("***ERROR: OUT = %b, OUT_expected = %b", OUT, OUT_EXPECTED);
ERRORS = ERRORS + 1;

end

if (OUT_fast !== OUT_EXPECTED) begin

$display ("***ERROR: OUT_fast = %b, OUT_expected = %b", OUT_fast, OUT_EXPECTED);
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


if (IN == 4'b1000)
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
