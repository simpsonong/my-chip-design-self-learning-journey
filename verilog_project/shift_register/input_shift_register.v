module input_shift_register(
input int TICKPERIOD,
input TICK,
output reg RST,
output reg D,
output reg eof,
output reg done,
output reg flag_init,
output reg flag_general,flag_lsb_to_msb,
output reg [3:0] start_test
);

reg ch;
reg int mode;
reg int burst;
reg [31:0]flag_group_count[0:5];
reg flag_X;
reg [31:0]tick_count;
reg [31:0]total_flag_group_count[0:1];

reg [INPUT_WIDTH-1:0]INPUT_coverage;
reg [INPUT_WIDTH+DATA_WIDTH-1:0]INPUT_drive;
reg [31:0]prev_total_flag_group_count;
reg flag_done;
reg [31:0]num_of_GROUP;



//PARAMETER
parameter DATA_WIDTH = 1;
parameter coverage_VECTOR_bits = 1;
localparam INPUT_WIDTH = $clog2('b1<<coverage_VECTOR_bits);



//TASK

//task 1 initialize
task initialize; begin

ch = $urandom_range(0,1);
{RST,D} = {1'b0,ch};
eof=0;

for(int j=0; j<6; j++)begin
flag_group_count[j] = 0;
end

tick_count=0;

end
endtask



//task2 task general_input
task general_input; begin

ch = $urandom_range(0,1);

//EOF
if(flag_lsb_to_msb)begin
eof = 1;
end


//2 TEST OF SHIFT from LSB to MSB

else if(flag_general) begin

//display start test
if(start_test[3] !==1)begin
$display ();
$display("%12s ***time = %0d, TEST OF SHIFT from LSB to MSB***","",$time);
$display ();
start_test[3] = 1;
end

//--------------------------------------------------------------------------------

//total flag_group_count
num_of_GROUP = 1;
prev_total_flag_group_count = total_flag_group_count[0];
total_flag_group_count[1] = num_of_GROUP + prev_total_flag_group_count;

//--------------------------------------------------------------------------------


//input section

flag_X = 0;
for(int j=0; j<num_of_GROUP; j++)begin
if(flag_group_count[j + prev_total_flag_group_count] !==1 && !flag_X)begin
INPUT_drive = {j[0],ch};
flag_X = 1;
end
end

tick_count <= tick_count + 1;
//--------------------------------------------------------------------------------

{RST,D} = INPUT_drive; 

//--------------------------------------------------------------------------------

//flag_group_count

if(tick_count === 8)begin
for(int j=0; j<num_of_GROUP; j++)begin
flag_group_count[j + prev_total_flag_group_count]++;
end
end


for(int j=0; j<num_of_GROUP; j++)begin
if(flag_group_count[j + prev_total_flag_group_count])begin
flag_done =1;
tick_count = 0;
end
else begin
flag_done =0;
end
end

//--------------------------------------------------------------------------------
flag_lsb_to_msb = flag_done;
//--------------------------------------------------------------------------------

end




//1 GENERAL TEST OF RST=1 and RST=0

else if(flag_init) begin


//display start test
if(start_test[2] !==1)begin
$display ();
$display("%12s ***time = %0d, GENERAL TEST OF RST=1 and RST=0***","",$time);
$display ();
start_test[2] <= 1;
end

//--------------------------------------------------------------------------------
//total flag_group_count
num_of_GROUP = 'b1<<coverage_VECTOR_bits;
prev_total_flag_group_count = 0;
total_flag_group_count[0] = num_of_GROUP + prev_total_flag_group_count;

//--------------------------------------------------------------------------------

//input section

flag_X = 0;
for(int j=0; j<num_of_GROUP; j++)begin
if(flag_group_count[j + prev_total_flag_group_count] !==1 && !flag_X)begin

if(start_test[j] !==1)begin
$display ();
$display("%12s ***time =%2d, GROUP%2d RST=%2d***","",$time,j,j);
$display ();
start_test[j] = 1;
end

INPUT_drive = {j[0],ch};
flag_X = 1;
end
end

//--------------------------------------------------------------------------------
{RST,D} = INPUT_drive; 

//--------------------------------------------------------------------------------

//flag_group_count
for(int j=0; j<num_of_GROUP; j++)begin
if(INPUT_drive[INPUT_WIDTH+DATA_WIDTH-1:INPUT_WIDTH+DATA_WIDTH-coverage_VECTOR_bits]==j[coverage_VECTOR_bits-1:0])begin
flag_group_count[j + prev_total_flag_group_count]++;
end
end

flag_done <=1;
for(int j=0; j<num_of_GROUP; j++)begin
if(flag_group_count[j + prev_total_flag_group_count]!==1)
flag_done <=0;
end

//--------------------------------------------------------------------------------
flag_general = flag_done;
//--------------------------------------------------------------------------------

end



//INITIAL INPUT
else begin
flag_init = 1;
end

end
endtask



//RANDOM IN

task random_in; begin


//--------------------------------------------------------------------------------

ch= $urandom_range(0,1);
mode = $urandom_range(0,3);
burst = $urandom_range (1,5);

//--------------------------------------------------------------------------------

//input section
repeat(burst)begin

@(negedge TICK);

# ($urandom_range(0,10));

case(mode)
0:begin
INPUT_drive[INPUT_WIDTH+DATA_WIDTH-1] = 1'b0; 
INPUT_drive[INPUT_WIDTH+DATA_WIDTH-2:0] = ch;
end
1:begin
INPUT_drive[INPUT_WIDTH+DATA_WIDTH-1] = 1'b1; 
INPUT_drive[INPUT_WIDTH+DATA_WIDTH-2:0] = ch;
end
endcase

//--------------------------------------------------------------------------------
{RST,D} = INPUT_drive; 
//--------------------------------------------------------------------------------

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

if (!eof) begin
general_input;
end
end

//AFTER EOF

initial begin

wait (eof);

$display ();
$display("%13s ***time = %0d,eof ***","",$time);
$display ();
$display ("%12s random stimulus to improve coverage","");


for (int i = 0; i < 100; i++) begin
if(i==99)begin
random_in;
done = 1;
end else begin
random_in;
end
end

end


endmodule
