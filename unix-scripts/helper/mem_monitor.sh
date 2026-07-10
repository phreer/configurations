#!/usr/bin/env bash
#
# mem_monitor.sh - Sample system "available memory" over the lifetime of a
# program and record a consumption curve.
#
# Why available memory (not just process RSS)?
#   The target program uses GPU / NPU. Their drivers allocate memory on the
#   kernel / device side (DRM/GEM, dma-buf, level-zero USM, intel_vpu buffers),
#   much of which never shows up in the process's VmRSS. Tracking the drop in
#   /proc/meminfo:MemAvailable captures process + driver + kernel-side usage.
#   We still record process VmRSS/VmHWM alongside, so you can quantify how much
#   the driver/NPU side consumes on top of what RSS reports.
#
# Lifecycle: this script STARTS the program (mode A). Sampling begins right
# before launch and stops automatically when the program exits. The program's
# exit code is propagated.
#
# Usage:
#   mem_monitor.sh -o out.csv [-l out.log] [-i 200] -- <program> [args...]
#
#   -o FILE   Output CSV path (default: mem_usage.csv)
#   -l FILE   Timestamped stdout/stderr log path (default: <CSV stem>.log)
#   -i MS     Sampling interval in milliseconds (default: 200)
#   --        Everything after this is the program + its arguments
#
# CSV columns:
#   t_seconds                 elapsed seconds since sampling start (monotonic-ish)
#   mem_available_bytes       /proc/meminfo MemAvailable, in bytes
#   delta_from_baseline_bytes baseline_available - current_available (>=0 => usage)
#   proc_vmrss_bytes          target process VmRSS (0 if unavailable)
#   proc_vmhwm_bytes          target process peak RSS so far (VmHWM)
#
# Log format:
#   t_seconds [stdout] program output
#   t_seconds [stderr] program output
# The timestamps use the same start time as the CSV. stdout/stderr are handled
# independently, so ordering between the two sources is not guaranteed.
# stdbuf requests line buffering to reduce the delay caused by pipe buffering.
#
# Notes:
#   - Available memory is affected by other processes on the system. Run on an
#     otherwise-idle machine and repeat measurements for reliable numbers.
#   - Intended for Linux (reads /proc). Not portable to macOS/Windows.

set -u

OUT="mem_usage.csv"
LOG=""
INTERVAL_MS=200

# ---- parse args --------------------------------------------------------------
while [[ $# -gt 0 ]]; do
    case "$1" in
        -o)
            OUT="$2"; shift 2 ;;
        -l)
            LOG="$2"; shift 2 ;;
        -i)
            INTERVAL_MS="$2"; shift 2 ;;
        --)
            shift; break ;;
        -h|--help)
            grep '^#' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Usage: $0 -o out.csv [-l out.log] [-i 200] -- <program> [args...]" >&2
            exit 2 ;;
    esac
done

if [[ $# -eq 0 ]]; then
    echo "Error: no program specified after '--'." >&2
    echo "Usage: $0 -o out.csv [-l out.log] [-i 200] -- <program> [args...]" >&2
    exit 2
fi

if [[ ! -r /proc/meminfo ]]; then
    echo "Error: /proc/meminfo not readable; this script requires Linux." >&2
    exit 1
fi

INTERVAL_S=$(awk "BEGIN{printf \"%.6f\", ${INTERVAL_MS}/1000.0}")
if [[ -z "${LOG}" ]]; then
    LOG="${OUT%.*}.log"
    [[ "${LOG}" == "${OUT}" ]] && LOG="${OUT}.log"
fi

# ---- helpers -----------------------------------------------------------------
# Read MemAvailable (kB) from /proc/meminfo and echo bytes.
read_mem_available_bytes() {
    awk '/^MemAvailable:/ {print $2 * 1024; exit}' /proc/meminfo
}

# Read a field (in kB) from /proc/<pid>/status, echo bytes (0 if missing).
read_proc_field_bytes() {
    local pid="$1" field="$2"
    local kb
    kb=$(awk -v f="${field}:" '$1==f {print $2; exit}' "/proc/${pid}/status" 2>/dev/null)
    if [[ -n "${kb}" ]]; then
        echo $(( kb * 1024 ))
    else
        echo 0
    fi
}

# Prefix each complete output line with the elapsed time on the CSV timeline.
timestamp_stream() {
    local source="$1" line now_ns t_s
    while IFS= read -r line || [[ -n "${line}" ]]; do
        now_ns=$(date +%s%N)
        t_s=$(awk "BEGIN{printf \"%.3f\", (${now_ns}-${START_NS})/1e9}")
        printf '%s [%s] %s\n' "${t_s}" "${source}" "${line}"
    done
}

# ---- baseline & program launch ----------------------------------------------
BASELINE=$(read_mem_available_bytes)
echo "Baseline MemAvailable: ${BASELINE} bytes ($((BASELINE / 1024 / 1024)) MiB)"

# Both the sampler and log forwarders use this single time origin.
START_NS=$(date +%s%N)
echo "t_seconds,mem_available_bytes,delta_from_baseline_bytes,proc_vmrss_bytes,proc_vmhwm_bytes" > "${OUT}"
: > "${LOG}"

# Use FIFOs so the log forwarders can be reaped before this script exits.
LOG_DIR=$(mktemp -d)
STDOUT_FIFO="${LOG_DIR}/stdout"
STDERR_FIFO="${LOG_DIR}/stderr"
mkfifo "${STDOUT_FIFO}" "${STDERR_FIFO}"
timestamp_stream stdout < "${STDOUT_FIFO}" | tee -a "${LOG}" &
STDOUT_LOG_PID=$!
timestamp_stream stderr < "${STDERR_FIFO}" | tee -a "${LOG}" >&2 &
STDERR_LOG_PID=$!

# Launch the target program in the background so we can watch its PID. stdbuf
# makes C/C++ output line-buffered after redirecting it through the FIFOs.
if command -v stdbuf >/dev/null 2>&1; then
    stdbuf -oL -eL "$@" > "${STDOUT_FIFO}" 2> "${STDERR_FIFO}" &
else
    "$@" > "${STDOUT_FIFO}" 2> "${STDERR_FIFO}" &
fi
CHILD_PID=$!
echo "Launched PID ${CHILD_PID}: $*"

# Ensure the child is cleaned up if the monitor is interrupted.
cleanup() {
    if kill -0 "${CHILD_PID}" 2>/dev/null; then
        kill -TERM "${CHILD_PID}" 2>/dev/null
        wait "${CHILD_PID}" 2>/dev/null
    fi
    wait "${STDOUT_LOG_PID}" "${STDERR_LOG_PID}" 2>/dev/null
    rm "${STDOUT_FIFO}" "${STDERR_FIFO}" 2>/dev/null
    rmdir "${LOG_DIR}" 2>/dev/null
}
trap 'cleanup; exit 130' INT TERM

# ---- sampling loop -----------------------------------------------------------
MIN_AVAIL=${BASELINE}
MAX_VMHWM=0

while kill -0 "${CHILD_PID}" 2>/dev/null; do
    now_ns=$(date +%s%N)
    t_s=$(awk "BEGIN{printf \"%.3f\", (${now_ns}-${START_NS})/1e9}")

    avail=$(read_mem_available_bytes)
    delta=$(( BASELINE - avail ))
    vmrss=$(read_proc_field_bytes "${CHILD_PID}" VmRSS)
    vmhwm=$(read_proc_field_bytes "${CHILD_PID}" VmHWM)

    echo "${t_s},${avail},${delta},${vmrss},${vmhwm}" >> "${OUT}"

    (( avail < MIN_AVAIL )) && MIN_AVAIL=${avail}
    (( vmhwm > MAX_VMHWM )) && MAX_VMHWM=${vmhwm}

    sleep "${INTERVAL_S}"
done

# Reap the child and capture its exit status.
wait "${CHILD_PID}"
EXIT_CODE=$?
wait "${STDOUT_LOG_PID}" "${STDERR_LOG_PID}"
rm "${STDOUT_FIFO}" "${STDERR_FIFO}"
rmdir "${LOG_DIR}"
trap - INT TERM

# ---- summary -----------------------------------------------------------------
PEAK_SYS=$(( BASELINE - MIN_AVAIL ))
DRIVER_EXTRA=$(( PEAK_SYS - MAX_VMHWM ))

echo ""
echo "===== memory summary ====="
echo "baseline available       : ${BASELINE} bytes ($((BASELINE/1024/1024)) MiB)"
echo "min available (during run): ${MIN_AVAIL} bytes ($((MIN_AVAIL/1024/1024)) MiB)"
echo "peak system consumption  : ${PEAK_SYS} bytes ($((PEAK_SYS/1024/1024)) MiB)   [baseline - min_available]"
echo "process peak RSS (VmHWM) : ${MAX_VMHWM} bytes ($((MAX_VMHWM/1024/1024)) MiB)"
echo "driver/kernel-side extra : ${DRIVER_EXTRA} bytes ($((DRIVER_EXTRA/1024/1024)) MiB)   [system_peak - process_VmHWM]"
echo "CSV written to           : ${OUT}"
echo "Program log written to   : ${LOG}"
echo "program exit code        : ${EXIT_CODE}"

exit ${EXIT_CODE}
