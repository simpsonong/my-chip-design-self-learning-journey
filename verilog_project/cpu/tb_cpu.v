`timescale 1ns/1ps
module tb_cpu;

//VECTOR FROM PARAMETER_SECTION



//VECTORS FOR DUT
reg TICK;
wire [3:0] OPCODE;
wire [DATA_WIDTH-1:0] DATA_IN_A;
wire [DATA_WIDTH-1:0] DATA_IN_B;
wire GO_BAR;
wire RESET;
wire JAM;
wire [DATA_WIDTH-1:0] MICROADDRESS;
wire [DATA_WIDTH-1:0] DATA_OUT;

//VECTORS FOR TESTING
reg [8*31-1:0] COMMENT;
reg [31:0] VECTORCOUNT, ERRORS;
int i;
reg [31:0] state_input_coverage[0:23];
reg [31:0] input_coverage[0:3];
wire eof;
wire done;
reg flag_init;
wire [4:0]start_test;
event post_process_event;

wire [23:0] MICROWORD_TB;
wire [3:0] STATUS_BIT_TB;
wire [7:0] MICROADRESS_TB;
wire EIL_BAR_TB;
wire [23:13] CONTROL_BITS_TB;
reg  [DATA_WIDTH-1:0]DATA_OUT_EXPECTED;



parameter TICKPERIOD = 20;

`include"parameter_section.vh"

//DUT INSTANTIATION


programable_8_bit_microprocessor dut_cpu (
    .CLK(TICK),
    .GO_BAR(GO_BAR),
    .RESET(RESET),
    .JAM(JAM),
    .OPCODE(OPCODE),
    .DATA_IN_A(DATA_IN_A),
    .DATA_IN_B(DATA_IN_B),
    .MICROADDRESS(MICROADDRESS),
    .DATA_OUT(DATA_OUT)
);




//OUT_EXP    ***edit***  done

control_store control_store1 (
    .microadress(MICROADRESS_TB),
    .microword(MICROWORD_TB)
);


control control_tb1 (
    .CLK(TICK),
    .DATA_IN_A(DATA_IN_A),
    .DATA_IN_B(DATA_IN_B),
    .RESET(RESET),
    .JAM(JAM),
    .GO_BAR(GO_BAR),
    .OPCODE(OPCODE),
    .MICROWORD(MICROWORD_TB),
    .STATUS_BIT(STATUS_BIT_TB),
    .CONTROL_BITS(CONTROL_BITS_TB),
    .MICORADRESS(MICORADRESS_TB),
    .EIL_BAR(EIL_BAR_TB)
);



processor processor_tb1 (
    .CONTROL_BITS(CONTROL_BITS_TB),
    .DATA_IN_A(DATA_IN_A),
    .DATA_IN_B(DATA_IN_B),
    .SYSTEM_CLK(TICK),
    .EIL_BAR(EIL_BAR_TB),
    .DATA_OUT(DATA_OUT_EXPECTED),
    .STATUS_BITS(STATUS_BITS_TB)
);


//DUMP EVERYTHING INTO DUMPFILE

initial begin

$dumpfile ("tb_cpu.vcd");
$dumpvars (0, tb_cpu);

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
$display ("TEST_START------------------------------------------------------------------------------------------------------------------------");
$display ();
$display ("                                | TIME | GO_BAR | RESET | JAM | OPCODE | DATA_IN_A | DATA_IN_B | DATA_OUT | DATA_OUT_EXPECTED |");
$display ("----------------------------------------------------------------------------------------------------------------------------------");


end
endtask



//task4 COMMENT
task comment; begin   //***edit***


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
$display ("input combination GO_BAR = %b, RESET = %b, JAM= %b and OPCODE =%b has occured %d times***ERROR***",j[6],j[5],j[4],j[3:0],input_coverage[j]);       //***edit*** done
ERRORS = ERRORS + 1;
end
else begin
$display ("input combination GO_BAR = %b, RESET = %b, JAM= %b and OPCODE =%b has occured %d times***ERROR***",j[6],j[5],j[4],j[3:0],input_coverage[j]);         //***edit*** done
end
end

for (int j = 0; j < total_num_of_group; j++ ) begin

if(j==0)begin
if(state_input_coverage[j] == 0) begin
$display ("not all input combination of {GO_BAR,RESET,JAM,OPCODE} has been tested***ERROR***");
ERRORS = ERRORS + 1;
end
else begin
$display ("all input combination of {GO_BAR,RESET,JAM,OPCODE} has been tested");
end
end
else if (j==1)begin          //***edit***
if(state_input_coverage[j] == 0) begin
$display ("input combination of LD_bar maintain 0 then 1 each for 4 posedge clk has been tested  ***ERROR***");
ERRORS = ERRORS + 1;
end
else begin                  
$display ("input combination of LD_bar maintain 0 then 1 each for 4 posedge clk has been tested ");
end
end
else if (j==2)begin         //***edit***  
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

$strobe ("%10d %20s | %4d | %4b   | %3b   | %2b  |  %8b |  %8b | %8b |      %8b     | ", VECTORCOUNT, COMMENT, $time, GO_BAR, RESET, JAM, DATA_IN_A, DATA_IN_B, DATA_OUT, DATA_OUT_EXPECTED);     //***edit*** done
end
endtask



//task 8 in_coverage_update  

task coverage_update; begin             

input_coverage[INPUT_drive[coverage_VECTOR_bits + total_DATA_WIDTH : total_DATA_WIDTH]]++;


if(flag_done[0])begin                   //***edit*** 
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
//INPUT COMBINATION        ***edit***  done
assign {GO_BAR,RESET,JAM,OPCODE,DATA_IN_A,DATA_IN_B} = INPUT_drive;                    //{GO_BAR,RESET,JAM,OPCODE,DATA_IN_A,DATA_IN_B} or something else


//3 check file on  posedge TICK

always  @ (posedge TICK) begin

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
