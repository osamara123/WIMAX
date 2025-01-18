module WIMAX_WRAPPER #(
    parameter [0:95] in_data_WRAPPER = 96'hAC_BC_D2_11_4D_AE_15_77_C6_DB_F4_C9,
    parameter [0:95] PRBS_data = 96'h55_8A_C4_A5_3A_17_24_E1_63_AC_2B_F9,
    parameter [0:191] FEC_data = 192'h2833_E48D_3920_26D5_B6DC_5E4A_F47A_DD29_494B_6C89_1513_48CA,
    parameter [0:191] INTER_data = 192'h4B04_7DFA_42F2_A5D5_F61C_021A_5851_E9A3_09A2_4FD5_8086_BD1E,
    parameter [0:95] Q_data_MOD = 96'h92F_C8C_3FE_604_CD9_110_BF0_276,
    parameter [0:95] I_data_MOD = 96'h306_F1D_C8D_213_20E_D2D_388_9E3
)(    
    input logic clock,
    input logic reset,

    output logic PRBS_pass,
    output logic FEC_pass,
    output logic INTER_pass,
    output logic MOD_pass
);

logic load;
logic enable;

logic in_data;
logic in_ready;
logic in_valid;

logic out_valid_PRBS;
logic out_valid_FEC;
logic out_valid_INTER;
logic out_valid_MOD;

logic out_PRBS;
logic out_FEC;
logic out_INTER;

logic clock_50;
logic clock_100;

logic out_ready;
logic [15:0] Q;
logic [15:0] I;

logic [7:0] data_counter;
logic [7:0] PRBS_counter;
logic [7:0] FEC_counter;
logic [7:0] INTER_counter;
logic [7:0] MOD_counter;

logic I_sign;
logic Q_sign;
logic counter;

logic flag;

wimax #(
    .Ncbps(8'd192),
    .Ncpc(8'd2),
    .s(8'd1), 
    .d(8'd16),
    .seed(15'b011_011_100_010_101)
) DUT (
    .clock(clock),
    .reset(reset),

    .load(load),
    .enable(enable),

    .in_data(in_data),
    .in_ready(in_ready),
    .in_valid(in_valid),

    .out_valid_PRBS (out_valid_PRBS),  
    .out_valid_INTER (out_valid_INTER),
    .out_valid_FEC (out_valid_FEC),  
             
    .out_PRBS (out_PRBS),                
    .out_FEC (out_FEC),        
    .out_INTER (out_INTER),   

    .out_ready(out_ready),
    .out_valid (out_valid_MOD),
    .Q (Q),
    .I (I),

    .clock_50 (clock_50),
    .clock_100 (clock_100)
);

assign in_valid = 1;
assign in_ready = 1;

// in_data to wrapper 
assign in_data = in_data_WRAPPER [data_counter];       

assign Q_sign = (Q == 16'h5a82) ? 0 : (Q == 16'hA57E) ? 1 : 0;
assign I_sign = (I == 16'h5a82) ? 0 : (I == 16'hA57E) ? 1 : 0;


// in_data counter
always_ff @(posedge clock_50 or negedge reset) begin
    if(!reset)
        data_counter <= 0;
    else if (enable) begin
        if (data_counter < 95)
            data_counter <= data_counter + 1;
        else
            data_counter <= 'b0;
    end
end

// verify prbs & modulator outputs
always_ff @(posedge clock_50 or negedge reset) begin
    if (!reset) begin
        PRBS_pass <= 0;
        MOD_pass <= 0;
    end 
    else begin
        if (out_valid_PRBS)
            PRBS_pass <= PRBS_data[PRBS_counter] == out_PRBS;
        if (out_valid_MOD) begin
            MOD_pass <= (I_sign == I_data_MOD[MOD_counter]) & (Q_sign == Q_data_MOD[MOD_counter]);	
    	end
    end
end

// verify interleaver & fec outputs
always_ff @(posedge clock_100 or negedge reset) begin
    if (!reset) begin
        FEC_pass <= 0;
        INTER_pass <= 0;
        flag <= 'b0;
    end 
    else begin
        if (out_valid_FEC)
            FEC_pass <= (FEC_data [FEC_counter] == out_FEC); 
        if (out_valid_INTER)
            INTER_pass <= (INTER_data[INTER_counter] == out_INTER);
	end
end

// prbs counter
always_ff @(posedge clock_50 or negedge reset) begin
    if(!reset)
        PRBS_counter <= 0;
    else if (out_valid_PRBS) begin
        if (PRBS_counter < 95)
            PRBS_counter <= PRBS_counter + 1;
        else
            PRBS_counter <= 'b0;
    end
end

// fec counter
always_ff @(posedge clock_100 or negedge reset) begin
    if(!reset)
        FEC_counter <= 0;
    else if (out_valid_FEC) begin
        if (FEC_counter < 191)
            FEC_counter <= FEC_counter + 1;
        else
            FEC_counter <= 0;
    end
end

// interleaver counter
always_ff @(posedge clock_100 or negedge reset) begin
    if(!reset)
        INTER_counter <= 0;
    else if (out_valid_INTER) begin
        if (INTER_counter < 191)
            INTER_counter <= INTER_counter + 1;
        else
            INTER_counter <= 0;
    end
end

// modulator counter
always_ff @(posedge clock_50 or negedge reset) begin
    if (!reset)
        MOD_counter <= 0;
    else if (out_valid_MOD) begin
        if (MOD_counter < 95)
            MOD_counter <= MOD_counter + 1;
        else
            MOD_counter <= 0;
    end
end


// in_data feed to prbs
always_ff @(posedge clock_50 or negedge reset) begin
    if(!reset) begin
        counter <= 0;
        load <= 0;
        enable <= 0;
    end
    else begin
        if (counter == 0) begin
            load <= 1;
            enable <= 'b0;
            counter <= counter + 1;
        end
        else begin
            load <= 0;
            enable <= 1;
            if (data_counter == 94)
                counter <= 'b0;
        end
    end
end


endmodule
