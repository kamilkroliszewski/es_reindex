# es_reindex
Reindex indices created in Elasticsearch 5.6 to 6.x

# Usage
```
$ chmod +x reindex.sh
$ ./reindex.sh elastic_server_hostname source_index_name destination_index_name
```

|Parameter|Description|
|---------|-----------|
| `elastic_server_hostname` | Address of your Elasticsearch server, ex. http://localhost:9200 |
| `source_index_name` | Name of the source index |
| `destination_index_name` | Name of the destination index |

# Prerequisites
This project needs `curl` and `jq` installed, please refer to your Linux distro documentation on how to install those packages.
