module fifo(
input clk,
input rst,
input push,
input pop,
input [7:0] data_in,
output full,empty,
output [addr_width:0] w_ptr,r_ptr,
output [7:0] data_out,
output reg [addr_width:0] addra,
output reg [addr_width:0] addrb,
output reg nextw
);
parameter addr_width = 4;

wire [3:0] addr_a, addr_b;
wire next_w,next_r;



assign next_w = push & !full;
assign next_r = pop & !empty;

assign nextw = next_w;

assign addr_a = w_ptr[addr_width-1:0];
assign addr_b = r_ptr[addr_width-1:0];


always@(posedge clk) begin
addra <= w_ptr;
addrb <= r_ptr;
end



//2.write_pointer
w_ptr_section dut_w_ptr_section (.clk(clk), .rst(rst),.next(next_w), .w_ptr(w_ptr));



//3.read_pointer
r_ptr_section dut_r_ptr_section (.clk(clk), .rst(rst),.next(next_r), .r_ptr(r_ptr));


//1.compare 
compare_and_status_section dut_compare_and_status_section(
.w_ptr(w_ptr), .r_ptr(r_ptr), .empty(empty), .full(full));


//0.dual_port_ram_synchronous

dual_port_ram_synchronous dut_dual_port_ram_synchronous(
.clk(clk), .rst(rst), .we_a(next_w), .addr_a(addr_a), .data_in_a(data_in), .data_out_a(), 
.we_b(1'b0), .addr_b(addr_b), .data_in_b(8'h00), .data_out_b(data_out));



endmodule


module compare_and_status_section(
input [4:0] w_ptr,
input [4:0] r_ptr,
output empty,
output full
);


parameter addr_width = 4;


assign empty = (w_ptr == r_ptr);
assign full = ((w_ptr[addr_width] != r_ptr[addr_width]) && (w_ptr[addr_width-1:0] == r_ptr[addr_width-1:0]));


endmodule





module w_ptr_section(
input clk,
input rst,
input next,
output reg [4:0] w_ptr
);

always@(posedge clk)begin
 
if(rst)
w_ptr <= 5'b0;

else if(next)
w_ptr <= w_ptr + 1;



end

endmodule




module r_ptr_section(
input clk,
input rst,
input next,
output reg [4:0] r_ptr
);

always@(posedge clk)begin
 
if(rst)
r_ptr <= 5'b0;
else if(next)
r_ptr <= r_ptr + 1;


end

endmodule
