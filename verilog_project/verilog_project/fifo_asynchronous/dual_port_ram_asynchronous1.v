module dual_port_ram_asynchronous1(
input clk_a,
input rst_a,
input we_a, //write enable
input [ADDR_WIDTH-1:0]addr_a,
input [DATA_WIDTH-1:0]data_in_a,
output reg [DATA_WIDTH-1:0]data_out_a,

input clk_b,
input rst_b,
input we_b, //write enable
input [ADDR_WIDTH-1:0]addr_b,
input [DATA_WIDTH-1:0]data_in_b,
output reg [DATA_WIDTH-1:0]data_out_b
);

parameter DATA_WIDTH = 8, ADDR_WIDTH = 4, MEM_DEPTH = 16;

reg [DATA_WIDTH-1:0]mem[MEM_DEPTH-1:0];


always@(posedge clk_a)begin

if(rst_a)begin
data_out_a <= 8'h00;;
end else if(we_a)begin
mem[addr_a] <= data_in_a;
data_out_a <= mem[addr_a]; //验证时改成data_out = mem[addr]，在data_in了之后，blocking

end

else begin
data_out_a <= mem[addr_a];
end

end


always@(posedge clk_b)begin

if(rst_b)begin
data_out_b <= 8'h00;
end else if(we_b)begin

mem[addr_b] <= data_in_b;
data_out_b <= mem[addr_b]; //验证时改成data_out = mem[addr]，在data_in了之后，blocking

end

else begin
data_out_b <= mem[addr_b];
end

end


endmodule
