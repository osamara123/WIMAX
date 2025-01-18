`timescale 1ns / 1ns

module WIMAX_WRAPPER_tb;

logic clock;
logic reset;
logic PRBS_pass;
logic FEC_pass;
logic INTER_pass;
logic MOD_pass;

parameter CLOCK_PERIOD = 20;
always #(CLOCK_PERIOD/2) clock =~clock;


WIMAX_WRAPPER #(
    .in_data_WRAPPER (96'hAC_BC_D2_11_4D_AE_15_77_C6_DB_F4_C9),
    .PRBS_data (96'h55_8A_C4_A5_3A_17_24_E1_63_AC_2B_F9),
    .FEC_data (192'h2833_E48D_3920_26D5_B6DC_5E4A_F47A_DD29_494B_6C89_1513_48CA),
    .INTER_data (192'h4B04_7DFA_42F2_A5D5_F61C_021A_5851_E9A3_09A2_4FD5_8086_BD1E),
    .Q_data_MOD (96'h92F_C8C_3FE_604_CD9_110_BF0_276),
    .I_data_MOD (96'h306_F1D_C8D_213_20E_D2D_388_9E3)
) DUT (
    .clock(clock),
    .reset(reset),
    .PRBS_pass(PRBS_pass),
    .FEC_pass(FEC_pass),
    .INTER_pass(INTER_pass),
    .MOD_pass(MOD_pass)
);



initial begin
    clock = 0;
    reset = 0;
    @(posedge clock);
    reset = 1;
    repeat(2000) @(posedge clock);

    $finish;
end

endmodule