#!/bin/sh -e

me=`basename "$0"`

txHash=""
orionPubKey=""
httpEndpoint=""
if [[ $# != 6 ]]
then
  echo "Unsupported flags, use -h|--help for complete usage"
  exit 0
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      echo "Usage: ${me}"
      echo "    -txHash : the transaction hash returned by executing a transaction"
      echo "    -orionPubKey : the public key with which Orion was started"
      echo "    -httpEndpoint : the HTTP service endpoint of node"
      exit 0
      ;;
    -txHash)
      txHash="${2}"
      shift 2
      ;;
    -orionPubKey)
      orionPubKey="${2}"
      shift 2
      ;;
    -httpEndpoint)
      httpEndpoint="${2}"
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

curl -X POST --data '{"jsonrpc":"2.0","method":"eea_getTransactionReceipt","params":["'${txHash}'", "'${orionPubKey}'"],"id":1}' ${httpEndpoint}
