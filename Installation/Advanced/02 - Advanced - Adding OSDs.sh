# ---------------------------------------------------------------------------------
#                        Advanced OSD Service Specifications
# ---------------------------------------------------------------------------------

# https://docs.ceph.com/en/latest/cephadm/services/osd/#advanced-osd-service-specifications
# https://access.redhat.com/documentation/en-us/red_hat_ceph_storage/7/html-single/operations_guide/index#deploying-ceph-osds-using-advanced-service-specifications_ops
# https://access.redhat.com/documentation/en-us/red_hat_ceph_storage/7/html-single/operations_guide/index#advanced-service-specifications-and-filters-for-deploying-osds_ops

# Service Specifications of type "osd" are a way to describe a cluster layout, using the properties of disks. 
# Service specifications give the user an abstract way to tell Ceph which disks should turn into OSDs with which configurations, 
# without knowing the specifics of device names and paths.
# Service specifications make it possible to define a yaml or json file 
# that can be used to reduce the amount of manual work involved in creating OSDs.

# ΝΟΤΕ
# It is recommended that advanced OSD specs include the service_id field set. 
# The plain osd service with no service id is where OSDs created using "ceph orch daemon" 
# add or "ceph orch apply osd --all-available-devices" are placed. 
# Not including a service_id in your OSD spec would mix the OSDs from your spec 
# with those OSDs and potentially overwrite services specs created by cephadm to track them. 
# Newer versions of cephadm will even block creation of advanced OSD specs without the service_id present

# ● define an OSD spec
# --------------------------------------------------------------------------------- 

# file: osd_spec.yml
service_type: osd
service_id: default_drive_group  # custom name of the osd spec
placement:
  host_pattern: '*'              # which hosts to target
spec:
  data_devices:                  # the type of devices you are applying specs to
    all: true                    # a filter, check below for a full list

# mount the spec file
cephadm shell --mount osd_spec.yaml:/path/to/osd_spec.yml

# apply the YAML file
ceph orch apply -i /path/to/osd_spec.yml

# A --dry-run flag can be passed to the apply osd command to display a synopsis of the proposed layout
ceph orch apply -i /path/to/osd_spec.yml --dry-run

 
# ● define an OSD spec with NVMes
# --------------------------------------------------------------------------------- 
# enforce all rotating devices to be declared as ‘data devices’ 
# and all non-rotating devices will be used as shared_devices (wal, db)

service_type: osd
service_id: osd_spec_default
placement:
  host_pattern: '*'
spec:
  data_devices:
    rotational: 1
  db_devices:
    rotational: 0

# ● filters on OSD spec YAML files
# --------------------------------------------------------------------------------- 
# SEE: https://docs.ceph.com/en/latest/cephadm/services/osd/#filters    

# vendor 
model: disk_model_name

# or model
vendor: disk_vendor_name

# size
size: size_spec

size: '10G'         # To include disks of an exact size
size: '10G:40G'     # To include disks within a given range of size:
size: ':10G'        # To include disks that are less than or equal to 10G in size:
size: '40G:'        # To include disks equal to or greater than 40G in size:

# rotational
rotational: 1       # HDD disks
rotational: 0       # NVMe disks

# ● using specific device paths
# --------------------------------------------------------------------------------- 
# SEE: https://docs.ceph.com/en/latest/cephadm/services/osd/#dedicated-wal-db

service_type: osd
service_id: osd_using_paths
placement:
  hosts:
    - Node01
    - Node02
spec:
  data_devices:
    paths:
    - /dev/sdb
  db_devices:
    paths:
    - /dev/sdc
  wal_devices:
    paths:
    - /dev/sdd


# ● osds_per_device setting
# --------------------------------------------------------------------------------- 
# SEE: https://docs.ceph.com/en/quincy/cephadm/services/osd/#additional-options
# Number of osd daemons per “DATA” device. To fully utilize nvme devices multiple osds are required. 
# Can be used to split dual-actuator devices across 2 OSDs, by setting the option to 2.

# so we may use
service_type: osd
service_id: osd_spec_default
placement:
  host_pattern: '*'
spec:
  data_devices:
    rotational: 1
  db_devices:
    rotational: 0
osds_per_device: 2
