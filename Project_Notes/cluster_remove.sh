#!/bin/bash

# RUN: on admin host
# disable cephadm to stop all the orchestration operations to avoid deploying new daemons
ceph mgr module disable cephadm

# RUN: on all hosts
# get the FSID of the cluster
# and then purge the Ceph daemons from all hosts in the cluster
cephadm rm-cluster --fsid $(cephadm ls | jq -r '.[0].fsid') --force --zap-osds


cephadm ls