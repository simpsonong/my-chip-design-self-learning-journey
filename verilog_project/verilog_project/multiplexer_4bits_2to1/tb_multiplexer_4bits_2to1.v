module tb_multiplexer_4bits_2to1;

//VECTORS FOR DUT
reg EN;
reg SEL;
reg[3:0] A,B;
wire[3:0] Y;

//VECTORS FOR TESTING

reg TICK;
integer FD, COUNT;
reg [8*31-1:0] COMMENT;
reg [3:0] Y_EXPECTED;
reg [31:0] VECTORCOUNT, ERRORS;
int i;
reg [31:0] input_coverage [0:3];
reg eof;
reg [7:0]J;

//DUT INSTANTIATION

multiplexer_4bits_2to1 dut_multiplexer_4bits_2to1 (.en(EN), .sel(SEL), .a(A), .b(B), .y(Y));



//DUMP EVERYTHING INTO DUMPFILE

initial begin

$dumpfile ("tb_multiplexer_4bits_2to1.vcd");
$dumpvars (0, tb_multiplexer_4bits_2to1);

end

//TICKPERIOD

localparam TICKPERIOD = 20;

always begin

#(TICKPERIOD/2) TICK = ~TICK;

end



//TASKS

//task 1 initialize

task initialize; begin

FD = $fopen ("tb_multiplexer_4bits_2to1.tv" , "r");
COUNT = $fscanf (FD, "%s", COMMENT);

COUNT = $fscanf (FD, "%s %b %b %b %b %b ", COMMENT, EN, SEL, A, B, Y_EXPECTED);
TICK = 0;
VECTORCOUNT = 0;
ERRORS = 0;

for(i=0; i<4; i++)begin
input_coverage[i] = 0;
end

eof = 0;


$display ();
$display ("TEST_START-------------------------------------------------------------------------------------------------------------------------------------");
$display ();
$display ("                     | TIME | EN | SEL |  A   |  B   |  Y   | Y_EXPECTED |");
$display ("-----------------------------------------------------------------------------------------------------------------------------------------------");



end
endtask


//task 3 scan_file

task scan_file; begin

COUNT = $fscanf (FD, "%s %b %b %b %b %b ", COMMENT, EN, SEL, A, B, Y_EXPECTED);
eof = (COUNT == -1);

end
endtask

//task 4 random_in

task random_in; begin

EN =$urandom %2;
SEL =(EN == 0)? 0: $urandom %2;
A = $urandom %16;
B = $urandom %16;

COMMENT = "-";

# ($urandom_range(0.1,10));

end
endtask

//task5 OUT_EXP

task OUT_EXP; begin

if(!EN)begin
Y_EXPECTED = 4'b0000;
end

else begin

case(SEL)
1'b0: Y_EXPECTED = A;
1'b1: Y_EXPECTED = B;
endcase

end


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
$display ("input EN = %b with SEL = %b has occured %d times ***ERROR***", j[1], j[0], input_coverage[j]);
ERRORS = ERRORS + 1;
end

else if(j == 1) begin
$display ("input EN = %b with SEL = %b has occured %d times ***LOGIC SAME AS EN = 0 WITH SEL = 0***", j[1], j[0], input_coverage[j]); 
end


else begin
$display ("input EN = %b with SEL = %b has occured %d times", j[1], j[0], input_coverage[j]);
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

$display ("%10d %9s | %4d | %1b  |  %1b  | %4b | %4b | %4b | %7b    |", VECTORCOUNT, COMMENT, $time, EN, SEL, A, B, Y,  Y_EXPECTED);

end
endtask

//task 8 coverage_update

task coverage_update; begin

input_coverage[{EN,SEL}]++;

if(EN == 1'b0 && SEL == 1'b0)begin
input_coverage[{1'b0,1'b1}]++;
end

end
endtask




//task 9 errors_warnings_check

task errors_warnings_check; begin


if (Y !== Y_EXPECTED) begin

$display ("***ERROR: Y = %b, Y_expected = %b", Y, Y_EXPECTED);
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


if (EN == 1'b1 && SEL == 2'b10)
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

