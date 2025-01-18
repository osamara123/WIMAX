`timescale 1ns / 1ns

module fec (
    input logic in_ready, // ready to send 
    input logic in_valid,
    input logic in_data,

    input logic reset,
    input logic clock_50,
    input logic clock_100,

    output logic out_valid,
    output logic out_ready, // ready to recieve 
    output logic out_data
);


logic toggle;
logic [5: 0] shift_register;
logic [5: 0] seed;
logic q_a;  // data to encode

logic [7: 0] counter_a;
logic [7: 0] counter_b;
logic read_flag;
logic enable; // enable encoding

logic [1: 0] counter;
logic init_done;

parameter G1 = 7'b1111001;
parameter G2 = 7'b1011011;



DPR DUT (
    .address_a (counter_a), // input signal
	.address_b (counter_b),
	.clock_a (clock_50), // read clock
	.clock_b (clock_50), // write clock
	.data_a (),
	.data_b (in_data),
	.rden_a (1), 
	.rden_b (),
	.wren_a (),
	.wren_b (1), 
	.q_a (q_a),
	.q_b ()
);


// define state 
typedef enum logic [1:0] {idle, encode, done} fec_state_type;

// state register
fec_state_type state_reg, state_next;

// state register
always_ff @(posedge clock_50 or negedge reset) begin
    if (!reset)
        state_reg <= idle;
    else
        state_reg <= state_next;
end

// next-state logic
always_comb begin
    state_next = state_reg;
    case (state_reg)
        idle: begin 
            if (in_valid && in_ready) 
                state_next = encode;
        end
        encode: begin 
            if (!in_valid || !in_ready) 
                state_next = idle;
            else if ((counter_a == 191 || counter_a == 95) && read_flag)
                state_next = done;
        end
        done: begin  
            state_next = idle;
        end
    endcase
end

// Moore output logic
always_comb begin
    enable = 0; // default output
    case (state_reg)
        idle: begin
            // no outputs
        end
        encode: begin
            enable = 1; // enable encoding
        end
        done: begin
            enable = 1;
        end
    endcase
end

// 1->95 bank0
// 96->191 bank1

// write counter
always_ff @(posedge clock_50 or negedge reset) begin
    if (!reset) begin
        counter_b <= 'b0;
        read_flag <= 1'b0;
    end 
    else if (in_ready && in_valid) begin
        if (counter_b == 95) begin
            read_flag <= 'b1;
            counter_b <= counter_b + 1;
        end 
        else if (counter_b < 191)
            counter_b <= counter_b + 1'b1;
        else    
            counter_b <= 'b0;
    end
end


// read counter
always_ff @(posedge clock_50 or negedge reset) begin
    if (!reset)
        counter_a <= 96;
    else if (in_ready && in_valid) begin 
        if (counter_a < 191)
            counter_a <= counter_a + 1'b1;
        else
            counter_a <= 'b0;
    end
end

// initialize shift_register
always_ff @(posedge clock_50 or negedge reset) begin
    if (!reset)
        seed <= 'b0;
    else if (in_valid && in_ready) begin 
        if ((counter_b >= 90 && counter_b <= 95) || (counter_b >= 186 && counter_b <= 191))
            seed <= {in_data, seed[5:1]};
    end
end

// FEC operations 
always_ff @(posedge clock_50 or negedge reset) begin
    if (!reset)
        shift_register <= 'b0;
    else if (enable) begin
        if (counter_b == 96 || counter_b == 0)
            shift_register <= seed; 
        else if (q_a == 1'b1 || q_a == 1'b0)  // block is read from DPR
            shift_register <= {q_a, shift_register [5:1]};
    end
end


// out_data output
always_ff @(posedge clock_100 or negedge reset) begin
    if (!reset) begin
        out_data <= 1'b0;
        toggle <= 1'b1;
        counter <= 'b0;
        init_done <= 'b0;
    end 
    else if (enable && read_flag) begin
        out_data <= toggle ? ^({q_a, shift_register} & G1) : ^({q_a, shift_register} & G2); // output X then Y
        toggle <= ~toggle;  // Toggle the selection every clock cycle
        if (counter <  2)
            counter <= counter + 'b1;
        else
            init_done <= 1;     // wait two clock cycles
    end 
end

assign out_valid = (enable && read_flag && init_done) ? 'b1 : 'b0;
assign out_ready = in_ready; 

endmodule