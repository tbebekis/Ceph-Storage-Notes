# ---------------------------------------------------------------------------------
#                               OSDs
# ---------------------------------------------------------------------------------
# ● REQUIREMENT: one ceph-osd daemon per drive (disk)
#
# ● IMPORTANT 1: Do not let a storage cluster reach the full ratio before adding an OSD. 
# OSD failures that occur after the storage cluster reaches the near full ratio 
# can cause the storage cluster to exceed the full ratio. 
# Ceph blocks write access to protect the data until you resolve the storage capacity issues. 
# Do not remove OSDs without considering the impact on the full ratio first. 

# ● IMPORTANT 2: If you add drives of dissimilar size, adjust their weights accordingly. 
# When you add the OSD to the CRUSH map, consider the weight for the new OSD. 
# Hard drive capacity grows approximately 40% per year, 
# so newer OSD nodes might have larger hard drives than older nodes in the storage cluster, 
# that is, they might have a greater weight. 
#
# SEE: https://access.redhat.com/documentation/en-us/red_hat_ceph_storage/7/html-single/operations_guide/index#management-of-osds-using-the-ceph-orchestrator

#  ● WARNING
# When deploying new OSDs with cephadm, ensure that the ceph-osd package is not already installed on the target host. 
# If it is installed, conflicts may arise in the management and control of the OSD that may lead to errors or unexpected behavior.


# ● MEMORY and OSDs
# --------------------------------------------------------------------------------- 
# The OSD daemons adjust the memory consumption based on the osd_memory_target configuration option. 
# The option osd_memory_target sets OSD memory based upon the available RAM in the system.
# If Ceph Storage is deployed on dedicated nodes that do not share memory with other services, 
# cephadm automatically adjusts the per-OSD consumption based on the total amount of RAM and the number of deployed OSDs
#
# The osd_memory_target parameter is calculated as follows
# osd_memory_target = TOTAL_RAM_OF_THE_OSD * (1048576) * (autotune_memory_target_ratio) / NUMBER_OF_OSDS_IN_THE_OSD_NODE - (SPACE_ALLOCATED_FOR_OTHER_DAEMONS)
#
# By default, the osd_memory_target_autotune parameter is set to true on bootstrap, 
# with mgr/cephadm/autotune_memory_target_ratio set to .7 of total host memory.
#
# SEE: https://access.redhat.com/documentation/en-us/red_hat_ceph_storage/7/html-single/operations_guide/index#automatically-tuning-osd-memory_ops
ceph config set osd osd_memory_target_autotune true


# ● list cluster host devices (disks)
# ---------------------------------------------------------------------------------
# SEE: https://access.redhat.com/documentation/en-us/red_hat_ceph_storage/7/html-single/operations_guide/index#listing-devices-for-ceph-osd-deployment_ops

# log into cephadm shell
cephadm shell

# SYNTAX: ceph orch device ls [--hostname=HOSTNAME_1 HOSTNAME_2] [--wide] [--refresh]
ceph orch device ls

# ● deploying Ceph OSDs
# --------------------------------------------------------------------------------- 
# log into cephadm shell
cephadm shell

# to consume any available and unused storage device
# NOTE: This command creates colocated WAL and DB daemons. 
# If you want to create non-colocated daemons, do not use this command. 
ceph orch apply osd --all-available-devices

# WARNING 
# After running the above command:
#   - If you add new disks to the cluster, they will automatically be used to create new OSDs.
#   - If you remove an OSD and clean the LVM physical volume, a new OSD will be created automatically.
# If you want to avoid this behavior (disable automatic creation of OSD on available devices), use the unmanaged parameter
#
# IMPORTANT
# Keep these three facts in mind:
# - The default behavior of "ceph orch apply" causes cephadm constantly to reconcile. This means that cephadm creates OSDs as soon as new drives are detected.
# - Setting unmanaged: True disables the creation of OSDs. If unmanaged: True is set, nothing will happen even if you apply a new OSD service.
# - "ceph orch daemon add" creates OSDs, but does not add an OSD service.
ceph orch apply osd --all-available-devices --unmanaged=true

# to create an OSD from a specific device on a specific host
# SYNTAX: ceph orch daemon add osd HOSTNAME:DEVICE_PATH
ceph orch daemon add osd host1:/dev/sdb

# to create an OSD on a specific LVM logical volume on a specific host
# SYNTAX: ceph orch daemon add osd HOSTNAME:DEVICE_PATH
ceph orch daemon add osd host1:/dev/vg_osd/lvm_osd1701

# advanced OSD creation from specific devices on a specific host
# NOTE: includes db_devices flag
# NOTE: We need more information on that syntax as it deploys db_devices on NVMes
ceph orch daemon add osd host1:data_devices=/dev/sda,/dev/sdb,db_devices=/dev/sdc,osds_per_device=2

# to deploy ODSs on a raw physical device, without an LVM layer, use the --method raw option. 
# NOTE: If you have separate DB or WAL devices, the ratio of block to DB or WAL devices MUST be 1:1.    // ?????
# QUESTION: what do they mean by "raw"
ceph orch daemon add osd --method raw host02:/dev/sdb
 
# ● DRY RUN flag
# --------------------------------------------------------------------------------- 
# The --dry-run flag causes the orchestrator to present a preview of what will happen without actually creating the OSDs.

# the following
ceph orch apply osd --all-available-devices --dry-run

# results in an output as below
NAME                  HOST  DATA      DB  WAL
all-available-devices node1 /dev/vdb  -   -
all-available-devices node2 /dev/vdc  -   -
all-available-devices node3 /dev/vdd  -   -

# ● check OSD deployment
# --------------------------------------------------------------------------------- 
ceph orch ls osd                    # list the service
ceph osd tree                       # view details
ceph orch ps --service_name=osd     # list hosts, daemons, and processes

# ● remove an OSD
# --------------------------------------------------------------------------------- 
# Removing an OSD from a cluster involves two steps:
# - evacuating all placement groups (PGs) from the cluster
# - removing the PG-free OSD from the cluster
# The following command performs these two steps

# SYNTAX: ceph orch osd rm <osd_id(s)> [--replace] [--force]
ceph orch osd rm 0

# to query the status of removal operation
ceph orch osd rm status

# ● erasing OSDs (zapping)
# --------------------------------------------------------------------------------- 
# erase (zap) a device so that it can be reused. 
# zap calls "ceph-volume zap" on the remote host.

# SYNTAX: ceph orch device zap HOST_NAME DEVICE_PATH
ceph orch device zap my_hostname /dev/sdx
