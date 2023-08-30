#!/bin/bash

# Get a distribution name and version.
if [ -f /etc/os-release ]; then
    source /etc/os-release
    DISTR="$ID"
    VERSION="$VERSION_ID"
elif [ -f /etc/redhat-release ]; then
    DISTR=$(cat /etc/redhat-release | cut -d" " -f1 | awk '{ print tolower($1) }')
    VERSION=$(cat /etc/redhat-release | cut -d" " -f4 | cut -d "." -f1)
fi

if [ $PACKER_BUILDER_TYPE == 'virtualbox-iso' ]; then
    # Install the packages required for building kernel modules.
    if [ $DISTR == "debian" ]; then
        sudo apt-get install -y build-essential bzip2 dkms linux-headers-$(uname -r)
    elif [ $DISTR == "centos" ]; then
        sudo yum install -y bzip2 dkms kernel-devel kernel-headers
    fi

    # Install the Guest Additions.
    if [ -f /tmp/VBoxGuestAdditions.iso ]; then
        sudo mkdir -p /tmp/virtualbox
        sudo mount -r -o loop /tmp/VBoxGuestAdditions.iso /tmp/virtualbox
        sudo sh /tmp/virtualbox/VBoxLinuxAdditions.run
        sudo umount /tmp/virtualbox
        sudo rm -rf /tmp/VBoxGuestAdditions.iso
    fi
fi

if [ $PACKER_BUILDER_TYPE == 'hyperv-iso' ]; then
    if [ $DISTR == "debian" ]; then
        sudo apt-get install -y hyperv-daemons
    elif [ $DISTR == "centos" ]; then
        sudo yum install -y hyperv-daemons
    fi
fi
