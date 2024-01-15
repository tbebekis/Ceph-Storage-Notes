# ● Monitor services installation
# ---------------------------------------------------------------------------------
# log into cephadm shell
cephadm shell

# to apply monitor service to specific hosts
ceph orch apply mon --placement="HOST-0 HOST-1"

# to apply specific number of monitor services in each host
ceph orch apply mon --placement="NUMBER_OF_DAEMONS HOST-0 HOST-1"
# e.g.
ceph orch apply mon --placement="3 HOST-0 HOST-1"

# to deploy a specified total number of monitor services in the cluster
ceph orch apply mon NUMBER_OF_DAEMONS

