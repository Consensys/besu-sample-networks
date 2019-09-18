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

# write pub key for checking that network works
node_id=`hostname`

PUBLIC_KEYS_DIR=${BESU_PUBLIC_KEY_DIRECTORY:=/opt/besu/public-keys/}
GENESIS_FILE_DIR=${BESU_GENESIS_FILE_DIRECTORY:=/opt/besu/genesis/}
DATA_DIR=${BESU_DATA_DIR:=/var/lib/besu/}
GENESIS_FILE=${GENESIS_FILE_DIR}genesis.json

BESU_BINARY="/opt/besu/bin/besu $@ --data-path=${DATA_DIR}"

PUBLIC_FILES_PATH_PREFIX=${PUBLIC_KEYS_DIR}${node_id}
${BESU_BINARY} public-key export --to="${PUBLIC_FILES_PATH_PREFIX}_pubkey"

# export address to be able to add this node as a validator
raw_address=`${BESU_BINARY} public-key export-address --to="${PUBLIC_FILES_PATH_PREFIX}_address"`

# remove database as exporting public keys init the db but we don't have the right genesis yet
rm -Rf ${DATA_DIR}/database

BOOTNODE_KEY_FILE="${PUBLIC_KEYS_DIR}bootnode_pubkey"

# sleep loop to wait for the public key file to be written
while [ ! -f $BOOTNODE_KEY_FILE ]
do
  echo "waiting for bootnode key file to be written"
  sleep 1
done

# sleep loop to wait for the genesis file to be written
while [ ! -f $GENESIS_FILE ]
do
  echo "waiting for genesis file to be written"
  sleep 1
done

# get bootnode enode address
bootnode_pubkey=`sed 's/^0x//' $BOOTNODE_KEY_FILE`
boonode_ip=`getent hosts bootnode | awk '{ print $1 }'`
BOOTNODE_P2P_PORT="30303"

bootnode_enode_address="enode://${bootnode_pubkey}@${boonode_ip}:${BOOTNODE_P2P_PORT}"

# run with bootnode param
${BESU_BINARY} --bootnodes=$bootnode_enode_address --genesis-file="${GENESIS_FILE}"
