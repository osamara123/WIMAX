`timescale 1ns / 1ns

module prbs #(
parameter [14:0] seed = 15'b011_011_100_010_101
) (
    input logic clock,
    input logic reset,
    input logic enable,
    input logic load,
    input logic in_data,
    input logic in_ready, 
    input logic in_valid, 

    output logic out_valid,
    output logic out_ready,
    output logic out_data
);

logic [14:0] shift_register;
logic XOR;

always_ff @(posedge clock or negedge reset) begin
    if (!reset) begin
        shift_register <= 'b0;
        out_valid <= 'b0;
        out_data <= 'b0; 
    end 
    else if (in_valid && in_ready) begin
        if (load) begin
            shift_register <= seed;
            out_valid <= 'b0;
        end
        else if (enable) begin
            shift_register <= {XOR, shift_register[14:1]};
            out_data <= XOR ^ in_data;
            out_valid <= 1;
        end
    end
end

assign XOR = shift_register[1] ^ shift_register[0];
assign out_ready = in_ready;

endmodule