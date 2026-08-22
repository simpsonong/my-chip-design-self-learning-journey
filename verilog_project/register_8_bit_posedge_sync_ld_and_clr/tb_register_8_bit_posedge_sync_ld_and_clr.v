`timescale 1ns/1ps
module tb_register_8_bit_posedge_sync_ld_and_clr;

//VECTOR FROM PARAMETER_SECTION



//VECTORS FOR DUT
reg TICK;
wire CLR_bar,LD_bar;
wire [DATA_WIDTH-1:0] DATA_IN;
wire [DATA_WIDTH-1:0] DATA_OUT;

//VECTORS FOR TESTING
reg [8*31-1:0] COMMENT;
reg [DATA_WIDTH-1:0]DATA_OUT_EXPECTED;
reg [31:0] VECTORCOUNT, ERRORS;
int i;
reg [31:0] state_input_coverage[0:23];
reg [31:0] input_coverage[0:3];
wire eof;
wire done;
reg flag_init;
wire [4:0]start_test;
event post_process_event;


parameter TICKPERIOD = 20;

`include"parameter_section.vh"

//DUT INSTANTIATION


register_8_bit_posedge_sync_ld_and_clr dut_register_8_bit_posedge_sync_ld_and_clr (.clk(TICK),.clr_bar(CLR_bar), .ld_bar(LD_bar), .DATA_IN(DATA_IN), .DATA_OUT(DATA_OUT));




//DUMP EVERYTHING INTO DUMPFILE

initial begin

$dumpfile ("tb_register_8_bit_posedge_sync_ld_and_clr.vcd");
$dumpvars (0, tb_register_8_bit_posedge_sync_ld_and_clr);

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

for(i=0; i<total_num_of_group; i++)begin
state_input_coverage[i] = 0;
end

for(i=0; i<num_of_group_general; i++)begin
input_coverage[i] = 0;
end

$display ();
$display ();
$display ("TEST_START-------------------------------------------------------------------------------------------");
$display ();
$display ("                                | TIME | CLR_bar | LD_bar | DATA_IN  | DATA_OUT | DATA_OUT_EXPECTED |");
$display ("-----------------------------------------------------------------------------------------------------");


end
endtask



//task4 COMMENT
task comment; begin


if(eof)begin
COMMENT = "RANDOM_INPUT";
end
else if(start_test[2])begin
COMMENT = "change_frequently";
end
else if(start_test[1])begin
if(!LD_bar)begin
COMMENT = "MANTAIN_0";
end
else if(LD_bar)begin
COMMENT = "MANTAIN_1";
end
end
else if(start_test[0])begin
COMMENT = "GENERAL_TEST";
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

for (int j=0; j<num_of_group_general; j++) begin
if(input_coverage[j] == 0) begin
$display ("input combination CLR_bar = %b and LD_bar =%b has occured %d times***ERROR***",j[1],j[0],input_coverage[j]);
ERRORS = ERRORS + 1;
end
else begin
$display ("input combination CLR_bar = %b and LD_bar =%b has occured %d times",j[1],j[0],input_coverage[j]);
end
end

for (int j = 0; j < total_num_of_group; j++ ) begin

if(j==0)begin
if(state_input_coverage[j] == 0) begin
$display ("not all input combination of {CLR_bar,LD_bar} has been tested***ERROR***");
ERRORS = ERRORS + 1;
end
else begin
$display ("all input combination of {CLR_bar,LD_bar} has been tested");
end
end
else if (j==1)begin
if(state_input_coverage[j] == 0) begin
$display ("input combination of LD_bar maintain 0 then 1 each for 4 posedge clk has been tested  ***ERROR***");
ERRORS = ERRORS + 1;
end
else begin
$display ("input combination of LD_bar maintain 0 then 1 each for 4 posedge clk has been tested ");
end
end
else if (j==2)begin
if(state_input_coverage[j] == 0) begin
$display ("input combination {CLR_bar,LD_bar} toggle as complementary signals for 4 posedge clk has been tested ***ERROR*** ");
ERRORS = ERRORS + 1;
end
else begin
$display ("input combination {CLR_bar,LD_bar} toggle as complementary signals for 4 posedge clk has been tested");
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


//task 7 strobe_file

task strobe_file; begin

$strobe ("%10d %20s | %4d |    %1b    |   %1b    | %8b | %8b |     %8b      | ", VECTORCOUNT, COMMENT, $time, CLR_bar, LD_bar, DATA_IN, DATA_OUT, DATA_OUT_EXPECTED);
end
endtask



//task 8 in_coverage_update

task coverage_update; begin

input_coverage[{CLR_bar,LD_bar}]++;


if(flag_done[0])begin
state_input_coverage[0]++;  //GENERAL_TEST
end
if(flag_done[1])begin
state_input_coverage[1]++;  //MANTAIN_LD_0_then_1_TEST
end
if(flag_done[2])begin
state_input_coverage[2]++;  //FREQUENTLY_CHANGE_CLRbar_and_LDbar_TEST0
end


end
endtask




//task 9 errors_warnings_check

task errors_warnings_check; begin

if (DATA_OUT !== DATA_OUT_EXPECTED) begin
$display ("***ERROR: DATA_OUT = %b, DATA_OUT_expected = %b", DATA_OUT, DATA_OUT_EXPECTED);
ERRORS = ERRORS + 1;
end

end
endtask



//DRIVE

//0 initialize

initial begin

initialize;

end


//1 ASSIGN 
//INPUT COMBINATION
assign {CLR_bar,LD_bar,DATA_IN} = INPUT_drive;                    //{CLR_bar,LD_bar,DATA_IN} or something else


//3 check file on  posedge TICK

always  @ (posedge TICK) begin

for(int j=0;j<3;j++)begin
end

//OUT_EXP (it has to be written here instead of written as a task otherwise it will cause racing condition's error)
if(~CLR_bar)begin
DATA_OUT_EXPECTED <= 0;
end
else if(~LD_bar)begin
DATA_OUT_EXPECTED <= DATA_IN;
end


coverage_update;
-> post_process_event;

end


always@(post_process_event)begin
comment;
strobe_file;
errors_warnings_check;
vectorcount;


end


//4 eof

initial begin

wait (eof);

$display ();
$display("%13s ***time = %0d,eof ***","",$time);
$display ();
$display ("random stimulus to improve coverage");

end

always@(posedge TICK)begin
if (DATA_OUT_EXPECTED === 9'b100000000)
begin
vectorcount;
close;
end

else if(done)begin
close;
end

end


endmodule
