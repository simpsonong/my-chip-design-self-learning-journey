//easy-to-adjust-mode
module encoder(
    input  [7:0] in,
    output reg [2:0] out
);

integer i;
reg[7:0] J;
reg found;

always@(*) begin
found=0;

for (i = 0; i < 8; i++ ) begin

J=8'b0;
J[i]=1'b1;

for(int k = 1+i; k<8; k++)begin
J[k]=1'bx;
end


if(!found && (in[i] == J[i])) begin
out = i[2:0];
found = 1'b1;
end

else if(in == 8'b0) begin
out = 3'bx;
end

else begin
out = out;
end

end
end

endmodule


//fast-mode(less logic-depth)
module encoder_fast(
    input  [7:0] in,
    output reg [2:0] out
);

always @(*) begin
    casez (in)
        8'bzzzzzzz1: out = 3'b000; // 最低位 1
        8'bzzzzzz10: out = 3'b001;
        8'bzzzzz100: out = 3'b010;
        8'bzzzz1000: out = 3'b011;
        8'bzzz10000: out = 3'b100;
        8'bzz100000: out = 3'b101;
        8'bz1000000: out = 3'b110;
        8'b10000000: out = 3'b111; // 最高位 1
        default:     out = 3'bxxx; // 输入全 0 或非法
    endcase
end

endmodule

