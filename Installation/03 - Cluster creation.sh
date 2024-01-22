# ● bootstrap Ceph
# ---------------------------------------------------------------------------------
# The "ceph bootstrap" command installs the monitor and the management daemon for the new cluster on the host
# SEE: https://docs.ceph.com/en/latest/cephadm/install/#running-the-bootstrap-command
#
# The "--cluster-network" defines the cluster network.
# If you declare a cluster network, OSDs will route heartbeat, 
# object replication and recovery traffic over the cluster network. 
# This may improve performance compared to using a single network.
# SEE: https://docs.ceph.com/en/latest/rados/configuration/network-config-ref/#cluster-network
#
# The "cephadm bootstrap" command:
#   - does alot of things and creates a long output.
#   - runs Ceph's web portal with the Dashboard.
#   - output displays the Dashboard URL and Credentials to access it.

# Variables
MONITOR_IP=10.80.80.81                    # the IP of the local host 
CLUSTER_NETWORK_CIDR=10.80.80.0/24         # the cluster network


# execute the bootstrap operation
cephadm bootstrap --mon-ip ${MONITOR_IP} --cluster-network ${CLUSTER_NETWORK_CIDR}

# ● confirm that the "ceph" command is available
# ---------------------------------------------------------------------------------
ceph -v

# ● check Ceph status
# ---------------------------------------------------------------------------------
ceph -s
ceph health

# ● verify that Podman containers are running for each service
# ---------------------------------------------------------------------------------
podman ps

# ● to check the status of the running services
# ---------------------------------------------------------------------------------
systemctl status ceph-* --no-pager

# ● install the cluster's public SSH key to the rest of the hosts
# ---------------------------------------------------------------------------------
# SSH key is already installed on the local host (HOST-0)

ssh-copy-id -f -i /etc/ceph/ceph.pub root@HOST-1
ssh-copy-id -f -i /etc/ceph/ceph.pub root@HOST-2
# etc

# ● to run the Ceph CLI
# ---------------------------------------------------------------------------------
cephadm shell