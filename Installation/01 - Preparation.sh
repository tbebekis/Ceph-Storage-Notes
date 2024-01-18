# ● clock synchronization
# ---------------------------------------------------------------------------------
# CRUCIAL: Clock synchronization (such as chrony or NTP) needs to be set on all nodes.

# ● on the manager host
# ---------------------------------------------------------------------------------
# this host is going to be the host where the first Ceph Monitor daemon is installed

# ● update and upgrade
# ---------------------------------------------------------------------------------
# RH/CentOS 
dnf update -y
dnf upgrade -y

# Ubuntu
apt-get update
apt-get upgrade

# ● install prerequisites on any Ceph host
# ---------------------------------------------------------------------------------
# - Python 3
# - Systemd
# - Podman or Docker for running containers
# - Time synchronization (such as chrony or NTP)
# - LVM2 for provisioning storage devices

# RH/CentOS
dnf install -y python3 
dnf install -y lvm2 
dnf install -y podman

# Ubuntu 
apt-get install -y python3
apt-get install -y lvm2
apt-get install -y podman

# ● check hosts file
# ---------------------------------------------------------------------------------
# add Ceph hosts to the hosts file 
cat /etc/hosts

# ● set hostname on Ceph hosts
# ---------------------------------------------------------------------------------
# we are going to use the cephadm tool in installing the Ceph cluster.
# cephadm demands that the name of the host given via ceph orch host add equals the output of hostname on remote hosts.
ssh HOST-0 hostname HOST-0
ssh HOST-1 hostname HOST-1
ssh HOST-2 hostname HOST-2
# etc.

# ● set password-less access to Ceph hosts
# ---------------------------------------------------------------------------------
ssh-keygen
ssh-copy-id HOST-0
ssh-copy-id HOST-1
ssh-copy-id HOST-2
 
# ● check versions
# ---------------------------------------------------------------------------------
# Ceph Quincy cephadm requires 
# Podman >= 3
# Python >= 3.6 
# SEE: https://docs.ceph.com/en/latest/cephadm/compatibility/#cephadm-compatibility-with-podman
python3 --version
podman -v

# lvm2 utility versions
pvcreate --version
vgcreate --version
lvcreate --version
