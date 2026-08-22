`ifndef parameter_section
`define parameter_section


reg [31:0]total_flag_group_count[0:total_group_x_general];
reg [31:0]prev_total_flag_group_count[0:total_group_x_general];
reg [31:0]num_of_GROUP[0:total_group_x_general];
reg [31:0]num_of_group_general;
reg [31:0]total_num_of_group;
wire [coverage_VECTOR_WIDTH+DATA_WIDTH-1:0]INPUT_drive;
wire flag_done[0:total_group_x_general];




//AREA TO BE MODIFY (between the dashed line)   ***edit***  crucial parameter and TB_VECTOR combination
//--------------------------------------------------------------------------------------------------------------------------------

parameter coverage_VECTOR_bits = 7;                          //total bits of vectors to be covered
parameter DATA_WIDTH = 8;                                    //width of data(or bits of vector that doesn't need to be covered)
parameter num_of_DATA = 2;
parameter total_DATA_WIDTH = num_of_DATA*DATA_WIDTH;
parameter total_group_x_general = 7;                         //total number of groups excluding general test groups
parameter num_test_with_more_than_one_group_x_general = 4;
parameter num_of_GROUPS_in_test_1 = 5;                                              //number of groups in test 1
parameter num_of_GROUPS_in_test_2 = 3;                                              //number of groups in test 2
parameter num_of_GROUPS_in_test_3 = 3;                                              //number of groups in test 3
parameter num_of_GROUPS_in_test_6 = 10;                                             //number of groups in test 6


//INPUT COMBINATION
assign {GO_BAR,RESET,JAM,OPCODE,DATA_IN_A,DATA_IN_B} = INPUT_drive;                    //{CLR_bar,LD_bar,D} or something else

//--------------------------------------------------------------------------------------------------------------------------------

parameter num_of_GROUP_general = 'b1<<coverage_VECTOR_bits;
parameter coverage_VECTOR_WIDTH = coverage_VECTOR_bits;      //width of vectors to be covered
parameter num_test_with_only_one_group_x_general = total_group_x_general - num_test_with_more_than_one_group_x_general;
parameter total_flag_group_count_all = num_of_GROUP_general + num_of_GROUPS_in_test_1 + num_of_GROUPS_in_test_2 + 
                                       num_of_GROUPS_in_test_3 + num_of_GROUPS_in_test_6 +
                                       num_test_with_only_one_group_x_general;


//INSTANTIATE INPUT
input_register #(

//PARAMETER OVERRIDE

 .TICKPERIOD(TICKPERIOD),
 .coverage_VECTOR_bits(coverage_VECTOR_bits),
 .coverage_VECTOR_WIDTH(coverage_VECTOR_WIDTH),
 .total_DATA_WIDTH(total_DATA_WIDTH),
 .total_group_x_general(total_group_x_general),
 .total_flag_group_count_all(total_flag_group_count_all)
)input_register1(

//INSTANTIATE

 .TICK(TICK), .prev_total_flag_group_count(prev_total_flag_group_count),
 .num_of_GROUP(num_of_GROUP),.total_flag_group_count(total_flag_group_count),
 .INPUT_drive(INPUT_drive), .eof(eof), .done(done), .flag_init(flag_init),
 .flag_done(flag_done),
 .start_test(start_test));




//flag group count (provide group count to input for combination and record done group)

assign total_num_of_group = total_group_x_general+1;
assign num_of_group_general = num_of_GROUP[0];


initial begin

for(int j=0; j<(total_group_x_general+1); j++)begin       //***edit*** done, just copy paste, and edit j and number of num_of_GROUP
if(j==0)begin                                     
prev_total_flag_group_count[j] = 0;
num_of_GROUP[j] = num_of_GROUP_general;
total_flag_group_count[j] = num_of_GROUP[j] + prev_total_flag_group_count[j];
end
else if (j==1) begin
prev_total_flag_group_count[j] = total_flag_group_count[j-1];
num_of_GROUP[j] = 5;    //only to be modify if willing to test multiple group in same test
total_flag_group_count[j] = num_of_GROUP[j] + prev_total_flag_group_count[j];
end
else if (j==2) begin
prev_total_flag_group_count[j] = total_flag_group_count[j-1];
num_of_GROUP[j] = 3;    //only to be modify if willing to test multiple group in same test
total_flag_group_count[j] = num_of_GROUP[j] + prev_total_flag_group_count[j];
end
else if (j==3) begin
prev_total_flag_group_count[j] = total_flag_group_count[j-1];
num_of_GROUP[j] = 3;    //only to be modify if willing to test multiple group in same test
total_flag_group_count[j] = num_of_GROUP[j] + prev_total_flag_group_count[j];
end
else if (j==4) begin
prev_total_flag_group_count[j] = total_flag_group_count[j-1];
num_of_GROUP[j] = 1;    //only to be modify if willing to test multiple group in same test
total_flag_group_count[j] = num_of_GROUP[j] + prev_total_flag_group_count[j];
end
else if (j==5) begin
prev_total_flag_group_count[j] = total_flag_group_count[j-1];
num_of_GROUP[j] = 1;    //only to be modify if willing to test multiple group in same test
total_flag_group_count[j] = num_of_GROUP[j] + prev_total_flag_group_count[j];
end
else if (j==6) begin
prev_total_flag_group_count[j] = total_flag_group_count[j-1];
num_of_GROUP[j] = 10;    //only to be modify if willing to test multiple group in same test
total_flag_group_count[j] = num_of_GROUP[j] + prev_total_flag_group_count[j];
end
else begin
prev_total_flag_group_count[j] = total_flag_group_count[j-1];
num_of_GROUP[j] = 1;    //only to be modify if willing to test multiple group in same test
total_flag_group_count[j] = num_of_GROUP[j] + prev_total_flag_group_count[j];
end
end


end








`endif
