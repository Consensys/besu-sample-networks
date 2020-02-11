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

. ./.env
composeFile="docker-compose_permissioning_poa"

displayUsage()
{
  echo "This script creates and start a local private Besu network using Docker."
  echo "You can select the consensus mechanism to use.\n"
  echo "Usage: ${me} [OPTIONS]"
  echo "    -e                       : setup ELK with the network."
  exit 0
}

while getopts "he" o; do
  case "${o}" in
    h)
      displayUsage
      ;;
    e)
      elk_compose="${composeFile/docker-compose/docker-compose_elk}"
      composeFile="$elk_compose"
      ;;
    *)
      displayUsage
    ;;
  esac
done

# migrate the contracts
# Onchain permissioning uses smart contracts to store and maintain the node, account, and admin whitelists.
# Using onchain permissioning enables all nodes to read the whitelists from a single source, the blockchain.
# 1. Ingress contracts for nodes and accounts - proxy contracts defined in the genesis file that defer the permissioning logic
# to the Node Rules and Account Rules contracts. The Ingress contracts are deployed to static addresses.
# 2. Node Rules - stores the node whitelist and node whitelist operations (for example, add and remove).
# 3. Account Rules - stores the accounts whitelist and account whitelist operations (for example, add and remove).
# 4. Admin - stores the list of admin accounts and admin list operations (for example, add and remove).
# There is one list of admin accounts for node and accounts.
echo "Migrating contracts..."
cd permissioning-smart-contracts
NODE_INGRESS_CONTRACT_ADDRESS="0x0000000000000000000000000000000000009999" \
 ACCOUNT_INGRESS_CONTRACT_ADDRESS="0x0000000000000000000000000000000000008888" \
  BESU_NODE_PERM_ACCOUNT="0x627306090abaB3A6e1400e9345bC60c78a8BEf57" \
   BESU_NODE_PERM_KEY="0xc87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3" \
    BESU_NODE_PERM_ENDPOINT="http://localhost:8545" \
     INITIAL_WHITELISTED_ACCOUNTS=0xfe3b557e8fb62b89f4916b721be55ceb828dbd73,0x627306090abab3a6e1400e9345bc60c78a8bef57 \
      INITIAL_WHITELISTED_NODES=enode://05e2aab6df08db103fd75c4fb2b8582fe43eebce6a0f077b590a5e7f44ed081e498fa2c57788372d7bc0c41a34394f34c5c11332f4473a1bdf83589316edc2c4@172.24.2.5:30303,enode://e64f7af088eb0c51ddfa9700dbe0e00771b26b12e8e622fdc54027b20632701d49926ad46836133fb752912569437eb6a53b6196777cb0516c96ae5a4f90cf3a@172.24.2.6:30303,enode://3548c87b9920ff16aa4bdcf01c85f25117a29ae1574d759bad48cc9463d8e9f7c3c1d1e9fb0d28e73898951f90e02714abb770fd6d22e90371882a45658800e9@172.24.2.7:30303,enode://dcb9390953aec5dde1d60dd556c36827053ca9adaefd1b03f531592fea43824bae2919743f620bb8a9b6c2b9a54439771d4f9a74d261b74af7a10c2dd9f13c97@172.24.2.8:30303,enode://3548c87b9920ff16aa4bdcf01c85f25117a29ae1574d759bad48cc9463d8e9f7c3c1d1e9fb0d28e73898951f90e02714abb770fd6d22e90371882a45658800e9@172.24.2.11:30303,enode://dcb9390953aec5dde1d60dd556c36827053ca9adaefd1b03f531592fea43824bae2919743f620bb8a9b6c2b9a54439771d4f9a74d261b74af7a10c2dd9f13c97@172.24.2.12:30303 \
        yarn truffle migrate --reset
mv build/ ../permissioning-dapp/

# run the dapp
# The Permissioning Management Dapp is provided to view and maintain the whitelists.
# 1. Accounts can submit transactions to the network
# 2. Nodes can participate in the network
# 3. Admins are accounts that can update the accounts and nodes whitelists
cd ../permissioning-dapp
docker build . -t besu-sample-network_permissioning_dapp
docker run -p 3001:80 -e BESU_NODE_PERM_ACCOUNT="0x627306090abaB3A6e1400e9345bC60c78a8BEf57" \
                      -e BESU_NODE_PERM_KEY="0xc87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3" \
                      -e BESU_NODE_PERM_ENDPOINT="http://localhost:8545" \
                      -e NODE_ENV=development --name besu-sample-network_permissioning_dapp --detach besu-sample-network_permissioning_dapp
cd ..
sleep 30

# do a restart in normal terms - here we do a start and stop with the env var PERMISSIONING_ENABLED=true
echo "Restarting the nodes to enable permissioning..."
./stop.sh
sleep 60

echo "Starting network up again..."
PERMISSIONING_ENABLED=true docker-compose -f  ${composeFile}.yml up -d bootnode
sleep 60
PERMISSIONING_ENABLED=true docker-compose -f ${composeFile}.yml up -d
