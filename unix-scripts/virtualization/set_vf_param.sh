CARD_PATH='/sys/bus/pci/devices/0000:00:02.0/drm/card0/'
echo 40     | sudo tee $CARD_PATH/prelim_iov/pf/gt0/exec_quantum_ms
echo 40000  | sudo tee $CARD_PATH/prelim_iov/pf/gt0/preempt_timeout_us
echo 200    | sudo tee $CARD_PATH/prelim_iov/vf1/gt0/exec_quantum_ms
echo 200000 | sudo tee $CARD_PATH/prelim_iov/vf1/gt0/preempt_timeout_us
