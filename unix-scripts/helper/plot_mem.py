#!/usr/bin/env python3
"""Plot a memory-consumption curve produced by mem_monitor.sh.

Reads the CSV (columns: t_seconds, mem_available_bytes,
delta_from_baseline_bytes, proc_vmrss_bytes, proc_vmhwm_bytes) and draws two
curves for comparison:

  * System consumption  = baseline - available memory (captures process +
    GPU/NPU driver + kernel-side allocations).
  * Process RSS (VmRSS)  = what the process itself reports.

The gap between them is roughly the memory consumed by the GPU/NPU driver and
kernel side that never shows up in the process RSS.

Usage:
  ./plot_mem.py mem_usage.csv [-o mem_usage.png]

If -o is omitted, the plot is shown interactively (falls back to saving
"<csv_stem>.png" when no display is available).
"""

import argparse
import csv
import os
import sys

import matplotlib

import matplotlib.pyplot as plt


MIB = 1024 * 1024


def load(csv_path):
    t, sys_mib, rss_mib, hwm_mib = [], [], [], []
    with open(csv_path, newline="") as f:
        reader = csv.DictReader(f)
        for row in reader:
            t.append(float(row["t_seconds"]))
            sys_mib.append(int(row["delta_from_baseline_bytes"]) / MIB)
            rss_mib.append(int(row["proc_vmrss_bytes"]) / MIB)
            hwm_mib.append(int(row["proc_vmhwm_bytes"]) / MIB)
    return t, sys_mib, rss_mib, hwm_mib


def main():
    ap = argparse.ArgumentParser(description="Plot mem_monitor.sh CSV output.")
    ap.add_argument("csv", help="CSV file produced by mem_monitor.sh")
    ap.add_argument("-o", "--output", help="Save figure to this path (PNG/SVG/...)")
    args = ap.parse_args()

    if not os.path.isfile(args.csv):
        sys.exit(f"Error: CSV not found: {args.csv}")

    t, sys_mib, rss_mib, hwm_mib = load(args.csv)
    if not t:
        sys.exit("Error: CSV has no data rows.")

    peak_sys = max(sys_mib)
    peak_rss = max(hwm_mib)
    driver_extra = peak_sys - peak_rss

    # Decide backend: save non-interactively if -o given or no display.
    interactive = args.output is None and bool(os.environ.get("DISPLAY"))
    if not interactive:
        matplotlib.use("Agg")

    fig, ax = plt.subplots(figsize=(10, 5))
    ax.plot(t, sys_mib, label="System consumption (baseline - available)",
            color="tab:red", linewidth=1.8)
    ax.plot(t, rss_mib, label="Process RSS (VmRSS)",
            color="tab:blue", linewidth=1.2)
    ax.fill_between(t, rss_mib, sys_mib, where=[s >= r for s, r in zip(sys_mib, rss_mib)],
                    color="tab:orange", alpha=0.15,
                    label="Driver/kernel-side extra")

    ax.set_xlabel("time (s)")
    ax.set_ylabel("memory (MiB)")
    ax.set_ylim(0, 10 * 1024)
    ax.set_title(
        f"Memory usage — peak system {peak_sys:.0f} MiB, "
        f"peak RSS {peak_rss:.0f} MiB, driver extra {driver_extra:.0f} MiB"
    )
    ax.grid(True, alpha=0.3)
    ax.legend(loc="best")
    fig.tight_layout()

    out = args.output
    if out is None and not interactive:
        out = os.path.splitext(args.csv)[0] + ".png"

    if out:
        fig.savefig(out, dpi=120)
        print(f"Saved plot to {out}")
    else:
        plt.show()


if __name__ == "__main__":
    main()
