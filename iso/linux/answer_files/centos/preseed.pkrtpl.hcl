# Install from an installation tree on a remote server in text mode.
install
text
url --url=http://vault.centos.org/centos/$releasever/os/$basearch/

# Configures additional yum repositories that can be used as sources for package installation.
repo --name=updates --baseurl=http://vault.centos.org/centos/$releasever/updates/$basearch/
repo --name=epel --mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-7&arch=$basearch

# Localization settings.
lang ru_RU.UTF-8
keyboard us

# Sets the system time zone to timezone.
timezone ${timezone}

# Configure network information for target system and activate network devices in the installer environment.
network --bootproto=dhcp

# Lock root account and creates a new user on the system.
rootpw --lock
user --name=${username} --groups=${username} --password=${password} --plaintext

zerombr
clearpart --all --initlabel
autopart --type=plain
bootloader --timeout=1

# Package Selection.
%packages
@core
bash-completion
epel-release
# mandatory packages in the @core group
-btrfs-progs
-iprutils
-kexec-tools
-plymouth
# default packages in the @core group
-*-firmware
-dracut-config-rescue
-kernel-tools
-libsysfs
-microcode_ctl
-NetworkManager*
-postfix
-rdma
%end

# Post-installation Script.
%post --erroronfail
yum update -y

echo "Defaults:${username} !requiretty" > /etc/sudoers.d/${username}
echo "${username} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/${username}
chmod 440 /etc/sudoers.d/${username}
%end

# Reboot after the installation is successfully completed.
## Attempt to eject the bootable media (DVD, USB, or other media) before rebooting.
reboot --eject