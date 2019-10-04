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

me=`basename "$0"`

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
    -*|--*=|*) # unsupported flags
      echo "Error: Unsupported flag $1, try ${me} -h or ${me} --help for complete usage help." >&2
      exit 1
      ;;
  esac
done

# hack such that the DB files(created by docker) can be deleted without sudo
mkdir -p besu/data1/privateState
mkdir -p besu/data1/database
mkdir -p besu/data1/private

mkdir -p besu/data2/privateState
mkdir -p besu/data2/database
mkdir -p besu/data2/private

mkdir -p besu/data3/privateState
mkdir -p besu/data3/database
mkdir -p besu/data3/private

# Build and run containers and network
docker-compose up -d

./list.sh
