#!/bin/bash


# Release focus -> Ctl_Left + Alt_Left + g
# Password: 1234
# Install without Microsoft account: (Shift + F10) oobe\bypassnro + ipconfig /release

# See: https://wiki.archlinux.org/title/QEMU
# See: https://github.com/tianocore/tianocore.github.io/wiki/OVMF
# See: https://man.archlinux.org/man/swtpm.8.en
# See: https://archlinux.org/packages/extra/x86_64/libtpms/
# See: https://github.com/stefanberger/swtpm/wiki
# See: https://virtio-fs.gitlab.io/
# See: https://www.spice-space.org/index.html
# See: https://wiki.archlinux.org/title/Virt-manager

# Create virtual disk of 64GB with the format "qcow2".
# Qemu won't allocate upfront 64GB, but rather this is
# the maximum space the disk is allow to grow.
#
qemu-img create -f qcow2 Windows11.qcow2 64G

# Start swtpm emulator and create a socket where
# the emulator will be listening.
#
# We need to ensure the directory "/tmp/emulated_tpm" exists 
# before running this command, as swtpm will store 
# the TPM state data there.
#
# For more information run -> "swtpm socket --help"
#
# -d -> start as a daemon
# -tpm2 -> use TPM 2.0
#
rm -rf /tmp/emulated_tpm
mkdir /tmp/emulated_tpm
swtpm socket \
	-d \
	--tpm2 \
	--tpmstate dir=/tmp/emulated_tpm \
	--ctrl type=unixio,path=/tmp/emulated_tpm/swtpm-sock \
	--log level=20
# Check it's running -> ps aux | grep swtpm

# Start virtual machine:
#
# qemu-system-x86_64 -> emulation for x86_64 architecture
# smp -> 2 CPU cores
# cpu -> The type of CPU model to use (use the host CPU model). An example would be "Skylake-Client-v3"
# enable-kvm -> Enable kernel based virtualization
# m -> principal memory size
# usb -> Enables USB support
# cdrom -> Location of our image (only needed on first boot)
# drive -> Location of the virtual disk
# boot -> The boot order to use. "d" means cdrom
# bios -> Location to the EFI information 
# chardev -> This part of the command creates a new character device in QEMU, 
#	     which is a socket connected to the swtpm emulator. 
#	     The id=chrtpm assigns an identifier to this chardev, 
#	     and path= specifies the socket path to which swtpm is listening.
# tpmdev -> This creates a TPM device (tpmdev) in the VM that is an emulator, 
#	    with the identifier tpm0, and it connects this TPM device to the 
#	    previously defined chardev (chrtpm).
# device -> This adds the TPM device to your virtual machine. The tpm-tis 
#	    is a type of TPM interface specification, and tpmdev=tpm0 links 
#	    this device to the tpmdev created in the previous step.
# device -> sets the sound card to be a standard Intel one
cp /usr/share/edk2/x64/OVMF_VARS.4m.fd ./
chmod +w ./OVMF_VARS.4m.fd
qemu-system-x86_64 \
	-machine q35 \
	-m 8192 \
	-smp 2 \
	-cpu host \
	-enable-kvm \
	-drive file=/home/jmarimon/VirtualMachines/Windows11/Windows11.qcow2,format=qcow2,index=0,media=disk \
	-drive if=pflash,format=raw,readonly=on,file=/usr/share/edk2/x64/OVMF_CODE.secboot.4m.fd \
	-drive if=pflash,format=raw,file=/home/jmarimon/VirtualMachines/Windows11/OVMF_VARS.4m.fd \
	-nic user \
	-chardev socket,id=chrtpm,path=/tmp/emulated_tpm/swtpm-sock \
	-tpmdev emulator,id=tpm0,chardev=chrtpm \
	-device tpm-tis,tpmdev=tpm0 \
	-usb \
	-D log.txt \
	-display sdl,gl=on \
	-device qxl-vga

