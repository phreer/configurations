#!/bin/bash

for i in `seq 0 $(($(nproc)-1))`; do
  echo performance| sudo tee /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor
done
