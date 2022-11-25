#!/usr/bin/bash

export LD_LIBRARY_PATH=/home/data/phree/qemu-virgl/virglrenderer-install/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH

IMAGE_FOLDER=/home/data/images
DISK_PATH=$IMAGE_FOLDER/qemu-debian-virgl.qcow2

UEFI_PATH=$HOME/workspace/scripts/OVMF_CODE.fd

QEMU_DIR=/home/data/phree/qemu-virgl/qemu-install/bin/
$QEMU_DIR/qemu-system-x86_64                                       \
    -enable-kvm                                                    \
    -M q35                                                         \
    -smp 4                                                         \
    -m 4G                                                          \
    -cpu host                                                      \
    -boot order=c,menu=on,splash-time=3                            \
    -drive if=pflash,format=raw,file=$UEFI_PATH                    \
    -net nic,model=virtio                                          \
    -net user,hostfwd=tcp::2222-:22                                \
    -hda $DISK_PATH                                                \
    -device virtio-vga-gl,blob=false                               \
    -display gtk                                                   \
    -vga none                                                      \
    -display gtk,gl=on,show-cursor=on                              \
    -usb -device usb-tablet                                        \
    -device vfio-pci,host=01:00.0,id=hostdev0                      \
    -d guest_errors

# -device virtio-vga-gl,context_init=true,blob=true,hostmem=4G \
#     -object memory-backend-memfd,id=mem1,size=4G                   \
#     -machine memory-backend=mem1                                   \
