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

NO_LOCK_REQUIRED=true

. ./.env
. ./.common.sh


composeFile="-f docker-compose_privacy.yml"
PARAMS=""

displayUsage()
{
  echo "This script creates and start a local private Besu network using Docker."
  echo "You can select the consensus mechanism to use.\n"
  echo "Usage: ${me} [OPTIONS]"
  echo "    -p or --explorer-port <NUMBER>          : the port number you want to use for the endpoint
                                              mapping, otherwise default is a port
                                              automatically selected by Docker."
  echo "    -c or --consensus <ibft2|clique|ethash> : the consensus mechanism that you want to run
                                              on your network, default is ethash"
  exit 0
}

# options values and api values are not necessarily identical.
# value to use for ibft2 option as required for Besu --rpc-http-api and --rpc-ws-api
# we want to explicitely display IBFT2 in the quickstart options to prevent people from
# being confused with previous version IBFT, however the RPC API remains commons, so the name
# that's the reason of this not obvious mapping.
# variables names must be similar to the option -c|--consensus values to map.
ibft2='ibft'
clique='clique' # value to use for clique option

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)
      displayUsage
      ;;
    -p|--explorer-port)
      export EXPLORER_PORT_MAPPING="${2}:"
      shift 2
      ;;
    -c|--consensus)
      case "${2}" in
        ibft2|clique)
          export QUICKSTART_POA_NAME="${2}"
          export QUICKSTART_POA_API="${!2}"
          export QUICKSTART_VERSION="${BESU_VERSION}-${QUICKSTART_POA_NAME}"
          composeFile="-f docker-compose_privacy_poa.yml"
          ;;
        ethash)
          ;;
        *)
          echo "Error: Unsupported consensus value." >&2
          displayUsage
      esac
      shift 2
      ;;
    --) # end argument parsing
      shift
      break
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag." >&2
      displayUsage
      ;;
  esac
done

# Build and run containers and network
echo "${composeFile}" > ${LOCK_FILE}
echo "${QUICKSTART_VERSION}" >> ${LOCK_FILE}

echo "${bold}*************************************"
echo "Besu Quickstart ${QUICKSTART_VERSION}"
echo "*************************************${normal}"
echo "Start network"
echo "--------------------"

echo "Starting network..."
docker-compose ${composeFile} up -d

#list services and endpoints
./list.sh

if [[ "${QUICKSTART_POA_API:-}" == "${ibft2}" ]]; then
  echo "IBFT 2 Validator Addresses:"
  echo "----------------------------------"
  HOST=${DOCKER_PORT_2375_TCP_ADDR:-"localhost"}
  echo `curl -s -X POST --data '{"jsonrpc":"2.0","method":"ibft_getValidatorsByBlockNumber","params":["latest"],"id":1}' http://${HOST}:8545 | grep 'result' `
fi
