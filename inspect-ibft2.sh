#!/bin/bash -u

# Copyright 2018 ConsenSys AG.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
# the License. You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
# an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.

NO_LOCK_REQUIRED=false

. ./.env
. ./.common.sh

if [[ ${version} != *"ibft"* ]]; then
  echo "Quickstart is not running an IBFT 2 network." >&2
  echo "Run it with ./run.sh -c ibft2" >&2
  exit 1
fi

echo "${bold}*************************************"
echo "Besu Quickstart ${version}"
echo "*************************************${normal}"
echo "List IBFT 2 nodes information"
echo "----------------------------------"

containerIds=`docker-compose ${composeFile} ps -q`
explorerMapping=`docker-compose ${composeFile} port explorer 80`
HOST=${DOCKER_PORT_2375_TCP_ADDR:-"localhost"}
rpcNodeHttpEndpoint="http://${HOST}:${explorerMapping##*:}/jsonrpc"

containerCount=`grep -c "" <<< "${containerIds}"`

# retrieve list of node addresses
addressFilesWaitCommand="counter=0; while [ \$(ls -1 /tmp/keys/*_address 2>/dev/null | wc -l 2>/dev/null) -lt ${containerCount} ] && [ \"\$counter\" -lt \"30\" ];do sleep 1; printf '.' >&2; let \"counter++\"; done;"
addressRetrievalCommand="grep \"0x\" /tmp/keys/*_address 2>/dev/null"
addressList=`docker run --rm -v ${current_dir}_public-keys:/tmp/keys alpine:3.4 /bin/sh -c "${addressFilesWaitCommand} ${addressRetrievalCommand}"`

if [ -z "${addressList}" ]; then
  echo "Nodes addresses not yet available, please try again later."
  exit 1
else
  echo "Nodes addresses found."
fi

# retrieve validators list
validatorList=`curl -s -X POST --data '{"jsonrpc":"2.0","method":"ibft_getValidatorsByBlockNumber","params":["latest"],"id":1}' ${rpcNodeHttpEndpoint} | grep 'result'`

while read -r containerId; do

    shortId="${containerId:0:12}"

    nodeAddress=`grep "${shortId}"  <<< "${addressList}" | grep -oE '0x.*$'`

    if [ -n "${nodeAddress}" ]; then

      containerName=`docker inspect --format='{{.Name}}' ${containerId}`
      projectName=`docker inspect --format='{{index .Config.Labels "com.docker.compose.project"}}' ${containerId}`
      nodeName=`docker inspect --format='{{index .Config.Labels "com.docker.compose.service"}}' ${containerId}`
      nodeNumber=`docker inspect --format='{{index .Config.Labels "com.docker.compose.container-number"}}' ${containerId}`
      nodeInstances=`docker-compose ${composeFile} ps | grep -c "${projectName}_${nodeName}_"`

      #scaling check
      if [ "${nodeInstances}" -gt 1 ]; then
        nodeFullName=${projectName}_${nodeName}_${nodeNumber}
        scaled="yes (${nodeNumber}/${nodeInstances})"
      else
        scaled="no"
        nodeFullName=${nodeName}
      fi

      #validator check
      grep "${nodeAddress}"  <<< "${validatorList}" >/dev/null
      if [ "$?" = "0" ];then
        isValidator="yes"
      else
        isValidator="no"
      fi

      httpEndpoint="http://${HOST}:${explorerMapping##*:}/${nodeFullName}/jsonrpc"
      wsEndpoint="ws://${HOST}:${explorerMapping##*:}/${nodeFullName}/jsonws"

      echo "${bold}Node container name/id : ${nodeFullName} / ${shortId}${normal}"
      echo "Scaled node : ${scaled}"
      echo "Validator : ${isValidator}"
      echo "Node address : ${nodeAddress}"
      echo "JSON-RPC HTTP service endpoint      : ${httpEndpoint}"
      echo "JSON-RPC WebSocket service endpoint : ${wsEndpoint}"
      echo "---------------------------------"
    fi
done <<< "${containerIds}"
