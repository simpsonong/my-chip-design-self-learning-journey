`timescale 1ns/10ps

module tb_alu;

//VECTORS FOR DUT
reg[3:0]  A, B;
reg[3:0]  S;
reg       M;
reg       Ci_bar;
wire[3:0] F;
wire      AEQB,Co_bar,X;

//VECTORS FOR TESTING

reg TICK;
integer FD, COUNT;
reg [8*32-1:0] COMMENT;
reg [3:0] F_EXPECTED;
reg Co_bar_EXPECTED;
reg AEQB_EXPECTED;
reg X_EXPECTED;
reg [31:0] VECTORCOUNT, ERRORS;
int i;
reg [31:0] input_coverage [0:63];
reg eof;
reg [3:0] prev_A;
reg [3:0] prev_B;
reg [3:0] prev_S;
reg prev_M;
reg prev_Ci_bar;
reg prev_FEx;
reg prev_FExbar;


//DUT INSTANTIATION

alu dut_alu( .a(A), .b(B),.s(S),
             .m(M),
             .ci_bar(Ci_bar),
             .aeqb(AEQB),
             .f3(F[3]), .f2(F[2]), .f1(F[1]), .f0(F[0]),
             .co_bar(Co_bar), .x(X) );



//DUMP EVERYTHING INTO DUMPFILE

initial begin

$dumpfile ("tb_alu.vcd");
$dumpvars (0, tb_alu);

end

//TICKPERIOD

localparam TICKPERIOD = 20;

always begin

#(TICKPERIOD/2) TICK = ~TICK;

end





//FUNCTION

//function 1 change character to number

function  num;
input [7:0] cha; // 4字符，每个8位

num = (cha == "1") ? 1'b1 :(cha == "0")? 1'b0 : 1'bx;  

endfunction




//function 2 COMMENT for random_in


function [8*32-1:0] cmt_arith_ci_bar;
  input  [3:0] A;
  input  [3:0] B;  
  input [3:0] S;
 
begin

  case (S)
    4'b0000: cmt_arith_ci_bar = "A + 1";
    4'b0001: cmt_arith_ci_bar = "(A|B) + 1";
    4'b0010: cmt_arith_ci_bar = "(A|~B) + 1"; 
    4'b0011: cmt_arith_ci_bar = "0"; 
    4'b0100: cmt_arith_ci_bar = "A + (A&~B) + 1";
    4'b0101: cmt_arith_ci_bar = "(A|B) + (A&~B) + 1";
    4'b0110: cmt_arith_ci_bar = "A - B"; 
    4'b0111: cmt_arith_ci_bar = "A&~B"; 
    4'b1000: cmt_arith_ci_bar = "A + (A&B) + 1";
    4'b1001: cmt_arith_ci_bar = "A + B + 1";
    4'b1010: cmt_arith_ci_bar = "(A|~B) + (A&B) + 1"; 
    4'b1011: cmt_arith_ci_bar = "A&B"; 
    4'b1100: cmt_arith_ci_bar = "A + A + 1 //shift";
    4'b1101: cmt_arith_ci_bar = "(A|B) + A + 1";
    4'b1110: cmt_arith_ci_bar = "(A|~B) + A + 1"; 
    4'b1111: cmt_arith_ci_bar = "A"; 
 
 endcase

end
endfunction

function [8*32-1:0] cmt_arith_xci_bar;
  input  [3:0] A;
  input  [3:0] B;  
  input [3:0] S;
 
begin

  case (S)
    4'b0000: cmt_arith_xci_bar = "A";
    4'b0001: cmt_arith_xci_bar = "A|B";
    4'b0010: cmt_arith_xci_bar = "A|~B"; 
    4'b0011: cmt_arith_xci_bar = "-1 //2'sComp"; 
    4'b0100: cmt_arith_xci_bar = "A + (A&~B)"; 
    4'b0101: cmt_arith_xci_bar = "(A|B) + (A&~B)";
    4'b0110: cmt_arith_xci_bar = "A - B - 1"; 
    4'b0111: cmt_arith_xci_bar = "(A&~B) - 1"; 
    4'b1000: cmt_arith_xci_bar = "A + (A&B)";
    4'b1001: cmt_arith_xci_bar = "A + B";
    4'b1010: cmt_arith_xci_bar = "(A|~B) + (A&B)"; 
    4'b1011: cmt_arith_xci_bar = "(A&B) - 1"; 
    4'b1100: cmt_arith_xci_bar = "A + A //shift";
    4'b1101: cmt_arith_xci_bar = "(A|B) + A";
    4'b1110: cmt_arith_xci_bar = "(A|~B) + A"; 
    4'b1111: cmt_arith_xci_bar = "A - 1"; 
 
 endcase

end
endfunction

function [8*32-1:0] cmt_logic_ci_bar;
  input  [3:0] A;
  input  [3:0] B;  
  input [3:0] S;
 
begin

  case (S)
    4'b0000: cmt_logic_ci_bar = "~A";
    4'b0001: cmt_logic_ci_bar = "~(A|B)";
    4'b0010: cmt_logic_ci_bar = "~A&B"; 
    4'b0011: cmt_logic_ci_bar = "0"; 
    4'b0100: cmt_logic_ci_bar = "~(A&B)";
    4'b0101: cmt_logic_ci_bar = "~B";
    4'b0110: cmt_logic_ci_bar = "A^B"; 
    4'b0111: cmt_logic_ci_bar = "A&~B"; 
    4'b1000: cmt_logic_ci_bar = "~A|B";
    4'b1001: cmt_logic_ci_bar = "~(A^B)";
    4'b1010: cmt_logic_ci_bar = "B"; 
    4'b1011: cmt_logic_ci_bar = "A&B"; 
    4'b1100: cmt_logic_ci_bar = "1111";
    4'b1101: cmt_logic_ci_bar = "A|~B";
    4'b1110: cmt_logic_ci_bar = "A|B"; 
    4'b1111: cmt_logic_ci_bar = "A"; 
 
 endcase

end
endfunction




//function 3 fexp for random_in


function [3:0] fexp_arith_ci_bar;
  input  [3:0] A;
  input  [3:0] B;  
  input [3:0] S;

begin

  case (S)
    4'b0000: fexp_arith_ci_bar = A + 4'b1;
    4'b0001: fexp_arith_ci_bar = (A|B) + 4'b1;
    4'b0010: fexp_arith_ci_bar = (A|~B) + 4'b1; 
    4'b0011: fexp_arith_ci_bar = 4'b0; 
    4'b0100: fexp_arith_ci_bar = A + (A&~B) + 4'b1;
    4'b0101: fexp_arith_ci_bar = (A|B) + (A&~B) + 4'b1;
    4'b0110: fexp_arith_ci_bar = A - B; 
    4'b0111: fexp_arith_ci_bar = A&~B; 
    4'b1000: fexp_arith_ci_bar = A + (A&B) + 4'b1;
    4'b1001: fexp_arith_ci_bar = A + B + 4'b1;
    4'b1010: fexp_arith_ci_bar = (A|~B) + (A&B) + 4'b1; 
    4'b1011: fexp_arith_ci_bar = A&B; 
    4'b1100: fexp_arith_ci_bar = A + A + 4'b1;
    4'b1101: fexp_arith_ci_bar = (A|B) + A + 4'b1;
    4'b1110: fexp_arith_ci_bar = (A|~B) + A + 4'b1; 
    4'b1111: fexp_arith_ci_bar = A; 
 
 endcase

end
endfunction

function [3:0] fexp_arith_xci_bar;
  input  [3:0] A;
  input  [3:0] B;  
  input [3:0] S;
begin


  case (S)
    4'b0000: fexp_arith_xci_bar = A;
    4'b0001: fexp_arith_xci_bar = A|B;
    4'b0010: fexp_arith_xci_bar = A|~B; 
    4'b0011: fexp_arith_xci_bar = -4'b1; 
    4'b0100: fexp_arith_xci_bar = A + (A&~B); 
    4'b0101: fexp_arith_xci_bar = (A|B) + (A&~B);
    4'b0110: fexp_arith_xci_bar = A - B - 4'b1; 
    4'b0111: fexp_arith_xci_bar = (A&~B) - 4'b1; 
    4'b1000: fexp_arith_xci_bar = A + (A&B);
    4'b1001: fexp_arith_xci_bar = A + B;
    4'b1010: fexp_arith_xci_bar = (A|~B) + (A&B); 
    4'b1011: fexp_arith_xci_bar = (A&B) - 4'b1; 
    4'b1100: fexp_arith_xci_bar = A + A;
    4'b1101: fexp_arith_xci_bar = (A|B) + A;
    4'b1110: fexp_arith_xci_bar = (A|~B) + A; 
    4'b1111: fexp_arith_xci_bar = A - 4'b1; 
 
 endcase

end
endfunction

function [3:0] fexp_logic_ci_bar;
  input  [3:0] A;
  input  [3:0] B;  
  input [3:0] S;
begin

  case (S)
    4'b0000: fexp_logic_ci_bar = ~A;
    4'b0001: fexp_logic_ci_bar = ~(A|B);
    4'b0010: fexp_logic_ci_bar = ~A&B; 
    4'b0011: fexp_logic_ci_bar = 4'b0; 
    4'b0100: fexp_logic_ci_bar = ~(A&B);
    4'b0101: fexp_logic_ci_bar = ~B;
    4'b0110: fexp_logic_ci_bar = A^B; 
    4'b0111: fexp_logic_ci_bar = A&~B; 
    4'b1000: fexp_logic_ci_bar = ~A|B;
    4'b1001: fexp_logic_ci_bar = ~(A^B);
    4'b1010: fexp_logic_ci_bar = B; 
    4'b1011: fexp_logic_ci_bar = A&B; 
    4'b1100: fexp_logic_ci_bar = 4'b1111;
    4'b1101: fexp_logic_ci_bar = A|~B;
    4'b1110: fexp_logic_ci_bar = A|B; 
    4'b1111: fexp_logic_ci_bar = A; 
 
 endcase

end
endfunction

//function 1 input_out1
function input_out1;
input A,B;
input [3:0]S;
begin
input_out1 = ~( (A & B & S[3]) | (A & ~B & S[2]) );

end
endfunction


//function 2 input_out2
function input_out2;
input A,B;
input [3:0]S;
begin

input_out2 = ~( A | (~B & S[1]) | (B & S[0]) );

end
endfunction

//function 4 co_bar_general 

function co_bar_general; 
input CI_BAR;
input [3:0]A,B;
reg [3:0]S;
reg y;

begin

S = 4'b1001;
y =  ~ ( input_out2(A[3],B[3],S) ||
       (input_out1(A[3],B[3],S) && input_out2(A[2],B[2],S)) ||
       (input_out1(A[3],B[3],S) && input_out1(A[2],B[2],S) && input_out2(A[1],B[1],S)) ||
       (input_out1(A[3],B[3],S) && input_out1(A[2],B[2],S) && input_out1(A[1],B[1],S) && input_out2(A[0],B[0],S))||
       (input_out1(A[3],B[3],S) && input_out1(A[2],B[2],S) && input_out1(A[1],B[1],S) && input_out1(A[0],B[0],S)));

co_bar_general = ~y || (input_out1(A[3],B[3],S) && input_out1(A[2],B[2],S) && input_out1(A[1],B[1],S) && input_out1(A[0],B[0],S) && CI_BAR);


end
endfunction



//function 6 x_general
function x_general;
input CI_BAR;
input [3:0]A,B;
reg [3:0]S;
begin

S = 4'b1001;

x_general = (~ (input_out1(A[3],B[3],S) && input_out1(A[2],B[2],S) && input_out1(A[1],B[1],S) && input_out1(A[0],B[0],S)))||
           (input_out1(A[0],B[0],S) && ~CI_BAR);
end
endfunction





//TASKS



//task 1 initialize

task initialize; begin

integer j;

FD = $fopen ("tb_alu.tv" , "r");


TICK = 0;
VECTORCOUNT = 0;
ERRORS = 0;

for ( j = 0 ; j < 64 ; j++ ) begin
input_coverage[j] = 0;
end

eof = 0;

$display ();
$display ("TEST_START------------------------------------------------------------------------------------------------------------------------------------------------------------------");
$display ();
$display ("                                | TIME | M | Ci_bar |    S    |    A    |    B    |    F    | CO_bar | AEQB | X | FEXPECTED | CObar_EXPECTED | AEQB_EXPECTED | X_EXPECTED |");
$display ("----------------------------------------------------------------------------------------------------------------------------------------------------------------------------");



end
endtask

//task 0 scan_file

task scan_file; begin

reg [8*256-1:0] line;
integer cut, idx, c, a;
integer j;      //专门给task里面的for用的

// 1. 读整行
COUNT = $fgets(line, FD);
eof = (COUNT == 0);
COMMENT = 0;               //重置COMMENT

// 2. 去掉换行符

cut =0;

while ((cut < 256)  && (line[cut*8 +:8] !== 8'h00) &&
      (line[cut*8 +:8] !== 8'h0A) && (line[cut*8 +:8] !== 8'h0D))         //ASII: 8'h0A = \n (new line,换行符)，8'h0D = \r (return,回车符)
begin
cut = cut + 1;        //cut有加就是从前面scan，cut没有加就是从后面scan
end


if (cut !== 0) begin
idx = cut - 1;     //skip过无效字符
end
else if (cut == 0)begin
idx = cut + 1;     //skip过无效字符
end


if ((idx <= 0) || (line[idx*8 +:8] == 8'h00))begin    //空行情况
disable scan_file;
end




// 3. 从尾巴向前找 FEXPECTED,B,A,S,Ci_bar,M


// 跳过空格

while (idx > 0 && (line[idx*8 +:8] == 8'h20 || line[idx*8 +:8] == 8'h09))                    //ASII: 8'h20 = "" (space,空格)，8'h09 ="    " (tab)
begin 
idx = (cut == 0)? (idx + 1):(idx - 1);
end

c = idx;


if(cut == 0) begin                                                                            //去除尾部(255:COMMENT[most significant bit(msb)]的空格，然后放结束符)
a = 0;
while ((a < 256)  && (line[a*8 +:8] !== 8'h00))begin
a = a + 1;        
end

while ((line[a*8 +:8] == 8'h20 || line[a*8 +:8] == 8'h09|| line[a*8 +:8] == 8'h00))begin 
a = a - 1;
end

line[(a+1)*8 +:8] = 8'h0;


end

else begin
line[cut*8 +:8] = 8'h0;
end


// 找 FEXPECTED

//如果中间要放COMMENT，写成"#COMMENT",判断放while (c >=0 && (line[c*8 +:8]！=="#"，然后不用cha2num的function))

while (c > 0 && (line[c*8 +:8]==8'h31 || line[c*8 +:8]==8'h30))                   //ASII: 8'h31 = "1" ，8'h30 = "0"
begin 
c = (cut == 0)? (c + 1):(c - 1);
end

if ((line[idx*8 +:8] == 8'h31)||(line[idx*8 +:8] == 8'h30)|| (line[idx*8 +:8] == 8'h2D))begin              //ASII: 8'h2D = "-"   


for(j = 0; j < ((cut == 0)? (c - idx):(idx - c)); j++) begin
if (idx >= 0)begin
F_EXPECTED[j] = (cut == 0)? num(line[(idx+j)* 8 +: 8]) : num(line[(idx-j)* 8 +: 8]);
end

end

end



// 跳过空格
idx = c;

while (idx > 0 && (line[idx*8 +:8] == 8'h20 || line[idx*8 +:8] == 8'h09))            
begin 
idx = (cut == 0)? (idx + 1):(idx - 1);
end

c = idx;



// 找 B
while (c > 0 && (line[c*8 +:8]==8'h31 || line[c*8 +:8]==8'h30))                   
begin 
c = (cut == 0)? (c + 1):(c - 1);
end

if ((line[idx*8 +:8] == 8'h31)||(line[idx*8 +:8] == 8'h30)|| (line[idx*8 +:8] == 8'h2D))begin              

for(j = 0; j < ((cut == 0)? (c - idx):(idx - c)); j++) begin
if (idx >= 0)begin
B[j] = (cut == 0)? num(line[(idx+j)* 8 +: 8]) : num(line[(idx-j)* 8 +: 8]);
end

end


end


// 跳过空格
idx = c;

while (idx > 0 && (line[idx*8 +:8] == 8'h20 || line[idx*8 +:8] == 8'h09))            
begin 
idx = (cut == 0)? (idx + 1):(idx - 1);
end

c = idx;




// 找 A
while (c > 0 && (line[c*8 +:8]==8'h31 || line[c*8 +:8]==8'h30))                   
begin 
c = (cut == 0)? (c + 1):(c - 1);
end

if ((line[idx*8 +:8] == 8'h31)||(line[idx*8 +:8] == 8'h30)|| (line[idx*8 +:8] == 8'h2D))begin              

for(j = 0; j < ((cut == 0)? (c - idx):(idx - c)); j++) begin
if (idx >= 0)begin
A[j] = (cut == 0)? num(line[(idx+j)* 8 +: 8]) : num(line[(idx-j)* 8 +: 8]);
end

end


end



// 跳过空格
idx = c;

while (idx > 0 && (line[idx*8 +:8] == 8'h20 || line[idx*8 +:8] == 8'h09))            
begin 
idx = (cut == 0)? (idx + 1):(idx - 1);
end

c = idx;




// 找 S
while (c > 0 && (line[c*8 +:8]==8'h31 || line[c*8 +:8]==8'h30))                   
begin 
c = (cut == 0)? (c + 1):(c - 1);
end

if ((line[idx*8 +:8] == 8'h31)||(line[idx*8 +:8] == 8'h30)|| (line[idx*8 +:8] == 8'h2D))begin              

for(j = 0; j < ((cut == 0)? (c - idx):(idx - c)); j++) begin
if (idx >= 0)begin
S[j] = (cut == 0)? num(line[(idx+j)* 8 +: 8]) : num(line[(idx-j)* 8 +: 8]);
end

end

end


// 跳过空格
idx = c;

while (idx > 0 && (line[idx*8 +:8] == 8'h20 || line[idx*8 +:8] == 8'h09))            
begin 
idx = (cut == 0)? (idx + 1):(idx - 1);
end

c = idx;




// 找 Ci_bar
while (c > 0 && (line[c*8 +:8]==8'h31 || line[c*8 +:8]==8'h30))                   
begin 
c = (cut == 0)? (c + 1):(c - 1);
end

if ((line[idx*8 +:8] == 8'h31)||(line[idx*8 +:8] == 8'h30)|| (line[idx*8 +:8] == 8'h2D))begin              

for(j = 0; j < ((cut == 0)? (c - idx):(idx - c)); j++) begin
if (idx >= 0)begin
Ci_bar = (cut == 0)? num(line[(idx+j)* 8 +: 8]) : num(line[(idx-j)* 8 +: 8]);
end

end


end




// 跳过空格
idx = c;

while (idx > 0 && (line[idx*8 +:8] == 8'h20 || line[idx*8 +:8] == 8'h09))            
begin 
idx = (cut == 0)? (idx + 1):(idx - 1);
end

c = idx;




// 找 M
while (c > 0 && (line[c*8 +:8]==8'h31 || line[c*8 +:8]==8'h30))                   
begin 
c = (cut == 0)? (c + 1):(c - 1);
end

if ((line[idx*8 +:8] == 8'h31)||(line[idx*8 +:8] == 8'h30)|| (line[idx*8 +:8] == 8'h2D))begin              

for(j = 0; j < ((cut == 0)? (c - idx):(idx - c)); j++) begin
if (idx >= 0)begin
M = (cut == 0)? num(line[(idx+j)* 8 +: 8]) : num(line[(idx-j)* 8 +: 8]);
end

end

end




// 跳过空格
idx = c;

while (idx > 0 && (line[idx*8 +:8] == 8'h20 || line[idx*8 +:8] == 8'h09))            
begin 
idx = (cut == 0)? (idx + 1):(idx - 1);
end

c = idx;




//找COMMENT


for(j=0; j < (a-idx+1); j++)begin
COMMENT[j*8 +:8] = line[(idx+j)*8 +:8]; 
end


end
endtask


//task 4 random_in

task random_in; begin


M      =  $urandom %2 ;
Ci_bar =  (M == 0)?$urandom %2: 0;  //I skip when M=Ci_bar=1, because output logic is same with M=1,Ci_bar=0
S      =  $urandom %16 ;
A      =  $urandom %16 ;
B      =  $urandom %16 ;


case ({M,Ci_bar})
    2'b00: COMMENT = cmt_arith_ci_bar(A, B, S);
    2'b01: COMMENT = cmt_arith_xci_bar(A, B, S);
    2'b10: COMMENT = cmt_logic_ci_bar(A, B, S);
    default: COMMENT = cmt_logic_ci_bar(A, B, S);
endcase


#($urandom_range(1,10));

end
endtask



//task2 F_EXP

task F_EXP; begin

  case ({M,Ci_bar})
    2'b00: F_EXPECTED = fexp_arith_ci_bar(A, B, S);
    2'b01: F_EXPECTED = fexp_arith_xci_bar(A, B, S);
    2'b10: F_EXPECTED = fexp_logic_ci_bar(A, B, S);
    default: F_EXPECTED = fexp_logic_ci_bar(A, B, S);
  endcase

end
endtask


//task3 Cobar_EXP

task Co_bar_EXP; begin

if(M == 0) begin
  case (S)
    4'b0000: Co_bar_EXPECTED = co_bar_general(Ci_bar,A,4'b0);
    4'b0001: Co_bar_EXPECTED = co_bar_general(Ci_bar,(A|B),4'b0);
    4'b0010: Co_bar_EXPECTED = co_bar_general(Ci_bar,(A|~B),4'b0);
    4'b0011: Co_bar_EXPECTED = 1;
    4'b0100: Co_bar_EXPECTED = co_bar_general(Ci_bar,A,(A&~B));
    4'b0101: Co_bar_EXPECTED = co_bar_general(Ci_bar,(A|B),(A&~B));
    4'b0110: Co_bar_EXPECTED = co_bar_general(Ci_bar,A,(~(B+1)+1));
    4'b0111: Co_bar_EXPECTED = co_bar_general(Ci_bar,(A&~B),(~4'b1+1));
    4'b1000: Co_bar_EXPECTED = co_bar_general(Ci_bar,A,(A&B));
    4'b1001: Co_bar_EXPECTED = co_bar_general(Ci_bar,A,B);
    4'b1010: Co_bar_EXPECTED = co_bar_general(Ci_bar,(A|~B),(A&B));
    4'b1011: Co_bar_EXPECTED = co_bar_general(Ci_bar,(A&B),(~4'b1+1));
    4'b1100: Co_bar_EXPECTED = co_bar_general(Ci_bar,A,A);
    4'b1101: Co_bar_EXPECTED = co_bar_general(Ci_bar,A,(A|B));
    4'b1110: Co_bar_EXPECTED = co_bar_general(Ci_bar,A,(A|~B));
    4'b1111: Co_bar_EXPECTED = co_bar_general(Ci_bar,A,(~4'b1+1));
 endcase
end
  
else begin
Co_bar_EXPECTED = 1;
end


end
endtask

//task4 AEQB_EXP

task AEQB_EXP;begin
AEQB_EXPECTED = (A == B);
end
endtask


//task5 X_EXP

task X_EXP;begin

if(M == 0) begin
case (S)
    4'b0000: X_EXPECTED = x_general(Ci_bar,A,4'b0);
    4'b0001: X_EXPECTED = x_general(Ci_bar,(A|B),4'b0);
    4'b0010: X_EXPECTED = x_general(Ci_bar,(A|~B),4'b0);
    4'b0011: X_EXPECTED = 0;
    4'b0100: X_EXPECTED = x_general(Ci_bar,A,(A&~B));
    4'b0101: X_EXPECTED = x_general(Ci_bar,(A|B),(A&~B));
    4'b0110: X_EXPECTED = x_general(Ci_bar,A,(~(B+1)+1));
    4'b0111: X_EXPECTED = x_general(Ci_bar,(A&~B),(~4'b1+1));
    4'b1000: X_EXPECTED = x_general(Ci_bar,A,(A&B));
    4'b1001: X_EXPECTED = x_general(Ci_bar,A,B);
    4'b1010: X_EXPECTED = x_general(Ci_bar,(A|~B),(A&B));
    4'b1011: X_EXPECTED = x_general(Ci_bar,(A&B),(~4'b1+1));
    4'b1100: X_EXPECTED = x_general(Ci_bar,A,A);
    4'b1101: X_EXPECTED = x_general(Ci_bar,A,(A|B));
    4'b1110: X_EXPECTED = x_general(Ci_bar,A,(A|~B));
    4'b1111: X_EXPECTED = x_general(Ci_bar,A,(~4'b1+1));
 endcase
end

else begin
X_EXPECTED = 0;
end


end
endtask


//task 5 close
task close; begin

integer j;

#10;
$fclose (FD);

$display ();
$display ("COVERAGE_REPORT");

for ( j = 0; j < 64; j++ ) begin

if(input_coverage[j] == 0) begin

$display ("input %b has occured %d times (***ERROR***)",j, input_coverage[j]);
ERRORS = ERRORS +1;

end

else begin

$display ("input %b has occured %d times",j[5:0], input_coverage[j]);
end

end

$display ();
$display ("VECTORCOUNT = %d", VECTORCOUNT);
$display ("ERRORS = %15d", ERRORS);
$display ();
$display ("TEST_END------------------------------------------------------------------------------------------------");
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

$display ("%10d %-20s | %4d | %1b | %3b    | %6b  | %6b  | %6b  | %6b  | %3b    | %3b  | %b | %7b   | %8b       | %7b       | %5b      |", VECTORCOUNT, COMMENT, $time, M, Ci_bar, S, A, B, F, Co_bar, AEQB, X, F_EXPECTED, Co_bar_EXPECTED,AEQB_EXPECTED, X_EXPECTED);

end
endtask

//task 8 coverage_update

task coverage_update; begin

input_coverage[{M,Ci_bar,S}]++;

if(M==1 && Ci_bar==0) begin
input_coverage[{1'b1,1'b1,S}]++;
end

end
endtask

//task 9 errors_warnings_check

task errors_warnings_check; begin


if (F !== F_EXPECTED) begin

$display ("***ERROR: F = %b, F_expected = %b", F, F_EXPECTED);
ERRORS = ERRORS + 1;

end

if (Co_bar !== Co_bar_EXPECTED) begin

$display ("***ERROR: Co_bar = %b, Co_bar_expected = %b", Co_bar, Co_bar_EXPECTED);
ERRORS = ERRORS + 1;

end
if (AEQB !== AEQB_EXPECTED) begin

$display ("***ERROR: AEQB = %b, AEQB_expected = %b", AEQB, AEQB_EXPECTED);
ERRORS = ERRORS + 1;

end
if (X !== X_EXPECTED) begin

$display ("***ERROR: X = %b, X_expected = %b", X, X_EXPECTED);
ERRORS = ERRORS + 1;

end


if (A !== prev_A || B !== prev_B || S !== prev_S || M !== prev_M || Ci_bar !== prev_Ci_bar) begin

$display ("***ERROR: Racing Condition Occur");
ERRORS = ERRORS + 1;

end


end
endtask



//DRIVE

//0 initialize

initial begin

initialize;

for (i=0; i<2; i++)begin
scan_file;
end

end

//2 scan file on negedge TICK

always @ (negedge TICK) begin


#1.2;

if (!eof) begin

scan_file;


end
end



//3 display file on posedge TICK

always  @ (posedge TICK) begin

coverage_update;
prev_A = A;
prev_B = B;
prev_S = S;
prev_M = M;
prev_Ci_bar = Ci_bar;

#0.1;

X_EXP;
AEQB_EXP;
Co_bar_EXP;
F_EXP;
display_file;
errors_warnings_check;
vectorcount;


end



// eof

initial begin

wait (eof);

$display ();
$display("%13s ***time = %0d,eof ***","",$time);
$display ();

for (i = 0; i < 50; i++) begin


if (M == 1 && Ci_bar == 2 && S == 4'b0000)

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
