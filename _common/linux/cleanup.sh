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

# Clean up package cache.
if [ $DISTR == "debian" ]; then
    sudo apt-get autoremove -y --purge
    sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*
elif [ $DISTR == "centos" ]; then
    sudo yum clean all
fi

# Remove temporary files.
sudo rm -rf /tmp/* /var/tmp/*

# Zero out free space.
sudo dd if=/dev/zero of=/EMPTY bs=1M
sudo rm -f /EMPTY