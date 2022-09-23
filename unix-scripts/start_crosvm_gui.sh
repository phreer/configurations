KERNEL_VERSION_CR600=6.0.0-rc4+
KERNEL_VERSION_US519=5.19.0-1-amd64
KERNEL_VERSION=$KERNEL_VERSION_CR600

OUTPUT_PATH=$(date +%Y%m%d%H%M)
IMAGE_DIR=/home/data/images/crosvm/

ROOTFS_DISK="$IMAGE_DIR"/debian-mp.qcow2

IMAGE_PATH="$IMAGE_DIR"/boot/wl-vmlinux-"$KERNEL_VERSION"
INITRAMFS_PATH="$IMAGE_DIR"/boot/initrd.img-"$KERNEL_VERSION"

# IMAGE_PATH="$IMAGE_DIR"/out/boot/vmlinuz-5.18.0-4-amd64
# INITRAMFS_PATH="$IMAGE_DIR"/out/boot/initrd.img-5.18.0-4-amd64

GDB_DEBUG=0
CPUS=1
FEATURES=wl-dmabuf,gpu,x,virgl_renderer,virgl_renderer_next
DEBUG_CMDLINE=
DEBUG_PORT=
if [ $GDB_DEBUG = 1 ]; then
	FEATURES=$FEATURES,gdb
	DEBUG_CMDLINE=--gdb
	DEBUG_PORT=11000
fi

cd $HOME/workspace/crosvm
rm crosvm.sock 2>/dev/null

# sudo ./target/debug/crosvm --log-level debug run \
cargo run --features=$FEATURES -- --log-level debug run \
	$DEBUG_CMDLINE $DEBUG_PORT \
	--disable-sandbox --tap-name crosvm_tap \
	--rwdisk  $ROOTFS_DISK \
	-s crosvm.sock --cpus $CPUS --mem 4096 \
	--gpu-display mode=windowed \
	--gpu context-types=virgl:virgl2:cross-domain,backend=3d,vulkan=true,egl=true \
	--x-display=:0 \
	--wayland-sock "$XDG_RUNTIME_DIR"/wayland-0 \
	--display-window-keyboard --display-window-mouse \
	-p "root=/dev/vda2 rootfstype=ext4 rootflags=rw drm.debug=2" \
	--shared-dir "$HOME"/workspace:workspace \
	-i $INITRAMFS_PATH \
	$IMAGE_PATH

# --gpu backend=virglrenderer,width=1920,height=1080 \
#context-types=virgl:virgl2:gfxstream:venus:cross-domain:drm,
