# Pantheon Privacy enabled Network Quickstart Tutorial

The privacy enabled Network Quickstart uses Pantheon and Orion
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
Pantheon nodes as well as Orion nodes which include 3 nodes with privacy
enabled.
Where the node details are as follows:

Name  | Pantheon Node address                      | Orion node key | Node URL
----- | ---- | ---- | ---- |
node1 | 0xfe3b557e8fb62b89f4916b721be55ceb828dbd73 | A1aVtMxLCUHmBVHXoZzzBgPbW/wj5axDpW9X8l91SGo= | http://localhost:20000
node2 | 0x627306090abab3a6e1400e9345bc60c78a8bef57 | Ko2bVqD+nNlNYL5EE7y3IdOnviftjiizpjRt+HTuFBs= | http://localhost:20002
node3 | 0xf17f52151EbEF6C7334FAD080c5704D77216b732 | k2zXEin4Ip/qBGlRkJejnGWdP9cjkK+DAvKNW31L2C8= | http://localhost:20004


### Using `eeajs` to deploy contracts
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

### Using Hardcoded scripts

We need RLP-encoded signed transactions to perform
`eea_sendRawTransaction`. Currently, we have hardcoded the 3
transactions to verify the working of the private network. 

All the scripts are a part of the `scripts` folder:
- `create_contract.sh` 
- `set_value.sh` 
- `get_value.sh`

These scripts can be executed only once and in the given order for each time we start the containers. 
The execute them again we need to `./stop.sh` and `./remove.sh` and restart the docker containers. 

The transaction receipts of the corresponding transaction can be viewed by executing `get_receipt.sh` with
the correct parameters as explained later. 


#### Create and Deploy the Contract
`./scripts/create_contract.sh` deploys the EventEmitter Smart Contract by
calling eea_sendRawTransaction using as a parameter the given
RLP-encoded signed transaction. We are creating the contract using credentials of `node1`.
This contract is private to `node1` and `node2`.

Example:
`./scripts/create_contract.sh`

Sample Output:
```bash
{
  "jsonrpc" : "2.0",
  "id" : 1,
  "result" : "0x36b1fff467c4793bf0afa2d2571486f7faa07830f03f1e534a0ed39189fa05cb"
}
```


#### Change the Value in the Contract
`./scripts/set_value.sh` sets value to the contract deployed. We are calling the `store` function 
of the `EventEmitter` contract from `node2` and setting the value of 1000.

The transaction receipt will contain the `logs` field which will contain the value stored. 

Example:
`./scripts/set_value.sh`

Sample Output:
```bash
{
  "jsonrpc" : "2.0",
  "id" : 1,
  "result" : "0xee7df3b27c3824c5f451997c43eaec3582f708e17290a182643ee320ac211d72"
}
```

`./scripts/get_receipt.sh --transactionHash 0xee7df3b27c3824c5f451997c43eaec3582f708e17290a182643ee320ac211d72 --httpNodeEndpoint http://localhost:20002`

Sample Output:
```bash
{
  "jsonrpc" : "2.0",
  "id" : 1,
  "result" : {
    "contractAddress" : null,
    "from" : "0x627306090abab3a6e1400e9345bc60c78a8bef57",
    "to" : "0x2f351161a80d74047316899342eedc606b13f9f8",
    "output" : "0x",
    "logs" : [ {
      "address" : "0x2f351161a80d74047316899342eedc606b13f9f8",
      "topics" : [ "0xc9db20adedc6cf2b5d25252b101ab03e124902a73fcb12b753f3d1aaa2d8f9f5" ],
      "data" : "0x000000000000000000000000627306090abab3a6e1400e9345bc60c78a8bef5700000000000000000000000000000000000000000000000000000000000003e8",
      "blockNumber" : "0xd5",
      "transactionHash" : "0xee7df3b27c3824c5f451997c43eaec3582f708e17290a182643ee320ac211d72",
      "transactionIndex" : "0x0",
      "blockHash" : "0x7bbd22e318575e2e56e6eec1b583a9945fbe8c6009fdb83f2cf9e4a5a3ba2b5c",
      "logIndex" : "0x0",
      "removed" : false
    } ]
  }
}
```

#### Acquire the Value
`./scripts/get_value.sh` gets value from the `EventEmitter` contract deployed which was
set. This is also being called from `node2`. Once the transaction is successful, we can use the `transactionHash` 
generated to get the transaction receipt which will have the stored value in the `output` field.

Example:
`./scripts/get_value.sh`

Sample Output:
```bash
{
  "jsonrpc" : "2.0",
  "id" : 1,
  "result" : "0xdeb0a738c9841894959256196757e3c8df08f069b34d92184a500468b4e37d29"
}
```

`./scripts/get_receipt.sh --transactionHash 0xdeb0a738c9841894959256196757e3c8df08f069b34d92184a500468b4e37d29 --httpNodeEndpoint http://localhost:20002`

Sample Output:
```bash
{
  "jsonrpc" : "2.0",
  "id" : 1,
  "result" : {
    "contractAddress" : null,
    "from" : "0x627306090abab3a6e1400e9345bc60c78a8bef57",
    "to" : "0x2f351161a80d74047316899342eedc606b13f9f8",
    "output" : "0x00000000000000000000000000000000000000000000000000000000000003e8",
    "logs" : [ ]
  }
}
```

#### Getting the Transaction Receipt
`./scripts/get_receipt.sh` gets the information about the private transaction,
after the transaction was mined. Receipts for pending transactions the
contract address are not available.

**txHash :** *the transaction hash returned by executing a transaction.*

**httpEndpoint :** *the HTTP service endpoint of node.*


```bash tab="Example"
./scripts/get_receipt.sh -txhash <transactionHash> -httpEndpoint <nodeEndpoint>
```

#### Troubleshooting

##### `nonce too low`

Since the scripts are hardcoded RLP transactions with fixed nonce, they can be executed only once. 
And in the order of `create_contract.sh` `set_value.sh` `get_value.sh`. 

To restart the docker containers afresh you need to `./stop.sh` and `./remove.sh` to clear all the DB and 
start a new container. 
### Stop Services and Network
`./stop.sh` stops all the docker containers created.

### Remove stopped containers and volumes 
`./remove.sh` stops and removes all the containers and volumes. 

### Remove Docker Images
`./delete.sh` stops the containers and deletes all the docker images.

