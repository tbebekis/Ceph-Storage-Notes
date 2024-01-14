
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

# ● Manager services installation
# ---------------------------------------------------------------------------------
# The Ceph Orchestrator deploys two Manager daemons by default. 
# NOTE: Ensure your deployment has at least 3 Ceph Managers in each deployment. 
#
# You can deploy additional manager daemons using the placement specification in the CLI. 
# To deploy a different number of Manager daemons, specify a different number. 
# If you do not specify the hosts where the Manager daemons should be deployed, 
# the Ceph Orchestrator randomly selects the hosts and deploys the Manager daemons to them. 

# log into cephadm shell
cephadm shell

ceph orch apply mgr --placement="HOST-0 HOST-1" 
ceph orch apply mgr NUMBER_OF_DAEMONS