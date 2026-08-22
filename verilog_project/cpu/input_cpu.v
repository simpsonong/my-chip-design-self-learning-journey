module input_register(
input TICK,
input reg [31:0]total_flag_group_count[0:total_group_x_general],
input reg [31:0]prev_total_flag_group_count[0:total_group_x_general],
input reg [31:0]num_of_GROUP[0:total_group_x_general],
input [7:0] MICROADDRESS;
output LD_bar,
output CLR_bar,
output reg [total_DATA_WIDTH-1:0] D,
output reg eof,
output reg done,
output reg flag_init,
output reg flag_general,flag_mantain_ld,flag_freq,
output reg [4:0] start_test,
output reg [coverage_VECTOR_WIDTH+total_DATA_WIDTH-1:0]INPUT_drive,
output reg flag_done[0:total_group_x_general]
);

reg [total_DATA_WIDTH-1:0]ch;
reg int mode;
reg int burst;
reg CLR,LD;
reg [31:0]flag_group_count[0:6];
reg [3:0]prev_LD;
reg flag_X;
reg [31:0]tick_count;
reg [coverage_VECTOR_WIDTH-1:0]INPUT_coverage;


//PARAMETER
parameter TICKPERIOD = 20;
parameter total_DATA_WIDTH = 16;
parameter coverage_VECTOR_bits = 2;
parameter coverage_VECTOR_WIDTH = coverage_VECTOR_bits;
parameter total_group_x_general = 2;
parameter total_flag_group_count_all = 7;


assign LD_bar = ~LD;
assign CLR_bar = ~CLR;


//TASK

//task 1 initialize
task initialize; begin

ch = $urandom_range(32,126);



INPUT_drive = {2'b11,5'b0,ch};

eof=0;

for(int j=0; j<total_flag_group_count_all; j++)begin
flag_group_count[j] = 0;

end

tick_count=0;



end
endtask


//task2 task general_input
task general_input; begin


ch = $urandom_range(32,126);

flag_X =0;
for(int i=0; i<total_group_x_general+1; i++)begin
if(i==0)begin


//0 INITIAL INPUT
if(flag_init !==1 && !flag_X)begin
flag_init = 1;
flag_X = 1;
end



//1 GENERAL TEST of {GO_BAR, RESET, JAM, OP_CODE}
else if(flag_done[i] !==1 && !flag_X)begin

//display start test
if(start_test[i] !==1)begin
$display ();
$display("%12s ***time = %0d, GENERAL TEST of {GO_BAR, RESET, JAM, OP_CODE}***","",$time);       //***edit*** done
$display ();
start_test[i] = 1;
end


//input section
flag_X = 0;
for(int j=0; j<num_of_GROUP[i]; j++)begin
if(flag_group_count[j] !==1 && !flag_X)begin
INPUT_drive = {j[coverage_VECTOR_bits-1:0],ch};
flag_X = 1;
end
end


//flag_group_count
for(int j=0; j<num_of_GROUP[i]; j++)begin
if(j==0)begin
if(INPUT_drive[coverage_VECTOR_WIDTH+total_DATA_WIDTH-1:total_DATA_WIDTH]==j[coverage_VECTOR_bits-1:0])begin
flag_group_count[j + prev_total_flag_group_count[i]]++;           
end
end

else begin
if(INPUT_drive[coverage_VECTOR_WIDTH+total_DATA_WIDTH-1:total_DATA_WIDTH]==j[coverage_VECTOR_bits-1:0])begin
flag_group_count[j + prev_total_flag_group_count[i]]++;
end
end
end

for(int j=0; j<num_of_GROUP[i]; j++)begin
if(j==num_of_GROUP[i]-1)begin
if(flag_group_count[j + prev_total_flag_group_count[i]])begin
flag_done[i] =1;
flag_X = 1;
end
end

else begin
flag_done[i] =0;
flag_X = 1;
end
end

end
end


else if(i==1)begin

//2 TEST of RESET-WAIT_FOR_GO 

if(flag_done[i] !==1 && !flag_X) begin

//display start test
if(start_test[i] !==1)begin
$display ();
$display("%12s ***time = %0d, TEST of RESET-WAIT_FOR_GO","",$time);
$display ();
start_test[i] = 1;
end



//input section               //***edit***
flag_X = 0;
for(int j=0; j<num_of_GROUP[i]; j++)begin
if(flag_group_count[j + prev_total_flag_group_count[i]] === 0 && !flag_X)begin

if(j==0)begin  //START RESET-FLASH 11 OUTPUT
INPUT_drive = {7'b1100000,ch};
flag_X = 1;
end
if(j==1)begin  //LOAD TB and TA WITH 1s, JUST SO THE ALU HAS KNOWN VALUES GOING INTO IT
INPUT_drive = {7'b1100000,ch};
flag_X = 1;
end
if(j==2)begin //FLASH 00 OUTPUT
INPUT_drive = {7'b1100000,ch};
flag_X = 1;
end
if(j==3)begin //WAIT FOR GO_BAR-OUTPUT F
INPUT_drive = {7'b1100000,ch};
flag_X = 1;
end
if(j==4)begin //GET OPCODE
INPUT_drive = {7'b0100000,ch};
flag_X = 1;
end

end
end


tick_count = tick_count + 1;



//flag_group_count     ***edit***
for(int j=0; j<num_of_GROUP[i]; j++)begin

if(j==0)begin
if(tick_count == 1)begin                  
flag_group_count[j+prev_total_flag_group_count[i]]++;
flag_X=1;
end
end

if(j==1)begin
if(tick_count == 2)begin                  
flag_group_count[j+prev_total_flag_group_count[i]]++;
flag_X=1;
end
end

if(j==2)begin
if(tick_count == 3)begin                  
flag_group_count[j+prev_total_flag_group_count[i]]++;
flag_X=1;
end
end

if(j==3)begin
if(tick_count == 4)begin                  
flag_group_count[j+prev_total_flag_group_count[i]]++;
flag_X=1;
end
end

if(j==4)begin
if(tick_count == 5)begin                  
flag_group_count[j+prev_total_flag_group_count[i]]++;
flag_X=1;
end
end

else begin
if(tick_count > 5)begin
flag_group_count[j+prev_total_flag_group_count[i]] = flag_group_count[j+prev_total_flag_group_count[i]];
flag_X=1;
end
end

end


for(int j=0; j<num_of_GROUP[i]; j++)begin
if(j==num_of_GROUP[i]-1)begin
if(flag_group_count[j + prev_total_flag_group_count[i]])begin
flag_done[i] =1;
tick_count = 0;
flag_X = 1;
end
end
else begin
flag_done[i] =0;
flag_X = 1;
end
end

end
end



if(i==2)begin


//3 TEST of ADD
if(flag_done[i]!==1 && !flag_X) begin
//display start test
if(start_test[i] !==1)begin
$display ();
$display("%12s ***time = %0d, TEST of ADD***","",$time);
$display ();
start_test[i] = 1;
end


//input section   //***edit***
flag_X = 0; 
for(int j=0; j<num_of_GROUP[i]; j++)begin
if(flag_group_count[j + prev_total_flag_group_count[i]] !==1 && !flag_X)begin

if(j==0)begin  //ADD
INPUT_drive = {7'b0100000,ch};
flag_X = 1;
end
if(j==1)begin  //WAIT FOR GO TO BE RELEASED
INPUT_drive = {7'b1100000,ch};
flag_X = 1;
end
if(j==2)begin  //GO TO RESET, FLASH 00
INPUT_drive = {7'b1100000,ch};
flag_X = 1;
end

end
end

tick_count = tick_count + 1;  //***edit***


//flag_group_count
for(int j=0; j<num_of_GROUP[i]; j++)begin

if(j==0)begin
if(tick_count == 1)begin
flag_group_count[j + prev_total_flag_group_count[i]]++;
flag_X = 1;
end
end
if(j==1)begin
if(tick_count == 2)begin
flag_group_count[j + prev_total_flag_group_count[i]]++;
flag_X = 1;
end
end
if(j==2)begin
if(tick_count == 3)begin
flag_group_count[j + prev_total_flag_group_count[i]]++;
flag_X = 1;
end
end
else begin
if(tick_count > 3)begin
flag_group_count[j + prev_total_flag_group_count[i]] = flag_group_count[j + prev_total_flag_group_count[i]];
end
end

end


for(int j=0; j<num_of_GROUP[i]; j++)begin
if(j==num_of_GROUP[i]-1)begin
if(flag_group_count[j + prev_total_flag_group_count[i]])begin
flag_done[i] =1;
tick_count = 0;
flag_X=1;
end
end
else begin
flag_done[i] =0;
flag_X=1;
end
end

end


if(i==3)begin


//4 TEST of SUBTRACT
if(flag_done[i]!==1 && !flag_X) begin
//display start test
if(start_test[i] !==1)begin
$display ();
$display("%12s ***time = %0d, TEST of SUBTRACT***","",$time);
$display ();
start_test[i] = 1;
end


//input section
flag_X = 0;
for(int j=0; j<num_of_GROUP[i]; j++)begin
if(flag_group_count[j + prev_total_flag_group_count[i]] !==1 && !flag_X)begin

if(j==0)begin  //SUBTRACT
INPUT_drive = {7'b0100000,ch};
flag_X = 1;
end
if(j==1)begin  //WAIT FOR GO TO BE RELEASED
INPUT_drive = {7'b1100000,ch};
flag_X = 1;
end
if(j==2)begin  //GO TO RESET, FLASH 00
INPUT_drive = {7'b1100000,ch};
flag_X = 1;
end

end
end

tick_count = tick_count + 1;



//flag_group_count
for(int j=0; j<num_of_GROUP[i]; j++)begin

if(j==0)begin
if(tick_count == 1)begin
flag_group_count[j + prev_total_flag_group_count[i]]++;
flag_X = 1;
end
end
if(j==1)begin
if(tick_count == 2)begin
flag_group_count[j + prev_total_flag_group_count[i]]++;
flag_X = 1;
end
end
if(j==2)begin
if(tick_count == 3)begin
flag_group_count[j + prev_total_flag_group_count[i]]++;
flag_X = 1;
end
end
else begin
if(tick_count > 3)begin
flag_group_count[j + prev_total_flag_group_count[i]] = flag_group_count[j + prev_total_flag_group_count[i]];
end
end

end



for(int j=0; j<num_of_GROUP[i]; j++)begin
if(j==num_of_GROUP[i]-1)begin
if(flag_group_count[j + prev_total_flag_group_count[i]])begin
flag_done[i] =1;
tick_count = 0;
flag_X=1;
end
end
else begin
flag_done[i] =0;
flag_X=1;
end
end

end


if(i==4)begin


//5 TEST of MULTIPLICATION
if(flag_done[i]!==1 && !flag_X) begin
//display start test
if(start_test[i] !==1)begin
$display ();
$display("%12s ***time = %0d, TEST of MULTIPLICATION***","",$time);
$display ();
start_test[i] = 1;
end


//input section
flag_X = 0;
for(int j=0; j<num_of_GROUP[i]; j++)begin
if(flag_group_count[j + prev_total_flag_group_count[i]] !==1 && !flag_X)begin

if(j==0)begin
repeat(8'b01111111*3+5)begin
@(negedge TICK);
tick_count = tick_count + 1;
if(tick_count<8'b01111111*3+4)begin
INPUT_drive = {7'b0100000,8'b11110111,8'b01111111};
end
else begin
INPUT_drive = {7'b1100000,8'b11110111,8'b01111111};
end
end

flag_X=1;
end
end



//flag_group_count
for(int j=0; j<num_of_GROUP[i]; j++)begin

if(j==0)begin
if(tick_count == 8'b01111111*3+5)begin
flag_group_count[j + prev_total_flag_group_count[i]]++;
flag_X = 1;
end
end
else begin
if(tick_count > 8'b01111111*3+5)begin
flag_group_count[j + prev_total_flag_group_count[i]] = flag_group_count[j + prev_total_flag_group_count[i]];
end
end

end


for(int j=0; j<num_of_GROUP[i]; j++)begin
if(j==num_of_GROUP[i]-1)begin
if(flag_group_count[j + prev_total_flag_group_count[i]])begin
flag_done[i] =1;
tick_count = 0;
flag_X=1;
end
end
else begin
flag_done[i] =0;
flag_X=1;
end
end

end


if(i==5)begin


//6 TEST of DIVISION
if(flag_done[i]!==1 && !flag_X) begin
//display start test
if(start_test[i] !==1)begin
$display ();
$display("%12s ***time = %0d, TEST of DIVISION***","",$time);
$display ();
start_test[i] = 1;
end


//input section
flag_X = 0;
for(int j=0; j<num_of_GROUP[i]; j++)begin
if(flag_group_count[j + prev_total_flag_group_count[i]] !==1 && !flag_X)begin

if(j==0)begin
repeat(17)begin
@(negedge clk)
tick_count = tick_count + 1;
if(tick<16)begin
INPUT_drive = {7'b0100000,8'b01110111,1'b0,4'b1111,3'b000};
end
else begin
INPUT_drive = {7'b1100000,8'b01110111,1'b0,4'b1111,3'b000};
end
end
end

flag_X = 1;
end
end



//flag_group_count
for(int j=0; j<num_of_GROUP[i]; j++)begin
if(j==0)begin
if(tick_count == 17)begin
flag_group_count[j + prev_total_flag_group_count[i]]++;
end
end
else begin
if(tick_count > 17)begin
flag_group_count[j + prev_total_flag_group_count[i]] = flag_group_count[j + prev_total_flag_group_count[i]];
end
end
end


for(int j=0; j<num_of_GROUP[i]; j++)begin
if(j==num_of_GROUP[i]-1)begin
if(flag_group_count[j + prev_total_flag_group_count[i]])begin
flag_done[i] =1;
tick_count = 0;
flag_X=1;
end
end
else begin
flag_done[i] =0;
flag_X=1;
end
end

end



if(i==6)begin


//6 TEST of JAM
if(flag_done[i]!==1 && !flag_X) begin
//display start test
if(start_test[i] !==1)begin
$display ();
$display("%12s ***time = %0d, TEST of JAM***","",$time);
$display ();
start_test[i] = 1;
end


//input section
flag_X = 0;
for(int j=0; j<num_of_GROUP[i]; j++)begin
if(flag_group_count[j + prev_total_flag_group_count[i]] !==1 && !flag_X)begin
if(j==0)begin

end
if(j==1)begin

end
if(j==2)begin

end
if(j==3)begin

end
if(j==4)begin

end
if(j==5)begin

end
if(j==6)begin

end
if(j==7)begin

end
if(j==8)begin

end
if(j==9)begin

end


flag_X = 1;
end
end

tick_count = tick_count + 1;


//flag_group_count
for(int j=0; j<num_of_GROUP[i]; j++)begin
if(j==0)begin
if(tick_count == 8)begin
flag_group_count[j + prev_total_flag_group_count[i]]++;
end
end
else begin
if(tick_count == 8)begin
flag_group_count[j + prev_total_flag_group_count[i]]++;
end
end
end


for(int j=0; j<num_of_GROUP[i]; j++)begin
if(j==num_of_GROUP[i]-1)begin
if(flag_group_count[j + prev_total_flag_group_count[i]])begin
flag_done[i] =1;
tick_count = 0;
flag_X=1;
end
end
else begin
flag_done[i] =0;
flag_X=1;
end
end

end





if(i==7)begin


//6 TEST of DEFAULT
if(flag_done[i]!==1 && !flag_X) begin
//display start test
if(start_test[i] !==1)begin
$display ();
$display("%12s ***time = %0d, TEST of DEFAULT***","",$time);
$display ();
start_test[i] = 1;
end


//input section
flag_X = 0;
for(int j=0; j<num_of_GROUP[i]; j++)begin
if(flag_group_count[j + prev_total_flag_group_count[i]] !==1 && !flag_X)begin
if(j==0)begin

end

flag_X = 1;
end
end

tick_count = tick_count + 1;


//flag_group_count
for(int j=0; j<num_of_GROUP[i]; j++)begin
if(j==0)begin
if(tick_count == 8)begin
flag_group_count[j + prev_total_flag_group_count[i]]++;
end
end
else begin
if(tick_count == 8)begin
flag_group_count[j + prev_total_flag_group_count[i]]++;
end
end
end


for(int j=0; j<num_of_GROUP[i]; j++)begin
if(j==num_of_GROUP[i]-1)begin
if(flag_group_count[j + prev_total_flag_group_count[i]])begin
flag_done[i] =1;
tick_count = 0;
flag_X=1;
end
end
else begin
flag_done[i] =0;
flag_X=1;
end
end

end



//EOF
else if(flag_done[i]) begin
eof = 1;
end

end
end



end
endtask



//RANDOM IN

task random_in; begin

ch= $urandom_range(32,126);

mode = $urandom_range(1,num_of_group_x_general);
burst = $urandom_range (1,5);

repeat(burst)begin
@(negedge TICK);
# ($urandom_range(0,10));
case(mode)
3'b000: begin
end
3'b001: begin
end
3'b010: begin
end
3'b011: begin
end
3'b101: begin
end
3'b110: begin
INPUT_drive = {7'b0100000,ch[15:3],3'b000};
if(ch[15:8]>=ch[7:0])begin
repeat(3) begin
@(posedge TICK);
tick_count = tick_count + 1;
if(tick_count=1)begin
INPUT_drive = {7'b0100000,ch};
end
else begin
INPUT_drive = {7'b1100000,ch};
end
end
end
else begin
repeat()begin
tick_count = tick_count + 1;
end
end

end
3'b111: begin
end
end

end
endtask



//DRIVER

//INITITALIZE
initial begin
initialize;
end


//INPUT

always @ (negedge TICK) begin
for(int j=0; j<3;j++)begin
end

if (!eof) begin
general_input;
end
end

//AFTER EOF

initial begin

wait (eof);

for (int i = 0; i < 50; i++) begin
if(i==49)begin
random_in;
done = 1;
end else begin
random_in;
end
end

end



endmodule
