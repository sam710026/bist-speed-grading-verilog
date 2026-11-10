#!/usr/bin/env bash
set -euo pipefail
mkdir -p logs build/syn12
CLK_PERIOD_NS=${1:-10.0}
dc_shell -x "set DESIGN_TOP bist_adder12; set CLK_PERIOD_NS ${CLK_PERIOD_NS}; source syn/bist_syn.tcl" | tee logs/syn12_${CLK_PERIOD_NS}ns.log
