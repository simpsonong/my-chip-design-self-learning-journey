//easy-to-adjust-mode
module decoder(
    input  [2:0] in,
    output reg [7:0] out
);

integer i;
reg[7:0] J;
reg found;

always@(*) begin
found=0;

for (i = 0; i < 8; i++ ) begin

J=8'b0;
J[i]=1'b1;


if(!found && (in == i[2:0])) begin
out = J;
found = 1'b1;
end

else begin
out = out;
end

end
end

endmodule


//fast-mode(less logic-depth)
module decoder_fast(
    input  [2:0] in,
    output reg [7:0] out
);

 always @ ( * ) begin
        case (in)
            3'b000 : out = 8'b00000001;
            3'b001 : out = 8'b00000010;
            3'b010 : out = 8'b00000100;
            3'b011 : out = 8'b00001000;
            3'b100 : out = 8'b00010000;
            3'b101 : out = 8'b00100000;
            3'b110 : out = 8'b01000000;
            3'b111 : out = 8'b10000000;
        endcase
    end

endmodule
