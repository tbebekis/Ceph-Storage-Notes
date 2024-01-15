# ● drain a host
# ---------------------------------------------------------------------------------
# A host can safely be removed from the cluster after all daemons are removed from it.
#
# The _no_schedule and _no_conf_keyring labels will be applied to the host
# SEE: https://docs.ceph.com/en/latest/cephadm/host-management/#cephadm-special-host-labels

# drain all daemons from a host
ceph orch host drain HOST-5

# If you only want to drain daemons but leave managed ceph conf and keyring files on the host, 
# you may pass the --keep-conf-keyring flag to the drain command.
# This will apply the _no_schedule label to the host but not the _no_conf_keyring label.
ceph orch host drain HOST-5 --keep-conf-keyring

# The "orch host drain" command also supports a --zap-osd-devices flag. 
# Setting this flag while draining a host will cause cephadm 
# to zap the devices of the OSDs it is removing as part of the drain process
ceph orch host drain HOST-5 --zap-osd-devices

# ● check whether any daemons are still on the host
# ---------------------------------------------------------------------------------
ceph orch ps HOST-5

# ● check OSD removal status
# ---------------------------------------------------------------------------------
# after draining a host all OSDs on the host will be scheduled to be removed. 
# check the progress of the OSD removal operation
ceph orch osd rm status

# ● remove a host
# ---------------------------------------------------------------------------------
# After all daemons have been removed from the host, remove the host from the cluster
ceph orch host rm HOST-5
