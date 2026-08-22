module input_lifo(
input int TICKPERIOD,
input TICK,
input [1:0] prev_state,
output reg RST,W_EN,R_EN,
output reg [DATA_WIDTH-1:0] DATA_IN,
output reg eof,
output reg done
);

reg flag_group_init;
reg [31:0]flag_group_count[0:32];
reg flag_init;
reg flag_rst;
reg flag_x[0:2];
reg flag_group_all[0:3];
reg flag_group_w_stress,flag_group_r_stress;
reg flag_rst_w_interrupt, flag_rst_r_interrupt;
reg [7:0]ch;
reg flag_x_prevr[0:1],flag_x_prevw[0:1];
reg flag_start_stress;
reg flag_stop;
reg start_test[0:31];
wire prev_state_full,prev_state_empty;
reg flag_done;
reg flag_group_finish[0:3];
reg int mode;
reg int burst;

//PARAMETER
parameter DATA_WIDTH = 8, ADDR_WIDTH = 4;

//TASK

//task 1 initialize
task initialize; begin
ch = $urandom_range(32,126);

{RST,W_EN,R_EN,DATA_IN} = {3'b000, ch};

for(int i=0; i<15; i++)begin
flag_group_count[i] = 0;
end

eof=0;


end
endtask


//task2 task general_input
task general_input; begin

ch = $urandom_range(32,126);

//EOF
if(flag_rst_r_interrupt)begin

{RST,W_EN,R_EN,DATA_IN} = {3'b100, ch};
eof = 1;
end



//SHARP INTERRUPT OF RST WHILE READ TEST (interrupt with RST between posedges of TICK)

else if(flag_rst_w_interrupt)begin

//display start test

if(start_test[6] !==1)begin
$display ();
$display("%12s ***time = %0d,SHARP INTERRUPT OF RST WHILE READ TEST***","",$time);
$display("%12s ***(interrupt with RST between posedges of TICK)***","");
$display ();
start_test[6] = 1;
end

//ending reset
if(flag_rst)begin

{RST,W_EN,R_EN,DATA_IN} <= {3'b100, ch};
flag_rst <= 0;
flag_start_stress <= 0;
flag_rst_r_interrupt <= 1;
end

//input section
else if(flag_done)begin
{RST,W_EN,R_EN,DATA_IN} <= {3'b000, ch};
flag_rst <= 1;
end
else if (flag_start_stress)begin

{RST,W_EN,R_EN,DATA_IN} <= {3'b001, ch};
@(posedge TICK);
#0.2;
{RST,W_EN,R_EN,DATA_IN} <= {3'b100, ch};
flag_done <= 1;
end
else begin

{RST,W_EN,R_EN,DATA_IN} <= {3'b010, ch};
if(prev_state_full)begin
{RST,W_EN,R_EN,DATA_IN} <= {3'b000, ch};
flag_start_stress <= 1;
end
end

end




//SHARP INTERRUPT OF RST WHILE WRITE TEST (interrupt with RST between posedges of TICK)

else if(flag_group_r_stress)begin
//display start test

if(start_test[5] !==1)begin
$display ();
$display("%12s ***time = %0d,SHARP INTERRUPT OF RST WHILE WRITE TEST***","",$time);
$display("%12s ***(interrupt with RST between posedges of TICK)***","");
$display ();
start_test[5] = 1;
end


if(flag_rst)begin
{RST,W_EN,R_EN,DATA_IN} <= {3'b100, ch};
flag_rst <= 0;
flag_done <=0;
flag_rst_w_interrupt <= 1;
end
else if(flag_done)begin
{RST,W_EN,R_EN,DATA_IN} <= {3'b000, ch};
flag_rst <= 1;
end
else begin

{RST,W_EN,R_EN,DATA_IN} <= {3'b010, ch};
@(posedge TICK);
#0.2;
{RST,W_EN,R_EN,DATA_IN} <= {3'b100, ch};
flag_done <= 1;
end
end





//READ STRESS TEST (READ FROM FULL UNTIL EMPTY)

else if(flag_group_w_stress)begin
//display start test

if(start_test[4] !==1)begin
$display ();
$display("%12s ***time = %0d,READ STRESS TEST***","",$time);
$display("%12s ***(READ FROM FULL UNTIL EMPTY)***","");
$display ();
start_test[4] = 1;
end


//ending reset

if(flag_rst)begin
{RST,W_EN,R_EN,DATA_IN} = {3'b100, ch};
flag_rst = 0;
flag_start_stress = 0;
flag_group_r_stress = 1;
end

//input section

else if(flag_start_stress !==1) begin
if(!prev_state_full || RST)begin
{RST,W_EN,R_EN,DATA_IN} = {3'b010, ch};
end
else begin
{RST,W_EN,R_EN,DATA_IN} = {3'b000, ch};
flag_start_stress = 1;
end
end

else begin
if(!prev_state_empty)begin
{RST,W_EN,R_EN,DATA_IN} = {3'b001, ch};
end
else begin
{RST,W_EN,R_EN,DATA_IN} = {3'b000, ch};
flag_rst = 1; 
end
end

end




//WRITE STRESS TEST (WRITE FROM EMPTY UNTIL FULL)

else if(flag_group_finish[2])begin
//display start test

if(start_test[3] !==1)begin
$display ();
$display("%12s ***time = %0d,WRITE STRESS TEST***","",$time);
$display("%12s ***(WRITE FROM EMPTY UNTIL FULL)***","");
$display ();
start_test[3] = 1;
end


//ending reset
if(flag_rst)begin
{RST,W_EN,R_EN,DATA_IN} = {3'b100, ch};
flag_rst = 0;
flag_group_w_stress =1;
end

//input section
else begin
if(flag_group_w_stress !==1)begin
if(!prev_state_full)begin
{RST,W_EN,R_EN,DATA_IN} = {3'b010, ch};
end
else if(prev_state_full)begin
{RST,W_EN,R_EN,DATA_IN} = {3'b000, ch};
flag_rst = 1;
end
end
end

end




//GENERAL_TEST

else begin
//INPUT GROUP 10-14

if(flag_group_finish[1]) begin


//display start test
if(start_test[2] !==1)begin
$display ();
$display("%12s ***time = %0d, TEST for prev_state = {FULL_EXPECTED,!EMPTY_EXPECTED} and current_state = {RST,W_EN,R_EN}***","",$time);
$display ();
start_test[2] = 1;
end


//flag_count section (to record group occurance)
flag_group_all[3] = 1;
for(int j=10;j<15;j++)begin
if(!flag_group_count[j])
flag_group_all[3] = 0;
end

//GROUP 10-14: prev_state = {FULL_EXPECTED,!EMPTY_EXPECTED} , current_state = {RST,W_EN,R_EN}

//ending reset
if(flag_rst)begin
{RST,W_EN,R_EN,DATA_IN} = {3'b100, ch};
flag_rst = 0;
flag_group_finish[2]=1;
end

//input section
else begin

if(flag_group_all[3] !==1)begin
flag_x[0] = 0;
for(int k=0;k<5;k++)begin
if(!flag_group_count[k+10] && !flag_x[0]) begin
if(prev_state !== 2'b10)begin
{RST,W_EN,R_EN,DATA_IN} = {3'b010, ch};
flag_x[0] = 1;
end
else begin
{RST,W_EN,R_EN,DATA_IN} = {k[2:0], ch};
flag_x[0] = 1;
end
end
end
end
else begin
{RST,W_EN,R_EN,DATA_IN} = {3'b000, ch};
flag_rst = 1;
end


end
end



//INPUT GROUP 5-9

else if(flag_group_finish[0]) begin

//display start test
if(start_test[1] !==1)begin
$display ();
$display("%12s ***time = %0d, TEST for prev_state = {!FULL_EXPECTED,EMPTY_EXPECTED} and current_state = {RST,W_EN,R_EN}***","",$time);
$display ();
start_test[1] = 1;
end


//flag_count section (to record group occurance)
flag_group_all[2] = 1;
for(int j=5;j<10;j++)begin
if(!flag_group_count[j])
flag_group_all[2] = 0;
end



//GROUP 5-9: prev_state = {!FULL_EXPECTED,EMPTY_EXPECTED} , current_state = {RST,W_EN,R_EN}


//ending reset
if(flag_rst)begin
{RST,W_EN,R_EN,DATA_IN} = {3'b100, ch};
flag_rst = 0;
flag_group_finish[1] = 1;
end

//input section
else begin


for(int j=5;j<10;j++)begin
end

if(flag_group_all[2]!==1)begin
flag_x[0] = 0;
for(int k=0;k<5;k++)begin
if(!flag_group_count[k+5] && !flag_x[0]) begin
if(prev_state !== 2'b01)begin
{RST,W_EN,R_EN,DATA_IN} = {3'b100, ch};
flag_x[0] = 1;
end
else begin
{RST,W_EN,R_EN,DATA_IN} = {k[2:0], ch};
flag_x[0] = 1;
end
end
end
end
else begin
{RST,W_EN,R_EN,DATA_IN} = {3'b000, ch};
flag_rst = 1;
end
end



end



//INPUT GROUP 0-3

else if(flag_init) begin

//display start test
if(start_test[0] !==1)begin
$display ();
$display("%12s ***time = %0d, TEST for prev_state = {!FULL_EXPECTED,!EMPTY_EXPECTED} and current_state = {RST,W_EN,R_EN}***","",$time);
$display ();
start_test[0] = 1;
end


//flag_count section (to record group occurance)
flag_group_all[1] = 1;
for(int j=0;j<5;j++)begin
if(!flag_group_count[j])
flag_group_all[1] = 0;
end

//GROUP 0-4: prev_state = {!FULL_EXPECTED,!EMPTY_EXPECTED} , current_state = {RST,W_EN,R_EN}

//ending reset
if(flag_rst)begin
{RST,W_EN,R_EN,DATA_IN} = {3'b100, ch};
flag_rst = 0;
flag_group_finish[0]=1;
end

//input section
else begin

if(flag_group_all[1]!==1)begin
flag_x[0] = 0;
for(int k=0;k<5;k++)begin
if(!flag_group_count[k] && !flag_x[0]) begin
if(prev_state !== 2'b00)begin
{RST,W_EN,R_EN,DATA_IN} = {3'b010, ch};
flag_x[0] = 1;
end
else begin
{RST,W_EN,R_EN,DATA_IN} = {k[2:0], ch};
flag_x[0] = 1;
end 
end
end
end
else begin
{RST,W_EN,R_EN,DATA_IN} = {3'b000, ch};
flag_rst = 1;
end

end





end



//INITIAL INPUT FLAG_GROUP
else begin

flag_group_init = prev_state === 2'bx && $time <= 6*TICKPERIOD/2 ;

if(flag_group_init)begin
{RST,W_EN,R_EN,DATA_IN} = {3'b100, ch};
flag_init = 1;
end

end


//FLAG_GROUP_COUNT (define flag_group_count)


if({prev_state,RST,W_EN,R_EN} < 5'b01000)begin
flag_group_count[{prev_state,RST,W_EN,R_EN}]++;
end
else if(5'b10000 > {prev_state,RST,W_EN,R_EN} && {prev_state,RST,W_EN,R_EN} > 5'b00111)begin
flag_group_count[{prev_state,RST,W_EN,R_EN}-3]++;
end
else if({prev_state,RST,W_EN,R_EN} > 5'b01111)begin
flag_group_count[{prev_state,RST,W_EN,R_EN}-6]++;
end


//FLAG_GROUP_ALL(record that all general test have been done)

flag_group_all[0] = 1;
for(int j=0;j<15;j++)begin
if(!flag_group_count[j])
flag_group_all[0] = 0;
end



end


end
endtask



//RANDOM IN

task random_in; begin

ch= $urandom_range(32,126);

mode = $urandom_range(0,4);
burst = $urandom_range (1,20);

repeat(burst)begin

@(posedge TICK);

# ($urandom_range(0.1,10));

case(mode)
0:begin
RST = 1'b0; W_EN = 1'b0; R_EN = 1'b0; DATA_IN = ch;
end
1:begin
RST = 1'b0; W_EN = 1'b0; R_EN = 1'b1; DATA_IN = ch;
end
2:begin
RST = 1'b0; W_EN = 1'b1; R_EN = 1'b0; DATA_IN = ch;
end
3:begin
RST = 1'b0; W_EN = 1'b1; R_EN = 1'b1; DATA_IN = ch;
end
4:begin
RST = 1'b1; W_EN = 1'b0; R_EN = 1'b0; DATA_IN = ch;
end
endcase



end

end
endtask



//DRIVER

//INITITALIZE
initial begin
initialize;
end


//ASSIGN
assign prev_state_full = prev_state[1];
assign prev_state_empty = prev_state[0];


//INPUT

always @ (posedge TICK) begin

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
