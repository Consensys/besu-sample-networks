#!/bin/sh

echo "---------------------------------"
echo "Quickstart containers information"
echo "---------------------------------"

composeFile="-f docker-compose_ibft.yml"

containerIds=`docker-compose ${composeFile} ps -q`
explorerMapping=`docker-compose ${composeFile} port explorer 80`
HOST=${DOCKER_PORT_2375_TCP_ADDR:-"localhost"}

keysAndAddresses=`docker run --rm -v pantheon-quickstart_public-keys:/tmp/keys perl:slim /bin/sh -c "grep '0x' /tmp/keys/* 2>/dev/null"`

while read -r containerId; do

    keyAndAddress=`grep "${containerId:0:12}"  <<< "${keysAndAddresses}" | grep -oE '_(address:0x.*$)' | sed 's/_//' | sed 's/:/ : /'`


    if [ -n "${keyAndAddress}" ]; then

      containerName=`docker inspect --format='{{.Name}}' ${containerId}`
      projectName=`docker inspect --format='{{index .Config.Labels "com.docker.compose.project"}}' ${containerId}`
      nodeName=`docker inspect --format='{{index .Config.Labels "com.docker.compose.service"}}' ${containerId}`
      nodeNumber=`docker inspect --format='{{index .Config.Labels "com.docker.compose.container-number"}}' ${containerId}`
      nodeInstances=`docker-compose ${composeFile} ps | grep -c "${projectName}_${nodeName}_"`

      if [ "${nodeInstances}" -gt 1 ]; then
        nodeFullName=${projectName}_${nodeName}_${nodeNumber}
        scaled="(scaled ${nodeInstances} times)"
      else
        scaled=""
        nodeFullName=${nodeName}
      fi
      echo "${nodeFullName} (${containerId:0:12}) ${scaled}"
      echo "${keyAndAddress}"
      echo "JSON-RPC HTTP service endpoint      : http://${HOST}:${explorerMapping##*:}/${nodeFullName}/jsonrpc"
      echo "JSON-RPC WebSocket service endpoint : ws://${HOST}:${explorerMapping##*:}/${nodeFullName}/jsonws"
      echo "---------------------------------"
    fi
done <<< "${containerIds}"
