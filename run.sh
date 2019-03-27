#!/bin/sh

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

. ./.env

NO_LOCK_REQUIRED=true
. .common.sh

DEFAULT_SCALING=4
scaleNode=$DEFAULT_SCALING
composeFile=""

PARAMS=""

displayUsage()
{
  echo "${bold}*************************"
  echo "Pantheon Quickstart usage"
  echo "*************************${normal}"
  echo "This script creates and start a local private Pantheon network using Docker."
  echo "You can scale the number of nodes and select the consensus mechanism to use.\n"
  echo "Usage: ${me} [OPTIONS]"
  echo "    -p or --explorer-port <NUMBER>          : the port number you want to use for the endpoint
                                              mapping, otherwise default is a port
                                              automatically selected by Docker."
  echo "    -s or --scale-nodes <NUMBER>            : the quantity of regular nodes you want to run
                                              on your network, default is ${DEFAULT_SCALING}"
  echo "    -c or --consensus <ibft2|clique|ethash> : the consensus mechanism that you want to run
                                              on your network, default is ethash"
  exit 0
}

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)
      displayUsage
      ;;
    -p|--explorer-port)
      export EXPLORER_PORT_MAPPING="${2}:"
      shift 2
      ;;
    -s|--scale-nodes)
      scaleNode=${2}
      shift 2
      ;;
    -c|--consensus)
      case "${2}" in
        ibft2|clique)
          # options values and api values are not necessarily identical.
          ibft2=ibft # value to use for ibft2 option
          clique=clique # value to use for clique option
          export QUICKSTART_POA_NAME="${2}"
          export QUICKSTART_POA_API="${!2}"
          export QUICKSTART_VERSION="${PANTHEON_VERSION}-${QUICKSTART_POA_NAME}"
          composeFile="-f docker-compose_poa.yml"
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
echo "scale:${scaleNode}" >> ${LOCK_FILE}

echo "${bold}*************************************"
echo "Pantheon Quickstart ${QUICKSTART_VERSION}"
echo "*************************************${normal}"
echo "Start network"
echo "--------------------"


docker-compose ${composeFile} up -d --scale node=${scaleNode}

#list services and endpoints
./list.sh
#list individual nodes endpoints in case we run a PoA network
if [[ ${composeFile} == *"poa"* ]]; then
  ./inspect-poa.sh
fi
