#!/bin/sh

ids=`docker-compose -f docker-compose_ibft.yml ps -q`

while read -r id; do
    name=`docker inspect --format='{{.Name}}' $id`
    echo "${id:0:12} : $name"
done <<< "$ids"

# TODO display public keys and addresses for each node
