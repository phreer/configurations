# KERNEL_VERSION_CR600=6.0.0-rc4+
KERNEL_VERSION_CROS=5.10.120+
KERNEL_VERSION_US519=5.19.0-1-amd64
KERNEL_VERSION=$KERNEL_VERSION_CROS

OUTPUT_PATH=$(date +%Y%m%d%H%M)
# IMAGE_DIR=/home/data/images/crosvm/
IMAGE_DIR=/

ROOTFS_DIR=/home/data/images/crosvm/
ROOTFS_DISK="$ROOTFS_DIR"/debian-mp.qcow2

IMAGE_PATH="$IMAGE_DIR"/boot/vmlinuz-"$KERNEL_VERSION"
# IMAGE_PATH="$IMAGE_DIR"/boot/vmlinux
# IMAGE_PATH=/home/data/phree/termina/root/vm_kernel

INITRAMFS_PATH="$IMAGE_DIR"/boot/initrd.img-"$KERNEL_VERSION"


GDB_DEBUG=0
CPUS=1
FEATURES=wl-dmabuf,gpu,x,virgl_renderer,virgl_renderer_next
DEBUG_CMDLINE=
DEBUG_PORT=

CHROMEOS_DIR=/home/data/phree/chromeos
MESA_DIR=$CHROMEOS_DIR/install/mesa-R104
export LD_LIBRARY_PATH=$MESA_DIR/lib:$MESA_DIR/x86_64-linux-gnu:$MESA_DIR/x86_64-linux-gnu/dri
export LIBGL_DRIVERS_PATH=$MESA_DIR/lib/x86_64-linux-gnu/dri

echo LD_LIBRARY_PATH=$LD_LIBRARY_PATH
echo LIBGL_DRIVERS_PATH=$LIBGL_DRIVERS_PATH

if [ $GDB_DEBUG = 1 ]; then
	FEATURES=$FEATURES,gdb
	DEBUG_CMDLINE=--gdb
	DEBUG_PORT=11000
fi

export MESA_DEBUG=1
export LIBGL_DEBUG=verbose
export LIBEGL_LOG_LEVEL=debug

cd $HOME/workspace/crosvm
rm crosvm.sock 2>/dev/null

if [ $1 = '-c' ]; then
	cargo clean
fi
# sudo ./target/debug/crosvm --log-level debug run \
export LIBGL_DEBUG=verbose
cargo run --features=$FEATURES -- --log-level debug run \
	--x-display=:0 \
	--display-window-keyboard --display-window-mouse \
	$DEBUG_CMDLINE $DEBUG_PORT \
	--disable-sandbox --tap-name crosvm_tap \
	--rwdisk  $ROOTFS_DISK \
	-s crosvm.sock --cpus $CPUS --mem 4096 \
	--gpu context-types=virgl2:cross-domain,vulkan=false,egl=true \
	--wayland-sock "$XDG_RUNTIME_DIR"/wayland-0 \
	-p "root=/dev/vda2 rootfstype=ext4 drm.debug=2" \
	--shared-dir /home/data/phree/:shared \
	 -i $INITRAMFS_PATH \
	$IMAGE_PATH

#context-types=virgl:virgl2:gfxstream:venus:cross-domain:drm,
# --gpu-display mode=windowed \
