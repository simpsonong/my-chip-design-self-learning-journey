`timescale 1ns/10ps


module tb_fifo;

//VECTORS FOR DUT
reg RST;
reg PUSH,POP;
reg [DATA_WIDTH-1:0] DATA_IN;
wire FULL, EMPTY;
wire [ADDR_WIDTH:0] W_PTR, R_PTR;
wire [DATA_WIDTH-1:0] DATA_OUT;
wire [ADDR_WIDTH:0] ADDRA_ram,ADDRB_ram;
wire NEXTW;

//VECTORS FOR TESTING

reg TICK;
integer FD, COUNT;
reg [8*31-1:0] COMMENT;
reg EMPTY_EXPECTED,FULL_EXPECTED;
reg [ADDR_WIDTH:0] W_PTR_EXPECTED,R_PTR_EXPECTED;
reg [ADDR_WIDTH:0] prev_ADDRA_EXPECTED,prev_ADDRB_EXPECTED;
reg [ADDR_WIDTH:0] ADDRA_EXPECTED,ADDRB_EXPECTED;
wire [DATA_WIDTH-1:0]DATA_OUT_EXPECTED;
reg [31:0] VECTORCOUNT, ERRORS;
int i;
reg [31:0] state_input_coverage[0:23];
reg [31:0] wrap_coverage;
reg eof;
reg [10:0]prev_INPUT;
reg [4:0]prev_W_PTR;
reg [4:0]prev_R_PTR;
reg [1:0]prev_state;
reg [DATA_WIDTH-1:0] MEM [0:MEM_DEPTH-1];
reg NEXT_W,NEXT_R;
reg [ADDR_WIDTH-1:0]ADDR_A,ADDR_B;
reg WRAP_WR;


parameter DATA_WIDTH = 8, ADDR_WIDTH = 4, MEM_DEPTH = 16;


//DUT INSTANTIATION

fifo dut_fifo (.clk(TICK), .rst(RST), .push(PUSH), .pop(POP), .data_in(DATA_IN), .full(FULL), .empty(EMPTY), .w_ptr(W_PTR), .r_ptr(R_PTR), .data_out(DATA_OUT), .addra(ADDRA_ram), .addrb(ADDRB_ram), .nextw(NEXTW));
dual_port_ram_synchronous1 test_dual_port_ram_synchronous1(
.clk(TICK),.rst(RST), .we_a(NEXT_W), .addr_a(ADDR_A), .data_in_a(DATA_IN), .data_out_a(),
.we_b(1'b0), .addr_b(ADDR_B), .data_in_b(8'h00), .data_out_b(DATA_OUT_EXPECTED));



//DUMP EVERYTHING INTO DUMPFILE

initial begin

$dumpfile ("tb_fifo.vcd");
$dumpvars (0, tb_fifo);

end


//TICKPERIOD

localparam TICKPERIOD = 20;

always begin
#(TICKPERIOD/2) TICK <= ~TICK;
end



//TASKS

//task 1 initialize

task initialize; begin

FD = $fopen ("tb_fifo.tv" , "r");
COUNT = $fscanf (FD, "%s", COMMENT);
COUNT = $fscanf (FD, "%s %b %b %b %s", COMMENT, RST, PUSH, POP, DATA_IN);
TICK = 0;
VECTORCOUNT = 0;
ERRORS = 0;

for(i=0; i<48; i++)begin
state_input_coverage[i] = 0;
end

wrap_coverage = 0;

eof = 0;

$display ();
$display ("TEST_START--------------------------------------------------------------------------------------------------------------------------------------------------");
$display ();
$display ("                     | TIME | RST | PUSH | POP | DATA_IN | ADDR_A | ADDR_A_EXPECTED | ADDR_B | ADDR_B_EXPECTED | WRAP_WR | FULL | FULL_EXPECTED | EMPTY | EMPTY_EXPECTED | W_PTR | W_PTR_EXPECTED | R_PTR | R_PTR_EXPECTED | DATA_OUT | DATA_OUT_EXPECTED |");
$display ("------------------------------------------------------------------------------------------------------------------------------------------------------------");


end
endtask


//task 3 scan_file

task scan_file; begin

COUNT = $fscanf (FD, "%s %b %b %b %s", COMMENT, RST, PUSH, POP, DATA_IN);
eof = (COUNT == -1);

end
endtask

//task 4 random_in

task random_in; begin

RST =  $urandom %2;
POP = $urandom %2;
PUSH = $urandom %2;


# ($urandom_range(0.1,10));

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

//task4 ADDRAB_ram
task ADDRAB_ram;begin

ADDRA_EXPECTED = W_PTR_EXPECTED;
ADDRB_EXPECTED = R_PTR_EXPECTED;

end
endtask


//task5 NEXTWR_EXP

task NEXTWR_EXP; begin

NEXT_W = PUSH & !FULL_EXPECTED;
NEXT_R = POP & !EMPTY_EXPECTED;




end
endtask

//task5 OUT_EXP
task OUT_EXP; begin

if(RST)begin
W_PTR_EXPECTED = 5'b0;
end 
else if(NEXT_W) begin
W_PTR_EXPECTED = W_PTR_EXPECTED + 1;
end

if(RST)begin
R_PTR_EXPECTED = 5'b0;
end
else if(NEXT_R) begin
R_PTR_EXPECTED = R_PTR_EXPECTED + 1;
end

ADDR_A = W_PTR_EXPECTED[ADDR_WIDTH-1:0];
ADDR_B = R_PTR_EXPECTED[ADDR_WIDTH-1:0];

EMPTY_EXPECTED = (W_PTR_EXPECTED == R_PTR_EXPECTED);
FULL_EXPECTED = ((W_PTR_EXPECTED[ADDR_WIDTH] != R_PTR_EXPECTED[ADDR_WIDTH]) && (W_PTR_EXPECTED[ADDR_WIDTH-1:0] == R_PTR_EXPECTED[ADDR_WIDTH-1:0]));


WRAP_WR = (((ADDRA_EXPECTED[ADDR_WIDTH] != prev_ADDRA_EXPECTED[ADDR_WIDTH]) && (prev_ADDRA_EXPECTED[ADDR_WIDTH-1:0] == 4'b1111)) || ((ADDRB_EXPECTED[ADDR_WIDTH] != prev_ADDRB_EXPECTED[ADDR_WIDTH]) && (prev_ADDRB_EXPECTED[ADDR_WIDTH-1:0] == 4'b1111)));


NEXT_W = PUSH & !FULL_EXPECTED;
NEXT_R = POP & !EMPTY_EXPECTED;



end
endtask

//task 5 close

task close; begin

#10;

$fclose (FD);

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


for (int j = 0; j < 24; j++ ) begin

if(state_input_coverage[j] == 0) begin            
$display ("state FULL = %b, EMPTY = %b, input RST = %b, PUSH = %b, POP = %b has occured %d times ***ERROR***", j[4], j[3], j[2], j[1], j[0], state_input_coverage[j]);
ERRORS = ERRORS + 1;
end


else begin
$display ("state FULL = %b, EMPTY = %b, input RST = %b, PUSH = %b, POP = %b has occured %d times", j[4], j[3], j[2], j[1], j[0], state_input_coverage[j]);
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

$display ("%10d %9s | %4d | %2b  | %2b   | %2b  | %4c    | %5b  | %10b      | %5b  | %10b      | %4b    | %2b   | %7b       | %3b   | %7b        | %5b | %8b     | %5b | %8b     | %4c     | %9c         |", VECTORCOUNT, COMMENT, $time, RST, PUSH, POP, DATA_IN, ADDRA_ram[3:0], ADDRA_EXPECTED[3:0], ADDRB_ram[3:0], ADDRB_EXPECTED[3:0], WRAP_WR, FULL, FULL_EXPECTED, EMPTY, EMPTY_EXPECTED, W_PTR, W_PTR_EXPECTED, R_PTR, R_PTR_EXPECTED, DATA_OUT, DATA_OUT_EXPECTED);

end
endtask



//task 8 in_coverage_update

task coverage_update; begin

state_input_coverage[{prev_state,RST,PUSH,POP}]++;

for(int j=0;j<3;j++)begin


if(prev_state == j[1:0] && {RST,PUSH,POP} == 3'b111)begin
for(int k=6;k>3;k--)begin
state_input_coverage[{j[1:0],k[2:0]}]++;
end

end
end


if(WRAP_WR)
wrap_coverage++;


end
endtask




//task 9 errors_warnings_check

task errors_warnings_check; begin

if (ADDRA_ram !== ADDRA_EXPECTED) begin

$display ("***ERROR: ADDR_A = %b, ADDR_A_expected = %b", ADDR_A, ADDRA_EXPECTED);
ERRORS = ERRORS + 1;

end

if (ADDRB_ram !== ADDRB_EXPECTED) begin

$display ("***ERROR: ADDR_B = %b, ADDR_B_expected = %b", ADDR_B, ADDRB_EXPECTED);
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


if (W_PTR !== W_PTR_EXPECTED) begin

$display ("***ERROR: W_PTR = %b, W_PTR_expected = %b", W_PTR, W_PTR_EXPECTED);
ERRORS = ERRORS + 1;

end


if (R_PTR !== R_PTR_EXPECTED) begin

$display ("***ERROR: R_PTR = %b, R_PTR_expected = %b", R_PTR, R_PTR_EXPECTED);
ERRORS = ERRORS + 1;

end


if (DATA_OUT !== DATA_OUT_EXPECTED) begin

$display ("***ERROR: DATA_OUT = %b, DATA_OUT_expected = %b", DATA_OUT, DATA_OUT_EXPECTED);
ERRORS = ERRORS + 1;

end

if ({RST,PUSH,POP,DATA_IN} != prev_INPUT) begin
$display("prev_INPUT = %b,INPUT=%b",prev_INPUT,{RST,PUSH,POP,DATA_IN});
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
NEXTWR_EXP;

end
end



//3 check file on posedge TICK

always  @ (posedge TICK) begin
NEXTWR_EXP;
ADDRAB_ram;
prev_INPUT <= {RST,PUSH,POP,DATA_IN};
coverage_update;
OUT_EXP;
#0.1;
comment;
display_file;
errors_warnings_check;
vectorcount;

#0.1;
prev_ADDRA_EXPECTED <= ADDRA_EXPECTED;
prev_ADDRB_EXPECTED <= ADDRB_EXPECTED;
prev_state = {FULL_EXPECTED,EMPTY_EXPECTED};
end



// eof

initial begin

wait (eof);

$display ();
$display("%13s ***time = %0d,eof ***","",$time);
$display ();

for (i = 0; i < 50; i++) begin


if ({FULL,EMPTY,WRAP_WR,RST,PUSH,POP} == 7'b1000000)
begin

vectorcount;
close;

end

else begin

random_in;
NEXTWR_EXP;
end

end

close;

end


endmodule
