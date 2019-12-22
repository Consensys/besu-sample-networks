# Quickstart

## Prerequisites

To run this tutorial, you must have the following installed:

- MacOS or Linux 
   
    !!! important 
        The Private Network Quickstart is not supported on Windows. If using Windows, run the quickstart
        inside a Linux VM such as Ubuntu. 

- [Docker and Docker-compose](https://docs.docker.com/compose/install/) 

| ⚠️ **Note**: If on MacOS, please ensure that you allow docker to use upto 4G of memory under the _Resources_ section. The docker [site](https://docs.docker.com/docker-for-mac/) has details on how to do this |
| --- |


## For Blockchain quickstarts without privacy (orion):
For complete and up-to-date documentation, please see [Docker quick-start, on the Besu documentation site](https://besu.hyperledger.org/Tutorials/Quickstarts/Private-Network-Quickstart/).

## For Blockchain quickstarts with privacy (orion):

`./run-privacy.sh` creates docker images for configuring a network of
Besu nodes as well as Orion nodes which include 3 nodes with privacy
enabled.
Where the node details are as follows:

Name  | Besu Node address                      | Orion node key | Node URL
----- | ---- | ---- | ---- |
node1 | 0x866b0df7138daf807300ed9204de733c1eb6d600 | 9QHwUJ6uK+FuQMzFSXIo7wOLCGFZa0PiF771OLX5c1o= | http://localhost:20000
node2 | 0xa46f0935de4176ffeccdeecaf3c6e3ca03e31b22 | qVDsbJh2UluZOePxbXAL49g0S0s2gGlJ3ftQceMlchU= | http://localhost:20002
node3 | 0x998c8bc11c28b667e4b1930c3fe3c9ab1cde3c52 | T1ItOQxwgY1pTW6YXb2EbKXYkK4saBEys3CfJ2OIKHs= | http://localhost:20004


### Use `eeajs` to deploy contracts
#### Prerequisites
 - [Nodejs](https://nodejs.org/en/download/)
 
 Install the following after downloading `Nodejs` - 
 - [web3](https://www.npmjs.com/package/web3)
 - [axios](https://www.npmjs.com/package/axios)
  
 Clone [eeajs](https://github.com/PegaSysEng/web3js-eea) github repo. 
 
#### EventEmitter contract

After the containers from above have started, execute `node example/eventEmitter.js` in the `web3js-eea` project that you have just cloned
This deploys the `EventEmitter` contract, sets a value of `1000` and gets the value.

It can be verified from the output of the last transaction - `0x00000000000000000000000000000000000000000000000000000000000003e8`
which is the hex value of `1000`.

#### ERC20 token

Executing `node example/erc20.js` deploys a `HumanStandardToken` contract and transfers 1 token to node2.

This can be verified from the `data` field of the `logs` which is `1`.

### Stop Services and Network
`./stop.sh` stops all the docker containers created.

### Remove stopped containers and volumes 
`./remove.sh` stops and removes all the containers and volumes. 


