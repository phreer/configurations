#!/bin/bash

BASE_DIR=$HOME/workspace
path_type="$BASE_DIR"/virtualization.gpu.gvt.qemu
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$path_type/build

qemu="$path_type/build/qemu-system-x86_64"
MAC_ADDR="74:86:e2:34:dc:9e" #set it by yourself

OVMF_CODE_file="$BASE_DIR/efi/OVMF_CODE.fd"
OVMF_VARA_file="$BASE_DIR/efi/OVMF_VARS.fd"
GOP_FILE="$BASE_DIR/efi/GOP.rom"

DISK_IMG="$BASE_DIR/images/qemu-debian.qcow2"

$qemu \
        -name vm-ovmf \
        -vga none -display none -nographic \
        -machine type=q35,accel=kvm,kernel-irqchip=on \
        -enable-kvm -smp 8,cores=4,threads=2,sockets=1 \
        -cpu host,hv_relaxed,hv-vapic,hv-spinlocks=4096,hv-time,hv-runtime,hv-synic,hv-stimer,hv_vpindex,hv-tlbflush,hv-ipi \
        -m 16000 \
        -drive if=pflash,format=raw,unit=0,file=$OVMF_CODE_file,readonly=on \
        -drive if=pflash,format=raw,unit=1,file=$OVMF_VARA_file \
        -drive id=disk1,file=$DISK_IMG,if=none,format=qcow2 \
        -device virtio-blk-pci,id=blk1,drive=disk1,addr=0x4,bootindex=1 \
	-device qemu-xhci,id=ehci,bus=pcie.0,addr=0x05 \
	-device usb-host,bus=ehci.0,hostdevice='/dev/bus/usb/001/004' \
	-device usb-host,bus=ehci.0,hostdevice='/dev/bus/usb/001/005' \
        -device vfio-pci,host=00:02.0,id=gvtd_dev,bus=pcie.0,addr=0x2,x-igd-opregion=on,romfile=$GOP_FILE \
	-netdev user,id=mynet0,hostfwd=tcp::8080-:22 \
	-device e1000,netdev=mynet0 \
        -global ICH9-LPC.disable_s3=1 -global ICH9-LPC.disable_s4=1 \
#        -device usb-host,vendorid=0x413c,productid=0x2113 \
#        -device usb-host,vendorid=0x413c,productid=0x301a \
#        -net nic,model=e1000,macaddr=$MAC_ADDR,addr=0x3 -net tap,script=/etc/kvm/qemu-ifup,downscript=no \
#        -drive id=disk2,file=$perf_file,if=none,format=qcow2 \
#        -device virtio-blk,id=blk2,addr=0x9,drive=disk2 \
#        -net nic,model=e1000,macaddr=$MAC_ADDR,addr=0x3
