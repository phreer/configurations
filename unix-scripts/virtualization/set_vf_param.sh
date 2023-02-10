cd /sys/class/drm/card0/
echo 40     | sudo tee iov/pf/gt/exec_quantum_ms
echo 40000  | sudo tee iov/pf/gt/preempt_timeout_us
echo 200    | sudo tee iov/vf1/gt/exec_quantum_ms
echo 200000 | sudo tee iov/vf1/gt/preempt_timeout_us
