module input_register(
input TICK,
input reg [31:0]total_flag_group_count[0:total_group_x_general],
input reg [31:0]prev_total_flag_group_count[0:total_group_x_general],
input reg [31:0]num_of_GROUP[0:total_group_x_general],
output LD_bar,
output CLR_bar,
output reg [DATA_WIDTH-1:0] D,
output reg eof,
output reg done,
output reg flag_init,
output reg flag_general,flag_mantain_ld,flag_freq,
output reg [4:0] start_test,
output reg [coverage_VECTOR_WIDTH+DATA_WIDTH-1:0]INPUT_drive,
output reg flag_done[0:total_group_x_general]
);

reg [DATA_WIDTH-1:0]ch;
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

parameter DATA_WIDTH = 8;
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



INPUT_drive = {{coverage_VECTOR_bits{1'b0}},ch};

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



//1 GENERAL TEST of {CLR_bar,LD_bar}
else if(flag_done[i] !==1 && !flag_X)begin

//display start test
if(start_test[i] !==1)begin
$display ();
$display("%12s ***time = %0d, GENERAL TEST of {CLR,LD}***","",$time);
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
if(INPUT_drive[coverage_VECTOR_WIDTH+DATA_WIDTH-1:DATA_WIDTH]==j[coverage_VECTOR_bits-1:0])begin
flag_group_count[j + prev_total_flag_group_count[i]]++;
end
end
else begin
if(INPUT_drive[coverage_VECTOR_WIDTH+DATA_WIDTH-1:DATA_WIDTH]==j[coverage_VECTOR_bits-1:0])begin
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

//2 TEST of LD_bar maintains 0 then 1

if(flag_done[i] !==1 && !flag_X) begin

//display start test
if(start_test[i] !==1)begin
$display ();
$display("%12s ***time = %0d, TEST of LD maintains 0 then 1","",$time);
$display ();
start_test[i] = 1;
end



//input section
flag_X = 0;
for(int j=0; j<num_of_GROUP[i]; j++)begin
if(flag_group_count[j + prev_total_flag_group_count[i]] === 0 && !flag_X)begin
INPUT_drive = {j[coverage_VECTOR_bits-1:0],ch};
flag_X = 1;
end
end


tick_count = tick_count + 1;



//flag_group_count
for(int j=0; j<num_of_GROUP[i]; j++)begin
if(j==0)begin
if(tick_count == 4)begin
flag_group_count[j+prev_total_flag_group_count[i]]++;
flag_X=1;
end
end
else begin
if(tick_count == 8)begin
flag_group_count[j+prev_total_flag_group_count[i]]++;
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


//3 TEST of LD and CLR switch frequetly
if(flag_done[i]!==1 && !flag_X) begin
//display start test
if(start_test[i] !==1)begin
$display ();
$display("%12s ***time = %0d, TEST of ENABLE changes frequently***","",$time);
$display ();
start_test[i] = 1;
end


//input section
flag_X = 0;
for(int j=0; j<num_of_GROUP[i]; j++)begin
if(flag_group_count[j + prev_total_flag_group_count[i]] !==1 && !flag_X)begin
case({INPUT_drive[coverage_VECTOR_WIDTH+DATA_WIDTH-1],INPUT_drive[coverage_VECTOR_WIDTH+DATA_WIDTH-2]})
2'b01,2'b10: INPUT_drive = {~INPUT_drive[coverage_VECTOR_WIDTH+DATA_WIDTH-1:DATA_WIDTH],ch};
default: INPUT_drive = {INPUT_drive[coverage_VECTOR_WIDTH+DATA_WIDTH-1:DATA_WIDTH],ch};
endcase

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

mode = $urandom_range(1,'b1<<coverage_VECTOR_bits);
burst = $urandom_range (1,5);

repeat(burst)begin
@(negedge TICK);
# ($urandom_range(0,10));

for(int j=0; j<mode; j++)begin
if(j==mode-1)begin
INPUT_drive = {j[coverage_VECTOR_bits-1:0],ch};
end
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
