#!/bin/sh -e

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

me=`basename "$0"`
DEFAULT_SCALING=4
scaleNode=$DEFAULT_SCALING

PARAMS=""
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)
      echo "Usage: ${me} [OPTIONS] [PARAMS]"
      echo "    -p or --explorer-port <NUMBER>  : the port number you want to use for the endpoint
                                      mapping, otherwise default is a port automatically selected by Docker."
      echo "    -s or --scale-nodes <NUMBER>    : the quantity of regular nodes you want to run on your network,
                                      default is ${DEFAULT_SCALING}"
      exit 0
      ;;
    -p|--explorer-port)
      export EXPLORER_PORT_MAPPING="${2}:"
      shift 2
      ;;
    -s|--scale-nodes)
      scaleNode=${2}
      shift 2
      ;;
    --) # end argument parsing
      shift
      break
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1, try ${me} -h or ${me} --help for complete usage help." >&2
      exit 1
      ;;
  esac
done

# Build and run containers and network
docker-compose up -d --scale node=${scaleNode}

./list.sh
