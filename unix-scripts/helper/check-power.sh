#!/bin/sh

set -eu

interval=1
count=10

usage() {
  cat <<'EOF'
Usage: check-power.sh [OPTIONS]

Sample local power sysfs data. This script is intended to run directly on the
target system, including Android after adb push.

Options:
  -i SEC    Seconds between samples (default: 1)
  -c N      Number of samples to print (default: 10)
  -h        Show this help

Examples:
  check-power.sh
  check-power.sh -i 1 -c 10
EOF
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    -i)
      [ "$#" -ge 2 ] || die "-i requires a value"
      interval=$2
      shift 2
      ;;
    -c)
      [ "$#" -ge 2 ] || die "-c requires a value"
      count=$2
      shift 2
      ;;
    -h)
      usage
      exit 0
      ;;
    *)
      die "unknown option: $1"
      ;;
  esac
done

awk -v v="$interval" 'BEGIN { exit !(v > 0) }' || die "interval must be greater than 0"
awk -v v="$count" 'BEGIN { exit !(v > 0 && v == int(v)) }' || die "count must be a positive integer"

now_ns() {
  date '+%s%N'
}

read_energy() {
  for file in /sys/class/powercap/*/energy_uj; do
    [ -r "$file" ] || continue

    dir=${file%/*}
    name=${dir##*/}
    max=0

    [ -r "$dir/name" ] && name=$(cat "$dir/name")
    [ -r "$dir/max_energy_range_uj" ] && max=$(cat "$dir/max_energy_range_uj")

    value=$(cat "$file") || continue
    printf '%s\t%s\t%s\t%s\n' "$file" "$name" "$value" "$max"
  done
}

make_temp_file() {
  tmp_dir=${TMPDIR:-/tmp}

  if [ ! -d "$tmp_dir" ] || [ ! -w "$tmp_dir" ]; then
    tmp_dir=/data/local/tmp
  fi
  if [ ! -d "$tmp_dir" ] || [ ! -w "$tmp_dir" ]; then
    tmp_dir=.
  fi

  printf '%s/check-power.%s.%s\n' "$tmp_dir" "$$" "$1"
}

print_instant_power() {
  found=0
  printf 'time\t\tsource\t\twatts\telapsed_s\tpath\n'

  for file in /sys/class/power_supply/*/power_now; do
    [ -r "$file" ] || continue
    dir=${file%/*}
    value=$(cat "$file") || continue
    found=1
    awk -v time="$(date '+%T')" -v name="${dir##*/}" -v value="$value" -v path="$file" \
      'BEGIN { printf "%s\t%s\t%.3f\t-\t%s\n", time, name, value / 1000000, path }'
  done

  for current in /sys/class/power_supply/*/current_now; do
    [ -r "$current" ] || continue
    dir=${current%/*}
    voltage=$dir/voltage_now
    [ -r "$voltage" ] || continue

    current_value=$(cat "$current") || continue
    voltage_value=$(cat "$voltage") || continue
    found=1
    awk -v time="$(date '+%T')" -v name="${dir##*/}" -v current_value="$current_value" -v voltage_value="$voltage_value" -v path="$current + $voltage" \
      'BEGIN { printf "%s\t%s\t%.3f\t-\t%s\n", time, name, current_value * voltage_value / 1000000000000, path }'
  done

  [ "$found" -eq 1 ]
}

show_power_limits() {
  base=/sys/class/powercap/intel-rapl:0
  if [ ! -d "$base" ]; then
    echo "Path $base does not exist, skip"
    return;
  fi
  for i in 0 1 2; do
    if [ ! -e "$base/constraint_${i}_name" ]; then
      echo "Path $base/constraint_${i}_name does not exist, skip"
      return;
    fi
    echo "=== constraint_$i ==="
    cat "$base/constraint_${i}_name"
    awk '{printf "%.2f W\n", $1/1000000}' "$base/constraint_${i}_power_limit_uw"
    cat "$base/constraint_${i}_time_window_us" 2>/dev/null || true
  done
  return 0
}

show_power_limits

previous_file=$(make_temp_file previous)
current_file=$(make_temp_file current)
trap 'rm -f "$previous_file" "$current_file"' EXIT HUP INT TERM

read_energy >"$previous_file"

if [ ! -s "$previous_file" ]; then
  print_instant_power || die "no readable power sysfs data found"
  exit 0
fi

previous_ns=$(now_ns)
index=0

echo "=== realtime power ==="
printf 'time\t\tsource\t\twatts\telapsed_s\tpath\n'

while [ "$index" -lt "$count" ]; do
  sleep "$interval"
  read_energy >"$current_file"
  current_ns=$(now_ns)

  [ -s "$current_file" ] || die "powercap data disappeared while sampling"

  awk -v previous_ns="$previous_ns" -v current_ns="$current_ns" -v time="$(date '+%T')" '
    BEGIN {
      FS = "\t"
      elapsed = (current_ns - previous_ns) / 1000000000
    }

    NR == FNR {
      previous_value[$1] = $3
      next
    }

    {
      path = $1
      name = $2
      value = $3
      max = $4

      if (!(path in previous_value) || elapsed <= 0) {
        next
      }

      delta = value - previous_value[path]
      if (delta < 0 && max > 0) {
        delta += max
      }
      if (delta < 0) {
        next
      }

      watts = delta / 1000000 / elapsed
      printf "%s\t%s\t%.3f\t%.3f\t%s\n", time, name, watts, elapsed, path
    }
  ' "$previous_file" "$current_file"

  cp "$current_file" "$previous_file"
  previous_ns=$current_ns
  index=$((index + 1))
done
