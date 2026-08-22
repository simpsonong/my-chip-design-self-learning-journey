`timescale 1ns/1ps
module tb_shift_register;

//VECTORS FOR DUT
reg TICK;
wire RST;
wire DATA_IN;
wire [DATA_WIDTH-1:0] DATA_OUT;

//VECTORS FOR TESTING
reg [8*31-1:0] COMMENT;
reg [DATA_WIDTH-1:0]DATA_OUT_EXPECTED;
reg [31:0] VECTORCOUNT, ERRORS;
int i;
reg [31:0] state_input_coverage[0:1];
reg [31:0] input_coverage[0:1];
wire eof;
wire done;
reg flag_init;
wire flag_general,flag_lsb_to_msb;
wire [3:0]start_test;

parameter DATA_WIDTH = 8, TICKPERIOD = 20;


//DUT INSTANTIATION

input_shift_register dut_input_shift_register (.TICKPERIOD(TICKPERIOD), .TICK(TICK), .RST(RST), .D(DATA_IN), .eof(eof), .done(done), .flag_init(flag_init),
                                   .flag_general(flag_general), .flag_lsb_to_msb(flag_lsb_to_msb),
                                   .start_test(start_test));


shift_register dut_shift_register (.clk(TICK),.rst(RST), .data_in(DATA_IN), .data_out(DATA_OUT));




//DUMP EVERYTHING INTO DUMPFILE

initial begin

$dumpfile ("tb_shift_register.vcd");
$dumpvars (0, tb_shift_register);

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

for(i=0; i<2; i++)begin
input_coverage[i] = 0;
end

for(i=0; i<2; i++)begin
state_input_coverage[i] = 0;
end


$display ();
$display ();
$display ("TEST_START-------------------------------------------------------------------------------------------");
$display ();
$display ("                                | TIME | RST | DATA_IN  | DATA_OUT | DATA_OUT_EXPECTED |");
$display ("-----------------------------------------------------------------------------------------------------");


end
endtask


//task4 COMMENT
task comment; begin


if(eof)begin
COMMENT = "RANDOM_INPUT";
end
else if(start_test[3])begin
COMMENT = "LSB_to_MSB";
end
else if(start_test[1])begin
COMMENT = "RST=1";
end
else if(start_test[0])begin
COMMENT = "RST=0";
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

for (int j=0; j<2; j++) begin
if(input_coverage[j] == 0) begin
$display ("input RST =%b has occured %d times***ERROR***",j[0],input_coverage[j]);
ERRORS = ERRORS + 1;
end
else begin
$display ("input RST =%b has occured %d times",j[0],input_coverage[j]);
end
end

for (int j=0; j<2; j++) begin

if(j==0)begin
if(state_input_coverage[j] == 0) begin
$display ("not all input combination of RST has been tested***ERROR***");
ERRORS = ERRORS + 1;
end
else begin
$display ("all input combination of RST has been tested");
end
end
else if (j==1)begin
if(state_input_coverage[j] == 0) begin
$display ("input shifting from LSB to MSB has not been tested  ***ERROR***");
ERRORS = ERRORS + 1;
end
else begin
$display ("input shifting from LSB to MSB has been tested");
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


//task 7 strobe_vector

task strobe_vector; begin

$strobe ("%10d %20s | %4d |  %1b  | %8b | %8b |     %8b      | ", VECTORCOUNT, COMMENT, $time, RST, DATA_IN, DATA_OUT, DATA_OUT_EXPECTED);
end
endtask



//task 8 coverage_update

task coverage_update; begin

input_coverage[RST]++;

if(flag_general)begin
state_input_coverage[0]++;
end
if(flag_lsb_to_msb)begin
state_input_coverage[1]++;
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



//3 computation and display on  posedge TICK

always  @ (posedge TICK) begin
//OUT_EXP (it has to be written here instead of written as a task otherwise it will cause racing condition's error)
if(RST)begin
DATA_OUT_EXPECTED <= 0;
end
else begin
DATA_OUT_EXPECTED <= {DATA_OUT_EXPECTED[6:0],DATA_IN};
end

coverage_update;
#0;
comment;
strobe_vector;
errors_warnings_check;
vectorcount;

end




//close

always@(posedge TICK)begin

if (VECTORCOUNT==9999)
begin
vectorcount;
close;
end

else if(done)begin
close;
end

end


endmodule
