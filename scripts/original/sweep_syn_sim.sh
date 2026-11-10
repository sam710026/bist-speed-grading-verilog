#!/usr/bin/env bash
set -euo pipefail

# Sweep maximum speed with SAME clock period for synthesis and gate simulation.
# Save fastest PASS FSDB and first FAIL FSDB to:
#   /home/course/ee625001/hw3_bist_adder/max
#
# Usage:
#   chmod +x scripts/sweep_syn_sim_save_fsdb.sh
#   ./scripts/sweep_syn_sim_save_fsdb.sh 6  10000 500 100
#   ./scripts/sweep_syn_sim_save_fsdb.sh 12 10000 500 100

N=${1:-6}
START_PS=${2:-10000}
STOP_PS=${3:-500}
STEP_PS=${4:-100}

SAVE_ROOT="/home/course/ee625001/hw3_bist_adder/max"

if [[ "$N" == "6" ]]; then
    SYN=./scripts/syn6.sh
    SIM=./scripts/sim_gate6.sh
    NETLIST=build/syn6/bist_adder6_syn.v
    SDF=build/syn6/bist_adder6_syn.sdf
elif [[ "$N" == "12" ]]; then
    SYN=./scripts/syn12.sh
    SIM=./scripts/sim_gate12.sh
    NETLIST=build/syn12/bist_adder12_syn.v
    SDF=build/syn12/bist_adder12_syn.sdf
else
    echo "Error: N must be 6 or 12" >&2
    exit 2
fi

if [[ ! -x "$SYN" ]]; then
    echo "Error: $SYN not found or not executable."
    echo "Run: chmod +x scripts/syn${N}.sh"
    exit 2
fi

if [[ ! -x "$SIM" ]]; then
    echo "Error: $SIM not found or not executable."
    echo "Run: chmod +x scripts/sim_gate${N}.sh"
    exit 2
fi

mkdir -p logs waves
mkdir -p "build/best_synsim_N${N}"
mkdir -p "build/fail_synsim_N${N}"

PASS_FSDB_DIR="${SAVE_ROOT}/N${N}_fastest_pass"
FAIL_FSDB_DIR="${SAVE_ROOT}/N${N}_first_fail"

mkdir -p "$PASS_FSDB_DIR" "$FAIL_FSDB_DIR"

RESULT_CSV="logs/sweep_synsim_N${N}.csv"
echo "period_ps,clock_constraint_ns,frequency_mhz,syn_status,sim_status,result,signature_line" > "$RESULT_CSV"

BEST_PS=""
BEST_FREQ=""
FIRST_FAIL_SAVED=0

for ((P=${START_PS}; P>=${STOP_PS}; P-=${STEP_PS})); do
    CLK_NS=$(awk -v p="$P" 'BEGIN { printf "%.3f", p/1000.0 }')
    FREQ=$(awk -v p="$P" 'BEGIN { printf "%.3f", 1000000.0/p }')

    echo "============================================================"
    echo "[sweep-synsim] N=${N}, period=${P} ps, constraint=${CLK_NS} ns, freq=${FREQ} MHz"

    # Remove old FSDB before each simulation to avoid copying stale waveform.
    rm -f waves/*.fsdb 2>/dev/null || true

    # 1) Synthesis with the SAME clock period.
    set +e
    "$SYN" "$CLK_NS" > "logs/sweep_synsim_N${N}_${P}ps.syn.stdout" 2>&1
    SYN_STATUS=$?
    set -e

    # If synthesis exits non-zero but netlist and SDF exist, continue to simulation.
    # This avoids false SYN_FAIL caused by dc_shell return code.
    if [[ ! -f "$NETLIST" || ! -f "$SDF" ]]; then
        RESULT="SYN_FAIL"
        SIG_LINE=""
        echo "${P},${CLK_NS},${FREQ},${SYN_STATUS},NA,${RESULT},${SIG_LINE}" >> "$RESULT_CSV"
        echo "[result] ${RESULT} at ${P} ps"
        echo "  Missing netlist or SDF:"
        echo "  NETLIST=${NETLIST}"
        echo "  SDF=${SDF}"
        break
    fi

    # 2) Gate-level simulation with the SAME clock period.
    set +e
    "$SIM" "$P" > "logs/sweep_synsim_N${N}_${P}ps.sim.stdout" 2>&1
    SIM_STATUS=$?
    set -e

    SIM_LOG="logs/vcs_gate${N}_${P}ps.log"
    SIG_LINE=$(grep "HW3_RESULT" "$SIM_LOG" 2>/dev/null | tail -n 1 | tr ',' ';' || true)

    FSDB=$(find waves -maxdepth 1 -type f -name "*.fsdb" | head -n 1 || true)

    if [[ $SIM_STATUS -eq 0 ]] \
       && grep -q "HW3_PASS" "$SIM_LOG" 2>/dev/null \
       && ! grep -Eiq "timing violation|setuphold|setup violation|hold violation|recovery violation|removal violation|width violation" "$SIM_LOG" 2>/dev/null; then

        RESULT="PASS"
        BEST_PS="$P"
        BEST_FREQ="$FREQ"

        # Save best netlist/SDF/log.
        cp -f "$NETLIST" "build/best_synsim_N${N}/" 2>/dev/null || true
        cp -f "$SDF"     "build/best_synsim_N${N}/" 2>/dev/null || true
        cp -f "$SIM_LOG" "build/best_synsim_N${N}/" 2>/dev/null || true
        cp -f "logs/sweep_synsim_N${N}_${P}ps.syn.stdout" "build/best_synsim_N${N}/" 2>/dev/null || true
        cp -f "logs/sweep_synsim_N${N}_${P}ps.sim.stdout" "build/best_synsim_N${N}/" 2>/dev/null || true

        # Keep only the current fastest PASS FSDB in max/N*_fastest_pass.
        if [[ -n "$FSDB" && -f "$FSDB" ]]; then
            rm -f "${PASS_FSDB_DIR}"/*.fsdb 2>/dev/null || true
            cp -f "$FSDB" "${PASS_FSDB_DIR}/fastest_pass_N${N}_${P}ps_${FREQ}MHz.fsdb"
            echo "  Saved PASS FSDB: ${PASS_FSDB_DIR}/fastest_pass_N${N}_${P}ps_${FREQ}MHz.fsdb"
        else
            echo "  Warning: no FSDB found for PASS period ${P} ps"
        fi

        echo "[result] PASS at ${P} ps (${FREQ} MHz)"

    else
        RESULT="FAIL"

        # Save first FAIL FSDB only.
        if [[ "$FIRST_FAIL_SAVED" -eq 0 ]]; then
            if [[ -n "$FSDB" && -f "$FSDB" ]]; then
                rm -f "${FAIL_FSDB_DIR}"/*.fsdb 2>/dev/null || true
                cp -f "$FSDB" "${FAIL_FSDB_DIR}/first_fail_N${N}_${P}ps_${FREQ}MHz.fsdb"
                echo "  Saved FAIL FSDB: ${FAIL_FSDB_DIR}/first_fail_N${N}_${P}ps_${FREQ}MHz.fsdb"
            else
                echo "  Warning: no FSDB found for FAIL period ${P} ps"
            fi
            FIRST_FAIL_SAVED=1
        fi

        cp -f "$SIM_LOG" "build/fail_synsim_N${N}/" 2>/dev/null || true
        cp -f "logs/sweep_synsim_N${N}_${P}ps.syn.stdout" "build/fail_synsim_N${N}/" 2>/dev/null || true
        cp -f "logs/sweep_synsim_N${N}_${P}ps.sim.stdout" "build/fail_synsim_N${N}/" 2>/dev/null || true

        echo "[result] FAIL at ${P} ps"
        echo "  Check: logs/sweep_synsim_N${N}_${P}ps.syn.stdout"
        echo "  Check: logs/sweep_synsim_N${N}_${P}ps.sim.stdout"
        echo "  Check: ${SIM_LOG}"
    fi

    echo "${P},${CLK_NS},${FREQ},${SYN_STATUS},${SIM_STATUS},${RESULT},${SIG_LINE}" >> "$RESULT_CSV"

    # Sweep from slow to fast. First FAIL after at least one PASS means maximum speed was crossed.
    if [[ "$RESULT" == "FAIL" && -n "$BEST_PS" ]]; then
        break
    fi

    if [[ "$RESULT" == "FAIL" && -z "$BEST_PS" ]]; then
        echo "No passing period found. Try a larger START_PS."
        break
    fi
done

echo "============================================================"
if [[ -n "$BEST_PS" ]]; then
    echo "Best passing period for N=${N}: ${BEST_PS} ps (${BEST_FREQ} MHz)"
    echo "Fastest PASS FSDB saved in: ${PASS_FSDB_DIR}"
    echo "First FAIL FSDB saved in: ${FAIL_FSDB_DIR}"
else
    echo "No passing period found in this range."
fi

echo "CSV saved to: ${RESULT_CSV}"