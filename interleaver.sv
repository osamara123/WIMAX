module interleaver #(
    parameter Ncbps = 192,
    parameter Ncpc = 2,
    parameter s = Ncpc / 2,
    parameter d = 16
) (
    input logic clock_100,
    input logic reset,

    input logic in_valid,
    input logic in_ready,
    input logic in_data, 

    output logic out_data, 
    output logic out_ready,
    output logic out_valid
);

logic read_flag;
logic enable;

logic [8:0] counter; 
logic [8:0] counter_b; 
logic [8:0] counter_a; 
logic q_a; // read port

logic init_done;
logic flag_counter;


// Dual-Port RAM
DPRAM DPR (
    .address_a (counter_a),
    .address_b (counter_b),
    .clock_a (clock_100),
    .clock_b (clock_100),
    .data_a (),
    .data_b (in_data),
    .rden_a (1),
    .rden_b (),
    .wren_a (),
    .wren_b (1),
    .q_a (q_a),
    .q_b ()
);



function [7:0] first_permutation(input [8:0] k);
    begin
        first_permutation = (Ncbps / d) * (k % d) + (k / d);
    end
endfunction


function [7:0] second_permutation(input [8:0] m);
    begin
        second_permutation = s * (m / s) + ((m + Ncbps - ((d * m) / Ncbps)) % s);
    end
endfunction


// define state  
typedef enum logic [1:0] {idle, shuffle, done} inter_state_type;

// state register
inter_state_type state_reg, state_next;

// state register 
always_ff @(posedge clock_100 or negedge reset) begin
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
                state_next = shuffle;
        end
        shuffle: begin 
            if (!in_valid || !in_ready) 
                state_next = idle;
            else if ((counter == 191 || counter == 383) && read_flag)
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
        shuffle: begin
            enable = 1; // enable shuffling
        end
        done: begin
            enable = 1;
        end
    endcase
end

// 0->191 bank0
// 192->383 bank1

// counter
always_ff @(posedge clock_100 or negedge reset) begin
    if (!reset) begin
        counter <= 'b0;
        read_flag <= 'b0;
    end 
    else if (in_ready && in_valid) begin
        if (counter < 383) begin
            counter <= counter + 1'b1;
            if (counter == 191)
                read_flag <= 'b1; 
        end 
        else   
            counter <= 'b0;
    end
end

// counter_a (read_counter), counter_b (write_counter)
always_comb begin
    if (counter < 192) begin // bank0 
        counter_b = second_permutation (first_permutation (counter));
        counter_a = counter + 192;
    end 
    else begin // bank1
        counter_b = second_permutation (first_permutation (counter - 192)) + 192;
        counter_a = counter - 192;
    end
end


// out_data output
always_ff @(posedge clock_100 or negedge reset) begin
    if (!reset) begin
        out_data <= 'b0;
        init_done <= 'b0;
        flag_counter <= 'b0;
    end 
    else if (enable && read_flag) begin
        out_data <= q_a;
        if (flag_counter <  1)
            flag_counter <= flag_counter + 'b1;
        else
            init_done <= 1;     // wait two clock cycles
    end 
end

assign out_valid = (enable && read_flag && init_done) ? 'b1 : 'b0;
assign out_ready = in_ready;

endmodule
