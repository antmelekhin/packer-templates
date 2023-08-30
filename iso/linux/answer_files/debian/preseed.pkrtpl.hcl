# Localization
d-i debian-installer/locale string ru_RU.UTF-8
#d-i debian-installer/language string en
#d-i debian-installer/country string NL
#d-i debian-installer/locale string en_GB.UTF-8
# Optionally specify additional locales to be generated.
#d-i localechooser/supported-locales multiselect en_US.UTF-8, nl_NL.UTF-8
d-i keyboard-configuration/xkb-keymap select us
# d-i keyboard-configuration/toggle select No toggling

# Network configuration
d-i netcfg/choose_interface select auto

# Mirror settings
d-i mirror/country string manual
d-i mirror/http/hostname string ${repository_mirror}
d-i mirror/http/directory string /debian
d-i mirror/suite string stable

# Account setup
d-i passwd/root-login boolean false
d-i passwd/make-user boolean true
d-i passwd/user-fullname string ${username}
d-i passwd/username string ${username}
d-i passwd/user-password password ${password}
d-i passwd/user-password-again password ${password}

# Clock and time zone setup
d-i clock-setup/utc boolean true
d-i time/zone string ${timezone}
d-i clock-setup/ntp boolean true

# Partitioning
d-i partman-auto/method string regular
d-i partman-auto/choose_recipe select atomic
d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true

# Base system installation
d-i base-installer/install-recommends boolean false
d-i base-installer/kernel/image string linux-image-686

# Apt setup
d-i apt-setup/contrib boolean true
d-i apt-setup/non-free boolean true
d-i apt-setup/services-select multiselect security
d-i apt-setup/security_host string ${repository_mirror}

# Package selection
tasksel tasksel/first multiselect
d-i pkgsel/include string bash-completion ca-certificates curl openssh-server man-db sudo
popularity-contest popularity-contest/participate boolean false

# Boot loader installation
d-i grub-installer/only_debian boolean true
d-i grub-installer/with_other_os boolean false
d-i grub-installer/bootdev string default

# Finishing up the installation
d-i finish-install/reboot_in_progress note
#d-i cdrom-detect/eject boolean false

# Running custom commands during the installation
#d-i preseed/early_command string anna-install some-udeb
d-i preseed/late_command string \
    echo "Defaults:${username} !requiretty" > /target/etc/sudoers.d/${username} ; \
    echo "${username} ALL=(ALL) NOPASSWD: ALL" >> /target/etc/sudoers.d/${username} ; \
    chmod 440 /target/etc/sudoers.d/${username}
