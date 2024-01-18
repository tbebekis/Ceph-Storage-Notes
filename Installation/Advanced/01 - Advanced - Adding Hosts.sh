# ● add many hosts at once
# ---------------------------------------------------------------------------------
# SEE: https://docs.ceph.com/en/latest/cephadm/host-management/#creating-many-hosts-at-once
# SEE: https://access.redhat.com/documentation/en-us/red_hat_ceph_storage/7/html-single/operations_guide/index#adding-multiple-hosts-using-the-ceph-orchestrator_ops

# Many hosts can be added at once using "ceph orch apply -i" by submitting a multi-document YAML file.

# file: hosts.yaml
service_type: host
hostname: node-00
addr: 192.168.0.10
labels:
- example1
- example2
---
service_type: host
hostname: node-01
addr: 192.168.0.11
labels:
- grafana
---
service_type: host
hostname: node-02
addr: 192.168.0.12

# mount the file
cephadm shell --mount hosts.yaml:/path/to/hosts.yaml

# cd to that folder
cd /path/to/hosts_file/

# apply
ceph orch apply -i hosts.yaml

# This can be combined with service specifications to create a cluster spec file to deploy a whole cluster in one command. 
# see "cephadm bootstrap --apply-spec" also to do this during bootstrap. 
# Cluster SSH Keys must be copied to hosts prior to adding them.

service_type: host
addr: host01
hostname: host01
---
service_type: host
addr: host02
hostname: host02
---
service_type: host
addr: host03
hostname: host03
---
service_type: host
addr: host04
hostname: host04
---
service_type: mon
placement:
  host_pattern: "host[0-2]"
---
service_type: osd
service_id: my_osds
placement:
  host_pattern: "host[1-3]"
data_devices:
  all: true
