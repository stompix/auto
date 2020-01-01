#!/usr/bin/env sh

set -e

check_net() {
	wget --spider --quiet google.com
}

setup_time() {
	timedatectl set-ntp true
}

instructions() {
    echo -e "\n\nInstallingStompix\n"
    echo "The partition scheme is hard coded into the install.sh script. If your needs differ, you should alter the function partition_and_mount()"
    echo -e "Note: your system must support UEFI boot to install via this script\n"
}

partition_and_mount() {
    echo "Examine the following fdisk output"
    echo "When prompted, enter the full path to the target drive."
    fdisk -l
    echo "Enter the full path to the drive:"
    read drive
	cfdisk $drive
    # All in one partition
    mkfs.ext4 "${drive}2"
    mount "${drive}2" /mnt
    # Separate home partition
    # mkfs.ext4 "${drive}1"
    # mount "${drive}" /mnt
    # mkdir /mnt/home
    # mkfs.ext4 "{$drive}2"
    # mount "${drive}" /mnt/home
}

rank_mirrors() {
    pacd=/etc/pacman.d
    pacman -Sy --noconfirm pacman-contrib
    cp $pacd/mirrorlist $pacd/mirrorlist.backup
    rankmirrors -v -n 6 $pacd/mirrorlist.backup > $pacd/mirrorlist
}

install_packages() {
    echo -e "[dvzrv]\nServer = https://pkgbuild.com/~dvzrv/repo/x86_64" >> /etc/pacman.conf
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
        networkmanager \
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

main() {
    clear
    instructions
	# loadkeys
    check_net
    setup_time
    partition_and_mount
    rank_mirrors
    install_packages
}

main
set +e
