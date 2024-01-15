
# ● remove a Ceph cluster
# ---------------------------------------------------------------------------------

# disable cephadm to stop all the orchestration operations to avoid deploying new daemons
ceph mgr module disable cephadm

# get the FSID of the cluster
ceph fsid

# purge the Ceph daemons from all hosts in the cluster
cephadm rm-cluster --force --zap-osds  --fsid FSID_FROM_PREVIOUS_STEP