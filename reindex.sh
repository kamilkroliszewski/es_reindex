#!/bin/bash

serverHostname="$1"
source_index="$2"
dest_index="$3"

if [[ "$serverHostname" == "" ]] || [[ "$source_index" == "" ]] || [[ "$dest_index" == "" ]]; then
    echo "You did not provide some of the arguments!"
    echo "Usage:"
    echo "./reindex.sh elastic_server_hostname source_index_name destination_index_name"
    echo 
    exit 0
fi

echo 
echo "ES Reindex : Get source index mapping and delete _all and include_in_all objects from JSON"
curl -XGET "$serverHostname/$source_index/_mapping" 2> /dev/null \
    | jq -r "del(.. | objects | ._all, .include_in_all)" \
    | awk 'NR > 2 { print }' \
    | sed -e '1s/^/{/' \
    | sed -e '$ d' > /tmp/es_$dest_index.tmp

echo "ES Reindex : Create destination index with new mapping"
curl -X PUT "$serverHostname/$dest_index" -H 'Content-Type: application/json' -d @/tmp/es_$dest_index.tmp 2> /dev/null | jq -r .

echo
echo "ES Reindex : Start reindexing data from source to destination index"
curl -X POST "$serverHostname/_reindex?wait_for_completion=true" -H 'Content-Type: application/json' -d'
{
  "source": {
    "index": "'$source_index'"
  },
  "dest": {
    "index": "'$dest_index'"
  }
}
' 2>/dev/null | jq -r .

sleep 5s
echo 
echo "ES Reindex : Compare size of indices"
curl -XGET "$serverHostname/_cat/indices" 2>/dev/null | grep "$source_index\|$dest_index"

echo ""
echo "Do you want to delete old index $source_index and create alias for $dest_index? [y/n]"
read choice

if [[ "$choice" == "y" ]]; then 
    echo 
    echo "ES Reindex : Delete $source_index index"
    curl -XDELETE "$serverHostname/$source_index" 2>/dev/null | jq -r . 

    echo
    echo "ES Reindex : Create alias name $source_index for new index $dest_index"
    curl -X PUT "$serverHostname/$dest_index/_alias/$source_index" 2>/dev/null | jq -r .
fi
