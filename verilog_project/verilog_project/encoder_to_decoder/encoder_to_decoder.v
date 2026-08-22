module encoder_to_decoder(
input[7:0] in,
output [7:0] out
);
reg[2:0] out_en;

encoder dut_encoder(.in(in),.out(out_en));
decoder dut_decoder(.in(out_en),.out(out));

endmodule



//fast-mode(less logic-depth)
module encoder(
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



//fast-mode(less logic-depth)
module decoder(
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
            default: out=  8'bx;
        endcase
    end

endmodule
