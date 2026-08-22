module fifo_asynchronous(
input w_clk,
input w_rst,
input w_en,
input [data_width-1:0] data_in,
output reg [data_width-1:0] data_in_sync2,
output full,
output [addr_width:0] w_ptr,
output [addr_width:0] w_ptr_gray_flop,
output reg [addr_width:0] addr_w,
output reg [addr_width:0] addrw,
output next_w,


input r_clk,
input r_rst,
input r_en,
output [7:0] data_out,
output empty,
output [addr_width:0] r_ptr,
output [addr_width:0] r_ptr_gray_flop,
output reg [addr_width:0] addr_r,
output reg [addr_width:0] addrr
);
parameter data_width = 8, addr_width = 4;
reg [data_width-1:0] data_in_sync1;


//function 1 gray_decoder
function [addr_width:0] addr_binary;
input [addr_width:0] addr_gray;

parameter addr_width = 4;
begin

addr_binary[addr_width] = addr_gray[addr_width];

for(int i=0; i< addr_width; i++)begin
addr_binary[addr_width-1-i] = addr_binary[addr_width-i]^addr_gray[addr_width-1-i];
end

end
endfunction

always@(posedge w_clk or posedge w_rst)begin
addrw = addr_w;
end
always@(posedge r_clk or posedge r_rst)begin
addrr = addr_r;
end

//1.write_pointer
w_ptr_section dut_w_ptr_section (.w_clk(w_clk), .w_rst(w_rst),.w_en(w_en), .r_ptr_gray_flop(r_ptr_gray_flop), .w_ptr(w_ptr), .w_ptr_gray_flop(w_ptr_gray_flop), .addr_w(addr_w), .full(full), .next_w(next_w));



//2.read_pointer
r_ptr_section dut_r_ptr_section (.r_clk(r_clk), .r_rst(r_rst),.r_en(r_en), .w_ptr_gray_flop(w_ptr_gray_flop), .r_ptr(r_ptr), .r_ptr_gray_flop(r_ptr_gray_flop), .addr_r(addr_r), .empty(empty));



//4.dual_port_ram_asynchronous
dual_port_ram_asynchronous test_dual_port_ram_asynchronous(
.clk_a(w_clk), .rst_a(w_rst), .we_a(next_w), .addr_a(addr_w[addr_width-1:0]), .data_in_a(data_in), .data_out_a(),
.clk_b(r_clk),.rst_b(r_rst),.we_b(1'b0), .addr_b(addr_r[addr_width-1:0]), .data_in_b(8'h00), .data_out_b(data_out));




endmodule




module w_ptr_section(
input w_clk,
input w_rst,
input w_en,
input [addr_width:0] r_ptr_gray_flop,
output reg [addr_width:0] w_ptr,
output reg [addr_width:0] w_ptr_gray_flop,
output [addr_width:0] addr_w,
output full,
output next_w
);

parameter addr_width = 4;
reg [addr_width:0] w_ptr_gray;
reg [addr_width:0] r_ptr_gray_sync1, r_ptr_gray_sync2;
wire [addr_width:0]r_ptr_sync2;

always@(posedge w_clk)begin

r_ptr_gray_sync1 <= r_ptr_gray_flop;
r_ptr_gray_sync2 <= r_ptr_gray_sync1;

w_ptr_gray_flop <= w_ptr_gray;

end


always@(posedge w_clk or posedge w_rst)begin
if(w_rst)begin
w_ptr <= 5'b0;
w_ptr_gray <= 5'b0;
end 

else if(next_w)begin
w_ptr <= w_ptr + 1;
w_ptr_gray <= (w_ptr + 1) ^ ((w_ptr + 1)>>1);
end


end

assign addr_w = w_ptr;
assign r_ptr_sync2 = addr_binary(r_ptr_gray_sync2);
assign full = w_ptr == {~r_ptr_sync2[addr_width], r_ptr_sync2[addr_width-1:0]};
assign next_w = w_en & !full;


endmodule




module r_ptr_section(
input r_clk,
input r_rst,
input r_en,
input [addr_width:0] w_ptr_gray_flop,
input w_rst_flag,
output reg [addr_width:0] r_ptr,
output reg [addr_width:0] r_ptr_gray_flop,
output empty,
output [addr_width:0] addr_r
);

parameter addr_width = 4;
reg [addr_width:0] r_ptr_gray;
reg [addr_width:0] w_ptr_gray_sync1, w_ptr_gray_sync2;
wire [addr_width:0] w_ptr_sync2;
wire next_r;

always@(posedge r_clk)begin



w_ptr_gray_sync1 <= w_ptr_gray_flop;
w_ptr_gray_sync2 <= w_ptr_gray_sync1;

r_ptr_gray_flop <= r_ptr_gray;

end


always@(posedge r_clk or posedge r_rst)begin


if(r_rst)begin
r_ptr <= 5'b0;
r_ptr_gray <= 5'b0;
end

else if(next_r)begin
r_ptr <= r_ptr + 1;
r_ptr_gray <= (r_ptr + 1) ^ ((r_ptr + 1)>>1);
end

end


assign addr_r = r_ptr;
assign w_ptr_sync2 = addr_binary(w_ptr_gray_sync2);
assign empty = (r_ptr == w_ptr_sync2);
assign next_r = r_en & !empty;

endmodule


