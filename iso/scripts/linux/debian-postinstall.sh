#!/bin/sh
username=$1
echo "Defaults:$username !requiretty" > /target/etc/sudoers.d/$username
echo "$username ALL=(ALL) NOPASSWD: ALL" >> /target/etc/sudoers.d/$username
chmod 440 /target/etc/sudoers.d/$username
in-target apt install hyperv-daemons -y