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

echo "${bold}*************************************"
echo "Besu Quickstart ${version}"
echo "*************************************${normal}"
echo "Stop and remove network..."
docker-compose ${composeFile} down -v
docker-compose ${composeFile} rm -sfv

docker image rm quickstart/besu:${version}
docker image rm quickstart/block-explorer-light:${version}
docker image rm besu-quickstart_filebeat
docker image rm besu-quickstart_logstash
docker image rm besu-quickstart_elasticsearch

rm ${LOCK_FILE}
echo "Lock file ${LOCK_FILE} removed"
