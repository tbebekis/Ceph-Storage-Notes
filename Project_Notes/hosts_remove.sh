#!/bin/bash

hosts=( `ceph orch host ls --format json-pretty | jq -r '.[].hostname'` )
for host in "${hosts[@]}"
do
    ceph orch host rm ${host} --force
done