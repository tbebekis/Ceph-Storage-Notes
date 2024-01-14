# ● add the rest of the hosts to the cluster (HOST-0 is added by the bootstrap operation)
# ---------------------------------------------------------------------------------
ceph orch host add HOST-1 IP_ADDRESS
ceph orch host add HOST-2 IP_ADDRESS
# etc

# ● list cluster hosts
# ---------------------------------------------------------------------------------
ceph orch host ls

# ● apply labels to hosts
# ---------------------------------------------------------------------------------
# some labels have special meaning to cephadm and they begin with _
# by default, the _admin label is applied to the bootstrapped host
#
# custom labels usually used: mgr, mon, and osd
# 
# SEE: https://access.redhat.com/documentation/en-us/red_hat_ceph_storage/7/html-single/operations_guide/index#adding-labels-to-hosts-using-the-ceph-orchestrator_ops

# log into cephadm shell
cephadm shell

# apply the label
ceph orch host label add HOST_NAME LABEL_NAME