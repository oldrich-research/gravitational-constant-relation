#!/bin/bash
# AX: AV6 | SUM: parameterized jl15 launcher — patches MAX_GENERAL_SHELL_COST to $1 in tmp copy, runs julia -t 24, moves CSVs into jl15_c${COST}_outputs/; PRESERVES existing checkpoint so canonical source resumes at next_cost; pass --fresh to force restart from C1 | SIG: 2
#
# Invocation (run inside hive_compute):
#   docker exec -u compute -w /data/research/programs/g-decode/local_runs/av6_exhaustive_c40_plan_20260430T133000Z 6499fba4c7da_hive_compute \
#     bash launch_jl15.sh 19
#
# Prereq: canonical source `run_av6_exhaustive_c40_jl15.jl` must contain the
# canonical-seeding fix (`maximum(budgets)`). The shell cap default in the
# canonical source is 16; this script patches it to $1 in a tmp copy.

set -euo pipefail

FRESH=0
if [ $# -ge 1 ] && [ "$1" = "--fresh" ]; then
    FRESH=1
    shift
fi

if [ $# -ne 1 ]; then
    echo "usage: $0 [--fresh] <max_cost>"
    echo "  default: preserves existing c14_c25_checkpoint_jl15.jls so the canonical"
    echo "          source resumes at next_cost (saves redo of C1..prev_cap)."
    echo "  --fresh: moves existing checkpoint aside and restarts from C1."
    exit 2
fi

COST="$1"
case "$COST" in
    ''|*[!0-9]*) echo "[jl15] ABORT: max_cost must be integer, got '$COST'"; exit 2 ;;
esac
if [ "$COST" -lt 6 ] || [ "$COST" -gt 25 ]; then
    echo "[jl15] ABORT: max_cost out of expected range [6,25]: $COST"
    exit 2
fi

RUN_DIR="/data/research/programs/g-decode/local_runs/av6_exhaustive_c40_plan_20260430T133000Z"
CANONICAL="$RUN_DIR/run_av6_exhaustive_c40_jl15.jl"
TMP="$RUN_DIR/run_av6_exhaustive_c40_jl15_c${COST}_tmp.jl"
CHECKPOINT="$RUN_DIR/c14_c25_checkpoint_jl15.jls"
NEW_OUT="$RUN_DIR/jl15_c${COST}_outputs"
LOG="$RUN_DIR/logs/run_julia_jl15_c${COST}.log"
TS=$(date -u +%Y%m%dT%H%M%SZ)

echo "[jl15-c${COST}] start: $TS"

if ! grep -q 'maximum(budgets)' "$CANONICAL"; then
    echo "[jl15-c${COST}] ABORT: canonical source $CANONICAL missing canonical-seeding fix"
    exit 2
fi

if pgrep -af 'run_av6_exhaustive_c40' > /dev/null; then
    echo "[jl15-c${COST}] ABORT: another jl1*/enumeration process already running"
    pgrep -af 'run_av6_exhaustive_c40'
    exit 2
fi

if [ -f "$CHECKPOINT" ]; then
    if [ "$FRESH" -eq 1 ]; then
        echo "[jl15-c${COST}] --fresh: moving pre-existing checkpoint aside"
        mv -v "$CHECKPOINT" "$CHECKPOINT.pre_run_c${COST}_$TS.bak"
    else
        echo "[jl15-c${COST}] preserving pre-existing checkpoint at $CHECKPOINT"
        echo "[jl15-c${COST}] (canonical source will resume at saved next_cost; pass --fresh to override)"
        cp -v "$CHECKPOINT" "$CHECKPOINT.pre_run_c${COST}_$TS.snapshot"
    fi
fi

# Patch shell cap 16 -> $COST in tmp file (canonical jl15 source kept at default 16)
sed "s/const MAX_GENERAL_SHELL_COST = 16/const MAX_GENERAL_SHELL_COST = $COST/" "$CANONICAL" > "$TMP"
grep -q "MAX_GENERAL_SHELL_COST = $COST" "$TMP" || { echo "[jl15-c${COST}] ABORT: cap not patched"; exit 2; }
grep -q 'maximum(budgets)' "$TMP" || { echo "[jl15-c${COST}] ABORT: fix not in tmp"; exit 2; }

mkdir -p "$NEW_OUT"
mkdir -p "$RUN_DIR/logs"

cd "$RUN_DIR"
echo "[jl15-c${COST}] launching julia -t 24..."
JULIA_DEPOT_PATH=/home/compute/.julia \
  julia -t 24 -O3 --check-bounds=no --startup-file=no \
  "$TMP" >> "$LOG" 2>&1
JULIA_RC=$?
echo "[jl15-c${COST}] julia exit: $JULIA_RC"

for f in c14_c25_same_target_rank_tables.csv c14_c25_sham_best_ledger.csv c14_c25_bounded_shell_stats.csv; do
    if [ -f "$RUN_DIR/$f" ]; then
        mv -v "$RUN_DIR/$f" "$NEW_OUT/$f"
    fi
done

if [ -f "$CHECKPOINT" ]; then
    cp -v "$CHECKPOINT" "$NEW_OUT/c14_c25_checkpoint_jl15_post_run.jls"
fi

rm -f "$TMP"
echo "[jl15-c${COST}] done: $(date -u +%FT%TZ) rc=$JULIA_RC"
exit $JULIA_RC
