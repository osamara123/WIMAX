
module modulator (
    input logic clock,
    input logic reset,

    input logic in_data,
    input logic in_ready,
    input logic in_valid,

    output logic out_valid,
    output logic out_ready,
    output logic [15:0] I, Q
);

logic [1: 0] shift_register; // store current and previous recieved bit
logic [1: 0] counter; 

    
always_comb begin
    out_valid = 0; 
    if (in_valid && in_ready && counter == 2) begin
        case (shift_register)
            2'b00: begin
                Q = 16'h5a82; 
                I = 16'h5a82;
            end
            2'b01: begin
                I = 16'h5a82;
                Q = 16'hA57E;
            end
            2'b10: begin
                I = 16'hA57E;
                Q = 16'h5a82;
            end
            2'b11: begin
                Q = 16'hA57E;
                I = 16'hA57E;
            end
            default: begin
                Q = 16'd0;
                I = 16'd0;
            end
        endcase
        out_valid = 1; 
    end
end


always_ff @(posedge clock or negedge reset)begin
    if (!reset) begin 
        shift_register <= 'b0;
        counter <= 'b0;
    end 
    else if (in_valid && in_ready) begin
        shift_register <= {shift_register [0], in_data};
        if (counter < 2)
            counter <= counter + 1;
        else
            counter <= 1;
    end
end

assign out_ready = in_ready;

endmodule