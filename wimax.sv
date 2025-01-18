module wimax #(
    parameter Ncbps = 8'd192,
    parameter Ncpc = 8'd2,
    parameter s = Ncpc / 2,
    parameter d = 8'd16,
    parameter [14:0] seed  = 15'b011_011_100_010_101
) (
    input logic clock,
    input logic reset,

    input logic load,
    input logic enable,
    
    input logic in_data, 
    input logic in_ready,
    input logic in_valid,
    
    output logic out_valid_PRBS,  
    output logic out_valid_INTER,
    output logic out_valid_FEC,  

    output logic out_PRBS,                
    output logic out_FEC,        
    output logic out_INTER,      

    output logic [15:0] Q,        // outputs of modulator (last block)
    output logic [15:0] I,
    output logic out_valid,  
    output logic out_ready,

    output logic clock_50,      // PLL clocks
    output logic clock_100
);


logic ready_FEC_PRBS;   // in_ready prbs, out_ready fec
logic ready_INTER_MOD;  // in_ready interleaver, out_ready modulator
logic ready_FEC_INTER;  // in_ready fec, out_ready interleaver


prbs #(
    .seed(seed)
) DUT1(
    .clock(clock_50),
    .reset(locked),

    .load(load),
    .enable(enable),
    
    .in_data(in_data),
    .in_ready(ready_FEC_PRBS),
    .in_valid(in_valid),
    
    .out_valid(out_valid_PRBS),
    .out_ready(out_ready),
    .out_data(out_PRBS)
);

fec DUT2 (
    .reset(locked),
    .clock_50(clock_50),
    .clock_100(clock_100),

    .in_ready(ready_FEC_INTER), 
    .in_valid(out_valid_PRBS),
    .in_data(out_PRBS),

    .out_valid(out_valid_FEC),
    .out_ready(ready_FEC_PRBS), 
    .out_data(out_FEC)
);

interleaver #(
    .Ncbps(Ncbps),
    .Ncpc(Ncpc),
    .s(s),
    .d(d)
) DUT3 (
    .clock_100 (clock_100),
    .reset (locked),
    .in_data (out_FEC),
    .in_valid (out_valid_FEC),
    .in_ready (ready_INTER_MOD),
    
    .out_ready (ready_FEC_INTER),
    .out_data (out_INTER),
    .out_valid (out_valid_INTER)
);

modulator DUT4 (
    .clock (clock_100),
    .reset (locked),
    .in_data (out_INTER),
    .in_ready (in_ready),
    .in_valid(out_valid_INTER),

    .out_valid (out_valid),
    .out_ready (ready_INTER_MOD),
    .I (I),
    .Q (Q)
);

// Generate 50MHZ and 100 MHZ clocks 
// Don't work until locked signal asserted
PLL DUT5 (
    .refclk (clock),  
    .rst (!reset),      
    .outclk_0 (clock_100),
    .outclk_1 (clock_50),
    .locked (locked)    
);

endmodule