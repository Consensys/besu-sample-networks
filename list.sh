#!/bin/bash -eu

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

EXPLORER_SERVICE=explorer
HOST=${DOCKER_PORT_2375_TCP_ADDR:-"localhost"}

# Displays links to exposed services
echo "${bold}*************************************"
echo "Besu Quickstart ${version}"
echo "*************************************${normal}"
echo "List endpoints and services"
echo "----------------------------------"

# Displays services list with port mapping
docker-compose ps

# Get individual port mapping for exposed services
explorerMapping=`docker-compose port explorer 80`

dots=""
maxRetryCount=50
while [ "$(curl -m 1 -s -o /dev/null -w ''%{http_code}'' http://${HOST}:${explorerMapping##*:})" != "200" ] && [ ${#dots} -le ${maxRetryCount} ]
do
  dots=$dots"."
  printf "Block explorer is starting, please wait $dots\\r"
  sleep 1
done

echo "****************************************************************"
if [ ${#dots} -gt ${maxRetryCount} ]; then
  echo "ERROR: Web block explorer is not started at http://${HOST}:${explorerMapping##*:}$ !"
  echo "****************************************************************"
else
  echo "JSON-RPC HTTP service endpoint      : http://${HOST}:${explorerMapping##*:}/jsonrpc"
  echo "JSON-RPC WebSocket service endpoint : ws://${HOST}:${explorerMapping##*:}/jsonws"
  echo "GraphQL HTTP service endpoint       : http://${HOST}:${explorerMapping##*:}/graphql"
  echo "Web block explorer address          : http://${HOST}:${explorerMapping##*:}"
  echo "Prometheus address                  : http://${HOST}:${explorerMapping##*:}/prometheus/graph"
  echo "Grafana address                     : http://${HOST}:${explorerMapping##*:}/grafana-dashboard"
  echo "****************************************************************"
fi
