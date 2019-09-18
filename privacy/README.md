# Besu Privacy enabled Network Quickstart Tutorial

The privacy enabled Network Quickstart uses Besu and Orion
nodes managed by Docker Compose. 

## Prerequisites

To run this tutorial, you must have the following installed:

- MacOS or Linux 
    
    !!! important 
        The Private Network Quickstart is not supported on Windows. If using Windows, run the quickstart
        inside a Linux VM such as Ubuntu. 

- [Docker and Docker-compose](https://docs.docker.com/compose/install/) 

- [Git command line](https://git-scm.com/)


## Execution Process to Create a Privacy enabled Network

### Build Docker Images and Start Services and Network
`./run.sh` creates docker images for configuring a network of
Besu nodes as well as Orion nodes which include 3 nodes with privacy
enabled.
Where the node details are as follows:

Name  | Besu Node address                      | Orion node key | Node URL
----- | ---- | ---- | ---- |
node1 | 0xfe3b557e8fb62b89f4916b721be55ceb828dbd73 | A1aVtMxLCUHmBVHXoZzzBgPbW/wj5axDpW9X8l91SGo= | http://localhost:20000
node2 | 0x627306090abab3a6e1400e9345bc60c78a8bef57 | Ko2bVqD+nNlNYL5EE7y3IdOnviftjiizpjRt+HTuFBs= | http://localhost:20002
node3 | 0xf17f52151EbEF6C7334FAD080c5704D77216b732 | k2zXEin4Ip/qBGlRkJejnGWdP9cjkK+DAvKNW31L2C8= | http://localhost:20004


### Use `eeajs` to deploy contracts
#### Prerequisites
 - [Nodejs](https://nodejs.org/en/download/)
 
 Install the following after downloading `Nodejs` - 
 - [web3](https://www.npmjs.com/package/web3)
 - [axios](https://www.npmjs.com/package/axios)
  
 Clone [eeajs](https://github.com/iikirilov/eeajs) github repo. 
 
#### EventEmitter contract

After starting the docker containers, execute `node example/eventEmitter.js` in the `eeajs` project.
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

### Remove Docker Images
`./delete.sh` stops the containers and deletes all the docker images.

