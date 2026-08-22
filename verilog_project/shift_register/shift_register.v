module shift_register(
input clk,
input rst,
input data_in,
output reg [DATA_WIDTH-1:0] data_out
);

parameter DATA_WIDTH = 8;

always@(posedge clk)begin
if(rst)begin
data_out <=0;
end
else begin
data_out <= {data_out[DATA_WIDTH-2:0],data_in};
end
end

endmodule
