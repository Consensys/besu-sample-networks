#!/bin/sh -x

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

PUBLIC_KEYS_DIR=${PANTHEON_PUBLIC_KEY_DIRECTORY:=/opt/pantheon/public-keys/}
GENESIS_FILE_DIR=${PANTHEON_GENESIS_FILE_DIRECTORY:=/opt/pantheon/genesis/}
DATA_DIR=${PANTHEON_DATA_DIR:=/var/lib/pantheon/}

PANTHEON_BINARY="/opt/pantheon/bin/pantheon $@ --data-path=${DATA_DIR}"

PUBLIC_KEY_FILE="${PUBLIC_KEYS_DIR}bootnode"
PUBLIC_ADDRESS_FILE="${PUBLIC_KEYS_DIR}bootnode_address"

GENESIS_TEMPLATE_FILE=${DATA_DIR}genesis.json.template
GENESIS_FILE=${GENESIS_FILE_DIR}genesis.json

# write pub key for making other nodes able to connect to bootnode
${PANTHEON_BINARY} public-key export --to="${PUBLIC_KEY_FILE}"

# get address for genesis
raw_address=`${PANTHEON_BINARY} public-key export-address --to="${PUBLIC_ADDRESS_FILE}"`
bootnode_address=`sed 's/^0x//' ${PUBLIC_ADDRESS_FILE}`

addressJsonToEncode="[\"${bootnode_address}\"]"
rlp=`echo ${addressJsonToEncode} | ${PANTHEON_BINARY} rlp encode`
sedCommand="s/<RLP_EXTRA_DATA>/${rlp}/g"
sed ${sedCommand} ${GENESIS_TEMPLATE_FILE} > ${GENESIS_FILE}

# remove database as exporting public keys init the db but we don't have the right genesis yet
rm -Rf ${DATA_DIR}/database

# run bootnode with discovery but no bootnodes as it's our bootnode.
${PANTHEON_BINARY} --genesis-file="${GENESIS_FILE}"
