echo 0 | sudo tee -a /sys/devices/pci0000\:00/0000\:00\:02.0/sriov_drivers_autoprobe
echo 1 | sudo tee -a /sys/devices/pci0000\:00/0000\:00\:02.0/sriov_numvfs
echo 1 | sudo tee -a /sys/devices/pci0000\:00/0000\:00\:02.0/sriov_drivers_autoprobe

vfshedexecq=25
vfschedtimeout=50000

echo $vfshedexecq    | sudo tee -a /sys/class/drm/card0/iov/vf1/gt/exec_quantum_ms
echo $vfschedtimeout | sudo tee -a /sys/class/drm/card0/iov/vf1/gt/preempt_timeout_us
