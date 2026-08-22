//4_bits counter golden module

module counter_4_gm(
input clk,
input clrbar,
input ent, //enable trigger
input enp, //enable parallel
input ld_bar,
input [3:0]data,
output [3:0]q,
output cout
);

wire ld;
wire [3:0] feedback;
wire [3:0] prev_q;

assign ld = ~ld_bar;

assign feedback[0] = ent & enp;
output_section dut_output_section0(.clk(clk), .clrbar(clrbar), .feedback(feedback[0]), .ld(ld), .data(data[0]), .q(q[0]), .prev_q(prev_q[0]));


assign feedback[1] = ent & enp & q[0];
output_section dut_output_section1(.clk(clk), .clrbar(clrbar), .feedback(feedback[1]), .ld(ld), .data(data[1]), .q(q[1]), .prev_q(prev_q[1]));


assign feedback[2] = ent & enp & q[1] & q[0];
output_section dut_output_section2(.clk(clk), .clrbar(clrbar), .feedback(feedback[2]), .ld(ld), .data(data[2]), .q(q[2]), .prev_q(prev_q[2]));

assign feedback[3] = ent & enp & q[2] & q[1] & q[0];
output_section dut_output_section3(.clk(clk), .clrbar(clrbar), .feedback(feedback[3]), .ld(ld), .data(data[3]), .q(q[3]), .prev_q(prev_q[3]));

assign cout = ent & enp & prev_q[3] & prev_q[2] & prev_q[1] & prev_q[0];


endmodule




module output_section(
input clk,
input clrbar,
input feedback,
input ld,
input data,
output q,
output prev_q
);

reg to_j_and_k, to_j, to_k, j, k, NOTHING;

assign to_j_and_k = feedback|ld;

assign to_j = ~(to_k & ld);
assign to_k = ~(data & ld);

assign j = to_j & to_j_and_k;
assign k = to_k & to_j_and_k;



jk_flip_flop dut_jk_flip_flop(
    .clk(clk),
    .clrbar(clrbar),
    .j(j),
    .k(k),
    .q(q),
    .qbar(NOTHING),
    .prev_q(prev_q)
);

endmodule

module jk_flip_flop(
input clk,
input clrbar,
input j,
input k,
output reg q,
output reg qbar,
output reg prev_q
);

assign qbar = ~q;

    always @(posedge clk) begin
        
        prev_q <= q;        
 
        if (~clrbar) begin
            q <= 1'b0;
        end else begin

        case ({j,k})
            2'b00 : q <= q;
            2'b01 : q <= 1'b0;
            2'b10 : q <= 1'b1;
            2'b11 : q <= ~q;


        endcase
        end

     end

endmodule
