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

version=$QUICKSTART_VERSION
composeFile=""
if [ -f ${LOCK_FILE} ]; then
    composeFile=`sed '1q;d' ${LOCK_FILE}`
    version=`sed '2q;d' ${LOCK_FILE}`
fi

docker-compose ${composeFile} down -v
docker-compose ${composeFile} rm -sfv
docker image rm quickstart/pantheon:${version}
docker image rm quickstart/block-explorer-light:${version}
rm ${LOCK_FILE}
