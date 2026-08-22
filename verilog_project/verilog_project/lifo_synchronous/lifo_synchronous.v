module lifo(
input clk,
input rst,
input w_en,
input r_en,
input [7:0] data_in,
output full,empty,
output reg [addr_width:0] ptr,
output reg [7:0] data_out,
output reg [addr_width:0] addr0,
output nextw
);
parameter addr_width = 4,mem_DEPTH=16;

wire [addr_width-1:0] addr;
wire next_w,next_r;

assign empty = ptr == 0;
assign full = ptr == mem_DEPTH;

assign next_w = w_en & !full;
assign next_r = r_en & !empty;
assign addr = ptr[addr_width-1:0];
assign nextw = next_w;






//0.pointer section
ptr_section dut_ptr_section (.clk(clk), .rst(rst), .next_w(next_w), .next_r(next_r), .ptr(ptr), .addr0(addr0));



//1.compare
compare_and_status_section dut_compare_and_status_section(
.ptr(ptr), .empty(empty), .full(full));


//2.dual_port_ram_synchronous

dual_port_ram_synchronous dut_dual_port_ram_synchronous(
.clk(clk), .rst(rst), .we_a(next_w), .addr_a(addr), .data_in_a(data_in), .data_out_a(),
.we_b(1'b0), .addr_b(addr), .data_in_b(8'h00), .data_out_b(data_out));



endmodule


module compare_and_status_section(
input [4:0] ptr,
output empty,
output full
);


parameter mem_DEPTH = 16;





endmodule





module ptr_section(
input clk,
input rst,
input next_w,
input next_r,
output reg [4:0] ptr,
output reg [4:0] addr0
);

always@(posedge clk or posedge rst)begin
$display("rst=%d",rst);
addr0 <= ptr;
if(rst)
ptr <= 5'b0;

else begin
case({next_w,next_r})
2'b01: ptr <= ptr - 1;
2'b10: ptr <= ptr + 1;
default: ptr <= ptr;
endcase

end

end

endmodule
