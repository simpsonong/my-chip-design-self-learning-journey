`ifndef parameter_section
`define parameter_section


reg [INPUT_WIDTH+DATA_WIDTH-1:0]INPUT_drive;
reg CLR,LD;
reg [31:0]total_flag_group_count[0:total_group_x_general];
reg [31:0]prev_total_flag_group_count[0:total_group_x_general];
reg flag_done[0:total_group_x_general];
reg [31:0]num_of_GROUP[0:total_group_x_general];
reg [31:0]num_of_group_general;
reg [31:0]total_num_of_group;



//INSTANTIATE INPUT
input_register #(

//PARAMETER OVERRIDE

 .TICKPERIOD(TICKPERIOD),
 .coverage_VECTOR_bits(coverage_VECTOR_bits),
 .INPUT_WIDTH(INPUT_WIDTH),
 .DATA_WIDTH(DATA_WIDTH),
 .total_group_x_general(total_group_x_general)
)input_register1(

//INSTANTIATE

 .TICK(TICK), .prev_total_flag_group_count(prev_total_flag_group_count),
 .num_of_GROUP(num_of_GROUP),.total_flag_group_count(total_flag_group_count),
 .INPUT_drive(INPUT_drive), .eof(eof), .done(done), .flag_init(flag_init),
 .flag_done(flag_done),
 .start_test(start_test));



//AREA TO BE MODIFY (between the dashed line)
//--------------------------------------------------------------------------------------------------------------------------------

parameter coverage_VECTOR_bits = 2;                //total bits of vectors to be covered
parameter INPUT_WIDTH = coverage_VECTOR_bits;      //width of vectors to be covered      
parameter DATA_WIDTH = 8;                          //width of data(or bits of vector that doesn't need to be covered)
parameter total_group_x_general = 2;               //total number of groups excluding general test groups

//INPUT COMBINATION
assign {CLR_bar,LD_bar,DATA_IN} = INPUT_drive                    //{CLR,LD,D} or something else

//--------------------------------------------------------------------------------------------------------------------------------






//flag group count (provide group count to input for combination and record done group)

assign total_num_of_group = total_group_x_general+1;
assign num_of_group_general = num_of_GROUP[0];

always@(*)begin

for(int j=0; j<(total_group_x_general+1); j++)begin
if(j==0)begin
prev_total_flag_group_count[j] = 0;
num_of_GROUP[j] = 'b1<<coverage_VECTOR_bits;
total_flag_group_count[j] = num_of_GROUP[j] + prev_total_flag_group_count;
end
else if(j==1)begin
prev_total_flag_group_count[j] = total_flag_group_count[j-1];
num_of_GROUP[j] = 2;    //only to be modify if willing to test multiple group in same test
total_flag_group_count[j] = num_of_GROUP[j] + prev_total_flag_group_count;
end
else begin
prev_total_flag_group_count[j] = total_flag_group_count[j-1];
num_of_GROUP[j] = 1;    //only to be modify if willing to test multiple group in same test
total_flag_group_count[j] = num_of_GROUP[j] + prev_total_flag_group_count;
end
end

for (int j=0; j< (total_group_x_general+1); j++)begin
if(j==0)begin
flag_general = flag_done[j];
end
if(j==1)begin
flag_mantain_ld = flag_done[j];
end
if(j==2)begin
flag_freq = flag_done[j];
end
end

end









`endif
