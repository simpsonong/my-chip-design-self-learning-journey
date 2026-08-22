module tb_mux_to_demux;

//VECTORS FOR DUT
reg[1:0] SEL;
reg A,B,C,D;
wire A_OUT,B_OUT,C_OUT,D_OUT;


//VECTORS FOR TESTING

reg TICK;
integer FD, COUNT;
reg [8*31-1:0] COMMENT;
reg A_EXPECTED,B_EXPECTED,C_EXPECTED,D_EXPECTED;
reg [31:0] VECTORCOUNT, ERRORS;
int i;
reg [31:0] input_coverage [0:3];
reg eof;
reg [7:0]J;

//DUT INSTANTIATION

mux_to_demux dut_mux_to_demux (.sel(SEL), .a(A), .b(B), .c(C), .d(D), .a_out(A_OUT), .b_out(B_OUT), .c_out(C_OUT), .d_out(D_OUT) );



//DUMP EVERYTHING INTO DUMPFILE

initial begin

$dumpfile ("tb_mux_to_demux.vcd");
$dumpvars (0, tb_mux_to_demux);

end

//TICKPERIOD

localparam TICKPERIOD = 20;

always begin

#(TICKPERIOD/2) TICK = ~TICK;

end



//TASKS

//task 1 initialize

task initialize; begin

FD = $fopen ("tb_mux_to_demux.tv" , "r");
COUNT = $fscanf (FD, "%s", COMMENT);

COUNT = $fscanf (FD, "%s %b %b %b %b %b %b %b %b %b", COMMENT, SEL, A, B, C, D, A_EXPECTED, B_EXPECTED, C_EXPECTED, D_EXPECTED);
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
$display ("                     | TIME | SEL | A | B | C | D | A_OUT | B_OUT | C_OUT | D_OUT | A_EXPECTED | B_EXPECTED | C_EXPECTED | D_EXPECTED |");
$display ("-----------------------------------------------------------------------------------------------------------------------------------------------");



end
endtask



//task 3 scan_file

task scan_file; begin

COUNT = $fscanf (FD, "%s %b %b %b %b %b %b %b %b %b", COMMENT, SEL, A, B, C, D, A_EXPECTED, B_EXPECTED, C_EXPECTED, D_EXPECTED);
eof = (COUNT == -1);

end
endtask

//task 4 random_in

task random_in; begin

SEL = $urandom %4;
A = $urandom %2;
B = $urandom %2;
C = $urandom %2;
D = $urandom %2;

COMMENT = "-";

# ($urandom_range(0.1,10));

end
endtask

//task5 OUT_EXP

task OUT_EXP; begin

case(SEL)
2'b00: begin
A_EXPECTED = A; B_EXPECTED = 1'b0; C_EXPECTED = 1'b0; D_EXPECTED = 1'b0;
end
2'b01: begin
A_EXPECTED = 1'b0; B_EXPECTED = B; C_EXPECTED = 1'b0; D_EXPECTED = 1'b0;
end
2'b10: begin
A_EXPECTED = 1'b0; B_EXPECTED = 1'b0; C_EXPECTED = C; D_EXPECTED = 1'b0;
end
2'b11: begin
A_EXPECTED = 1'b0; B_EXPECTED = 1'b0; C_EXPECTED = 1'b0; D_EXPECTED = D;
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

for (int j = 0; j < 4; j++ ) begin


if(input_coverage[j] == 0) begin
$display ("input SEL = %b has occured %d times ***ERROR***", j[1:0], input_coverage[j]);
ERRORS = ERRORS + 1;
end

else begin
$display ("input SEL = %b has occured %d times", j[1:0], input_coverage[j]);
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

$display ("%10d %9s | %4d | %2b  | %1b | %1b | %1b | %1b | %3b   | %3b   | %3b   | %3b   | %5b      | %5b      | %5b      | %5b      |", VECTORCOUNT, COMMENT, $time, SEL, A, B, C, D, A_OUT, B_OUT, C_OUT, D_OUT, A_EXPECTED, B_EXPECTED, C_EXPECTED, D_EXPECTED);

end
endtask

//task 8 coverage_update

task coverage_update; begin

input_coverage[SEL]++;


end
endtask




//task 9 errors_warnings_check

task errors_warnings_check; begin


if (A_OUT !== A_EXPECTED) begin

$display ("***ERROR: A_OUT = %b, A_expected = %b", A_OUT, A_EXPECTED);
ERRORS = ERRORS + 1;

end


if (B_OUT !== B_EXPECTED) begin

$display ("***ERROR: B_OUT = %b, B_expected = %b", B_OUT, B_EXPECTED);
ERRORS = ERRORS + 1;

end


if (C_OUT !== C_EXPECTED) begin

$display ("***ERROR: C_OUT = %b, C_expected = %b", C_OUT, C_EXPECTED);
ERRORS = ERRORS + 1;

end


if (D_OUT !== D_EXPECTED) begin

$display ("***ERROR: D_OUT = %b, D_expected = %b", D_OUT,D_EXPECTED);
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


if (SEL == 3'b100)
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

