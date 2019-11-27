For complete and up-to-date documentation, please see [Docker quick-start, on the Besu documentation site](https://besu.hyperledger.org/Tutorials/Quickstarts/Private-Network-Quickstart/).


curl -X POST "http://10.57.5.245:32773/kibana/api/saved_objects/index-pattern/besu" -H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d'
{
  "attributes": {
    "title": "besu-*",
    "timeFieldName": "@timestamp"
  }
}
'
