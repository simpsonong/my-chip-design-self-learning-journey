`timescale 1ns/1ps
module tb_lifo_synchronous;

//VECTORS FOR DUT
wire RST;
wire W_EN,R_EN;
wire  [DATA_WIDTH-1:0] DATA_IN;
wire FULL, EMPTY;
wire [ADDR_WIDTH:0] PTR;
wire [DATA_WIDTH-1:0] DATA_OUT;
wire [ADDR_WIDTH:0] ADDR0;
wire NEXTW;

//VECTORS FOR TESTING

reg TICK;
reg [8*31-1:0] COMMENT;
wire EMPTY_EXPECTED,FULL_EXPECTED;
reg [ADDR_WIDTH:0] PTR_EXPECTED;
reg [ADDR_WIDTH-1:0] prev_ADDR_EXPECTED;
wire [ADDR_WIDTH-1:0] ADDR_EXPECTED;
wire [DATA_WIDTH-1:0]DATA_OUT_EXPECTED;
reg [31:0] VECTORCOUNT, ERRORS;
int i;
reg [31:0] state_input_coverage[0:23];
reg [31:0] wrap_coverage;
wire eof;
reg [ADDR_WIDTH:0]prev_W_PTR;
reg [ADDR_WIDTH:0]prev_R_PTR;
reg [1:0]prev_state;
reg [DATA_WIDTH-1:0] MEM [0:MEM_DEPTH-1];
wire NEXT_W,NEXT_R;
wire WRAP;
wire done;
reg [ADDR_WIDTH:0] ADDR0_EXPECTED;


parameter DATA_WIDTH = 8, ADDR_WIDTH = 4, MEM_DEPTH = 16, TICKPERIOD = 20;


//DUT INSTANTIATION

input_lifo dut_input_lifo (.TICKPERIOD(TICKPERIOD), .TICK(TICK), .prev_state(prev_state), .RST(RST), .W_EN(W_EN), .DATA_IN(DATA_IN), .R_EN(R_EN), .eof(eof), .done(done));


lifo dut_lifo (.clk(TICK), .rst(RST), .w_en(W_EN), .r_en(R_EN), .data_in(DATA_IN), .full(FULL), .empty(EMPTY), .ptr(PTR),
 .data_out(DATA_OUT), .addr0(ADDR0), .nextw(NEXTW));

dual_port_ram_synchronous1 test_dual_port_ram_synchronous1(
.clk(TICK),.rst(RST), .we_a(NEXT_W), .addr_a(ADDR_EXPECTED), .data_in_a(DATA_IN), .data_out_a(),
.we_b(1'b0), .addr_b(ADDR_EXPECTED), .data_in_b(8'h00), .data_out_b(DATA_OUT_EXPECTED));




//DUMP EVERYTHING INTO DUMPFILE

initial begin

$dumpfile ("tb_lifo_synchronous.vcd");
$dumpvars (0, tb_lifo_synchronous);

end


//TICKPERIOD


always begin
#(TICKPERIOD/2) TICK <= ~TICK;
end



//TASKS

//task 1 initialize

task initialize; begin

TICK = 0;
VECTORCOUNT = 0;
ERRORS = 0;

for(i=0; i<5'b11000; i++)begin
state_input_coverage[i] = 0;
end

wrap_coverage = 0;


$display ();
$display ("TEST_START---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------");
$display ();
$display ("                     | TIME | RST | W_EN | R_EN | DATA_IN | ADDR0 | ADDR0_EXPECTED | WRAP | FULL | FULL_EXPECTED | EMPTY | EMPTY_EXPECTED | PTR | PTR_EXPECTED | DATA_OUT | DATA_OUT_EXPECTED |");
$display ("-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------");


end
endtask




//task4 COMMENT
task comment; begin

case({FULL_EXPECTED,EMPTY_EXPECTED})
2'b00: COMMENT = "NOT_FULL";
2'b01: COMMENT = "EMPTY";
2'b10: COMMENT = "FULL";
default: COMMENT = "ILLEGAL";
endcase

end
endtask




//task5 OUT_EXP
task OUT_EXP; begin

ADDR0_EXPECTED <= PTR_EXPECTED;

if(RST)
PTR_EXPECTED <= 5'b0;

else begin
case({NEXT_W,NEXT_R})
2'b01: PTR_EXPECTED <= PTR_EXPECTED - 1;
2'b10: PTR_EXPECTED <= PTR_EXPECTED + 1;
default: PTR_EXPECTED <= PTR_EXPECTED;
endcase
end


end
endtask

//task 5 close

task close; begin

#10;

$display ();
$display ("COVERAGE_REPORT");
$display ();
$display ();
$display ();



if(wrap_coverage == 0) begin
$display ("wrap around has occured %58d times ***ERROR***", wrap_coverage);
ERRORS = ERRORS + 1;
end


else begin
$display ("wrap around has occured %58d times", wrap_coverage);
end


for (int j = 0; j < 5'b11000; j++ ) begin


if(state_input_coverage[j] == 0) begin
$display ("state FULL = %b, EMPTY = %b, input RST = %b, W_EN = %b, R_EN = %b has occured %d times ***ERROR***", j[4], j[3], j[2], j[1], j[0], state_input_coverage[j]);
ERRORS = ERRORS + 1;
end

else if(j[2]==1 && j[1:0]!==2'b00) begin
$display ("state FULL = %b, EMPTY = %b, input RST = %b, W_EN = %b, R_EN = %b has occured %d times***identical behavior as RST=1,W_EN=0,R_EN=0,so it is left out from verification***", j[4], j[3], j[2], j[1], j[0], state_input_coverage[j]);
end

else begin
$display ("state FULL = %b, EMPTY = %b, input RST = %b, W_EN = %b, R_EN = %b has occured %d times", j[4], j[3], j[2], j[1], j[0], state_input_coverage[j]);
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

$display ("%10d %9s | %4d | %2b  | %2b   | %2b   | %4c    | %5b  | %10b      | %4b    | %2b   | %7b       | %3b   | %7b        | %5b | %9b      | %4c     | %9c         |", VECTORCOUNT, COMMENT, $time, RST, W_EN, R_EN, DATA_IN, ADDR0[ADDR_WIDTH-1:0], ADDR0_EXPECTED[ADDR_WIDTH-1:0], WRAP, FULL, FULL_EXPECTED, EMPTY, EMPTY_EXPECTED, PTR, PTR_EXPECTED, DATA_OUT, DATA_OUT_EXPECTED);
end
endtask



//task 8 in_coverage_update

task coverage_update; begin

state_input_coverage[{prev_state,RST,W_EN,R_EN}]++;

for(int j=0;j<3;j++)begin
for(int k=7;k>4;k--)begin
if(prev_state == j[1:0] && {RST,W_EN,R_EN} == 3'b100)begin
state_input_coverage[{j[1:0],k[2:0]}]++;
end
end
end


if(WRAP)
wrap_coverage++;


end
endtask




//task 9 errors_warnings_check

task errors_warnings_check; begin

if (ADDR0 !== ADDR0_EXPECTED) begin

$display ("***ERROR: ADDR = %b, ADDR_expected = %b", ADDR0, ADDR0_EXPECTED);
ERRORS = ERRORS + 1;

end




if (FULL !== FULL_EXPECTED) begin

$display ("***ERROR: FULL = %b, FULL_expected = %b", FULL, FULL_EXPECTED);
ERRORS = ERRORS + 1;

end


if (EMPTY !== EMPTY_EXPECTED) begin

$display ("***ERROR: EMPTY = %b, EMPTY_expected = %b", EMPTY, EMPTY_EXPECTED);
ERRORS = ERRORS + 1;

end


if (PTR !== PTR_EXPECTED) begin

$display ("***ERROR: PTR = %b, PTR_EXPECTED = %b", PTR, PTR_EXPECTED);
ERRORS = ERRORS + 1;

end


if (DATA_OUT !== DATA_OUT_EXPECTED) begin

$display ("***ERROR: DATA_OUT = %b, DATA_OUT_expected = %b", DATA_OUT, DATA_OUT_EXPECTED);
ERRORS = ERRORS + 1;

end

end
endtask

assign EMPTY_EXPECTED = PTR_EXPECTED == 0;
assign FULL_EXPECTED = PTR_EXPECTED == MEM_DEPTH;
assign NEXT_W = W_EN & !FULL_EXPECTED;
assign NEXT_R = R_EN & !EMPTY_EXPECTED;
assign ADDR_EXPECTED = PTR_EXPECTED[ADDR_WIDTH-1:0];
assign WRAP = PTR_EXPECTED == 5'b10000;

//DRIVE

//0 initialize

initial begin

initialize;

end



//3 check file on  posedge TICK

always  @ (posedge TICK or posedge RST) begin
OUT_EXP;
end

always  @ (posedge TICK or posedge RST) begin
coverage_update;
#0.1;
comment;
display_file;
errors_warnings_check;
vectorcount;

#0.1;
prev_ADDR_EXPECTED = ADDR_EXPECTED;
end

always@(posedge TICK)begin
prev_state = {FULL_EXPECTED,EMPTY_EXPECTED};
end

// eof

initial begin

wait (eof);

$display ();
$display("%13s ***time = %0d,eof ***","",$time);
$display ();

end

always@(posedge TICK)begin

if ({FULL,EMPTY,RST,W_EN,R_EN} == 6'b100000)
begin
vectorcount;
close;
end

else if(done)begin
close;
end

end


endmodule
