#!/bin/bash

if [ $PACKER_BUILDER_TYPE == 'virtualbox-iso' ]; then

    if [ -f /tmp/VBoxGuestAdditions.iso ]; then
        sudo apt-get install -y build-essential bzip2 dkms linux-headers-$(uname -r)
        sudo mkdir -p /tmp/virtualbox
        sudo mount -r -o loop /tmp/VBoxGuestAdditions.iso /tmp/virtualbox
        sudo sh /tmp/virtualbox/VBoxLinuxAdditions.run
        sudo umount /tmp/virtualbox
        sudo rm -rf /tmp/VBoxGuestAdditions.iso
    fi

elif [ $PACKER_BUILDER_TYPE == 'hyperv-iso' ]; then
    sudo apt-get install -y hyperv-daemons
fi
