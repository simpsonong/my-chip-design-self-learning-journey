module input_lifo(
input TICK_W,TICK_R,
input [ADDR_WIDTH:0] W_PTR,W_PTR_SYNC2,
input [ADDR_WIDTH:0] R_PTR,R_PTR_SYNC2,
input prev_state_w,prev_state_r;
output W_RST,W_EN,
output [DATA_WIDTH-1:0] DATA_IN,
output R_RST,R_EN
);

reg eof;
reg [31:0]flag_group_w_init;
reg [31:0]flag_group_w_count[0:32],flag_group_r_count[0:31];
reg flag_init;
reg flag_rst_w[0:32],flag_rst_r[0:32];
reg flag_x_w[0:2],flag_x_r[0:2];
reg [31:0]flag_group_w_all[0:3],flag_group_r_all[0:3];
reg [31:0]flag_group_w_all_stress,flag_group_r_all_stress;
reg flag_rst_w_interrupt, flag_rst_r_interrupt;
reg [7:0]ch;
reg rstsync_en_w,rstsync_en_r;
reg flag_x_prevr[0:1],flag_x_prevw[0:1];
reg flag_start_stress_r[0:2];
reg eof;
reg flag_stop_w;
reg flag_stop_r;
reg start_test_w[0:31];
reg start_test_r[0:31];

parameter DATA_WIDTH = 8, ADDR_WIDTH = 4;

else begin

//ONE_SIDE_RST_LOCK(used to prevent effective input while write and read reset are not synced)
//one-side-reset-lock
rstsync_en_w = 1;
if(flag_rst_w[0] || flag_rst_w[1] || flag_rst_w[2] || flag_rst_w[3])begin
rstsync_en_w = 0;
end

//RESET WRITE JUST BEFORE EOF(to make clean ending for next calculation)

if(flag_one_sided_rst_r && flag_rst_r[4]==0)begin
if(eof !==1)begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch};
flag_rst_w[5] = 1;
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
if(flag_rst_r[3] && {R_RST,R_EN} == 2'b10 && R_PTR_SYNC2 == 5'b0) begin
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
if(flag_rst_r[2] && {R_RST,R_EN} == 2'b10 && R_PTR_SYNC2 == 5'b0) begin
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
if(flag_rst_r[0] && {R_RST,R_EN} == 2'b10 && R_PTR_SYNC2 == 5'b0) begin
{W_RST,W_EN,DATA_IN} = {2'b10, ch};
flag_rst_r[0] = 0;
end
else begin
{W_RST,W_EN,DATA_IN} = {2'b00, ch};
end
end


else if(flag_rst_r[1])begin
if(flag_rst_r[1] && {R_RST,R_EN} == 2'b10 && R_PTR_SYNC2 == 5'b0) begin
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




//FLAG_GROUP_R_TICK_LONG
else begin

//ONE_SIDE_RST_LOCK(used to prevent effective input while write and read reset are not synced)

//one-side-reset-lock
rstsync_en_r = 1;
if(flag_rst_r[0] || flag_rst_r[1] || flag_rst_r[2])begin
rstsync_en_r = 0;
end



//RESET READ (to make clean ending for next calculation) AND EOF

if(flag_rst_r_interrupt && flag_rst_r[3]==0)begin
if(flag_rst_w[5] && W_RST && R_PTR_SYNC2 == 5'b0)begin
{R_RST,R_EN} = 2'b10;
flag_rst_w[5] = 0;
eof = 1;
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
if(flag_rst_w[3] && W_RST && R_PTR_SYNC2 == 5'b0)begin
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

if(flag_rst_w[2] && {W_RST,W_EN} == 2'b10  && W_PTR_SYNC2 == 5'b0) begin
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
if(flag_rst_w[1] && W_PTR_SYNC2 == 5'b0) begin
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
if(flag_init && {W_RST,W_EN} == 2'b10 && W_PTR_SYNC2 == 5'b0) begin
{R_RST,R_EN} = 2'b10;
flag_init = 0;
end
else begin
{R_RST,R_EN} = 2'b00;
flag_init = 1;
end
end

else if(flag_rst_w[0])begin
if(flag_rst_w[0] && {W_RST,W_EN} == 2'b10  && W_PTR_SYNC2 == 5'b0) begin
{R_RST,R_EN} = 2'b10;
flag_rst_w[0] = 0;
end
else begin
{R_RST,R_EN} = 2'b00;
flag_rst_w[0] = 1;
end
end

else if(flag_rst_w[1])begin
if(flag_rst_w[1] && {W_RST,W_EN} == 2'b10  && W_PTR_SYNC2 == 5'b0) begin
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


always @ (posedge TICK_W) begin
if (eof !==1) begin

general_input_w;

end
end

always @ (posedge TICK_R) begin
if (eof !==1) begin

general_input_r;

end
end


endmodule
