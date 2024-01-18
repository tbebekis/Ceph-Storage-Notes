# ● SSH key
# ---------------------------------------------------------------------------------
# install the cluster’s public SSH key in the new host’s root user’s authorized_keys file
ssh-copy-id -f -i /etc/ceph/ceph.pub root@HOST-1
ssh-copy-id -f -i /etc/ceph/ceph.pub root@HOST-2
# etc

# ● add the rest of the hosts to the cluster (HOST-0 is added by the bootstrap operation)
# ---------------------------------------------------------------------------------
# it is best to explicitly provide the host IP address. 
# If an IP is not provided, then the host name will be immediately resolved via DNS and that IP will be used.
# NOTE: cephadm demands that the name of the host given via "ceph orch host add" equals the output of hostname on remote hosts.
ceph orch host add HOST-1 IP_ADDRESS
ceph orch host add HOST-2 IP_ADDRESS
# etc

# one or more labels can also be included to immediately label the new host. 
# For example, by default the _admin label will make cephadm maintain a copy of the ceph.conf file 
# and a client.admin keyring file in /etc/ceph
# NOTE: more on labels below
# SEE: https://docs.ceph.com/en/latest/cephadm/host-management/#host-labels
ceph orch host add HOST-1 IP_ADDRESS --labels _admin
ceph orch host add HOST-2 IP_ADDRESS --labels LABEL_1,LABEL_2
# etc

# ● apply labels to hosts
# ---------------------------------------------------------------------------------
# some labels have special meaning to cephadm and they begin with _
# by default, the _admin label is applied to the bootstrapped host
#
# custom labels usually used: mgr, mon, and osd
# 
# SEE: https://docs.ceph.com/en/latest/cephadm/host-management/#cephadm-special-host-labels
# SEE: https://access.redhat.com/documentation/en-us/red_hat_ceph_storage/7/html-single/operations_guide/index#adding-labels-to-hosts-using-the-ceph-orchestrator_ops

# log into cephadm shell
cephadm shell

# apply the label
ceph orch host label add HOST_NAME LABEL_NAME

# ● list cluster hosts
# ---------------------------------------------------------------------------------
# SYNTAX: ceph orch host ls [--format yaml] [--host-pattern <name>] [--label <label>] [--host-status <status>] [--detail]
ceph orch host ls --detail

