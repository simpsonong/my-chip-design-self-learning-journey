module single_port_ram_synchronous(
input clk,
input we, //write enable
input [ADDR_WIDTH-1:0]addr,
input [DATA_WIDTH-1:0]data_in,
output reg [DATA_WIDTH-1:0]data_out,
output [DATA_WIDTH-1:0]out_mem
);

parameter DATA_WIDTH = 8, ADDR_WIDTH = 4, MEM_DEPTH = 16; 

reg [DATA_WIDTH-1:0]mem[MEM_DEPTH-1:0];

assign out_mem = mem[addr];

always@(posedge clk)begin

if(we)begin

mem[addr] <= data_in;
data_out <= data_in; //验证时改成data_out = mem[addr]，在data_in了之后，blocking

end

else begin
data_out <= mem[addr];
end

end

endmodule
