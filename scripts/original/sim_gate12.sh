#!/usr/bin/env bash
set -euo pipefail
mkdir -p logs waves build/sim12
PERIOD_PS=${1:-10000}
LIB_VERILOG=${LIB_VERILOG:-/usr/cadtool/ee5216/CBDK_TSMC90GUTM_Arm_f1.0/CIC/Verilog/tsmc090.v}
NETLIST=${NETLIST:-build/syn12/bist_adder12_syn.v}
SDF=${SDF:-build/syn12/bist_adder12_syn.sdf}
# Do NOT add +notimingcheck here. Speed grading needs timing checks enabled.
vcs -full64 +v2k -debug_access+all +neg_tchk +define+FSDB\
    +define+GATE \
    tb/tb_bist_adder12.v ${NETLIST} -v ${LIB_VERILOG} \
    -o build/sim12/simv_gate12 \
    -l logs/vcs_gate12_compile.log
./build/sim12/simv_gate12 +PERIOD_PS=${PERIOD_PS} +SDF=${SDF} -l logs/vcs_gate12_${PERIOD_PS}ps.log
