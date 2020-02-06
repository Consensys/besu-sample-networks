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

removeDockerImage(){
  if [[ ! -z `docker ps -a | grep $1` ]]; then
    docker image rm $1
  fi
}

echo "${bold}*************************************"
echo "Besu Quickstart ${version}"
echo "*************************************${normal}"
echo "Stop and remove network..."
docker-compose ${composeFile} down -v
docker-compose ${composeFile} rm -sfv
if [[ ! -z `docker ps -a | grep besu-quickstart_permissioning_dapp` ]]; then
  docker stop besu-quickstart_permissioning_dapp
  docker rm besu-quickstart_permissioning_dapp
  removeDockerImage besu-quickstart_permissioning_dapp
fi
if [[ ! -z `docker ps -a | grep besu-quickstart_pet_shop` ]]; then
  docker stop besu-quickstart_pet_shop
  docker rm besu-quickstart_pet_shop
  removeDockerImage besu-quickstart_pet_shop
fi
rm -rf permissioning-dapp/build
rm -rf permissioning-smart-contracts

docker image rm quickstart/besu:${version}
docker image rm quickstart/block-explorer-light:${version}
removeDockerImage besu-quickstart_filebeat
removeDockerImage besu-quickstart_logstash
removeDockerImage besu-quickstart_elasticsearch
removeDockerImage besu-quickstart_permissioning_dapp
rm ${LOCK_FILE}
echo "Lock file ${LOCK_FILE} removed"

# clean up permissioning data volumes if present
if [[ -d config/besu/networkFiles/bootnode/data/database ]]; then
  #cleanup old data mounts
  folders=(bootnode rpcnode node1 node2 node3 node4 node5)
  for i in "${folders[@]}"
  do
    sudo rm -rf config/besu/networkFiles/$i/data/*
  done
fi
