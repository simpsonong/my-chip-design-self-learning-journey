`timescale 1ns/10ps

module tb_buttons;

//VECTORS FOR DUT
reg PRESSED;
wire OUT_PRESSED, OUT_LOCK, OUT_TOGGER;

//VECTORS FOR TESTING

reg TICK;
integer FD, COUNT;
reg [8*31-1:0] COMMENT;
reg OUT_PRESSED_EXPECTED,OUT_LOCK_EXPECTED,OUT_TOGGLE_EXPECTED,OUT_TOGGLE_EXPECTED1;
reg [31:0] VECTORCOUNT, ERRORS;
int i;
reg [31:0] input_coverage[0:3];
reg eof;
reg LOCK;
reg TOGGLE;
reg prev_PRESSED;
reg prev_PRESSED_CHECK;

//DUT INSTANTIATION

buttons_pressed dut_buttons_pressed (.clk(TICK), .pressed(PRESSED), .out(OUT_PRESSED));
buttons_lock dut_buttons_lock (.clk(TICK), .pressed(PRESSED), .out(OUT_LOCK));
buttons_toggle dut_buttons_toggle (.clk(TICK), .pressed(PRESSED), .out(OUT_TOGGLE));


//DUMP EVERYTHING INTO DUMPFILE

initial begin

$dumpfile ("tb_buttons.vcd");
$dumpvars (0, tb_buttons);

end

//TICKPERIOD

localparam TICKPERIOD = 20;

always begin

#(TICKPERIOD/2) TICK = ~TICK;

end



//TASKS

//task 1 initialize

task initialize; begin

FD = $fopen ("tb_buttons.tv" , "r");
COUNT = $fscanf (FD, "%s", COMMENT);

COUNT = $fscanf (FD, "%s %b %b %b %b", COMMENT, PRESSED, OUT_PRESSED_EXPECTED, OUT_LOCK_EXPECTED, OUT_TOGGLE_EXPECTED);
TICK = 0;
VECTORCOUNT = 0;
ERRORS = 0;

for(i=0; i<4; i++)begin
input_coverage[i] = 0;
end

eof = 0;
LOCK = 1'b0;
TOGGLE = 1'b0;

$display ();
$display ("TEST_START-------------------------------------------------------------------------------------------------------------------------------------");
$display ();
$display ("                     | TIME | PRESSED | OUT_PRESSED | OUT_LOCK | OUT_TOGGLE | OUT_PRESSED_EXPECTED | OUT_LOCK_EXPECTED | OUT_TOGGLE_EXPECTED |");
$display ("-----------------------------------------------------------------------------------------------------------------------------------------------");



end
endtask

//task 2 force_release
task force_release; begin

force OUT_TOGGLE = 1'b0;
#10;
release OUT_TOGGLE;

end
endtask

//task 3 scan_file

task scan_file; begin
COUNT = $fscanf (FD, "%s %b %b %b %b", COMMENT, PRESSED, OUT_PRESSED_EXPECTED, OUT_LOCK_EXPECTED, OUT_TOGGLE_EXPECTED1);
eof = (COUNT == -1);

end
endtask

//task 4 random_in

task random_in; begin

PRESSED =  $urandom %2;

COMMENT = "-";

# ($urandom_range(0.1,10));

end
endtask

//task5 OUT_EXP

task OUT_EXP; begin


if(PRESSED)begin
OUT_PRESSED_EXPECTED = 1'b1;
end

else begin
OUT_PRESSED_EXPECTED = 1'b0;
end


if(PRESSED & ~LOCK)begin
OUT_LOCK_EXPECTED = 1'b1;
OUT_TOGGLE_EXPECTED = ~OUT_TOGGLE_EXPECTED;
LOCK = 1'b1;
end

else if (~PRESSED & LOCK)begin
OUT_LOCK_EXPECTED = 1'b0;
LOCK = 1'b0;
end

else begin
OUT_LOCK_EXPECTED = 1'b0;
OUT_TOGGLE_EXPECTED = OUT_TOGGLE_EXPECTED;
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
$display ("previous input PRESSED = %b and input PRESSED = %b has occured %d times ***ERROR***", j[1], j[0] , input_coverage[j]);
ERRORS = ERRORS + 1;
end



else begin
$display ("previous input PRESSED = %b and input PRESSED = %b has occured %d times", j[1], j[0] , input_coverage[j]);
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

$display ("%10d %9s | %4d | %4b    | %6b      | %5b    | %5b      | %10b           | %9b         | %10b          |", VECTORCOUNT, COMMENT, $time, PRESSED, OUT_PRESSED, OUT_LOCK, OUT_TOGGLE, OUT_PRESSED_EXPECTED, OUT_LOCK_EXPECTED, OUT_TOGGLE_EXPECTED);

end
endtask

//task 8 coverage_update

task coverage_update; begin

input_coverage[{PRESSED,LOCK}]++;

end
endtask




//task 9 errors_warnings_check

task errors_warnings_check; begin


if (OUT_PRESSED !== OUT_PRESSED_EXPECTED) begin

$display ("***ERROR: OUT_PRESSED = %b, OUT_PRESSED_expected = %b", OUT_PRESSED, OUT_PRESSED_EXPECTED);
ERRORS = ERRORS + 1;

end


if (OUT_LOCK !== OUT_LOCK_EXPECTED) begin

$display ("***ERROR: OUT_LOCK = %b, OUT_LOCK_expected = %b", OUT_LOCK, OUT_LOCK_EXPECTED);
ERRORS = ERRORS + 1;

end


if (OUT_TOGGLE !== OUT_TOGGLE_EXPECTED) begin

$display ("***ERROR: OUT_TOGGLE = %b, OUT_TOGGLE_expected = %b", OUT_TOGGLE, OUT_TOGGLE_EXPECTED);
ERRORS = ERRORS + 1;

end

if (PRESSED !== prev_PRESSED_CHECK) begin

$display ("***ERROR: RACING CONDITION OCCUR");
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
prev_PRESSED_CHECK = PRESSED;

#0.1;
OUT_EXP;
display_file;
errors_warnings_check;
vectorcount;

#0.1;

prev_PRESSED = PRESSED;

end



// eof

initial begin

wait (eof);

$display ();
$display("%13s ***time = %0d,eof ***","",$time);
$display ();

for (i = 0; i < 50; i++) begin


if (PRESSED == 2'b10)
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
