module input_register(
input int TICKPERIOD,
input TICK,
output reg EN,
output reg [DATA_WIDTH-1:0] D,
output reg eof,
output reg done,
output reg flag_init,
output reg flag_01,flag_10,flag_00,flag_11,flag_freq,
output reg [4:0] start_test
);

reg [7:0]ch;
reg int mode;
reg int burst;

//PARAMETER
parameter DATA_WIDTH = 8;

//TASK

//task 1 initialize
task initialize; begin
ch = $urandom_range(32,126);

{EN,D} = {1'b0,ch};



eof=0;


end
endtask


//task2 task general_input
task general_input; begin

ch = $urandom_range(32,126);

//EOF
if(flag_freq)begin
eof = 1;
end

//TEST of ENABLE changes frequently

else if(flag_11) begin

//display start test
if(start_test[4] !==1)begin
$display ();
$display("%12s ***time = %0d, TEST of ENABLE changes frequently***","",$time);
$display ();
start_test[4] = 1;
end

//input section
repeat(4)begin
{EN,D} = {~EN,ch};
@(posedge TICK);
end
flag_freq = 1;

end

//TEST of ENABLE maintains 1

else if(flag_00) begin
//display start test
if(start_test[3] !==1)begin
$display ();
$display("%12s ***time = %0d, TEST of ENABLE maintains 1***","",$time);
$display ();
start_test[3] = 1;
end

//input section
repeat(4)begin
{EN,D} = {1'b1,~ch};
@(posedge TICK);
end
flag_11 = 1;

end

//TEST of ENABLE maintains 0

else if(flag_10) begin

//display start test
if(start_test[2] !==1)begin
$display ();
$display("%12s ***time = %0d, TEST of ENABLE maintains 0***","",$time);
$display ();
start_test[2] = 1;
end

//input section
repeat(4)begin
{EN,D} = {1'b0,ch};
@(posedge TICK);
end
flag_00 = 1;

end

//TEST of ENABLE changes from 1 to 0

else if(flag_01) begin

//display start test
if(start_test[1] !==1)begin
$display ();
$display("%12s ***time = %0d, TEST of ENABLE changes from 1 to 0***","",$time);
$display ();
start_test[1] = 1;
end

//input section
{EN,D} = {1'b0,ch};
flag_10 = 1;

end


//TEST of ENABLE changes from 0 to 1

else if(flag_init) begin

//display start test
if(start_test[0] !==1)begin
$display ();
$display("%12s ***time = %0d, TEST of ENABLE changes from 0 to 1***","",$time);
$display ();
start_test[0] = 1;
end

//input section
{EN,D} = {1'b1,ch};
flag_01 = 1;

end

//INITIAL INPUT
else begin
flag_init = 1;
end

end
endtask



//RANDOM IN

task random_in; begin

ch= $urandom_range(32,126);

mode = $urandom_range(0,2);
burst = $urandom_range (1,5);

repeat(burst)begin

@(posedge TICK);

# ($urandom_range(0.1,10));

case(mode)
0:begin
EN = 1'b0; D = ch;
end
1:begin
EN = 1'b1; D = ch;
end
2:begin
EN = ~EN; D = ch;
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
