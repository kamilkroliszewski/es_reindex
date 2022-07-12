#!/bin/bash

# change replica count from 0 to 1 but gracefully, waiting for cluster status to be green

serverName="127.0.0.1:9200"

while :; do
echo "Waiting for status change..."
    while [ "$(curl -XGET '$serverName/_cluster/health' 2>/dev/null | jq -r .status)" == "green" ]; do
        index=$(curl -XGET '$serverName/_cat/indices?bytes=b' 2>/dev/null | grep business | sort -n -k9 | awk '$6 == 0 { print $0 }' | awk '{print $3}' | head -n1)
        echo "Changing replica of $index ..."
        curl -X PUT "$serverName:9200/$index/_settings?pretty" -H 'Content-Type: application/json' -d'{"index" : {"number_of_replicas" : 1}}'
        echo
        sleep 1s
    done
sleep 1s
done
