#!/usr/bin/env sh

set -e

check_net() {
	wget --spider --quiet google.com
}

setup_time() {
	timedatectl set-ntp true
one_partition_and_mount() {
    fdisk -l
    echo "Enter the full path to the drive:\n"
    read drive
	cfdisk $drive
    mkfs.ext4 "${drive}1"
    mount "${drive}1" /mnt
}

rank_mirrors() {
    pacd = /etc/pacman.d
    pacman -Sy --noconfirm pacman-contrib
    cp $pacd/mirrorlist $pacd/mirrorlist.backup
    rankmirrors -v -n6 $pacd/mirrorlist.backup > $pacd/mirrorlist
}

install_packages() {
    echo -e "[dvzrv]\nServer = https://pkgbuild.com/~dvzrv/x86_64" >> /etc/pacman.conf
	pacman -Syy
    pacstrap /mnt \
    	base \
        linux-rt \
        linux-firmware \
        xorg \
        lightdm \
        lightdm-webkit2-greeter \
        awesome \
        pro-audio \
        firefox \
        rxvt-unicode \
        gvim \
        network-manager \
        network-manager-applet
}

configure() {
    genfstab -U /mnt >> /mnt/etc/fstab
    arch-chroot /mnt
    # TODO: Select time zone from list
    ln -sf /usr/share/zoneinfo/US/Eastern /etc/localtime
    hwclock --systohc
    # TODO: select locale from list
    sed -i.bak -e "s/^#en_US.UTF/en_US.UTF/" /etc/locale.gen
    locale-gen
    # TODO: insert locale here too
    echo "LANG=en_US.UTF-8" >> /etc/locale.conf
    # TODO: Set keyboard layout (should have been done before!)
    echo "stompix" > /etc/hostname
    echo -e "127.0.0.1 localhost\n::1 localhost\n127.0.1.1 stompix"
    mkinitcpio -P
    echo "root password"
    passwd
}

install_bootloader() {
	
}

main() {
	# loadkeys
    check_net
    setup_time
    one_partition_and_mount
    rank_mirrors
    install_packages
}

main
