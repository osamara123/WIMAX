quit -sim
vlib work
vmap altera_mf "C:/intelFPGA_lite/22.1std/questa_fse/intel/verilog/altera_mf"
vmap cyclonev "C:/intelFPGA_lite/22.1std/questa_fse/intel/verilog/cyclonev"
vmap altera_lnsim "C:/intelFPGA_lite/22.1std/questa_fse/intel/verilog/altera_lnsim"

vlog -sv interleaver.sv
vlog -sv DPRAM.v
vlog -sv DPR.v
vlog -sv modulator.sv
vlog -sv wimax.sv
vlog -sv fec.sv
vlog -sv PLL.v
vlog -sv PLL_0002.v
vlog -sv prbs.sv
vlog -sv WIMAX_WRAPPER.sv
vlog -sv WIMAX_WRAPPER_tb.sv
vsim -voptargs="+acc" -debugDB -L altera_mf -L altera_lnsim work.WIMAX_WRAPPER_tb

add wave \
    sim:/WIMAX_WRAPPER_tb/clock \
    sim:/WIMAX_WRAPPER_tb/reset \
    sim:/WIMAX_WRAPPER_tb/FEC_pass \
    sim:/WIMAX_WRAPPER_tb/INTER_pass \
    sim:/WIMAX_WRAPPER_tb/MOD_pass \
    sim:/WIMAX_WRAPPER_tb/PRBS_pass \
    sim:/WIMAX_WRAPPER_tb/DUT/DUT/out_PRBS \
    sim:/WIMAX_WRAPPER_tb/DUT/DUT/out_valid_PRBS \
    sim:/WIMAX_WRAPPER_tb/DUT/DUT/out_FEC \
    sim:/WIMAX_WRAPPER_tb/DUT/DUT/out_valid_FEC \
    sim:/WIMAX_WRAPPER_tb/DUT/DUT/out_INTER \
    sim:/WIMAX_WRAPPER_tb/DUT/DUT/out_valid_INTER \
    sim:/WIMAX_WRAPPER_tb/DUT/DUT/I \
    sim:/WIMAX_WRAPPER_tb/DUT/DUT/Q \
    sim:/WIMAX_WRAPPER_tb/DUT/DUT/out_valid \
    sim:/WIMAX_WRAPPER_tb/DUT/DUT/out_ready \
    sim:/WIMAX_WRAPPER_tb/DUT/data_counter \
    sim:/WIMAX_WRAPPER_tb/DUT/FEC_counter \
    sim:/WIMAX_WRAPPER_tb/DUT/INTER_counter \
    sim:/WIMAX_WRAPPER_tb/DUT/MOD_counter \
    sim:/WIMAX_WRAPPER_tb/DUT/PRBS_counter \
    sim:/WIMAX_WRAPPER_tb/DUT/enable \
    sim:/WIMAX_WRAPPER_tb/DUT/load \
    sim:/WIMAX_WRAPPER_tb/DUT/DUT/DUT2/state_reg \
    sim:/WIMAX_WRAPPER_tb/DUT/DUT/DUT3/state_reg \ 
    sim:/WIMAX_WRAPPER_tb/DUT/clock_100 \
    sim:/WIMAX_WRAPPER_tb/DUT/DUT/clock_50 
run -all
quit
