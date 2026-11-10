#!/usr/bin/env bash
set -euo pipefail
mkdir -p logs waves build/sim6
PERIOD_PS=${1:-10000}
LIB_VERILOG=${LIB_VERILOG:-/usr/cadtool/ee5216/CBDK_TSMC90GUTM_Arm_f1.0/CIC/Verilog/tsmc090.v}
NETLIST=${NETLIST:-build/syn6/bist_adder6_syn.v}
SDF=${SDF:-build/syn6/bist_adder6_syn.sdf}
# Do NOT add +notimingcheck here. Speed grading needs timing checks enabled.
vcs -full64 +v2k -debug_access+all +neg_tchk +define+FSDB \
    +define+GATE \
    tb/tb_bist_adder6.v ${NETLIST} -v ${LIB_VERILOG} \
    -o build/sim6/simv_gate6 \
    -l logs/vcs_gate6_compile.log
./build/sim6/simv_gate6 +PERIOD_PS=${PERIOD_PS} +SDF=${SDF} -l logs/vcs_gate6_${PERIOD_PS}ps.log
