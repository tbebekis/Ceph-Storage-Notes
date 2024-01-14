# ● on the manager host
# ---------------------------------------------------------------------------------
# this host is going to be the host where the first Monitor daemon is installed
 
# Variables
# Quincy version. Replace this with the desired release 
CEPH_RELEASE=quincy

# ● update and upgrade
# ---------------------------------------------------------------------------------
# RH/CentOS 
dnf update -y
dnf upgrade -y

# Ubuntu
apt-get update
apt-get upgrade

# ● install prerequisites
# ---------------------------------------------------------------------------------
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

# ● IF
# a package is available for the OS, install cephadm using that package
# ---------------------------------------------------------------------------------
# RH/CentOS 
dnf search release-ceph
dnf install --assumeyes centos-release-ceph-${CEPH_RELEASE}
dnf install --assumeyes cephadm

# Ubuntu 
apt-get install -y cephadm

# ● ELSE 
# download and install cephadm
# ---------------------------------------------------------------------------------        
curl --silent --remote-name --location https://github.com/ceph/ceph/raw/${CEPH_RELEASE}/src/cephadm/cephadm

# make the cephadm script executable
chmod +x cephadm              

# install cephadm as Linux command
./cephadm add-repo --release ${CEPH_RELEASE}
./cephadm install

# check where it is installed, it should be in /usr/sbin/cephadm
which cephadm

# ● install ceph-common
# ---------------------------------------------------------------------------------
# RH/CentOS
dnf install -y ceph-common  

# Ubuntu 
apt-get install -y ceph-common  