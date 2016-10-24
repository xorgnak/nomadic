BASE_IMAGE='mini.iso'
RAM_SIZE=2048
HD_SIZE='4G'

QEMU=qemu-system-x86_64
QEMU_IMG=nomadic_qemu.img
IMG=nomadic.img

if [[ $1 == 'boot' ]]; then
    $QEMU -monitor stdio \
	-hda $QEMU_IMG \
	-net nic \
	-net user,hostfwd=tcp::10022-:22 \
	-net user,hostfwd=tcp::10080-:80 \
	-net user,hostfwd=tcp::16667-:6667 \
	-m $RAM_SIZE
elif [[ $1 == 'convert' ]]; then
    qemu-img convert $QEMU_IMG -O raw $IMG
else
    if [[ ! -e $QEMU_IMG ]]; then
	if [[ -e $BASE_IMAGE ]]; then
            qemu-img create -f qcow2 $QEMU_IMG $HD_SIZE
            $QEMU -hda $QEMU_IMG -cdrom $BASE_IMAGE -m $RAM_SIZE -boot d
	else
	    echo "Move $BASE_IMAGE into `pwd` to continue."
	    exit
	fi
    else
	echo "Qemu image already exists."
	echo "  ./$0 boot - Open the Qemu image."
	echo "  ./$0 convert - Convert the Qemu image to a bootable image."
    fi
fi
echo "DONE!"
