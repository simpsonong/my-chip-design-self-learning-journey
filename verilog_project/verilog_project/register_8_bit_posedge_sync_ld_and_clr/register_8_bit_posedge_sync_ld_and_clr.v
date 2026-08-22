
module register_8_bit_posedge_sync_ld_and_clr(
input clk,
input ld_bar,
input clr_bar,
input [DATA_WIDTH-1:0]DATA_IN,
output reg [DATA_WIDTH-1:0]DATA_OUT
);

parameter DATA_WIDTH = 8;

always@(posedge clk)begin
if(~clr_bar)begin
DATA_OUT <= 0;
end
else if(~ld_bar)begin
DATA_OUT <= DATA_IN;
end

end

endmodule
