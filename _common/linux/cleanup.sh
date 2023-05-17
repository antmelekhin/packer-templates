#!/bin/bash

# Clean up
sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Zero out free space
sudo dd if=/dev/zero of=/EMPTY bs=1M
sudo rm -f /EMPTY