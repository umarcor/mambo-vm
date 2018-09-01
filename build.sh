#!/bin/sh

# Create a new image and mount it
dd bs=1G seek=2 of=rootfs.img count=0
mkfs.ext4 rootfs.img
mkdir mnt
$(command -v sudo) mount -o loop rootfs.img ./mnt

# Extract the rootfs archive
cd mnt
tarball="ArchLinuxARM-aarch64-latest.tar.gz"
if [ ! -f "../$tarball" ]; then
  curl -L "http://os.archlinuxarm.org/os/$tarball" -o "../$tarball"
fi
$(command -v sudo) tar xpf "../$tarball"
cd ..

$(command -v sudo) mount -o bind /run/ mnt/run/
$(command -v sudo) mount -o bind /dev/ mnt/dev/
$(command -v sudo) mount -t proc none mnt/proc/
$(command -v sudo) chroot mnt/ /usr/bin/pacman -Syu gcc ruby git make --noconfirm
$(command -v sudo) chroot mnt/ /usr/bin/su alarm -c "cd /home/alarm && git clone https://github.com/beehive-lab/mambo.git && cd mambo && git submodule init && git submodule update"
$(command -v sudo) umount mnt/run/
$(command -v sudo) umount mnt/dev/
$(command -v sudo) umount mnt/proc/
$(command -v sudo) rm mnt/var/cache/pacman/pkg/*.tar.xz

# Extract the kernel and initrd images
cp mnt/boot/Image.gz .
cp mnt/boot/initramfs-linux-fallback.img .

$(command -v sudo) umount mnt
