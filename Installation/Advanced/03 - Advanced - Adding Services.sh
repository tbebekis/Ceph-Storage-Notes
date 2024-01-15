# ● Services and Deamons
# --------------------------------------------------------------------------------- 
# A service is a group of daemons configured together.
# A daemon is a systemd unit that is running, and it is part of a service.

# ● service status
# --------------------------------------------------------------------------------- 
# SYNTAX: ceph orch ls [--service_type type] [--service_name name] [--export] [--format f] [--refresh]
# --service_type : a Ceph service (mon, crash, mds, mgr, osd or rbd-mirror), 
#                  a gateway (nfs or rgw), part of the monitoring stack (alertmanager, grafana, node-exporter or prometheus) 
#                  or (container) for custom containers
# --service_name : not sure, perhaps the service_id as it is passed with the specs YAML file.
# --export       : exports service specification in a YAML file and that yaml can be used with the "ceph orch apply -i" command

ceph orch ls --service_type osd --export > osds.yaml

# ● daemon status
# --------------------------------------------------------------------------------- 
# SYNTAX: ceph orch ps [--hostname host] [--daemon_type type] [--service_name name] [--daemon_id id] [--format f] [--refresh]

# list all daemons
ceph orch ps

# check the status of a specified daemon
ceph orch ps --daemon_type osd --daemon_id 0

# ● service specification file
# --------------------------------------------------------------------------------- 
# SEE: https://docs.ceph.com/en/latest/cephadm/services/#service-specification
# A Service Specification is a data structure (and YAML file) that is used to specify the deployment of services.

# example YAML file
service_type: rgw
service_id: user_defined_service_name
placement:
  hosts:
    - host1
    - host2
    - host3
config:
  param_1: val_1
  ...
  param_N: val_N
unmanaged: false
networks:
- 192.169.142.0/24
spec:
  # Additional service specific attributes.

# IMPORTANT
# the "service_type" section denotes the Service Type
# the "placement" section defines the the number of Daemons (corresponding to hosts)
# the "unmanaged" section defines the automatic management of daemons and MUST be false
# because unmanaged=True disables the automatic management of dameons.


# in the config section the user can set initial values of service configuration parameters. 
# For each param/value configuration pair, cephadm calls the following command to set its value:
ceph config set <service-name> <param> <value>

# ● Service Specification health warnings
# --------------------------------------------------------------------------------- 
# cephadm raises health warnings in case 
# invalid configuration parameters are found in the spec (CEPHADM_INVALID_CONFIG_OPTION) 
# or if any error while trying to apply the new configuration option(s) (CEPHADM_FAILED_SET_OPTION).

 
# ● exporting the running Service Specification
# --------------------------------------------------------------------------------- 
# If the services have been started via "ceph orch apply...", 
# then directly changing the Services Specification is complicated. 
# Instead of attempting to directly change the Services Specification, 
# export the running Service Specification.
ceph orch ls --export > cluster.yaml

# The Specification can then be changed and re-applied
ceph orch apply -i cluster.yaml

# ● procedure for updating a single Service Specification
# --------------------------------------------------------------------------------- 
# export to file
ceph orch ls --service_name=<service-name> --export > myservice.yaml

# edit with vi or nano etc.

# re-apply
ceph orch apply -i myservice.yaml [--dry-run]

# ● WARNING
# ---------------------------------------------------------------------------------
# prefer to use a Service Specification YAML file instead of directly calling 
ceph orch apply SERVICE_TYPE HOST_NAME

# the following results with a single Monitor service deployed in host3
ceph orch apply mon host1
ceph orch apply mon host2
ceph orch apply mon host3

# the following results with a 3 Monitor services deployed, one in each specified host
ceph orch apply mon "host1,host2,host3"

# the last command is like having a YAML file as
service_type: mon
placement:
  hosts:
   - host1
   - host2
   - host3


# ● daemon placement can be configured... 
# ---------------------------------------------------------------------------------

# based on host labels
service_type: prometheus
placement:
  label: "mylabel"   

# based on host names
service_type: prometheus
placement:
  host_pattern: "myhost[1-3]"  

# on all hosts
service_type: node-exporter
placement:
  host_pattern: "*"  

# specifying the max number of daemons
service_type: prometheus
placement:
  count: 3  

# or
service_type: prometheus
placement:
  count: 2
  hosts:
    - host1
    - host2
    - host3 

# ● multiple daemons on the same host
# ---------------------------------------------------------------------------------
# The main reason for deploying multiple daemons per host is 
# an additional performance benefit for running multiple RGW and MDS daemons on the same host.

service_type: rgw
placement:
  label: rgw
  count_per_host: 2