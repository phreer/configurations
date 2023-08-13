cd /sys/class/drm/card0/
echo 0     | sudo tee prelim_iov/pf/device/sriov_drivers_auutoprobe
echo 1     | sudo tee prelim_iov/pf/device/sriov_numvfs
echo 4     | sudo tee prelim_iov/pf/gt/exec_quantum_ms
echo 4000  | sudo tee prelim_iov/pf/gt/preempt_timeout_us
echo 20    | sudo tee prelim_iov/vf1/gt/exec_quantum_ms
echo 20000 | sudo tee prelim_iov/vf1/gt/preempt_timeout_us
echo 1     | sudo tee prelim_iov/pf/device/sriov_drivers_auutoprobe

cd -
./set_vf_param.sh
sudo modprobe vfio-pci
sudo ./vfio-pci-bind/vfio-pci-bind.sh 0000:00:02.1
