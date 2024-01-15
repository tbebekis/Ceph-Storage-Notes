# ● cephadm
# ---------------------------------------------------------------------------------
# this text uses the "cephadm" tool in Ceph Storage installation.
# "cephadm" creates a new Ceph cluster by “bootstrapping” on a single host, 
# expanding the cluster to encompass any additional hosts, and then deploying the needed services.

# ● on the manager host
# ---------------------------------------------------------------------------------
# this host is going to be the host where the first Monitor daemon is installed 

# ● Variables
# ---------------------------------------------------------------------------------
# Quincy version. Replace this with the desired release 
CEPH_RELEASE=quincy

# ● two installation methods
# ---------------------------------------------------------------------------------
# - distribution-specific installation methods
# - a curl-based installation method
#
# WARNING
# These methods of installing cephadm are mutually exclusive. 
# Choose either the distribution-specific method or the curl-based method. 
# Do not attempt to use both these methods on one system.

# ● distribution-specific installation
# IF a package is available for the OS, install cephadm using that package
# ---------------------------------------------------------------------------------
# RH/CentOS 
dnf search release-ceph
dnf install --assumeyes centos-release-ceph-${CEPH_RELEASE}
dnf install --assumeyes cephadm

# Ubuntu 
apt-get install -y cephadm

# ● curl-based installation 
# ELSE use curl to download cephadm and then install it
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