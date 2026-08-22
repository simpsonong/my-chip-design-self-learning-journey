`timescale 1ns/10ps

module tb_counter_4bits;

//VECTORS FOR DUT
reg CLR_BAR,LD_BAR,ENT,ENP;
reg [3:0] DATA;
wire COUT;
wire [3:0] Q;

//VECTORS FOR TESTING

reg TICK;
integer FD, COUNT;
reg [8*31-1:0] COMMENT;
reg COUT_EXPECTED;
reg [3:0] Q_EXPECTED;
reg [3:0] Q_EXPECTED1;
reg [31:0] VECTORCOUNT, ERRORS;
int i;
reg [31:0] input_coverage[0:15];
reg eof;
reg [3:0] IN;
reg[7:0] prev_IN;
reg [3:0] prev_q;

//DUT INSTANTIATION

counter_4bits dut_counter_4bits (.clk(TICK), .clrbar(CLR_BAR), .ld_bar(LD_BAR), .ent(ENT), .enp(ENP), .data(DATA), .cout(COUT), .q(Q));


//DUMP EVERYTHING INTO DUMPFILE

initial begin

$dumpfile ("tb_counter_4bits.vcd");
$dumpvars (0, tb_counter_4bits);

end


//TICKPERIOD

localparam TICKPERIOD = 20;

always begin

#(TICKPERIOD/2) TICK = ~TICK;

end

//FUNCTION


//function 1 jk_flip_flop

function q; 
input clrbar;
input feedback;
input ld;
input data;
input prev_q;
begin

reg to_j_and_k, to_j, to_k, j, k;

to_j_and_k = feedback|ld;
to_k = ~(data & ld);
to_j = ~(to_k & ld);

j = to_j & to_j_and_k;
k = to_k & to_j_and_k;


if (~clrbar) begin
            q = 1'b0;
        end else begin

        case ({j,k})
            2'b00  : q = prev_q;
            2'b01  : q = 1'b0;
            2'b10  : q = 1'b1;
            2'b11  : q = ~prev_q;
        endcase
end

  
end
endfunction



//TASKS

//task 1 initialize

task initialize; begin

FD = $fopen ("tb_counter_4bits.tv" , "r");
COUNT = $fscanf (FD, "%s", COMMENT);

COUNT = $fscanf (FD, "%s %b %b %b %b %b %b %b", COMMENT, CLR_BAR, LD_BAR, ENT, ENP, DATA, COUT_EXPECTED, Q_EXPECTED1);
TICK = 0;
VECTORCOUNT = 0;
ERRORS = 0;

for(i=0; i<16; i++)begin
input_coverage[i] = 0;
end

eof = 0;

$display ();
$display ("TEST_START-------------------------------------------------------------------------------------------------------------------------------------");
$display ();
$display ("                     | TIME | CLR_BAR | LD_BAR | ENT | ENP | DATA | COUT | Q  | COUT_EXPECTED | Q_EXPECTED |");
$display ("-----------------------------------------------------------------------------------------------------------------------------------------------");



end
endtask


//task 3 scan_file

task scan_file; begin

COUNT = $fscanf (FD, "%s %b %b %b %b %b %b %b", COMMENT, CLR_BAR, LD_BAR, ENT, ENP, DATA, COUT_EXPECTED, Q_EXPECTED1);
eof = (COUNT == -1);

end
endtask

//task 4 random_in

task random_in; begin

CLR_BAR =  $urandom %2;
LD_BAR = (CLR_BAR == 1'b0)? 0: $urandom %2;
ENT = (CLR_BAR == 1'b0)? 0: (LD_BAR == 1'b0)? 0: $urandom %2;
ENP = (CLR_BAR == 1'b0)? 0: (LD_BAR == 1'b0)? 0: $urandom %2;
DATA =  $urandom %16;

if(CLR_BAR == 0)
COMMENT = "CLEAR";

else if(LD_BAR == 0)
COMMENT = "LOAD";

else if(ENT == 1 & ENP == 1)
COMMENT = "COUNT";

else
COMMENT = "WAIT";



# ($urandom_range(0.1,10));

end
endtask

//task5 OUT_EXP

task OUT_EXP; begin

reg LD;
reg [3:0] FEEDBACK;

LD = ~LD_BAR;

FEEDBACK[0] = ENT & ENP;
Q_EXPECTED[0] = q(CLR_BAR,FEEDBACK[0],LD,DATA[0], prev_q[0]);

FEEDBACK[1] = ENT & ENP & prev_q[0];
Q_EXPECTED[1] = q(CLR_BAR,FEEDBACK[1],LD,DATA[1], prev_q[1]);

FEEDBACK[2] = ENT & ENP & prev_q[1] & prev_q[0];
Q_EXPECTED[2] = q(CLR_BAR,FEEDBACK[2],LD,DATA[2], prev_q[2]);

FEEDBACK[3] = ENT & ENP & prev_q[2] & prev_q[1] & prev_q[0];
Q_EXPECTED[3] = q(CLR_BAR,FEEDBACK[3],LD,DATA[3], prev_q[3]);


COUT_EXPECTED = ENT & ENP & prev_q[3] & prev_q[2] & prev_q[1] & prev_q[0];
 

end
endtask



//task 5 close

task close; begin

#10;

$fclose (FD);

$display ();
$display ("COVERAGE_REPORT");

for (int j = 0; j < 16; j++ ) begin

if(input_coverage[j] == 0) begin
$display ("input CLR_BAR = %b, LD_BAR = %b, ENT = %b, ENP = %b has occured %d times ***ERROR***", j[3], j[2], j[1], j[0], input_coverage[j]);
ERRORS = ERRORS + 1;
end

else if(j>0 & j<8) begin
$display ("input CLR_BAR = %b, LD_BAR = %b, ENT = %b, ENP = %b has occured %d times ***same logic as above while CLR_BAR = 0", j[3], j[2], j[1], j[0], input_coverage[j]);
end

else if(j>8 & j<12) begin
$display ("input CLR_BAR = %b, LD_BAR = %b, ENT = %b, ENP = %b has occured %d times ***same logic as above while CLR_BAR = 0", j[3], j[2], j[1], j[0], input_coverage[j]);
end


else begin
$display ("input CLR_BAR = %b, LD_BAR = %b, ENT = %b, ENP = %b has occured %d times", j[3], j[2], j[1], j[0], input_coverage[j]);
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


//task 7 display_file

task display_file; begin

$display ("%10d %9s-%-2d | %4d | %4b    | %3b    | %2b  | %2b  | %4b | %2b   | %4b | %7b       | %7b    |", VECTORCOUNT, COMMENT, prev_q, $time, CLR_BAR, LD_BAR, ENT, ENP, DATA, COUT, Q, COUT_EXPECTED, Q_EXPECTED);

end
endtask

//task 8 coverage_update

task coverage_update; begin


input_coverage[IN]++;

if(IN == 4'b0)begin
for(int j=1; j<8; j++)
input_coverage[j]++;
end

if(CLR_BAR == 1 & LD_BAR == 0)begin
for(int j=9; j<12; j++)
input_coverage[j]++;
end


end
endtask




//task 9 errors_warnings_check

task errors_warnings_check; begin


if (COUT !== COUT_EXPECTED) begin

$display ("***ERROR: COUT = %b, COUT_expected = %b", COUT, COUT_EXPECTED);
ERRORS = ERRORS + 1;

end


if (Q !== Q_EXPECTED) begin

$display ("***ERROR: Q = %b, Q_expected = %b", Q, Q_EXPECTED);
ERRORS = ERRORS + 1;

end

if (IN !== prev_IN) begin

$display ("***ERROR: RACING CONDITION OCCUR");
ERRORS = ERRORS + 1;

end


end
endtask



//DRIVE

//0 initialize

initial begin

initialize;

end

//2 scan file on negedge TICK

always @ (negedge TICK) begin

#1.2;

if (!eof) begin

scan_file;

end
end

//posedge reset
always  @ (posedge TICK) begin

OUT_EXP;

end

//3 check file on posedge TICK

always  @ (posedge TICK) begin

IN = {CLR_BAR, LD_BAR, ENT, ENP};
coverage_update;
prev_IN = IN;

#0.1;
display_file;
errors_warnings_check;
vectorcount;

#0.1;
prev_q = Q_EXPECTED;

end



// eof

initial begin

wait (eof);

$display ();
$display("%13s ***time = %0d,eof ***","",$time);
$display ();

for (i = 0; i < 50; i++) begin


if (IN == 5'b10000)
begin

vectorcount;
close;

end

else begin

random_in;
end

end

close;

end


endmodule
