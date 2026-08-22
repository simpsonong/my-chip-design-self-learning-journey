`timescale 1ns/1ps
module tb_register_8_bit_posedge_sync_enable;

//VECTORS FOR DUT
reg TICK;
wire EN;
wire [DATA_WIDTH-1:0] D;
wire [DATA_WIDTH-1:0] Q;

//VECTORS FOR TESTING
reg [8*31-1:0] COMMENT;
wire EMPTY_EXPECTED,FULL_EXPECTED;
reg [DATA_WIDTH-1:0] Q_EXPECTED;
reg [ADDR_WIDTH-1:0] prev_ADDR_EXPECTED;
wire [ADDR_WIDTH-1:0] ADDR_EXPECTED;
wire [DATA_WIDTH-1:0]DATA_OUT_EXPECTED;
reg [31:0] VECTORCOUNT, ERRORS;
int i;
reg [31:0] prev_state_input_coverage[0:23];
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
wire NOTHING;
reg flag_X;
reg prev_en[0:3];
reg flag_init;
wire flag_01,flag_10,flag_00,flag_11,flag_freq;
reg [4:0]c;
wire [4:0]start_test;

parameter DATA_WIDTH = 8, ADDR_WIDTH = 4, MEM_DEPTH = 16, TICKPERIOD = 20;


//DUT INSTANTIATION

input_register dut_input_register (.TICKPERIOD(TICKPERIOD), .TICK(TICK), .EN(EN), .D(D), .eof(eof), .done(done), .flag_init(flag_init),
                                   .flag_01(flag_01), .flag_10(flag_10), .flag_00(flag_00),.flag_11(flag_11),.flag_freq(flag_freq),
                                   .start_test(start_test));

register_8_bit_posedge_sync_enable dut_register_8_bit_posedge_sync_enable (.clk(TICK), .en(EN), .d(D), .q(Q));



// OUT_EXP

dff_posedge_sync_enable1 dff_posedge_sync_enable1_0(.clk(TICK),.enable(EN),.d(D[0]),.q(Q_EXPECTED[0]),.qbar(NOTHING));
dff_posedge_sync_enable1 dff_posedge_sync_enable1_1(.clk(TICK),.enable(EN),.d(D[1]),.q(Q_EXPECTED[1]),.qbar(NOTHING));
dff_posedge_sync_enable1 dff_posedge_sync_enable1_2(.clk(TICK),.enable(EN),.d(D[2]),.q(Q_EXPECTED[2]),.qbar(NOTHING));
dff_posedge_sync_enable1 dff_posedge_sync_enable1_3(.clk(TICK),.enable(EN),.d(D[3]),.q(Q_EXPECTED[3]),.qbar(NOTHING));
dff_posedge_sync_enable1 dff_posedge_sync_enable1_4(.clk(TICK),.enable(EN),.d(D[4]),.q(Q_EXPECTED[4]),.qbar(NOTHING));
dff_posedge_sync_enable1 dff_posedge_sync_enable1_5(.clk(TICK),.enable(EN),.d(D[5]),.q(Q_EXPECTED[5]),.qbar(NOTHING));
dff_posedge_sync_enable1 dff_posedge_sync_enable1_6(.clk(TICK),.enable(EN),.d(D[6]),.q(Q_EXPECTED[6]),.qbar(NOTHING));
dff_posedge_sync_enable1 dff_posedge_sync_enable1_7(.clk(TICK),.enable(EN),.d(D[7]),.q(Q_EXPECTED[7]),.qbar(NOTHING));




//DUMP EVERYTHING INTO DUMPFILE

initial begin

$dumpfile ("tb_register_8_bit_posedge_sync_enable.vcd");
$dumpvars (0, tb_register_8_bit_posedge_sync_enable);

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

for(i=0; i<5; i++)begin
prev_state_input_coverage[i] = 0;
state_input_coverage[i] = 0;
end


$display ();
$display ("I apply both inputs and computations simutaneously on the posedge of the clock, so the output is delayed by one cycle");
$display ();
$display ("TEST_START------------------------------------------------------------------------");
$display ();
$display ("                                | TIME | EN |    D     |    Q     | Q_EXPECTED |");
$display ("----------------------------------------------------------------------------------");


end
endtask




//task4 COMMENT
task comment; begin


if(eof)begin
COMMENT = "RANDOM_INPUT";
end
else if(start_test[4])begin
COMMENT = "change_frequently";
c[3]=1;
end
else if(start_test[3])begin
COMMENT = "mantain_1";
c[2]=1;
end
else if(start_test[2])begin
COMMENT = "mantain_0";
c[1]=1;
end
else if(start_test[1])begin
COMMENT = "1_to_0";
c[0]=1;
end
else if(start_test[0])begin
COMMENT = "0_to_1";
end
else if(flag_init & $time < 2*TICKPERIOD/2)begin
COMMENT = "INIT";
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



for (int j = 0; j < 5; j++ ) begin

if(j<2)begin
if(state_input_coverage[j] == 0) begin
$display ("state of en = %b to en = %b has occured %d times ***ERROR***", j[0], ~j[0], state_input_coverage[j]);
ERRORS = ERRORS + 1;
end
else begin
$display ("state of en = %b to en = %b has occured %d times ", j[0], ~j[0], state_input_coverage[j]);
end
end
else if (j<4)begin
if(state_input_coverage[j] == 0) begin
$display ("state of en maintain %b has occured %d times ***ERROR***", j[0], state_input_coverage[j]);
ERRORS = ERRORS + 1;
end
else begin
$display ("state of en maintain %b has occured %d times", j[0], state_input_coverage[j]);
end
end
else if (j==4)begin
if(state_input_coverage[j] == 0) begin
$display ("state of en changes freqly has occured %d times ***ERROR*** ", state_input_coverage[j]);
ERRORS = ERRORS + 1;
end
else begin
$display ("state of en changes freqly has occured %d times ", state_input_coverage[j]);
end
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

$display ("%10d %20s | %4d | %2b | %8b | %8b |  %8b  |", VECTORCOUNT, COMMENT, $time, EN, D, Q, Q_EXPECTED);
end
endtask



//task 8 in_coverage_update

task coverage_update; begin


if(flag_01)begin
state_input_coverage[0]++;
end
if(flag_10)begin
state_input_coverage[1]++;
end
if(flag_00)begin
state_input_coverage[2]++;
end
if(flag_11)begin
state_input_coverage[3]++;
end
if(flag_freq)begin
state_input_coverage[4]++;
end


end
endtask




//task 9 errors_warnings_check

task errors_warnings_check; begin

if (Q !== Q_EXPECTED) begin
$display ("***ERROR: Q = %b, Q_expected = %b", Q, Q_EXPECTED);
ERRORS = ERRORS + 1;
end

end
endtask



//DRIVE

//0 initialize

initial begin

initialize;

end



//3 check file on  posedge TICK


always  @ (posedge TICK) begin
coverage_update;

#0.1;
comment;
display_file;
errors_warnings_check;
vectorcount;

#0.1;
prev_en[0] <= EN;
prev_en[1] <= prev_en[0];
prev_en[2] <= prev_en[1];
prev_en[3] <= prev_en[2];

for(int j=0; j<5; j++)begin
prev_state_input_coverage[j] <= state_input_coverage[j];
end

end


// eof

initial begin

wait (eof);

$display ();
$display("%13s ***time = %0d,eof ***","",$time);
$display ();
$display ("random stimulus to improve coverage");

end

always@(posedge TICK)begin

if (Q_EXPECTED === 9'b100000000)
begin
vectorcount;
close;
end

else if(done)begin
close;
end

end


endmodule
