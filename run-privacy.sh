#!/bin/bash -e

# Copyright 2019 ConsenSys AG.
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
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)
      echo "Usage: ${me} [OPTIONS] [PARAMS]"
      echo "    -p or --explorer-port <NUMBER>  : the port number you want to use for the endpoint
                                      mapping, otherwise default is a port automatically selected by Docker."
      exit 0
      ;;
    -p|--explorer-port)
      export EXPLORER_PORT_MAPPING="${2}:"
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

# Build and run containers and network
echo "Starting network..."
docker-compose ${composeFile} up -d

./list.sh
