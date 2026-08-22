//0.ALU

module alu(
input   [3:0]a,b,s,
input   m,
input   ci_bar,
output  aeqb,
output  f0, f1, f2, f3,
output  co_bar, x
);

wire m_bar;

//i.aeqb_section

aeqb dut_aeqb (.a(a), .b(b), .aeqb(aeqb) );


//ii.gpc_section

GPC_section gpc(
.a(a),.b(b),.s(s),
.m(m),.ci_bar(ci_bar),
.co_bar(co_bar),.x(x)
);


//iii. invert_m


invert_m invert(
.a(m),
.y(m_bar)
);


//iv. out_section

out_section_out0 out0(
.x(x),
.a(a),.b(b),.s(s),
.m_bar (m_bar),
.ci_bar (ci_bar),
.f0 (f0)
);

out_section_out1 out1(
.x(x),
.a(a),.b(b),.s(s),
.m_bar (m_bar),
.ci_bar (ci_bar),
.f1 (f1)
);

out_section_out2 out2(
.x(x),
.a(a),.b(b),.s(s),
.m_bar (m_bar),
.ci_bar (ci_bar),
.f2 (f2)
);


out_section_out3 out3(
.x(x),
.a(a),.b(b),.s(s),
.m_bar (m_bar),
.ci_bar (ci_bar),
.f3 (f3)
);


endmodule



//FUNCTION

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


//function 3 co_bar_general
function co_bar_general;
input CI_BAR;
input [3:0]A,B;

reg [3:0]S;
reg y;
begin

S = 4'b1001;

y =  ~ (input_out2(A[3],B[3],S) || (input_out1(A[3],B[3],S) && input_out2(A[2],B[2],S)) || 
       (input_out1(A[3],B[3],S) && input_out1(A[2],B[2],S) && input_out2(A[1],B[1],S)) ||
       (input_out1(A[3],B[3],S) && input_out1(A[2],B[2],S) & input_out1(A[1],B[1],S) && input_out2(A[0],B[0],S)) || 
       (input_out1(A[3],B[3],S) && input_out1(A[2],B[2],S) && input_out1(A[1],B[1],S) && input_out1(A[0],B[0],S)));

co_bar_general = ~y || (input_out1(A[3],B[3],S) && input_out1(A[2],B[2],S) && input_out1(A[1],B[1],S) && input_out1(A[0],B[0],S) && CI_BAR);


end
endfunction

//function 6 co_bar_pick
function co_bar_pick;
input CI_BAR;
input [3:0]A,B,S;

begin
  case (S)
    4'b0000: co_bar_pick = co_bar_general(CI_BAR,A,4'b0);
    4'b0001: co_bar_pick = co_bar_general(CI_BAR,(A|B),4'b0);
    4'b0010: co_bar_pick = co_bar_general(CI_BAR,(A|~B),4'b0);
    4'b0011: co_bar_pick = 1;
    4'b0100: co_bar_pick = co_bar_general(CI_BAR,A,(A&~B));
    4'b0101: co_bar_pick = co_bar_general(CI_BAR,(A|B),(A&~B));
    4'b0110: co_bar_pick = co_bar_general(CI_BAR,A,(~(B+1)+1));
    4'b0111: co_bar_pick = co_bar_general(CI_BAR,(A&~B),(~4'b1+1));
    4'b1000: co_bar_pick = co_bar_general(CI_BAR,A,(A&B));
    4'b1001: co_bar_pick = co_bar_general(CI_BAR,A,B);
    4'b1010: co_bar_pick = co_bar_general(CI_BAR,(A|~B),(A&B));
    4'b1011: co_bar_pick = co_bar_general(CI_BAR,(A&B),(~4'b1+1));
    4'b1100: co_bar_pick = co_bar_general(CI_BAR,A,A);
    4'b1101: co_bar_pick = co_bar_general(CI_BAR,A,(A|B));
    4'b1110: co_bar_pick = co_bar_general(CI_BAR,A,(A|~B));
    4'b1111: co_bar_pick = co_bar_general(CI_BAR,A,(~4'b1+1));
 endcase

end
endfunction


//function 6 x_general
function x_general;
input CI_BAR;
input [3:0]A,B;

reg [3:0]S;
begin

S = 4'b1001;

x_general = ~ (input_out1(A[3],B[3],S) && input_out1(A[2],B[2],S) && input_out1(A[1],B[1],S) && input_out1(A[0],B[0],S))||
           (input_out1(A[0],B[0],S) && ~CI_BAR);
end
endfunction


//function 6 x_pick
function x_pick;
input CI_BAR;
input [3:0]A,B,S;

begin

case (S)
    4'b0000: x_pick = x_general(CI_BAR,A,4'b0);
    4'b0001: x_pick = x_general(CI_BAR,(A|B),4'b0);
    4'b0010: x_pick = x_general(CI_BAR,(A|~B),4'b0);
    4'b0011: x_pick = 0;
    4'b0100: x_pick = x_general(CI_BAR,A,(A&~B));
    4'b0101: x_pick = x_general(CI_BAR,(A|B),(A&~B));
    4'b0110: x_pick = x_general(CI_BAR,A,(~(B+1)+1));
    4'b0111: x_pick = x_general(CI_BAR,(A&~B),(~4'b1+1));
    4'b1000: x_pick = x_general(CI_BAR,A,(A&B));
    4'b1001: x_pick = x_general(CI_BAR,A,B);
    4'b1010: x_pick = x_general(CI_BAR,(A|~B),(A&B));
    4'b1011: x_pick = x_general(CI_BAR,(A&B),(~4'b1+1));
    4'b1100: x_pick = x_general(CI_BAR,A,A);
    4'b1101: x_pick = x_general(CI_BAR,A,(A|B));
    4'b1110: x_pick = x_general(CI_BAR,A,(A|~B));
    4'b1111: x_pick = x_general(CI_BAR,A,(~4'b1+1));
 endcase

end
endfunction



//function 3 f_pick

function [3:0] f_pick;
  input M;
  input Ci_bar;
  input  [3:0] A;
  input  [3:0] B;
  input [3:0] S;

begin

 case ({M,Ci_bar})
    2'b00: f_pick = fexp_arith_xci_bar(A, B, S);
    2'b01: f_pick = fexp_arith_ci_bar(A, B, S);
    2'b10: f_pick = fexp_logic_ci_bar(A, B, S);
    default: f_pick = fexp_logic_ci_bar(A, B, S);
  endcase

end
endfunction


function [3:0] fexp_arith_xci_bar;
  input  [3:0] A;
  input  [3:0] B;
  input [3:0] S;

begin

  case (S)
    4'b0000: fexp_arith_xci_bar = A ^ 4'b1;
    4'b0001: fexp_arith_xci_bar = (A|B) ^ 4'b1;
    4'b0010: fexp_arith_xci_bar = (A|~B) ^ 4'b1;
    4'b0011: fexp_arith_xci_bar = 4'b0;
    4'b0100: fexp_arith_xci_bar = A ^ (A&~B) ^ 4'b1;
    4'b0101: fexp_arith_xci_bar = (A|B) ^ (A&~B) ^ 4'b1;
    4'b0110: fexp_arith_xci_bar = A ^ (~B+1);
    4'b0111: fexp_arith_xci_bar = A&~B;
    4'b1000: fexp_arith_xci_bar = A ^ (A&B) ^ 4'b1;
    4'b1001: fexp_arith_xci_bar = A ^ B ^ 4'b1;
    4'b1010: fexp_arith_xci_bar = (A|~B) ^ (A&B) ^ 4'b1;
    4'b1011: fexp_arith_xci_bar = A&B;
    4'b1100: fexp_arith_xci_bar = A ^ A ^ 4'b1;
    4'b1101: fexp_arith_xci_bar = (A|B) ^ A ^ 4'b1;
    4'b1110: fexp_arith_xci_bar = (A|~B) ^ A ^ 4'b1;
    4'b1111: fexp_arith_xci_bar = A;

 endcase

end
endfunction

function [3:0] fexp_arith_ci_bar;
  input  [3:0] A;
  input  [3:0] B;
  input [3:0] S;
begin


  case (S)
    4'b0000: fexp_arith_ci_bar = A;
    4'b0001: fexp_arith_ci_bar = A|B;
    4'b0010: fexp_arith_ci_bar = A|~B;
    4'b0011: fexp_arith_ci_bar = -4'b1;
    4'b0100: fexp_arith_ci_bar = A ^ (A&~B);
    4'b0101: fexp_arith_ci_bar = (A|B) ^ (A&~B);
    4'b0110: fexp_arith_ci_bar = A ^ (~(B+4'b1)+1);
    4'b0111: fexp_arith_ci_bar = (A&~B) ^ (~4'b1+1);
    4'b1000: fexp_arith_ci_bar = A ^ (A&B);
    4'b1001: fexp_arith_ci_bar = A ^ B;
    4'b1010: fexp_arith_ci_bar = (A|~B) ^ (~4'b1+1);
    4'b1011: fexp_arith_ci_bar = (A&B) ^ 4'b1;
    4'b1100: fexp_arith_ci_bar = A ^ A;
    4'b1101: fexp_arith_ci_bar = (A|B) ^ A;
    4'b1110: fexp_arith_ci_bar = (A|~B) ^ A;
    4'b1111: fexp_arith_ci_bar = A ^ (~4'b1+1);

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



//SUB_MODULES

//1.aeqb (a equal b) )

module aeqb(
input[3:0] a, b,
output aeqb
);

assign aeqb = (a == b);


endmodule




//2. GPC SECTION ( GENERATE, PROPAGATE, CARRY )

module GPC_section(
input  [3:0]a,b,s,
input  m,
input  ci_bar,
output reg co_bar,
output reg x
);

always@(*)begin

if(m == 0) begin

co_bar = co_bar_pick(ci_bar,a,b,s);
x = x_pick(ci_bar,a,b,s);


end

else begin
co_bar = 1;
x = 1;
end


if(m == 0) begin

  

end

else begin
x = 0;
end

end


endmodule


//3. INVERT_M

module invert_m(
input a,
output y
);

assign y = ~a;

endmodule



//4. OUT_SECTION

module out_section_out0(
input x,
input [3:0]a,b,s,
input m_bar,
input ci_bar,
output f0
);

wire [3:0] fpick;

assign fpick = f_pick(~m_bar,ci_bar,a,b,s);

assign f0 = (x == 1)?(input_out1(a[0],b[0],s) ^ input_out2(a[0],b[0],s)) ^ ~(ci_bar & m_bar):
            fpick[0];

endmodule


module out_section_out1(
input x,
input [3:0]a,b,s,
input m_bar,
input ci_bar,
output f1
);

wire [3:0] fpick;

assign fpick = f_pick(~m_bar,ci_bar,a,b,s);

assign f1 = (x == 1)?(input_out1(a[1],b[1],s) ^ input_out2(a[1],b[1],s)) ^ ~( (ci_bar & input_out1(a[0],b[0],s) & m_bar) | 
            (input_out2(a[0],b[0],s) & m_bar) ):
            fpick[1];
endmodule


module out_section_out2(
input x,
input [3:0]a,b,s,
input m_bar,
input ci_bar,
output f2
);

wire [3:0] fpick;

assign fpick = f_pick(~m_bar,ci_bar,a,b,s);

assign f2 = (x == 1)?(input_out1(a[2],b[2],s) ^ input_out2(a[2],b[2],s)) ^ ~( (ci_bar & input_out1(a[1],b[1],s) & input_out1(a[0],b[0],s) & m_bar) | 
            (input_out1(a[1],b[1],s) & input_out2(a[0],b[0],s) & m_bar) | 
            (input_out2(a[1],b[1],s) & m_bar) ):
            fpick[2];

endmodule



module out_section_out3(
input x,
input [3:0]a,b,s,
input m_bar,
input ci_bar,
output f3
);

wire [3:0] fpick;

assign fpick = f_pick(~m_bar,ci_bar,a,b,s);

assign f3 = (x == 1)?(input_out1(a[3],b[3],s) ^ input_out2(a[3],b[3],s)) ^ 
            ~( (ci_bar & input_out1(a[2],b[2],s) & input_out1(a[1],b[1],s) & input_out1(a[0],b[0],s) & m_bar) | 
            (input_out1(a[2],b[2],s) & input_out1(a[1],b[1],s) & input_out2(a[0],b[0],s) & m_bar)| 
            (input_out1(a[2],b[2],s) & input_out2(a[1],b[1],s) & m_bar) |
            (input_out2(a[2],b[2],s) & m_bar)):
            fpick[3];

endmodule









