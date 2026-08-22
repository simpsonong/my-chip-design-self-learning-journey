`timescale 1ns/10ps


module tb_fifo_asynchronous;

//VECTORS FOR DUT
reg W_RST;
reg W_EN;
reg [DATA_WIDTH-1:0] DATA_IN;
wire [DATA_WIDTH-1:0] DATA_IN_SYNC2;
wire FULL;
wire [ADDR_WIDTH:0] W_PTR;
wire [ADDR_WIDTH:0] W_PTR_GRAY_FLOP;
wire [ADDR_WIDTH:0] ADDR_W;
wire [ADDR_WIDTH:0] ADDRW;
wire NEXTW;

reg R_RST;
reg R_EN;
wire [DATA_WIDTH-1:0] DATA_OUT;
wire EMPTY;
wire [ADDR_WIDTH:0] R_PTR;
wire [ADDR_WIDTH:0] R_PTR_GRAY_FLOP;
wire [ADDR_WIDTH:0] ADDR_R;
wire [ADDR_WIDTH:0] ADDRR;

//VECTORS FOR TESTING

reg TICK;
reg TICK_W;
reg TICK_R;
integer W_FD, W_COUNT, R_FD, R_COUNT;
reg [8*31-1:0] COMMENT;
reg W_RST_FLOP,W_EN_FLOP,R_RST_FLOP,R_EN_FLOP;
reg [DATA_WIDTH-1:0] DATA_IN_FLOP;
reg [DATA_WIDTH-1:0] DATA_IN_SYNC2_EXPECTED;
reg W_RST_SYNC2,W_EN_SYNC2;
reg R_RST_SYNC2,R_EN_SYNC2;
reg EMPTY_EXPECTED,FULL_EXPECTED;
reg [ADDR_WIDTH:0] W_PTR_EXPECTED,R_PTR_EXPECTED;
reg [ADDR_WIDTH:0] W_PTR_SYNC2_EXPECTED,R_PTR_SYNC2_EXPECTED;
reg [ADDR_WIDTH:0] W_PTR_GRAY,R_PTR_GRAY;
reg [ADDR_WIDTH:0] W_PTR_GRAY_SYNC1,W_PTR_GRAY_SYNC2_EXPECTED,R_PTR_GRAY_SYNC1,R_PTR_GRAY_SYNC2_EXPECTED;
reg [ADDR_WIDTH:0] W_PTR_GRAY_FLOP_EXPECTED,R_PTR_GRAY_FLOP_EXPECTED;
reg [ADDR_WIDTH:0] prev_ADDR_W_EXPECTED,prev_ADDR_R_EXPECTED;
wire [ADDR_WIDTH:0] ADDR_W_EXPECTED,ADDR_R_EXPECTED;
reg  NEXT_W, NEXT_R;
wire [DATA_WIDTH-1:0]DATA_OUT_EXPECTED;
reg [31:0] VECTORCOUNT, ERRORS;
int i;
reg [31:0] state_input_coverage_w[0:47];
reg [31:0] state_input_coverage_r[0:47];
reg [31:0] wrap_coverage_w;
reg [31:0] wrap_coverage_r;
reg eof;
reg [4:0]prev_W_PTR;
reg [4:0]prev_R_PTR;
reg prev_state_w,prev_state_r;
reg [DATA_WIDTH-1:0] MEM [0:MEM_DEPTH-1];
reg [ADDR_WIDTH-1:0]ADDR_A,ADDR_B;
reg WRAP_W;
reg WRAP_R;
reg RRST_FLAG,WRST_FLAG;
reg [4:0] state_input_w,state_input_r;
reg [31:0]flag_group_w_init;
reg [31:0]flag_group_w_count[0:32],flag_group_r_count[0:31];
reg flag_rst_w_interrupt2_count;
reg flag_init;
reg flag_rst_w[0:32],flag_rst_r[0:32];
reg flag_x_w[0:2],flag_x_r[0:2];
reg [31:0]flag_group_w_all[0:3],flag_group_r_all[0:3];
reg [31:0]flag_group_w_all_stress,flag_group_r_all_stress;
reg [31:0]flag_group_w_all1[0:3],flag_group_r_all1[0:3];
reg [31:0]flag_group_w_all2[0:3],flag_group_r_all2[0:3];
reg [31:0]flag_group_w_all_stress1,flag_group_r_all_stress1;
reg [31:0]flag_group_w_all_stress2,flag_group_r_all_stress2;

reg [7:0]ch;
reg rstsync_en_w,rstsync_en_r;
reg flag_x_prevr[0:1],flag_x_prevw[0:1];
int mode_w, mode_r;
int burst_w, burst_r;
reg flag_start_stress_r[0:2],flag_start_stress_r1[0:2],flag_start_stress_r2[0:2];
reg eof_r_tick_long;
reg eof_r_tick_short;
reg flag_group_r_tick_short;
reg flag_group_r_tick_delay_point_one;
reg flag_rst_w_interrupt,flag_rst_w_interrupt1,flag_rst_w_interrupt2;
reg flag_rst_r_interrupt,flag_rst_r_interrupt1,flag_rst_r_interrupt2;
reg flag_one_sided_rst_w,flag_one_sided_rst_w1,flag_one_sided_rst_w2;
reg flag_one_sided_rst_r,flag_one_sided_rst_r1,flag_one_sided_rst_r2;
reg flag_stop_w,flag_stop_w1,flag_stop_w2;
reg flag_stop_r,flag_stop_r1,flag_stop_r2;
reg flag_end_one_sided_rst_w2;
reg start_test_w[0:31],start_test_w1[0:31],start_test_w2[0:31];
reg start_test_r[0:31],start_test_r1[0:31],start_test_r2[0:31];

parameter DATA_WIDTH = 8, ADDR_WIDTH = 4, MEM_DEPTH = 16;


//DUT INSTANTIATION

fifo_asynchronous dut_fifo_asynchronous (.w_clk(TICK_W), .w_rst(W_RST), .w_en(W_EN), .data_in(DATA_IN), .data_in_sync2(DATA_IN_SYNC2), .full(FULL), .w_ptr(W_PTR), .w_ptr_gray_flop(W_PTR_GRAY_FLOP), .addr_w(ADDR_W), .addrw(ADDRW), .next_w(NEXTW), .r_clk(TICK_R), .r_rst(R_RST), .r_en(R_EN), .data_out(DATA_OUT), .empty(EMPTY), .r_ptr(R_PTR), .r_ptr_gray_flop(R_PTR_GRAY_FLOP), .addr_r(ADDR_R), .addrr(ADDRR));
dual_port_ram_asynchronous1 test_dual_port_ram_asynchronous1(
.clk_a(TICK_W), .rst_a(W_RST),.we_a(NEXTW), .addr_a(ADDR_W_EXPECTED[ADDR_WIDTH-1:0]), .data_in_a(DATA_IN), .data_out_a(),
.clk_b(TICK_R),.rst_b(R_RST),.we_b(1'b0), .addr_b(ADDR_R_EXPECTED[ADDR_WIDTH-1:0]), .data_in_b(8'h00), .data_out_b(DATA_OUT_EXPECTED));



//DUMP EVERYTHING INTO DUMPFILE

initial begin

$dumpfile ("tb_fifo_asynchronous.vcd");
$dumpvars (0, tb_fifo_asynchronous);

end


//TICKPERIOD

localparam TICKPERIOD = 20;

always begin
#(TICKPERIOD/2) TICK <= ~TICK;
end


always begin
#(TICKPERIOD/2) TICK_W <= ~TICK_W;
end

always@(*) begin 

if(eof_r_tick_short && !eof) begin
#(TICKPERIOD/2+0.1) TICK_R <= ~TICK_R;
flag_group_r_tick_delay_point_one = 1;
end
else if(eof_r_tick_long && !eof) begin
#(TICKPERIOD/4) TICK_R <= ~TICK_R;
flag_group_r_tick_short = 1;
end
else begin
#(TICKPERIOD) TICK_R <= ~TICK_R;
end
end

//FUNCTION

//function 1 gray_decoder
function [ADDR_WIDTH:0] ADDR_BINARY;
input [ADDR_WIDTH:0] ADDR_GRAY;

parameter ADDR_WIDTH = 4;
begin

ADDR_BINARY[ADDR_WIDTH] = ADDR_GRAY[ADDR_WIDTH];

for(int i=0; i< ADDR_WIDTH; i++)begin
ADDR_BINARY[ADDR_WIDTH-1-i] = ADDR_BINARY[ADDR_WIDTH-i]^ADDR_GRAY[ADDR_WIDTH-1-i];
end

end
endfunction




//TASKS

//task 1 initialize

task initialize; begin
ch= $urandom_range(32,126);
{W_RST,W_EN,DATA_IN} = {2'b00, ch};
$display("ch=%b",ch);
{R_RST,R_EN} = {2'b00}; 

TICK = 0;
TICK_W = 0;
TICK_R = 0;
VECTORCOUNT = 0;
ERRORS = 0;

for(i=0; i<48; i++)begin
state_input_coverage_w[i] = 0;
state_input_coverage_r[i] = 0;
end


for(i=0; i<49; i++)begin
flag_group_w_count[i] = 0;
flag_group_r_count[i] = 0;
end


wrap_coverage_w = 0;
wrap_coverage_r = 0;


eof = 0;


$display ();
$display ("TEST_START-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------");
$display ();
$display ("                     | TIME | TICK_W | W_RST | W_EN | DATA_IN | FULL | FULL_EXPECTED | ADDR_A | ADDR_A_EXPECTED | WRAP_W | W_PTR | W_PTR_EXPECTED | TICK_R | R_RST | R_EN | EMPTY | EMPTY_EXPECTED | ADDR_B | ADDR_B_EXPECTED | WRAP_R | R_PTR | R_PTR_EXPECTED | DATA_OUT | DATA_OUT_EXPECTED |");
$display ("-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------");


end
endtask




//task 3 general_state_input

task general_input_w; begin

ch= $urandom_range(32,126);

//FLAG_GROUP_R_TICK_DELAY_POINT_ONE (TICK_R rise at #0.1 right after TICK_W)

if(flag_group_r_tick_delay_point_one)begin


//ONE_SIDE_RST_LOCK(used to prevent effective input while write and read reset are not synced)
//one-side-reset-lock
rstsync_en_w = 1;
if(flag_rst_w[0] || flag_rst_w[1] || flag_rst_w[2] || flag_rst_w[3])begin
rstsync_en_w = 0;
end

//RESET WRITE JUST BEFORE EOF(to make clean ending for next calculation)

if(flag_one_sided_rst_r2 && flag_rst_r[4]==0)begin
if(!eof)begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch}; 
flag_rst_w[5] = 1;
end
end


//TEST FOR ONE SIDED RESET OF WRITE WHILE STRESS READ (to make sure system will not collapse even if one sided reset occur, nevertheless output during this period is ineffective as data loss may occur)

else if(flag_one_sided_rst_w2 && flag_rst_w[4]==0)begin

//display start test

if(start_test_r2[0] !==1)begin
$display ();
$display("%12s ***time = %0d,START TEST FOR ONE SIDED RESET OF WRITE WHILE STRESS READ***","",$time);
$display("%12s ***(to make sure system will not collapse even if one sided reset occur, nevertheless output during this period is ineffective as data loss may occur)***","");
$display ();
start_test_r2[0] = 1;
end



//ending reset
if(flag_rst_r[4])begin
if(flag_rst_r[4] && {R_RST,R_EN} == 2'b10 && R_PTR_SYNC2_EXPECTED == 5'b0)begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch}; 
flag_rst_r[4] = 0;
flag_start_stress_r2[2] = 0;
end
begin
{W_RST,W_EN,DATA_IN} = {2'b00, ch}; 
end
end

//input section
else if(flag_start_stress_r2[2])begin
{W_RST,W_EN,DATA_IN} = {2'b00, ch}; 
end
else if(R_PTR_EXPECTED > 5'b00010 && flag_stop_w2 !==1)begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch}; 
flag_stop_w = 1;
flag_start_stress_r2[2] = 1;
end
else begin
{W_RST,W_EN,DATA_IN} = {2'b01, ch}; 
end
end


//TEST FOR ONE SIDED RESET OF READ WHILE STRESS WRITE (to make sure system will not collapse even if one sided reset occur, nevertheless output during this period is ineffective as data loss may occur)

else if(flag_rst_r_interrupt2 && flag_rst_r[3]==0)begin

//display start test
if(start_test_w2[0] !==1)begin
$display ();
$display("%12s ***time = %0d,START TEST FOR ONE SIDED RESET OF READ WHILE STRESS WRITE***","",$time);
$display("%12s ***(to make sure system will not collapse even if one sided reset occur, nevertheless output during this period is ineffective as data loss may occur)***","");
$display ();
start_test_w2[0] =1;
end

//ending reset
if(flag_rst_w[4])begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch};
end

//input section
else if(!prev_state_w)begin
{W_RST,W_EN,DATA_IN} = {2'b01, ch};
end
else begin
{W_RST,W_EN,DATA_IN} = {2'b00, ch};
flag_rst_w[4] = 1;
end
end

//INPUT OF W FOR SHARP INTERRUPT OF R_RST TEST (interrupt with R_RST between posedges of TICK_R)

else if(flag_rst_w_interrupt2 && flag_rst_w[3]==0)begin

//display start test

if(start_test_r2[1] !==1)begin
$display ();
$display("%12s ***time = %0d,SHARP INTERRUPT OF R_RST TEST***","",$time);
$display("%12s ***(interrupt with R_RST between posedges of TICK_R)***","");
$display ();
start_test_r2[1] = 1;
end

//ending reset
if(flag_rst_r[3])begin
if(flag_rst_r[3] && {R_RST,R_EN} == 2'b10 && R_PTR_SYNC2_EXPECTED == 5'b0) begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch};
flag_rst_r[3] = 0;
flag_rst_r_interrupt2 = 1;
end
else begin
{W_RST,W_EN,DATA_IN} = {2'b00, ch};
end
end

//input section 
else begin
{W_RST,W_EN,DATA_IN} = {2'b01, ch}; 
if(!prev_state_r)begin
{W_RST,W_EN,DATA_IN} = {2'b00, ch}; 
flag_start_stress_r2[1] = 1;
end
end
end


//SHARP INTERRUPT OF W_RST TEST (interrupt with W_RST between posedges of TICK_W)

else if(flag_group_r_all_stress2 && flag_rst_r[2] == 0 && flag_rst_w_interrupt2 !== 1)begin

//display start test

if(start_test_w2[1] !==1)begin
$display ();
$display("%12s ***time = %0d,SHARP INTERRUPT OF W_RST TEST***","",$time);
$display("%12s ***(interrupt with W_RST between posedges of TICK_W)***","");
$display ();
start_test_w2[1] = 1;
end


//ending reset

if(flag_rst_w[3])begin
{W_RST,W_EN,DATA_IN} <= {2'b10, ch};
end


//input section
else begin
{W_RST,W_EN,DATA_IN} <= {2'b01, ch};
@(posedge TICK_W);
#0.2;
{W_RST,W_EN,DATA_IN} <= {2'b10, ch};
flag_rst_w[3] <= 1;
end
end


//INPUT OF WRITE FOR READ STRESS TEST (READ FROM FULL UNTIL EMPTY)

else if(flag_group_w_all2[0] && flag_group_r_all2[0] && flag_group_w_all_stress2 && flag_rst_w[2]==0)begin


//display start test

if(start_test_r2[2] !==1)begin
$display ();
$display("%12s ***time = %0d,READ STRESS TEST***","",$time);
$display("%12s ***(READ FROM FULL UNTIL EMPTY)***","");
$display ();
start_test_r2[2] = 1;
end



//ending reset
if(flag_rst_r[2])begin
if(flag_rst_r[2] && {R_RST,R_EN} == 2'b10 && R_PTR_SYNC2_EXPECTED == 5'b0) begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch};
flag_rst_r[2] = 0;
flag_group_r_all_stress2 = 1;
end
else begin
{W_RST,W_EN,DATA_IN} = {2'b00, ch};
end
end 

//input section
else begin
if(rstsync_en_w && rstsync_en_r)begin           
if(!prev_state_w && flag_start_stress_r2[0] !==1)begin
{W_RST,W_EN,DATA_IN} = {2'b01, ch};
end
else if(prev_state_w)begin
{W_RST,W_EN,DATA_IN} = {2'b00, ch}; 
flag_start_stress_r2[0] = 1;
end
end

end

end

//WRITE STRESS TEST (WRITE FROM EMPTY UNTIL FULL)

else if(flag_group_w_all2[0] && flag_group_r_all2[0] && flag_rst_r[1]==0)begin

//display start test

if(start_test_w2[2] !==1)begin
$display ();
$display("%12s ***time = %0d,WRITE STRESS TEST***","",$time);
$display("%12s ***(WRITE FROM EMPTY UNTIL FULL)***","");
$display ();
start_test_w2[2] = 1;
end



//ending reset
if(flag_rst_w[2])begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch}; 
end 

//input section
else begin
if(rstsync_en_w && rstsync_en_r && flag_group_w_all_stress2 !==1 )begin             
if(!prev_state_w)begin
{W_RST,W_EN,DATA_IN} = {2'b01, ch};
end
else if(prev_state_w)begin
{W_RST,W_EN,DATA_IN} = {2'b00, ch}; 
flag_rst_w[2] = 1;
end
end
end


end

//INPUT OF WRITE FOR GENERAL_READ_TEST 

else if(flag_group_w_all2[0] && flag_rst_w[1]==0)begin

//display start test

if(start_test_r2[3] !==1)begin
$display ();
$display("%12s ***time = %0d,GENERAL_READ_TEST***","",$time);
$display ();
start_test_r2[3] = 1;
end


//ending reset for general write test
if(flag_rst_w[1])begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch};
end 


//reset section for general read test

else if(flag_rst_r[0])begin
if(flag_rst_r[0] && {R_RST,R_EN} == 2'b10 && R_PTR_SYNC2_EXPECTED == 5'b0) begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch};
flag_rst_r[0] = 0;
end
else begin
{W_RST,W_EN,DATA_IN} = {2'b00, ch};
end
end 


else if(flag_rst_r[1])begin
if(flag_rst_r[1] && {R_RST,R_EN} == 2'b10 && R_PTR_SYNC2_EXPECTED == 5'b0) begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch};
flag_rst_r[1] = 0;
end
else begin
{W_RST,W_EN,DATA_IN} = {2'b00, ch};
end
end 


//input section for general read test
else begin 

if(flag_group_r_all2[1] !==1) begin

//display start test

if(start_test_r2[4] !==1)begin
$display ();
$display("%12s ***time = %0d,TEST for prev_state_r = !EMPTY_EXPECTED and current_state = {R_RST,R_EN}***","",$time);
$display ();
start_test_r2[4] = 1;
end


for(int j=0; j<3; j++)begin
flag_x_prevw[j] = 0;
end

for(int k=0; k<3;k++)begin
if(!flag_group_r_count[k+14] && !flag_x_prevw[0])begin
{W_RST,W_EN,DATA_IN} = {2'b01, ch};
flag_x_prevw[0]=1;
end 
end

end

else if(flag_group_r_all2[1]) begin


//display start test
if(start_test_r2[5] !==1)begin
$display ();
$display("%12s ***time = %0d, TEST for prev_state_r = EMPTY_EXPECTED and current_state = {R_RST,R_EN}***","",$time);
$display ();
start_test_r2[5] = 1;
end


for(int k=0; k<3;k++)begin
if(!flag_group_r_count[k+17] && !flag_x_prevw[1] && flag_group_r_all2[1])begin
if(!prev_state_r)begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch};
flag_x_prevw[1]=1;
end
else begin
{W_RST,W_EN,DATA_IN} = {2'b00, ch};
flag_x_prevw[1]=1;
end
end 
end
end

end
end



//GENERAL_WRITE_TEST

else begin

//display start test

if(start_test_w2[3] !==1)begin
$display ();
$display("%12s ***time = %0d,GENERAL_WRITE_TEST***","",$time);
$display ();
start_test_w2[3] = 1;
end



//GROUP 14-16: prev_state_w = !FULL_EXPECTED , current_state = {W_RST,W_EN}

if(flag_group_w_all2[1] !==1)begin

//ending reset

if(flag_rst_w[0])begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch}; 
end 

//input section

else begin

//display start test
if(start_test_w2[4] !==1)begin
$display ();
$display("%12s ***time = %0d, TEST for prev_state_w = !FULL_EXPECTED and current_state = {W_RST,W_EN}***","",$time);
$display ();
start_test_w2[4] = 1;
end

flag_x_w[0] = 0;
for(int k=0;k<3;k++)begin
if(!flag_group_w_count[k+14] && !flag_x_w[0] && rstsync_en_w && rstsync_en_r) begin                   
if(prev_state_w)begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch}; 
flag_x_w[0] = 1;
end
else begin
{W_RST,W_EN,DATA_IN} = {k[1:0], ch}; 
flag_x_w[0] = 1;
flag_rst_w[0] = 1;
end
end

end
end

//flag_count section (to record group occurance)

flag_group_w_all2[1] = 1;
for(int j=14;j<17;j++)begin
if(!flag_group_w_count[j])
flag_group_w_all2[1] = 0;
end

end

//GROUP 17-19: prev_state_r = FULL_EXPECTED, current_state = {W_RST,W_EN}

else if(flag_group_w_all2[1])begin

//ending reset

if(flag_rst_w[1])begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch}; 
end 

//input section

else begin

//display start test
if(start_test_w2[5] !==1)begin
$display ();
$display("%12s ***time = %0d,TEST for prev_state_w = FULL_EXPECTED and current_state = {W_RST,W_EN}***","",$time);
$display ();
start_test_w2[5] = 1;
end

flag_x_w[1] = 0;
for(int k=0;k<3;k++)begin
if(!flag_group_w_count[k+17] && flag_group_w_all2[1] && !flag_x_w[1]  && rstsync_en_w && rstsync_en_r)begin             
if(!prev_state_w)begin
{W_RST,W_EN,DATA_IN} = {2'b01, ch};
flag_x_w[1] = 1; 
end
else begin
{W_RST,W_EN,DATA_IN} = {k[1:0], ch}; 
flag_x_w[1] = 1;
flag_rst_w[1] = 1;
end
end

end
end

//flag_count section (to record group occurance)

flag_group_w_all2[2] = 1;
for(int j=17;j<20;j++)begin
if(!flag_group_w_count[j])
flag_group_w_all2[2] = 0;
end

end


//FLAG_GROUP_W_COUNT (define flag_group_count)

if(rstsync_en_w && rstsync_en_r)begin
if({prev_state_w,W_RST,W_EN} < 3'b011)begin
flag_group_w_count[{prev_state_w,W_RST,W_EN}+14]++;
end
else if({prev_state_w,W_RST,W_EN} > 3'b011)begin
flag_group_w_count[{prev_state_w,W_RST,W_EN}+13]++;
end
end

//FLAG_GROUP_ALL(record that all general write test have been done)

flag_group_w_all2[0] = 1;
for(int j=14;j<20;j++)begin
if(!flag_group_w_count[j])
flag_group_w_all2[0] = 0;


//ONE_SIDE_RST_LOCK(used to prevent effective input while write and read reset are not synced)

//one-side-reset-lock
rstsync_en_w = 1;
if(flag_rst_w[0] || flag_rst_w[1] || flag_rst_w[2] || flag_rst_w[3])begin
rstsync_en_w = 0;
end

end

end


end



//FLAG_GROUP_R_TICK_SHORT
else begin

if(flag_group_r_tick_short)begin

//ONE_SIDE_RST_LOCK(used to prevent effective input while write and read reset are not synced)
//one-side-reset-lock
rstsync_en_w = 1;
if(flag_rst_w[0] || flag_rst_w[1] || flag_rst_w[2] || flag_rst_w[3])begin
rstsync_en_w = 0;
end


//RESET WRITE JUST BEFORE EOF(to make clean ending for next calculation)

if(flag_one_sided_rst_r1 && flag_rst_r[4]==0)begin
if(eof_r_tick_short !==1)begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch}; 
flag_rst_w[5] = 1;
end
end


//TEST FOR ONE SIDED RESET OF WRITE WHILE STRESS READ (to make sure system will not collapse even if one sided reset occur, nevertheless output during this period is ineffective as data loss may occur)

else if(flag_one_sided_rst_w1 && flag_rst_w[4]==0)begin

//display start test

if(start_test_r1[0] !==1)begin
$display ();
$display("%12s ***time = %0d,START TEST FOR ONE SIDED RESET OF WRITE WHILE STRESS READ***","",$time);
$display("%12s ***(to make sure system will not collapse even if one sided reset occur, nevertheless output during this period is ineffective as data loss may occur)***","");
$display ();
start_test_r1[0] = 1;
end

//ending reset
if(flag_rst_r[4])begin
if(flag_rst_r[4] && {R_RST,R_EN} == 2'b10 && R_PTR_SYNC2_EXPECTED == 5'b0)begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch}; 
flag_rst_r[4] = 0;
flag_one_sided_rst_r1 = 1; 
end
else begin
{W_RST,W_EN,DATA_IN} = {2'b00, ch}; 
end
end


//input section
else if(flag_start_stress_r1[2])begin
{W_RST,W_EN,DATA_IN} = {2'b00, ch}; 
end
else if(R_PTR_EXPECTED > 5'b00010 && flag_stop_w1 !==1)begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch}; 
flag_stop_w1 = 1;
flag_start_stress_r1[2] = 1;
end
else begin
{W_RST,W_EN,DATA_IN} = {2'b01, ch}; 
end
end



//TEST FOR ONE SIDED RESET OF READ WHILE STRESS WRITE (to make sure system will not collapse even if one sided reset occur, nevertheless output during this period is ineffective as data loss may occur)

else if(flag_rst_r_interrupt1 && flag_rst_r[3]==0)begin

//display start test
if(start_test_w1[0] !==1)begin
$display ();
$display("%12s ***time = %0d,START TEST FOR ONE SIDED RESET OF READ WHILE STRESS WRITE***","",$time);
$display("%12s ***(to make sure system will not collapse even if one sided reset occur, nevertheless output during this period is ineffective as data loss may occur)***","");
$display ();
start_test_w1[0] =1;
end



//ending reset
if(flag_rst_w[4])begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch};
end

//input_section
else if(!prev_state_w)begin
{W_RST,W_EN,DATA_IN} = {2'b01, ch};
end
else begin
{W_RST,W_EN,DATA_IN} = {2'b00, ch};
flag_rst_w[4] = 1;
end
end


//INPUT OF W FOR SHARP INTERRUPT OF R_RST TEST (interrupt with R_RST between posedges of TICK_R)

else if(flag_rst_w_interrupt1 && flag_rst_w[3]==0)begin

//display start test

if(start_test_r1[1] !==1)begin
$display ();
$display("%12s ***time = %0d,SHARP INTERRUPT OF R_RST TEST***","",$time);
$display("%12s ***(interrupt with R_RST between posedges of TICK_R)***","");
$display ();
start_test_r1[1] = 1;
end

//ending reset
if(flag_rst_r[3])begin
if(flag_rst_r[3] && {R_RST,R_EN} == 2'b10 && R_PTR_SYNC2_EXPECTED == 5'b0) begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch};
flag_rst_r[3] = 0;
flag_rst_r_interrupt1 = 1;
end 
else begin
{W_RST,W_EN,DATA_IN} = {2'b00, ch};
end
end

//input_section
else begin
{W_RST,W_EN,DATA_IN} <= {2'b01, ch}; 
if(!prev_state_r)begin
{W_RST,W_EN,DATA_IN} <= {2'b00, ch}; 
flag_start_stress_r1[1] <= 1;
end
end
end

//SHARP INTERRUPT OF W_RST TEST (interrupt with W_RST between posedges of TICK_W)

else if(flag_group_r_all_stress1 && flag_rst_r[2] == 0 && flag_rst_w_interrupt1 !== 1)begin

//display start test

if(start_test_w1[1] !==1)begin
$display ();
$display("%12s ***time = %0d,SHARP INTERRUPT OF W_RST TEST***","",$time);
$display("%12s ***(interrupt with W_RST between posedges of TICK_W)***","");
$display ();
start_test_w1[1] = 1;
end


//ending reset
if(flag_rst_w[3])begin
{W_RST,W_EN,DATA_IN} <= {2'b10, ch};
end
//input section
else begin
{W_RST,W_EN,DATA_IN} <= {2'b01, ch};
@(posedge TICK_W);
#0.2;
{W_RST,W_EN,DATA_IN} <= {2'b10, ch};
flag_rst_w[3] <= 1;
end
end


//INPUT OF WRITE FOR READ STRESS TEST (READ FROM FULL UNTIL EMPTY)

else if(flag_group_w_all1[0] && flag_group_r_all1[0] && flag_group_w_all_stress1 && flag_rst_w[2]==0)begin

//display start test

if(start_test_r1[2] !==1)begin
$display ();
$display("%12s ***time = %0d,READ STRESS TEST***","",$time);
$display("%12s ***(READ FROM FULL UNTIL EMPTY)***","");
$display ();
start_test_r1[2] = 1;
end


//ending reset
if(flag_rst_r[2])begin
if(flag_rst_r[2] && {R_RST,R_EN} == 2'b10 && R_PTR_SYNC2_EXPECTED == 5'b0) begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch};
flag_rst_r[2] = 0;
flag_group_r_all_stress1 = 1;
end
else begin
{W_RST,W_EN,DATA_IN} = {2'b00, ch};
end
end 

//input_section
else begin
if(rstsync_en_w && rstsync_en_r)begin           
if(!prev_state_w && flag_start_stress_r1[0] !==1)begin
{W_RST,W_EN,DATA_IN} = {2'b01, ch};
end
else if(prev_state_w)begin
{W_RST,W_EN,DATA_IN} = {2'b00, ch}; 
flag_start_stress_r1[0] = 1;
end
end

end

end



//WRITE STRESS TEST (WRITE FROM EMPTY UNTIL FULL)

else if(flag_group_w_all1[0] && flag_group_r_all1[0] && flag_rst_r[1]==0)begin

//display start test

if(start_test_w1[2] !==1)begin
$display ();
$display("%12s ***time = %0d,WRITE STRESS TEST***","",$time);
$display("%12s ***(WRITE FROM EMPTY UNTIL FULL)***","");
$display ();
start_test_w1[2] = 1;
end


//ending reset
if(flag_rst_w[2])begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch}; 
end 

//input section
else begin
if(rstsync_en_w && rstsync_en_r && flag_group_w_all_stress1 !==1)begin          
if(!prev_state_w)begin
{W_RST,W_EN,DATA_IN} = {2'b01, ch};
end
else if(prev_state_w)begin
{W_RST,W_EN,DATA_IN} = {2'b00, ch}; 
flag_rst_w[2] = 1;
end
end
end


end



//INPUT OF WRITE FOR GENERAL_READ_TEST 

else if(flag_group_w_all1[0] && flag_rst_w[1]==0)begin

//display start test

if(start_test_r1[3] !==1)begin
$display ();
$display("%12s ***time = %0d,GENERAL_READ_TEST***","",$time);
$display ();
start_test_r1[3] = 1;
end

//ending reset for general write test
if(flag_rst_w[1])begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch};
end 


//reset section for general read test

else if(flag_rst_r[0])begin
if(flag_rst_r[0] && {R_RST,R_EN} == 2'b10 && R_PTR_SYNC2_EXPECTED == 5'b0) begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch};
flag_rst_r[0] = 0;
end
else begin
{W_RST,W_EN,DATA_IN} = {2'b00, ch};
end
end 


else if(flag_rst_r[1])begin
if(flag_rst_r[1] && {R_RST,R_EN} == 2'b10 && R_PTR_SYNC2_EXPECTED == 5'b0) begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch};
flag_rst_r[1] = 0;
end
else begin
{W_RST,W_EN,DATA_IN} = {2'b00, ch};
end
end 


//input section for general read test
else begin

if(flag_group_r_all1[1] !==1) begin

//display start test

if(start_test_r1[4] !==1)begin
$display ();
$display("%12s ***time = %0d,TEST for prev_state_r = !EMPTY_EXPECTED and current_state = {R_RST,R_EN}***","",$time);
$display ();
start_test_r1[4] = 1;
end

for(int j=0; j<3; j++)begin
flag_x_prevw[j] = 0;
end

for(int k=0; k<3;k++)begin
if(!flag_group_r_count[k+7] && !flag_x_prevw[0])begin
{W_RST,W_EN,DATA_IN} = {2'b01, ch};
flag_x_prevw[0]=1;
end 
end

end

else if(flag_group_r_all1[1]) begin

//display start test
if(start_test_r1[5] !==1)begin
$display ();
$display("%12s ***time = %0d, TEST for prev_state_r = EMPTY_EXPECTED and current_state = {R_RST,R_EN}***","",$time);
$display ();
start_test_r1[5] = 1;
end

for(int k=0; k<3;k++)begin
if(!flag_group_r_count[k+10] && !flag_x_prevw[1] && flag_group_r_all1[1])begin
if(!prev_state_r)begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch};
flag_x_prevw[1]=1;
end
else begin
{W_RST,W_EN,DATA_IN} = {2'b00, ch};
flag_x_prevw[1]=1;
end
end 
end
end

end
end




//GENERAL_WRITE_TEST

else begin

//display start test

if(start_test_w1[3] !==1)begin
$display ();
$display("%12s ***time = %0d,GENERAL_WRITE_TEST***","",$time);
$display ();
start_test_w1[3] = 1;
end

//GROUP 6-8: prev_state_w = !FULL_EXPECTED , current_state = {W_RST,W_EN}

//ending reset
if(flag_rst_w[0])begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch}; 
end 


//input section
else begin

//display start test
if(start_test_w1[4] !==1)begin
$display ();
$display("%12s ***time = %0d, TEST for prev_state_w = !FULL_EXPECTED and current_state = {W_RST,W_EN}***","",$time);
$display ();
start_test_w1[4] = 1;
end

flag_x_w[0] = 0;
for(int k=0;k<3;k++)begin
if(!flag_group_w_count[k+7] && !flag_x_w[0] && rstsync_en_w && rstsync_en_r) begin                  
if(prev_state_w)begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch}; 
flag_x_w[0] = 1;
end
else begin
{W_RST,W_EN,DATA_IN} = {k[1:0], ch}; 
flag_x_w[0] = 1;
flag_rst_w[0] = 1;
end
end

end
end

//flag_count section (to record group occurance)
flag_group_w_all1[1] = 1;
for(int j=7;j<10;j++)begin
if(!flag_group_w_count[j])
flag_group_w_all1[1] = 0;
end




//GROUP 10-12: prev_state_w = !FULL_EXPECTED , current_state = {W_RST,W_EN}

//ending reset
if(flag_rst_w[1])begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch}; 
end 

//input section
else begin

//display start test
if(start_test_w1[5] !==1)begin
$display ();
$display("%12s ***time = %0d,TEST for prev_state_w = FULL_EXPECTED and current_state = {W_RST,W_EN}***","",$time);
$display ();
start_test_w1[5] = 1;
end

flag_x_w[1] = 0;

for(int k=0;k<3;k++)begin
if(!flag_group_w_count[k+10] && flag_group_w_all1[1] && !flag_x_w[1]  && rstsync_en_w && rstsync_en_r)begin            
if(!prev_state_w)begin
{W_RST,W_EN,DATA_IN} = {2'b01, ch};
flag_x_w[1] = 1; 
end
else begin
{W_RST,W_EN,DATA_IN} = {k[1:0], ch}; 
flag_x_w[1] = 1;
flag_rst_w[1] = 1;
end
end

end
end


//flag_count section (to record group occurance)
flag_group_w_all1[2] = 1;
for(int j=10;j<13;j++)begin
if(!flag_group_w_count[j])
flag_group_w_all1[2] = 0;
end


//FLAG_GROUP_W_COUNT (define flag_group_count)

if(rstsync_en_w && rstsync_en_r)begin
if({prev_state_w,W_RST,W_EN} < 3'b011)begin
flag_group_w_count[{prev_state_w,W_RST,W_EN}+7]++;
end
else if({prev_state_w,W_RST,W_EN} > 3'b011)begin
flag_group_w_count[{prev_state_w,W_RST,W_EN}+6]++;
end
end



//FLAG_GROUP_ALL(record that all general write test have been done)

flag_group_w_all1[0] = 1;
for(int j=7;j<13;j++)begin
if(!flag_group_w_count[j])
flag_group_w_all1[0] = 0;



//ONE_SIDE_RST_LOCK(used to prevent effective input while write and read reset are not synced)

//one-side-reset-lock
rstsync_en_w = 1;
if(flag_rst_w[0] || flag_rst_w[1] || flag_rst_w[2] || flag_rst_w[3])begin
rstsync_en_w = 0;
end

end

end


end


//FLAG_GROUP_R_TICK_LONG

else begin

//ONE_SIDE_RST_LOCK(used to prevent effective input while write and read reset are not synced)
//one-side-reset-lock
rstsync_en_w = 1;
if(flag_rst_w[0] || flag_rst_w[1] || flag_rst_w[2] || flag_rst_w[3])begin
rstsync_en_w = 0; 
end

//RESET WRITE JUST BEFORE EOF(to make clean ending for next calculation)

if(flag_one_sided_rst_r && flag_rst_r[4]==0)begin
if(eof_r_tick_long !==1)begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch}; 
flag_rst_w[5] = 1;
end
end


//TEST FOR ONE SIDED RESET OF WRITE WHILE STRESS READ (to make sure system will not collapse even if one sided reset occur, nevertheless output during this period is ineffective as data loss may occur)

else if(flag_one_sided_rst_w && flag_rst_w[4]==0)begin

//display start test

if(start_test_r[0] !==1)begin
$display ();
$display("%12s ***time = %0d,START TEST FOR ONE SIDED RESET OF WRITE WHILE STRESS READ***","",$time);
$display("%12s ***(to make sure system will not collapse even if one sided reset occur, nevertheless output during this period is ineffective as data loss may occur)***","");
$display ();
start_test_r[0] = 1;
end


//ending reset
if(flag_rst_r[4])begin
if(flag_rst_r[4] && {R_RST,R_EN} == 2'b10 && R_PTR_SYNC2_EXPECTED == 5'b0)begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch}; 
flag_rst_r[4] = 0;
flag_start_stress_r[2] = 0;
end
else begin
{W_RST,W_EN,DATA_IN} = {2'b00, ch}; 
end
end

//input section
else if(flag_start_stress_r[2])begin
{W_RST,W_EN,DATA_IN} = {2'b00, ch}; 
end
else if(R_PTR_EXPECTED > 5'b00010 && flag_stop_w !==1)begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch}; 
flag_stop_w = 1;
flag_start_stress_r[2] = 1;
end
else begin
{W_RST,W_EN,DATA_IN} = {2'b01, ch}; 
end
end


//TEST FOR ONE SIDED RESET OF READ WHILE STRESS WRITE (to make sure system will not collapse even if one sided reset occur, nevertheless output during this period is ineffective as data loss may occur)

else if(flag_rst_r_interrupt && flag_rst_r[3]==0)begin

//display start test
if(start_test_w[0] !==1)begin
$display ();
$display("%12s ***time = %0d,START TEST FOR ONE SIDED RESET OF READ WHILE STRESS WRITE***","",$time);
$display("%12s ***(to make sure system will not collapse even if one sided reset occur, nevertheless output during this period is ineffective as data loss may occur)***","");
$display ();
start_test_w[0] =1;
end



//ending reset
if(flag_rst_w[4])begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch};
end

//input section
else if(!prev_state_w)begin
{W_RST,W_EN,DATA_IN} = {2'b01, ch};
end
else begin
{W_RST,W_EN,DATA_IN} = {2'b00, ch};
flag_rst_w[4] = 1;
end

end



//INPUT OF W FOR SHARP INTERRUPT OF R_RST TEST (interrupt with R_RST between posedges of TICK_R)

else if(flag_rst_w_interrupt && flag_rst_w[3]==0)begin

//display start test

if(start_test_r[1] !==1)begin
$display ();
$display("%12s ***time = %0d,SHARP INTERRUPT OF R_RST TEST***","",$time);
$display("%12s ***(interrupt with R_RST between posedges of TICK_R)***","");
$display ();
start_test_r[1] = 1;
end

//ending reset
if(flag_rst_r[3])begin
if(flag_rst_r[3] && {R_RST,R_EN} == 2'b10 && R_PTR_SYNC2_EXPECTED == 5'b0) begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch};
flag_rst_r[3] = 0;
flag_rst_r_interrupt = 1;
end 
else begin
{W_RST,W_EN,DATA_IN} = {2'b00, ch};
end
end

//input section
else begin
{W_RST,W_EN,DATA_IN} <= {2'b01, ch}; 
if(!prev_state_r)begin
{W_RST,W_EN,DATA_IN} <= {2'b00, ch}; 
flag_start_stress_r[1] <= 1;
end
end
end


//SHARP INTERRUPT OF W_RST TEST (interrupt with W_RST between posedges of TICK_W)

else if(flag_group_r_all_stress && flag_rst_r[2] == 0 && flag_rst_w_interrupt !== 1)begin

//display start test

if(start_test_w[1] !==1)begin
$display ();
$display("%12s ***time = %0d,SHARP INTERRUPT OF W_RST TEST***","",$time);
$display("%12s ***(interrupt with W_RST between posedges of TICK_W)***","");
$display ();
start_test_w[1] = 1;
end


if(flag_rst_w[3])begin
{W_RST,W_EN,DATA_IN} <= {2'b10, ch};
end
else begin
{W_RST,W_EN,DATA_IN} <= {2'b01, ch};
@(posedge TICK_W);
#0.2;
{W_RST,W_EN,DATA_IN} <= {2'b10, ch};
flag_rst_w[3] <= 1;
end
end

//INPUT OF WRITE FOR READ STRESS TEST (READ FROM FULL UNTIL EMPTY)

else if(flag_group_w_all[0] && flag_group_r_all[0] && flag_group_w_all_stress && flag_rst_w[2]==0)begin

//display start test

if(start_test_r[2] !==1)begin
$display ();
$display("%12s ***time = %0d,READ STRESS TEST***","",$time);
$display("%12s ***(READ FROM FULL UNTIL EMPTY)***","");
$display ();
start_test_r[2] = 1;
end


//ending reset
if(flag_rst_r[2])begin
if(flag_rst_r[2] && {R_RST,R_EN} == 2'b10 && R_PTR_SYNC2_EXPECTED == 5'b0) begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch};
flag_rst_r[2] = 0;
flag_group_r_all_stress = 1;
end
else begin
{W_RST,W_EN,DATA_IN} = {2'b00, ch};
end
end 

//input section
else begin
if(rstsync_en_w && rstsync_en_r)begin            
if(!prev_state_w && flag_start_stress_r[0] !==1)begin
{W_RST,W_EN,DATA_IN} = {2'b01, ch};
end
else if(prev_state_w)begin
{W_RST,W_EN,DATA_IN} = {2'b00, ch}; 
flag_start_stress_r[0] = 1;
end
end

end

end



//WRITE STRESS TEST (WRITE FROM EMPTY UNTIL FULL)

else if(flag_group_w_all[0] && flag_group_r_all[0] && flag_rst_r[1]==0)begin

//display start test

if(start_test_w[2] !==1)begin
$display ();
$display("%12s ***time = %0d,WRITE STRESS TEST***","",$time);
$display("%12s ***(WRITE FROM EMPTY UNTIL FULL)***","");
$display ();
start_test_w[2] = 1;
end


//ending reset
if(flag_rst_w[2])begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch}; 
end 

//input section
else begin
if(rstsync_en_w && rstsync_en_r && flag_group_w_all_stress !==1)begin          
if(!prev_state_w)begin
{W_RST,W_EN,DATA_IN} = {2'b01, ch};
end
else if(prev_state_w)begin
{W_RST,W_EN,DATA_IN} = {2'b00, ch}; 
flag_rst_w[2] = 1;
end
end
end

end




//INPUT OF WRITE FOR GENERAL_READ_TEST 

else if(flag_group_w_all[0] && flag_rst_w[1]==0)begin

//display start test

if(start_test_r[3] !==1)begin
$display ();
$display("%12s ***time = %0d,GENERAL_READ_TEST***","",$time);
$display ();
start_test_r[3] = 1;
end

//ending reset for general write test
if(flag_rst_w[1])begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch};
end 


//reset section for general read test 
else if(flag_rst_r[0])begin
if(flag_rst_r[0] && {R_RST,R_EN} == 2'b10 && R_PTR_SYNC2_EXPECTED == 5'b0) begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch};
flag_rst_r[0] = 0;
end
else begin
{W_RST,W_EN,DATA_IN} = {2'b00, ch};
end
end 


else if(flag_rst_r[1])begin
if(flag_rst_r[1] && {R_RST,R_EN} == 2'b10 && R_PTR_SYNC2_EXPECTED == 5'b0) begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch};
flag_rst_r[1] = 0;
end
else begin
{W_RST,W_EN,DATA_IN} = {2'b00, ch};
end
end 


//input section for general read test
else begin 

if(flag_group_r_all[1] !==1) begin

//display start test

if(start_test_r[4] !==1)begin
$display ();
$display("%12s ***time = %0d,TEST for prev_state_r = !EMPTY_EXPECTED and current_state = {R_RST,R_EN}***","",$time);
$display ();
start_test_r[4] = 1;
end

for(int j=0; j<3; j++)begin
flag_x_prevw[j] = 0;
end

for(int k=0; k<3;k++)begin
if(!flag_group_r_count[k] && !flag_x_prevw[0])begin
{W_RST,W_EN,DATA_IN} = {2'b01, ch};
flag_x_prevw[0]=1;
end
end 

end


else if(flag_group_r_all[1]) begin

//display start test
if(start_test_r2[5] !==1)begin
$display ();
$display("%12s ***time = %0d, TEST for prev_state_r = EMPTY_EXPECTED and current_state = {R_RST,R_EN}***","",$time);
$display ();
start_test_r[5] = 1;
end

for(int k=0; k<3;k++)begin
if(!flag_group_r_count[k+3] && !flag_x_prevw[1] && flag_group_r_all[1])begin
if(!prev_state_r)begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch};
flag_x_prevw[1]=1;
end
else begin
{W_RST,W_EN,DATA_IN} = {2'b00, ch};
flag_x_prevw[1]=1;
end
end 
end
end

end

end




//GENERAL_WRITE_TEST

else begin                                             

//INITIAL INPUT FLAG_GROUP[0]

flag_group_w_init = prev_state_w === 1'bx && $time <= 6*TICKPERIOD/2 ;

if(flag_group_w_init)begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch}; 
flag_init = 1;
end


//GROUP 0-2: prev_state_w = !FULL_EXPECTED , current_state = {W_RST,W_EN}

//ending reset
else if(flag_rst_w[0])begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch}; 
end 

//input section
else begin

//display start test
if(start_test_w[4] !==1)begin
$display ();
$display("%12s ***time = %0d, TEST for prev_state_w = !FULL_EXPECTED and current_state = {W_RST,W_EN}***","",$time);
$display ();
start_test_w[4] = 1;
end

flag_x_w[0] = 0;
for(int k=0;k<3;k++)begin
if(!flag_group_w_count[k] && !flag_x_w[0] && rstsync_en_w && rstsync_en_r) begin                 
if(prev_state_w)begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch}; 
flag_x_w[0] = 1;
end
else begin
{W_RST,W_EN,DATA_IN} = {k[1:0], ch}; 
flag_x_w[0] = 1;
flag_rst_w[0] = 1;
end
end

end
end

//flag_count section (to record group occurance)
flag_group_w_all[1] = 1;
for(int j=0;j<3;j++)begin
if(!flag_group_w_count[j])
flag_group_w_all[1] = 0;
end




//GROUP 3-5: prev_state_w = FULL_EXPECTED , current_state = {W_RST,W_EN}

//ending reset
if(flag_rst_w[1])begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch}; 
end 


//input section
else begin

//display start test
if(start_test_w[5] !==1)begin
$display ();
$display("%12s ***time = %0d,TEST for prev_state_w = FULL_EXPECTED and current_state = {W_RST,W_EN}***","",$time);
$display ();
start_test_w[5] = 1;
end


flag_x_w[1] = 0;

for(int k=0;k<3;k++)begin
if(!flag_group_w_count[k+3] && flag_group_w_all[1] && !flag_x_w[1]  && rstsync_en_w && rstsync_en_r)begin            
if(!prev_state_w)begin
{W_RST,W_EN,DATA_IN} = {2'b01, ch};
flag_x_w[1] = 1; 
end
else begin
{W_RST,W_EN,DATA_IN} = {k[1:0], ch}; 
flag_x_w[1] = 1;
flag_rst_w[1] = 1;
end
end

end
end


//flag_count section (to record group occurance)
flag_group_w_all[2] = 1;
for(int j=3;j<6;j++)begin
if(!flag_group_w_count[j])
flag_group_w_all[2] = 0;
end


//FLAG_GROUP_W_COUNT (define flag_group_count)


if(rstsync_en_w && rstsync_en_r)begin
if({prev_state_w,W_RST,W_EN} < 3'b011)begin
flag_group_w_count[{prev_state_w,W_RST,W_EN}]++;
end
else if({prev_state_w,W_RST,W_EN} > 3'b011)begin
flag_group_w_count[{prev_state_w,W_RST,W_EN}-1]++;
end
end


//FLAG_GROUP_ALL(record that all general write test have been done)

flag_group_w_all[0] = 1;
for(int j=0;j<6;j++)begin
if(!flag_group_w_count[j])
flag_group_w_all[0] = 0;
end

//ONE_SIDE_RST_LOCK(used to prevent effective input while write and read reset are not synced)

//one-side-reset-lock
rstsync_en_w = 1;
if(flag_init || flag_rst_w[0] || flag_rst_w[1] || flag_rst_w[2] || flag_rst_w[3])begin
rstsync_en_w = 0;
end


end

end

end


end
endtask



task general_input_r; begin

ch= $urandom_range(32,126);

//FLAG_GROUP_R_TICK_DELAY_POINT_ONE

if(flag_group_r_tick_delay_point_one)begin


//ONE_SIDE_RST_LOCK(used to prevent effective input while write and read reset are not synced)

//one-side-reset-lock
rstsync_en_r = 1;
if(flag_rst_r[0] || flag_rst_r[1] || flag_rst_r[2])begin
rstsync_en_r = 0;
end


//RESET READ (to make clean ending for next calculation) AND EOF

if(flag_one_sided_rst_r2 && flag_rst_r[4]==0)begin
if(!eof)begin
if(flag_rst_w[5] && W_RST && R_PTR_SYNC2_EXPECTED == 5'b0)begin
{R_RST,R_EN} = 2'b10;
flag_rst_w[5] = 0;
end
end
if(flag_rst_w[5] == 0)begin
#0.2;
eof = 1;
end
end



//TEST FOR ONE SIDED RESET OF WRITE WHILE STRESS READ (to make sure system will not collapse even if one sided reset occur, nevertheless output during this period is ineffective as data loss may occur)

else if(flag_one_sided_rst_w2 && flag_rst_w[4]==0)begin

//display start test

if(start_test_r2[0] !==1)begin
$display ();
$display("%12s ***time = %0d,START TEST FOR ONE SIDED RESET OF WRITE WHILE STRESS READ***","",$time);
$display("%12s ***(to make sure system will not collapse even if one sided reset occur, nevertheless output during this period is ineffective as data loss may occur)***","");
$display ();
start_test_r2[0] = 1;
end

//ending reset
if(flag_rst_r[4])begin
{R_RST,R_EN} = 2'b10;
end

//input section
else if(prev_state_r && flag_start_stress_r2[2])begin
{R_RST,R_EN} = 2'b00;
flag_rst_r[4] = 1;
flag_one_sided_rst_r2 = 1; 
end
else begin
{R_RST,R_EN} = 2'b01;
end
end



//TEST FOR ONE SIDED RESET OF READ WHILE STRESS WRITE (to make sure system will not collapse even if one sided reset occur, nevertheless output during this period is ineffective as data loss may occur)

else if(flag_rst_r_interrupt2 && flag_rst_r[3]==0)begin

//display start test
if(start_test_w2[0] !==1)begin
$display ();
$display("%12s ***time = %0d,START TEST FOR ONE SIDED RESET OF READ WHILE STRESS WRITE***","",$time);
$display("%12s ***(to make sure system will not collapse even if one sided reset occur, nevertheless output during this period is ineffective as data loss may occur)***","");
$display ();
start_test_w2[0] =1;
end

//ending reset
if(flag_rst_w[4] && W_RST && R_PTR_SYNC2_EXPECTED == 5'b0)begin
{R_RST,R_EN} = 2'b10;
flag_rst_w[4] = 0;
flag_one_sided_rst_w2 = 1; 

end
else if(flag_stop_r2)begin
{R_RST,R_EN} = 2'b00;
end

//input section 
else if(W_PTR_EXPECTED > 5'b10000 && flag_stop_r2 !== 1)begin
{R_RST,R_EN} = 2'b10;
flag_stop_r2 = 1;
end
else begin
{R_RST,R_EN} = 2'b01;
end 
end



//SHARP INTERRUPT OF R_RST TEST (interrupt with R_RST between posedges of TICK_R)

else if(flag_rst_w_interrupt2 && flag_rst_w[3]==0)begin

//display start test

if(start_test_r2[1] !==1)begin
$display ();
$display("%12s ***time = %0d,SHARP INTERRUPT OF R_RST TEST***","",$time);
$display("%12s ***(interrupt with R_RST between posedges of TICK_R)***","");
$display ();
start_test_r2[1] = 1;
end


//ending reset
if(flag_rst_r[3])begin
{R_RST,R_EN} <= {2'b10};
end

//input section
else begin
if(flag_start_stress_r2[1])begin
{R_RST,R_EN} <= {2'b01};
@(posedge TICK_R);
#0.2;
{R_RST,R_EN} <= {2'b10};
flag_rst_r[3] <= 1;
end
else begin
{R_RST,R_EN} <= {2'b00};
end 
end
end


//INPUT OF R FOR SHARP INTERRUPT OF W_RST TEST (interrupt with W_RST between posedges of TICK_W)


else if(flag_group_r_all_stress2 && flag_rst_r[2] == 0 && flag_rst_w_interrupt2 !== 1)begin

//display start test

if(start_test_w2[1] !==1)begin
$display ();
$display("%12s ***time = %0d,SHARP INTERRUPT OF W_RST TEST***","",$time);
$display("%12s ***(interrupt with W_RST between posedges of TICK_W)***","");
$display ();
start_test_w2[1] = 1;
end

//ending reset and input section ({R_RST,R_EN} will always be 2'b00)
if(flag_rst_w[3])begin
if(flag_rst_w[3] && W_RST && R_PTR_SYNC2_EXPECTED == 5'b0)begin
{R_RST,R_EN} = 2'b10;
flag_rst_w[3] = 0;
flag_rst_w_interrupt2 = 1; 
end
else begin
{R_RST,R_EN} = 2'b00;
end
end

end

//READ STRESS TEST (READ FROM FULL UNTIL EMPTY)

else if(flag_group_w_all2[0] && flag_group_r_all2[0] && flag_group_w_all_stress2 &&flag_rst_w[2]==0)begin

//display start test

if(start_test_r2[2] !==1)begin
$display ();
$display("%12s ***time = %0d,READ STRESS TEST***","",$time);
$display("%12s ***(READ FROM FULL UNTIL EMPTY)***","");
$display ();
start_test_r2[2] = 1;
end



//ending reset
if(flag_rst_r[2])begin
{R_RST,R_EN} = 2'b10;
end 

//input section
else begin 
if(flag_start_stress_r2[0] && rstsync_en_w && rstsync_en_r)begin                                                                                               
{R_RST,R_EN} = 2'b01; 
if(prev_state_r) begin
{R_RST,R_EN} = 2'b00;
flag_rst_r[2] = 1; 
flag_start_stress_r2[0] = 0; 
end 
end

else begin
{R_RST,R_EN} = 2'b00;
end
end

end


//WRITE STRESS TEST (WRITE FROM EMPTY UNTIL FULL)


else if(flag_group_w_all2[0] && flag_group_r_all2[0] && flag_rst_r[1]==0)begin

//display start test

if(start_test_w2[2] !==1)begin
$display ();
$display("%12s ***time = %0d,WRITE STRESS TEST***","",$time);
$display("%12s ***(WRITE FROM EMPTY UNTIL FULL)***","");
$display ();
start_test_w2[2] = 1;
end



//ending reset and input section ({R_RST,R_EN} will always be 2'b00)

if(flag_rst_w[2] && {W_RST,W_EN} == 2'b10  && W_PTR_SYNC2_EXPECTED == 5'b0) begin
{R_RST,R_EN} = 2'b10;
flag_rst_w[2] = 0;
flag_group_w_all_stress2 = 1;
end
else begin
{R_RST,R_EN} = 2'b00; 
end

end



//GENERAL_READ_TEST

if(flag_group_w_all2[0])begin

//ending reset for general write test

if(flag_rst_w[1])begin
if(flag_rst_w[1] && W_PTR_SYNC2_EXPECTED == 5'b0) begin
{R_RST,R_EN} = {2'b10};
flag_rst_w[1] = 0;
end
else begin
{R_RST,R_EN} = {2'b00}; 
flag_rst_w[1] = 1;
end
end 

//display start test

if(start_test_r2[3] !==1)begin
$display ();
$display("%12s ***time = %0d,GENERAL_READ_TEST***","",$time);
$display ();
start_test_r2[3] = 1;
end


//GROUP 14-16: prev_state_r = !EMPTY_EXPECTED , current_state = {R_RST,R_EN}

else if(flag_group_r_all2[1] !==1) begin

//display start test
if(start_test_r2[4] !==1)begin
$display ();
$display("%12s ***time = %0d,TEST for prev_state_r = !EMPTY_EXPECTED and current_state = {R_RST,R_EN}***","",$time);
$display ();
start_test_r2[4] = 1;
end


//ending reset

if(flag_rst_r[0])begin
{R_RST,R_EN} = 2'b10; 
end 

//input section

else begin
flag_x_r[0] = 0;

for(int k=0;k<3;k++)begin
if(!flag_group_r_count[k+14] && !flag_x_r[0] && rstsync_en_r && rstsync_en_w) begin                   
if(prev_state_r)begin
{R_RST,R_EN} = 2'b00;  
flag_x_r[0] = 1;
end
else begin
{R_RST,R_EN} = k[1:0]; 
flag_x_r[0] = 1;
flag_rst_r[0] = 1;
end
end

end
end

//flag_count section (to record group occurance)

flag_group_r_all2[1] = 1;
for(int j=14;j<17;j++)begin
if(!flag_group_r_count[j])
flag_group_r_all2[1] = 0;
end

end


//GROUP 17-19: prev_state_r = !EMPTY_EXPECTED , current_state = {R_RST,R_EN}

else if(flag_group_w_all2[1])begin


//display start test
if(start_test_r2[5] !==1)begin
$display ();
$display("%12s ***time = %0d, TEST for prev_state_r = EMPTY_EXPECTED and current_state = {R_RST,R_EN}***","",$time);
$display ();
start_test_r2[5] = 1;
end



//ending reset

if(flag_rst_r[1])begin
{R_RST,R_EN} = 2'b10;  
end 

//input section

else begin
flag_x_r[1] = 0;


for(int k=0;k<3;k++)begin

if(!flag_group_r_count[k+17] && flag_group_r_all2[1] && !flag_x_r[1]  && rstsync_en_r && rstsync_en_w)begin         

if(!prev_state_r)begin
{R_RST,R_EN} = 2'b10; 
flag_x_r[1] = 1; 
end
else begin
{R_RST,R_EN} = k[1:0]; 
flag_x_r[1] = 1;
flag_rst_r[1] = 1;
end
end

end
end


//flag_count section (to record group occurance)

flag_group_r_all2[2] = 1;
for(int j=17;j<20;j++)begin
if(!flag_group_r_count[j])
flag_group_r_all2[2] = 0;
end

end

//FLAG_GROUP_W_COUNT (define flag_group_count)

if(rstsync_en_r && rstsync_en_w)begin
if({prev_state_r,R_RST,R_EN} < 3'b011)begin
flag_group_r_count[{prev_state_r,R_RST,R_EN}+14]++;
end
else if({prev_state_r,R_RST,R_EN} > 3'b011)begin
flag_group_r_count[{prev_state_r,R_RST,R_EN}+13]++;
end
end



//FLAG_GROUP_ALL(record that all general write test have been done)

flag_group_r_all2[0] = 1;
for(int j=14;j<20;j++)begin
if(!flag_group_r_count[j])
flag_group_r_all2[0] = 0;
end




//ONE_SIDE_RST_LOCK(used to prevent effective input while write and read reset are not synced)

//one-side-reset-lock
rstsync_en_r = 1;
if(flag_rst_r[0] || flag_rst_r[1] || flag_rst_r[2])begin
rstsync_en_r = 0;
end

end



//INPUT OF READ FOR GENERAL_WRITE_TEST 

else begin

//display start test

if(start_test_w2[3] !==1)begin
$display ();
$display("%12s ***time = %0d,GENERAL_WRITE_TEST***","",$time);
$display ();
start_test_w2[3] = 1;
end


//reset section for general write test


if(flag_rst_w[0])begin
if(flag_rst_w[0] && {W_RST,W_EN} == 2'b10  && W_PTR_SYNC2_EXPECTED == 5'b0) begin
{R_RST,R_EN} = 2'b10;
flag_rst_w[0] = 0;
end
else begin
{R_RST,R_EN} = 2'b00; 
flag_rst_w[0] = 1;
end
end 

else if(flag_rst_w[1])begin
if(flag_rst_w[1] && {W_RST,W_EN} == 2'b10  && W_PTR_SYNC2_EXPECTED == 5'b0) begin
{R_RST,R_EN} = 2'b10;
flag_rst_w[1] = 0;
end
else begin
{R_RST,R_EN} = 2'b00; 
flag_rst_w[1] = 1;
end
end 



//input section for general write test

else begin 

for(int j=0; j<3; j++)begin
flag_x_prevr[j] = 0;
end

if(flag_group_w_all2[1] !==1)begin

//display start test
if(start_test_w2[4] !==1)begin
$display ();
$display("%12s ***time = %0d, TEST for prev_state_w = !FULL_EXPECTED and current_state = {W_RST,W_EN}***","",$time);
$display ();
start_test_w2[4] = 1;
end

for(int k=0; k<3;k++)begin
if(!flag_group_w_count[k+14] && !flag_x_prevr[0])begin
if(prev_state_w)begin
{R_RST,R_EN} = 2'b10;
flag_x_prevr[0]=1;
end else begin 
{R_RST,R_EN} = 2'b00;
flag_x_prevr[0]=1;
end 
end
end

end

else if(flag_group_w_all2[1])begin


//display start test
if(start_test_w2[5] !==1)begin
$display ();
$display("%12s ***time = %0d,TEST for prev_state_w = FULL_EXPECTED and current_state = {W_RST,W_EN}***","",$time);
$display ();
start_test_w2[5] = 1;
end

for(int k=0; k<3;k++)begin
if(!flag_group_w_count[k+17] && !flag_x_prevr[1] && flag_group_w_all2[1])begin
{R_RST,R_EN} = 2'b00;
flag_x_prevr[1]=1;
end 
end

end
end 

end


end


//FLAG_GROUP_R_TICK_SHORT
if(flag_group_r_tick_short)begin

//ONE_SIDE_RST_LOCK(used to prevent effective input while write and read reset are not synced)

//one-side-reset-lock
rstsync_en_r = 1;
if(flag_rst_r[0] || flag_rst_r[1] || flag_rst_r[2])begin
rstsync_en_r = 0;
end



//RESET READ (to make clean ending for next calculation) AND EOF

if(flag_one_sided_rst_r1 && flag_rst_r[4]==0)begin
if(flag_rst_w[5] && W_RST && R_PTR_SYNC2_EXPECTED == 5'b0)begin
{R_RST,R_EN} = 2'b10;
flag_rst_w[5] = 0;
eof_r_tick_short = 1;
end
end



//TEST FOR ONE SIDED RESET OF WRITE WHILE STRESS READ (to make sure system will not collapse even if one sided reset occur, nevertheless output during this period is ineffective as data loss may occur)

else if(flag_one_sided_rst_w1 && flag_rst_w[4]==0)begin

//display start test

if(start_test_r1[0] !==1)begin
$display ();
$display("%12s ***time = %0d,START TEST FOR ONE SIDED RESET OF WRITE WHILE STRESS READ***","",$time);
$display("%12s ***(to make sure system will not collapse even if one sided reset occur, nevertheless output during this period is ineffective as data loss may occur)***","");
$display ();
start_test_r1[0] = 1;
end


//ending reset

if(flag_rst_r[4])begin
{R_RST,R_EN} = 2'b10;
flag_start_stress_r1[2] = 0;
end



//input section

else if(prev_state_r && flag_start_stress_r1[2])begin
{R_RST,R_EN} = 2'b00;
flag_rst_r[4] = 1;
end
else begin
{R_RST,R_EN} = 2'b01;
end
end



//TEST FOR ONE SIDED RESET OF READ WHILE STRESS WRITE (to make sure system will not collapse even if one sided reset occur, nevertheless output during this period is ineffective as data loss may occur)

else if(flag_rst_r_interrupt1 && flag_rst_r[3]==0)begin

//display start test
if(start_test_w1[0] !==1)begin
$display ();
$display("%12s ***time = %0d,START TEST FOR ONE SIDED RESET OF READ WHILE STRESS WRITE***","",$time);
$display("%12s ***(to make sure system will not collapse even if one sided reset occur, nevertheless output during this period is ineffective as data loss may occur)***","");
$display ();
start_test_w1[0] =1;
end


//ending reset

if(flag_rst_w[4])begin
if(flag_rst_w[4] && W_RST && R_PTR_SYNC2_EXPECTED == 5'b0)begin
{R_RST,R_EN} = 2'b10;
flag_rst_w[4] = 0;
flag_one_sided_rst_w1 = 1; 
end
else begin
{R_RST,R_EN} = 2'b00;
end
end


//input section
else if(flag_stop_r1)begin
{R_RST,R_EN} = 2'b00;
end 
else if(W_PTR_EXPECTED > 5'b10000 && flag_stop_r1 !== 1)begin
{R_RST,R_EN} = 2'b10;
flag_stop_r1 = 1;
end
else begin

{R_RST,R_EN} = 2'b01;
end 
end



//SHARP INTERRUPT OF R_RST TEST (interrupt with R_RST between posedges of TICK_R)

else if(flag_rst_w_interrupt1 && flag_rst_w[3]==0)begin

//display start test

if(start_test_r1[1] !==1)begin
$display ();
$display("%12s ***time = %0d,SHARP INTERRUPT OF R_RST TEST***","",$time);
$display("%12s ***(interrupt with R_RST between posedges of TICK_R)***","");
$display ();
start_test_r1[1] = 1;
end




//ending reset
if(flag_rst_r[3])begin
{R_RST,R_EN} <= {2'b10};
end

//input section
else begin
if(flag_start_stress_r1[1])begin
{R_RST,R_EN} <= {2'b01};
@(posedge TICK_R);
#0.2;
{R_RST,R_EN} <= {2'b10};
flag_rst_r[3] <= 1;
end
else begin
{R_RST,R_EN} <= {2'b00};
end 
end
end




//INPUT OF R FOR SHARP INTERRUPT OF W_RST TEST (interrupt with W_RST between posedges of TICK_W)


else if(flag_group_r_all_stress1 && flag_rst_r[2] == 0 && flag_rst_w_interrupt1 !== 1)begin

if(start_test_w1[1] !==1)begin
$display ();
$display("%12s ***time = %0d,SHARP INTERRUPT OF W_RST TEST***","",$time);
$display("%12s ***(interrupt with W_RST between posedges of TICK_W)***","");
$display ();
start_test_w1[1] = 1;
end


//ending reset and input section ({R_RST,R_EN} will always be 2'b00)

if(flag_rst_w[3])begin
if(flag_rst_w[3] && W_RST && R_PTR_SYNC2_EXPECTED == 5'b0)begin
{R_RST,R_EN} = 2'b10;
flag_rst_w[3] = 0;
flag_rst_w_interrupt1 = 1; 
end
else begin
{R_RST,R_EN} = 2'b00;
end
end

end

//READ STRESS TEST (READ FROM FULL UNTIL EMPTY)

else if(flag_group_w_all1[0] && flag_group_r_all1[0] && flag_group_w_all_stress1 &&flag_rst_w[2]==0)begin

//display start test

if(start_test_r1[2] !==1)begin
$display ();
$display("%12s ***time = %0d,READ STRESS TEST***","",$time);
$display("%12s ***(READ FROM FULL UNTIL EMPTY)***","");
$display ();
start_test_r1[2] = 1;
end


//ending reset

if(flag_rst_r[2])begin
{R_RST,R_EN} = 2'b10;
end 

//input section

else begin 
if(flag_start_stress_r1[0] && rstsync_en_w && rstsync_en_r)begin                                                                                                      //group13: prev_state_r = EMPTY_EXPECTED, current_state = {R_RST,R_EN} {R_RST,R_EN} = 2'b01; 
{R_RST,R_EN} = 2'b01; 
if(prev_state_r) begin
{R_RST,R_EN} = 2'b00; 
flag_rst_r[2] = 1; 
flag_start_stress_r1[0] = 0; 
end 
end

else begin
{R_RST,R_EN} = 2'b00;
end
end

end


//WRITE STRESS TEST (WRITE FROM EMPTY UNTIL FULL)

else if(flag_group_w_all1[0] && flag_group_r_all1[0] && flag_rst_r[1]==0)begin

//display start test

if(start_test_w1[2] !==1)begin
$display ();
$display("%12s ***time = %0d,WRITE STRESS TEST***","",$time);
$display("%12s ***(WRITE FROM EMPTY UNTIL FULL)***","");
$display ();
start_test_w1[2] = 1;
end

//ending reset and input section ({R_RST,R_EN} will always be 2'b00)

if(flag_rst_w[2] && {W_RST,W_EN} == 2'b10  && W_PTR_SYNC2_EXPECTED == 5'b0) begin
{R_RST,R_EN} = 2'b10;
flag_rst_w[2] = 0;
flag_group_w_all_stress1 = 1;
end
else begin
{R_RST,R_EN} = 2'b00; 
end

end


//GENERAL_READ_TEST

else if(flag_group_w_all1[0])begin

//ending reset for general write test

if(flag_rst_w[1])begin
if(flag_rst_w[1] && W_PTR_SYNC2_EXPECTED == 5'b0) begin
{R_RST,R_EN} = {2'b10};
flag_rst_w[1] = 0;
end
else begin
{R_RST,R_EN} = {2'b00}; 
flag_rst_w[1] = 1;
end
end 


//display start test

if(start_test_r1[3] !==1)begin
$display ();
$display("%12s ***time = %0d,GENERAL_READ_TEST***","",$time);
$display ();
start_test_r1[3] = 1;
end


//GROUP 7-9: prev_state_r = !EMPTY_EXPECTED , current_state = {R_RST,R_EN}

else if(flag_group_r_all1[1] !==1)begin

//display start test
if(start_test_r1[4] !==1)begin
$display ();
$display("%12s ***time = %0d,TEST for prev_state_r = !EMPTY_EXPECTED and current_state = {R_RST,R_EN}***","",$time);
$display ();
start_test_r1[4] = 1;
end


//ending reset

if(flag_rst_r[0])begin
{R_RST,R_EN} = 2'b10; 
end 

//input section

else begin
flag_x_r[0] = 0;

for(int k=0;k<3;k++)begin
if(!flag_group_r_count[k+7] && !flag_x_r[0] && rstsync_en_r && rstsync_en_w) begin                   //group7-9: prev_state_r = !EMPTY_EXPECTED, current_state = {R_RST,R_EN}

if(prev_state_r)begin
{R_RST,R_EN} = 2'b00;  
flag_x_r[0] = 1;

end
else begin
{R_RST,R_EN} = k[1:0]; 
flag_x_r[0] = 1;
flag_rst_r[0] = 1;
end
end

end
end


//flag_count section (to record group occurance)

flag_group_r_all1[1] = 1;
for(int j=7;j<10;j++)begin
if(!flag_group_r_count[j])
flag_group_r_all1[1] = 0;
end

end



//GROUP 10-12: prev_state_r = EMPTY_EXPECTED , current_state = {R_RST,R_EN}

if(flag_group_r_all1[1])

//display start test
if(start_test_r1[5] !==1)begin
$display ();
$display("%12s ***time = %0d, TEST for prev_state_r = EMPTY_EXPECTED and current_state = {R_RST,R_EN}***","",$time);
$display ();
start_test_r1[5] = 1;
end


//ending reset

if(flag_rst_r[1])begin
{R_RST,R_EN} = 2'b10;  
end 

//input section

else begin
flag_x_r[1] = 0;


for(int k=0;k<3;k++)begin

if(!flag_group_r_count[k+10] && flag_group_r_all1[1] && !flag_x_r[1]  && rstsync_en_r && rstsync_en_w)begin             //group10-12: prev_state_r = EMPTY_EXPECTED, current_state = {R_RST,R_EN}

if(!prev_state_r)begin
{R_RST,R_EN} = 2'b10; 
flag_x_r[1] = 1; 
end
else begin
{R_RST,R_EN} = k[1:0]; 
flag_x_r[1] = 1;
flag_rst_r[1] = 1;
end
end

end
end


//flag_count section (to record group occurance)

flag_group_r_all1[2] = 1;
for(int j=10;j<13;j++)begin
if(!flag_group_r_count[j])
flag_group_r_all1[2] = 0;
end






//FLAG_GROUP_W_COUNT (define flag_group_count)

if(rstsync_en_r && rstsync_en_w)begin
if({prev_state_r,R_RST,R_EN} < 3'b011)begin
flag_group_r_count[{prev_state_r,R_RST,R_EN}+7]++;
end
else if({prev_state_r,R_RST,R_EN} > 3'b011)begin
flag_group_r_count[{prev_state_r,R_RST,R_EN}+6]++;
end
end


//FLAG_GROUP_ALL(record that all general write test have been done)

flag_group_r_all1[0] = 1;
for(int j=7;j<13;j++)begin
if(!flag_group_r_count[j])
flag_group_r_all1[0] = 0;
end



//ONE_SIDE_RST_LOCK(used to prevent effective input while write and read reset are not synced)

//one-side-reset-lock
rstsync_en_r = 1;
if(flag_rst_r[0] || flag_rst_r[1] || flag_rst_r[2])begin
rstsync_en_r = 0;
end


end



//INPUT OF READ FOR GENERAL_WRITE_TEST 

else begin

//display start test

if(start_test_w1[3] !==1)begin
$display ();
$display("%12s ***time = %0d,GENERAL_WRITE_TEST***","",$time);
$display ();
start_test_w1[3] = 1;
end


//reset section for general write test

if(flag_rst_w[0])begin
if(flag_rst_w[0] && {W_RST,W_EN} == 2'b10  && W_PTR_SYNC2_EXPECTED == 5'b0) begin
{R_RST,R_EN} = 2'b10;
flag_rst_w[0] = 0;
end
else begin
{R_RST,R_EN} = 2'b00; 
flag_rst_w[0] = 1;
end
end 

else if(flag_rst_w[1])begin
if(flag_rst_w[1] && {W_RST,W_EN} == 2'b10  && W_PTR_SYNC2_EXPECTED == 5'b0) begin
{R_RST,R_EN} = 2'b10;
flag_rst_w[1] = 0;
end
else begin
{R_RST,R_EN} = 2'b00; 
flag_rst_w[1] = 1;
end
end 



//input section for general write test

else begin 

for(int j=0; j<3; j++)begin
flag_x_prevr[j] = 0;
end

if(flag_group_w_all2[1] !==1)begin

//display start test
if(start_test_w1[4] !==1)begin
$display ();
$display("%12s ***time = %0d, TEST for prev_state_w = !FULL_EXPECTED and current_state = {W_RST,W_EN}***","",$time);
$display ();
start_test_w1[4] = 1;
end

for(int k=0; k<3;k++)begin
if(!flag_group_w_count[k+7] && !flag_x_prevr[0])begin
if(prev_state_w)begin
{R_RST,R_EN} = 2'b01;
flag_x_prevr[0]=1;
end else begin 
{R_RST,R_EN} = 2'b00;
flag_x_prevr[0]=1;
end 
end
end

end

else if(flag_group_w_all2[1])begin


//display start test
if(start_test_w1[5] !==1)begin
$display ();
$display("%12s ***time = %0d,TEST for prev_state_w = FULL_EXPECTED and current_state = {W_RST,W_EN}***","",$time);
$display ();
start_test_w1[5] = 1;
end

for(int k=0; k<3;k++)begin
if(!flag_group_w_count[k+10] && !flag_x_prevr[1] && flag_group_w_all1[1])begin
{R_RST,R_EN} = 2'b00;
flag_x_prevr[1]=1;
end 
end

end
end

end

end


//FLAG_GROUP_R_TICK_LONG
else begin

//ONE_SIDE_RST_LOCK(used to prevent effective input while write and read reset are not synced)

//one-side-reset-lock
rstsync_en_r = 1;
if(flag_rst_r[0] || flag_rst_r[1] || flag_rst_r[2])begin
rstsync_en_r = 0;
end



//RESET READ (to make clean ending for next calculation) AND EOF

if(flag_one_sided_rst_r && flag_rst_r[4]==0)begin
if(flag_rst_w[5] && W_RST && R_PTR_SYNC2_EXPECTED == 5'b0)begin
{R_RST,R_EN} = 2'b10;
flag_rst_w[5] = 0;
eof_r_tick_long = 1;
end
end




//TEST FOR ONE SIDED RESET OF WRITE WHILE STRESS READ (to make sure system will not collapse even if one sided reset occur, nevertheless output during this period is ineffective as data loss may occur)

else if(flag_one_sided_rst_w && flag_rst_w[4]==0)begin

//display start test

if(start_test_r[0] !==1)begin
$display ();
$display("%12s ***time = %0d,START TEST FOR ONE SIDED RESET OF WRITE WHILE STRESS READ***","",$time);
$display("%12s ***(to make sure system will not collapse even if one sided reset occur, nevertheless output during this period is ineffective as data loss may occur)***","");
$display ();
start_test_r[0] = 1;
end


//ending reset

if(flag_rst_r[4])begin
{R_RST,R_EN} = 2'b10;
end

//input section

else if(prev_state_r && flag_start_stress_r[2])begin
{R_RST,R_EN} = 2'b00;
flag_rst_r[4] = 1;
flag_one_sided_rst_r = 1; 

end
else begin
{R_RST,R_EN} = 2'b01;
end
end




//TEST FOR ONE SIDED RESET OF READ WHILE STRESS WRITE (to make sure system will not collapse even if one sided reset occur, nevertheless output during this period is ineffective as data loss may occur)

else if(flag_rst_r_interrupt && flag_rst_r[3]==0)begin

//display start test
if(start_test_w[0] !==1)begin
$display ();
$display("%12s ***time = %0d,START TEST FOR ONE SIDED RESET OF READ WHILE STRESS WRITE***","",$time);
$display("%12s ***(to make sure system will not collapse even if one sided reset occur, nevertheless output during this period is ineffective as data loss may occur)***","");
$display ();
start_test_w[0] = 1;
end


//ending reset

if(flag_rst_w[4])begin
if(flag_rst_w[4] && W_RST && R_PTR_SYNC2_EXPECTED == 5'b0)begin
{R_RST,R_EN} = 2'b10;
flag_rst_w[4] = 0;
flag_one_sided_rst_w = 1; 
end
else begin
{R_RST,R_EN} = 2'b10;
end
end

//input section

else if(flag_stop_r)begin
{R_RST,R_EN} = 2'b00;
end 
else if(W_PTR_EXPECTED > 5'b10000 &&  flag_stop_r!== 1)begin
{R_RST,R_EN} = 2'b10;
flag_stop_r = 1;
end
else begin
{R_RST,R_EN} = 2'b01;
end 
end




//SHARP INTERRUPT OF R_RST TEST (interrupt with R_RST between posedges of TICK_R)

else if(flag_rst_w_interrupt && flag_rst_w[3]==0)begin

//display start test

if(start_test_r[1] !==1)begin
$display ();
$display("%12s ***time = %0d,SHARP INTERRUPT OF R_RST TEST***","",$time);
$display("%12s ***(interrupt with R_RST between posedges of TICK_R)***","");
$display ();
start_test_r[1] = 1;
end


//ending reset

if(flag_rst_r[3])begin
{R_RST,R_EN} <= {2'b10};
end

//input section

else begin
if(flag_start_stress_r[1])begin
{R_RST,R_EN} <= {2'b01};
@(posedge TICK_R);
#0.2;
{R_RST,R_EN} <= {2'b10};
flag_rst_r[3] <= 1;
end
else begin
{R_RST,R_EN} <= {2'b00};
end 
end
end



//INPUT OF R FOR SHARP INTERRUPT OF W_RST TEST (interrupt with W_RST between posedges of TICK_W)

else if(flag_group_r_all_stress && flag_rst_r[2] == 0 && flag_rst_w_interrupt !== 1)begin

if(start_test_w[1] !==1)begin
$display ();
$display("%12s ***time = %0d,SHARP INTERRUPT OF W_RST TEST***","",$time);
$display("%12s ***(interrupt with W_RST between posedges of TICK_W)***","");
$display ();
start_test_w[1] = 1;
end


//ending reset and input section ({R_RST,R_EN} will always be 2'b00;)

if(flag_rst_w[3])begin
if(flag_rst_w[3] && W_RST && R_PTR_SYNC2_EXPECTED == 5'b0)begin
{R_RST,R_EN} = 2'b10;
flag_rst_w[3] = 0;
flag_rst_w_interrupt = 1; 
end
else begin
{R_RST,R_EN} = 2'b00;
end
end

end

//READ STRESS TEST (READ FROM FULL UNTIL EMPTY)

else if(flag_group_w_all[0] && flag_group_r_all[0] && flag_group_w_all_stress &&flag_rst_w[2]==0)begin

//display start test

if(start_test_r[2] !==1)begin
$display ();
$display("%12s ***time = %0d,READ STRESS TEST***","",$time);
$display("%12s ***(READ FROM FULL UNTIL EMPTY)***","");
$display ();
start_test_r[2] = 1;
end


//ending reset

if(flag_rst_r[2])begin
{R_RST,R_EN} = 2'b10;
end 

//input section

else begin
if(flag_start_stress_r[0] && rstsync_en_w && rstsync_en_r)begin            
{R_RST,R_EN} = 2'b01;
if(prev_state_r)begin
{R_RST,R_EN} = 2'b00;
flag_rst_r[2] = 1;
flag_start_stress_r[0] = 0;
end
end

else begin
{R_RST,R_EN} = 2'b00;
end
end

end




//WRITE STRESS TEST (WRITE FROM EMPTY UNTIL FULL)

else if(flag_group_w_all[0] && flag_group_r_all[0] && flag_rst_r[1]==0)begin

//display start test

if(start_test_w[2] !==1)begin
$display ();
$display("%12s ***time = %0d,WRITE STRESS TEST***","",$time);
$display("%12s ***(WRITE FROM EMPTY UNTIL FULL)***","");
$display ();
start_test_w[2] = 1;
end

//ending reset and input section ({R_RST,R_EN} will always be 2'b00; ) 

if(flag_rst_w[2] && {W_RST,W_EN} == 2'b10  && W_PTR_SYNC2_EXPECTED == 5'b0) begin
{R_RST,R_EN} = 2'b10;
flag_rst_w[2] = 0;
flag_group_w_all_stress = 1;
end
else begin
{R_RST,R_EN} = 2'b00; 
end

end


//GENERAL_READ_TEST

else if(flag_group_w_all[0])begin

//ending reset for general write test

if(flag_rst_w[1])begin
if(flag_rst_w[1] && W_PTR_SYNC2_EXPECTED == 5'b0) begin
{R_RST,R_EN} = {2'b10};
flag_rst_w[1] = 0;
end
else begin
{R_RST,R_EN} = {2'b00}; 
flag_rst_w[1] = 1;
end
end 

//display start test

if(start_test_r[3] !==1)begin
$display ();
$display("%12s ***time = %0d,GENERAL_READ_TEST***","",$time);
$display ();
start_test_r[3] = 1;
end


//GROUP 0-2: prev_state_r = !EMPTY_EXPECTED , current_state = {R_RST,R_EN}

if(flag_group_r_all[1] !==1)begin

//display start test
if(start_test_r[4] !==1)begin
$display ();
$display("%12s ***time = %0d,TEST for prev_state_r = !EMPTY_EXPECTED and current_state = {R_RST,R_EN}***","",$time);
$display ();
start_test_r[4] = 1;
end

//ending reset

if(flag_rst_r[0])begin
{R_RST,R_EN} = 2'b10; 
end 


//input section

else begin
flag_x_r[0] = 0;


for(int k=0;k<3;k++)begin

if(!flag_group_r_count[k] && !flag_x_r[0] && rstsync_en_r && rstsync_en_w) begin                   //group0-2: prev_state_r = !EMPTY_EXPECTED, current_state = {R_RST,R_EN}

if(prev_state_r)begin
{R_RST,R_EN} = 2'b00;  
flag_x_r[0] = 1;

end
else begin
{R_RST,R_EN} = k[1:0]; 
flag_x_r[0] = 1;
flag_rst_r[0] = 1;
end
end

end
end


//flag_count section (to record group occurance)

flag_group_r_all[1] = 1;
for(int j=0;j<3;j++)begin
if(!flag_group_r_count[j])
flag_group_r_all[1] = 0;
end

end


//GROUP 3-5: prev_state_r = EMPTY_EXPECTED , current_state = {R_RST,R_EN}

if(flag_group_r_all[1])begin

//display start test
if(start_test_r[5] !==1)begin
$display ();
$display("%12s ***time = %0d, TEST for prev_state_r = EMPTY_EXPECTED and current_state = {R_RST,R_EN}***","",$time);
$display ();
start_test_r[5] = 1;
end


//ending reset

if(flag_rst_r[1])begin
{R_RST,R_EN} = 2'b10;  
end 

//input section

else begin
flag_x_r[1] = 0;


for(int k=0;k<3;k++)begin

if(!flag_group_r_count[k+3] && flag_group_r_all[1] && !flag_x_r[1]  && rstsync_en_r && rstsync_en_w)begin             //group3-5: prev_state_r = EMPTY_EXPECTED, current_state = {R_RST,R_EN}

if(!prev_state_r)begin
{R_RST,R_EN} = 2'b10; 
flag_x_r[1] = 1; 
end
else begin
{R_RST,R_EN} = k[1:0]; 
flag_x_r[1] = 1;
flag_rst_r[1] = 1;
end
end

end
end


//flag_count section (to record group occurance)

flag_group_r_all[2] = 1;
for(int j=3;j<6;j++)begin
if(!flag_group_r_count[j])
flag_group_r_all[2] = 0;
end

end



//FLAG_GROUP_W_COUNT (define flag_group_count)

if(rstsync_en_r && rstsync_en_w)begin
if({prev_state_r,R_RST,R_EN} < 3'b011)begin
flag_group_r_count[{prev_state_r,R_RST,R_EN}]++;
end
else if({prev_state_r,R_RST,R_EN} > 3'b011)begin
flag_group_r_count[{prev_state_r,R_RST,R_EN}-1]++;
end
end



//FLAG_GROUP_ALL(record that all general write test have been done)

flag_group_r_all[0] = 1;
for(int j=0;j<6;j++)begin
if(!flag_group_r_count[j])
flag_group_r_all[0] = 0;
end



//ONE_SIDE_RST_LOCK(used to prevent effective input while write and read reset are not synced)

//one-side-reset-lock
rstsync_en_r = 1;
if(flag_rst_r[0] || flag_rst_r[1] || flag_rst_r[2])begin
rstsync_en_r = 0;
end


end


//INPUT OF READ FOR GENERAL_WRITE_TEST 

else begin

//display start test
if(start_test_w[3] !==1)begin
$display ();
$display("%12s ***time = %0d,GENERAL_WRITE_TEST***","",$time);
$display ();
start_test_w[3] = 1;
end


//reset section for general write test

if(flag_init)begin
if(flag_init && {W_RST,W_EN} == 2'b10 && W_PTR_SYNC2_EXPECTED == 5'b0) begin
{R_RST,R_EN} = 2'b10; 
flag_init = 0;
end
else begin
{R_RST,R_EN} = 2'b00; 
flag_init = 1;
end
end

else if(flag_rst_w[0])begin
if(flag_rst_w[0] && {W_RST,W_EN} == 2'b10  && W_PTR_SYNC2_EXPECTED == 5'b0) begin
{R_RST,R_EN} = 2'b10;
flag_rst_w[0] = 0;
end
else begin
{R_RST,R_EN} = 2'b00; 
flag_rst_w[0] = 1;
end
end 

else if(flag_rst_w[1])begin
if(flag_rst_w[1] && {W_RST,W_EN} == 2'b10  && W_PTR_SYNC2_EXPECTED == 5'b0) begin
{R_RST,R_EN} = 2'b10;
flag_rst_w[1] = 0;
end
else begin
{R_RST,R_EN} = 2'b00; 
flag_rst_w[1] = 1;
end
end 


//input section for general write test

else begin 

for(int j=0; j<3; j++)begin
flag_x_prevr[j] = 0;
end

if(flag_group_w_all[1] !==1)begin

//display start test
if(start_test_w[4] !==1)begin
$display ();
$display("%12s ***time = %0d, TEST for prev_state_w = !FULL_EXPECTED and current_state = {W_RST,W_EN}***","",$time);
$display ();
start_test_w[4] = 1;
end

for(int k=0; k<3;k++)begin
if(!flag_group_w_count[k] && !flag_x_prevr[0])begin
if(prev_state_w)begin
{R_RST,R_EN} = 2'b01;
flag_x_prevr[0]=1;
end else begin 
{R_RST,R_EN} = 2'b00;
flag_x_prevr[0]=1;
end 
end
end

end

else if(flag_group_w_all[1])begin


//display start test
if(start_test_w[5] !==1)begin
$display ();
$display("%12s ***time = %0d,TEST for prev_state_w = FULL_EXPECTED and current_state = {W_RST,W_EN}***","",$time);
$display ();
start_test_w[5] = 1;
end


for(int k=0; k<3;k++)begin
if(!flag_group_w_count[k+3] && !flag_x_prevr[1] && flag_group_w_all[1])begin
{R_RST,R_EN} = 2'b00;
flag_x_prevr[1]=1;
end 
end

end
end

end

end

end
endtask




//task 4 random_in

task random_in_w; begin

ch= $urandom_range(32,126);

mode_w = $urandom_range(0,3);
burst_w = $urandom_range (1,20);

repeat(burst_w)begin

@(posedge TICK_W);

case(mode_w)
0:begin
W_RST = 1'b0; W_EN = 1'b0; DATA_IN = ch;
end
1:begin
W_RST = 1'b0; W_EN = 1'b1; DATA_IN = ch;
end
2:begin
W_RST = 1'b1; W_EN = 1'b0; DATA_IN = ch;
end
3:begin
W_RST = 1'b1; W_EN = 1'b1; DATA_IN = ch;
end
endcase

end

end
endtask

task random_in_r; begin

mode_r = $urandom_range(0,3);
burst_r = $urandom_range (1,20);

repeat(burst_r)begin

@(posedge TICK_R);

case(mode_r)
0:begin
R_RST = 1'b0; R_EN = 1'b0;
end
1:begin
R_RST = 1'b0; R_EN = 1'b1;
end
2:begin
R_RST = 1'b1; R_EN = 1'b0;
end
3:begin
R_RST = 1'b1; R_EN = 1'b1;
end
endcase

end


# ($urandom_range(0.1,10));

end
endtask


//task4 COMMENT
task comment_w; begin
if(W_RST)
COMMENT = "W_RST";
else if (!W_RST)begin
case(FULL_EXPECTED)
1'b0: COMMENT = "NOT_FULL";
1'b1: COMMENT = "FULL";
default: COMMENT = "ILLEGAL";
endcase
end

end
endtask


task comment_r; begin
if(R_RST)
COMMENT = "R_RST";
else if (!R_RST)begin
case(EMPTY_EXPECTED)
1'b0: COMMENT = "NOT_EMPTY";
1'b1: COMMENT = "EMPTY";
default: COMMENT = "ILLEGAL";
endcase
end

end
endtask

//task4 flop and two_stage_synchronizer


task sync2_flop_tick_w;begin


R_PTR_GRAY_SYNC1 <= R_PTR_GRAY_FLOP_EXPECTED;
R_PTR_GRAY_SYNC2_EXPECTED <= R_PTR_GRAY_SYNC1;

W_PTR_GRAY_FLOP_EXPECTED <= W_PTR_GRAY;

end
endtask

task sync2_flop_tick_r;begin


W_PTR_GRAY_SYNC1 <= W_PTR_GRAY_FLOP_EXPECTED;
W_PTR_GRAY_SYNC2_EXPECTED <= W_PTR_GRAY_SYNC1;

R_PTR_GRAY_FLOP_EXPECTED <= R_PTR_GRAY;

end
endtask

//task5 OUT_EXP

task OUT_EXP_W; begin
if(W_RST)begin
W_PTR_EXPECTED <= 5'b0;
W_PTR_GRAY <= 5'b0;
end

else if(NEXT_W)begin
W_PTR_EXPECTED <= W_PTR_EXPECTED + 1;
W_PTR_GRAY <= (W_PTR_EXPECTED + 1) ^ ((W_PTR_EXPECTED + 1)>>1);
end


end
endtask


task OUT_EXP_R; begin

if(R_RST)begin
R_PTR_EXPECTED <= 5'b0;
R_PTR_GRAY <= 5'b0;
end

else if(NEXT_R)begin
R_PTR_EXPECTED <= R_PTR_EXPECTED + 1;
R_PTR_GRAY <= (R_PTR_EXPECTED + 1) ^ ((R_PTR_EXPECTED + 1)>>1);
end


end
endtask

//task 5 close

task close; begin

#10;

$fclose (W_FD);
$fclose (R_FD);

$display ();
$display ("COVERAGE_REPORT");
$display ();
$display ("In this asynchronous fifo, independent reset for a single clock domain is not supported, but it will also be tested to verify in this situation even though the results will be ineffective, the system will not collapse");
$display ();



if(wrap_coverage_w == 0) begin
$display ("wrap around for write has occured %58d times ***ERROR***", wrap_coverage_w);
ERRORS = ERRORS + 1;
end


else begin
$display ("wrap around for write has occured %58d times", wrap_coverage_w);
end

if(wrap_coverage_r == 0) begin
$display ("wrap around for read has occured %58d times ***ERROR***", wrap_coverage_r);
ERRORS = ERRORS + 1;
end


else begin
$display ("wrap around for read has occured %58d times", wrap_coverage_r);
end


for (int j = 0; j < 8; j++ ) begin


if(state_input_coverage_w[j] == 0) begin
$display ("previous state FULL = %b, current input W_RST = %b, W_EN = %b has occured %d times ***ERROR***", j[2], j[1], j[0], state_input_coverage_w[j]);
ERRORS = ERRORS + 1;
end

else begin 

if(j[1:0] == 2'b10)begin
$display ("previous state FULL = %b, current input W_RST = %b, W_EN = %b has occured %d times ***identical behavior as while W_RST == 1 and W_EN == 1***", j[2], j[1], j[0], state_input_coverage_w[j]);
end


else if(j[1:0] == 2'b11)begin
$display ("previous state FULL = %b, current input W_RST = %b, W_EN = %b has occured %d times ***identical behavior as while W_RST == 1 and W_EN == 0***", j[2], j[1], j[0], state_input_coverage_w[j]);
end


else if((j[1:0] !== 2'b10) && (j[1:0] !== 2'b11)) begin
$display ("previous state FULL = %b, current input W_RST = %b, W_EN = %b has occured %d times ", j[2], j[1], j[0], state_input_coverage_w[j]);
end

end
end


for (int j = 0; j < 8; j++ ) begin


if(state_input_coverage_r[j] == 0) begin
$display ("previous state EMPTY = %b, current input R_RST = %b, R_EN = %b has occured %d times ***ERROR***", j[2], j[1], j[0], state_input_coverage_r[j]);
ERRORS = ERRORS + 1;
end

else begin

if(j[1:0] == 2'b10)begin
$display ("previous state EMPTY = %b, current input R_RST = %b, R_EN = %b has occured %d times ***identical behavior as while R_RST == 1 and R_EN == 1***", j[2], j[1], j[0], state_input_coverage_r[j]);
end


if(j[1:0] == 2'b11)begin
$display ("previous state EMPTY = %b, current input R_RST = %b, R_EN = %b has occured %d times ***identical behavior as while R_RST == 1 and R_EN == 0***", j[2], j[1], j[0], state_input_coverage_r[j]);
end

else if((j[1:0] !== 2'b10) && (j[1:0] !== 2'b11)) begin
$display ("previous state EMPTY = %b, current input R_RST = %b, R_EN = %b has occured %d times ", j[2], j[1], j[0], state_input_coverage_r[j]);
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


//task 7 display

task display_w; begin

$display ("%10d %9s | %4d | %3b    | %3b   | %2b   | %4c    | %2b   | %7b       | %5b  | %10b      | %3b    | %5b | %9b      |", VECTORCOUNT, COMMENT, $time, TICK_W, W_RST, W_EN, DATA_IN, FULL, FULL_EXPECTED,  ADDRW[ADDR_WIDTH-1:0], prev_ADDR_W_EXPECTED[ADDR_WIDTH-1:0], WRAP_W, W_PTR, W_PTR_EXPECTED);

end
endtask

task display_r; begin

$display ("%10d %9s | %4d |%117s| %3b    | %3b   | %2b  | %3b   | %7b        | %5b  | %10b      | %3b    | %5b | %9b      | %4c     | %9c         |", VECTORCOUNT, COMMENT, $time,"", TICK_R, R_RST, R_EN, EMPTY, EMPTY_EXPECTED, ADDRR[ADDR_WIDTH-1:0], prev_ADDR_R_EXPECTED[ADDR_WIDTH-1:0], WRAP_R, R_PTR, R_PTR_EXPECTED, DATA_OUT, DATA_OUT_EXPECTED);

end
endtask

//task 8 in_coverage_update

task coverage_update; begin

state_input_coverage_w[{prev_state_w,W_RST,W_EN}]++;

for(int j=0;j<2;j++)begin

if(prev_state_w == j[0] && {W_RST,W_EN} == 2'b10)begin
state_input_coverage_w[{j[0],2'b11}]++;
end

end


state_input_coverage_r[{prev_state_r,R_RST, R_EN}]++;

for(int j=0;j<2;j++)begin

if(prev_state_w == j[0] && {R_RST,R_EN} == 2'b10)begin
state_input_coverage_r[{j[0],2'b11}]++;
end

end


if(WRAP_W)
wrap_coverage_w++;

if(WRAP_R)
wrap_coverage_r++;


end
endtask




//task 9 errors_warnings_check_w

task errors_warnings_check_w; begin


if (ADDRW !== prev_ADDR_W_EXPECTED) begin

$display ("***ERROR: ADDR_W = %b, ADDR_W_expected = %b", ADDRW[3:0], prev_ADDR_W_EXPECTED[3:0]);
ERRORS = ERRORS + 1;

end



if (FULL !== FULL_EXPECTED) begin

$display ("***ERROR: FULL = %b, FULL_expected = %b", FULL, FULL_EXPECTED);
ERRORS = ERRORS + 1;

end



if (W_PTR !== W_PTR_EXPECTED) begin

$display ("***ERROR: W_PTR = %b, W_PTR_expected = %b", W_PTR, W_PTR_EXPECTED);
ERRORS = ERRORS + 1;

end




end
endtask

task errors_warnings_check_r; begin


if (EMPTY !== EMPTY_EXPECTED) begin

$display ("***ERROR: EMPTY = %b, EMPTY_expected = %b", EMPTY, EMPTY_EXPECTED);
ERRORS = ERRORS + 1;

end

if (ADDRR !== prev_ADDR_R_EXPECTED) begin

$display ("***ERROR: ADDR_R = %b, ADDR_R_expected = %b", ADDRR[3:0], prev_ADDR_R_EXPECTED[3:0]);
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



end
endtask


//DRIVE


//1 assign

assign state_input_w = {prev_state_r,W_RST,W_EN};
assign state_input_r = {prev_state_w,R_RST,R_EN};

assign ADDR_W_EXPECTED = W_PTR_EXPECTED;
assign R_PTR_SYNC2_EXPECTED = ADDR_BINARY(R_PTR_GRAY_SYNC2_EXPECTED);
assign FULL_EXPECTED = W_PTR_EXPECTED == {~R_PTR_SYNC2_EXPECTED[ADDR_WIDTH], R_PTR_SYNC2_EXPECTED[ADDR_WIDTH-1:0]};
assign NEXT_W = W_EN & !FULL_EXPECTED;

assign ADDR_R_EXPECTED = R_PTR_EXPECTED;
assign W_PTR_SYNC2_EXPECTED = ADDR_BINARY(W_PTR_GRAY_SYNC2_EXPECTED);
assign EMPTY_EXPECTED = (R_PTR_EXPECTED == W_PTR_SYNC2_EXPECTED);
assign NEXT_R = R_EN & !EMPTY_EXPECTED;


assign WRAP_W = ((ADDR_W_EXPECTED[ADDR_WIDTH] != prev_ADDR_W_EXPECTED[ADDR_WIDTH]) && (prev_ADDR_W_EXPECTED[ADDR_WIDTH-1:0] == 4'b1111));
assign WRAP_R = ((ADDR_R_EXPECTED[ADDR_WIDTH] != prev_ADDR_R_EXPECTED[ADDR_WIDTH]) && (prev_ADDR_R_EXPECTED[ADDR_WIDTH-1:0] == 4'b1111));



//0 initialize

initial begin

initialize;

end




//2 scan file on negedge TICK

always @ (posedge TICK_W) begin
if (!eof) begin

general_input_w;

end
end



//3 check file on posedge TICK


always@(posedge TICK_W)begin
sync2_flop_tick_w;
end

always  @ (posedge TICK_W or posedge W_RST) begin
coverage_update;
prev_ADDR_W_EXPECTED <= ADDR_W_EXPECTED;
OUT_EXP_W;
#0.1;

comment_w;
display_w;
errors_warnings_check_w;
vectorcount;

#0.1;
prev_state_w = FULL_EXPECTED;

end



always @ (posedge TICK_R) begin
if (!eof) begin

general_input_r;

end
end

always@(posedge TICK_R)begin
sync2_flop_tick_r;
end

always  @ (posedge TICK_R or posedge R_RST) begin
prev_ADDR_R_EXPECTED <= ADDR_R_EXPECTED;
OUT_EXP_R;

#0.1;
comment_r;
display_r;
errors_warnings_check_r;
vectorcount;

#0.1;
prev_state_r = EMPTY_EXPECTED;


end



// eof

//w_eof
initial begin

wait (flag_group_r_tick_short);

$display ();
$display("%13s **************************************************************************************************************************time = %0d,EOF_R_TICK_LONG **************************************************************************************************************************","",$time);
$display ();

wait (flag_group_r_tick_delay_point_one);

$display ();
$display("%13s **************************************************************************************************************************time = %0d,EOF_R_TICK_SHORT **************************************************************************************************************************","",$time);
$display ();

wait (eof);

$display ();
$display("%13s ********************************************************************************************************************************time = %0d,EOF **************&******************************************************************************************************************","",$time);
$display ();

for (i = 0; i < 50; i++) begin

if ({FULL,W_RST,W_EN} == 4'b1000)
begin
vectorcount;
close;
end

else begin
random_in_w;
end

end

close;

end

initial begin


//r_eof
wait (eof);

for (i = 0; i < 500; i++) begin

if ({EMPTY,R_RST,R_EN} == 4'b1000)
begin
vectorcount;
close;

end

else begin
random_in_r;
end

end

close;

end


endmodule
