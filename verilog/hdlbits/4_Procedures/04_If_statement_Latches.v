// synthesis verilog_input_version verilog_2001
module top_module (
    input      cpu_overheated,
    output reg shut_off_computer,
    input      arrived,
    input      gas_tank_empty,
    output reg keep_driving  ); //

    always @(*) begin
        if (cpu_overheated)
           shut_off_computer = 1;
    end

    always @(*) begin
        if (~arrived)
           keep_driving = ~gas_tank_empty;
    end

endmodule

// helpful short video for explanation (start from 0:21) :)
// https://www.youtube.com/watch?v=5i0AabnRAgs&list=PL0E9jhuDlj9qxAfV9hFKNQeHLWimarJJm&index=15
