# Pantheon Permissioned Network Quickstart Tutorial

The private Permissioned Network Quickstart uses Pantheon and Orion
nodes managed by Docker Compose. 

## Prerequisites

To run this tutorial, you must have the following installed:

- MacOS or Linux 
    
    !!! important 
        The Private Network Quickstart is not supported on Windows. If using Windows, run the quickstart
        inside a Linux VM such as Ubuntu. 

- [Docker and Docker-compose](https://docs.docker.com/compose/install/) 

- [Git command line](https://git-scm.com/)


## Verification

We need RLP-encoded signed transactions to perform
`eea_sendRawTransaction`. Currently, we have hardcoded the 3
transactions to verify the working of the private network. Its WIP to
bring up a client to do the same.


All the scripts are a part of the `scripts` folder and can be executed
only once and in the order of: 
- `create_contract.sh` 
- `set_value.sh` 
- `get_value.sh`

The transaction receipts of the corresponding transaction can be viewed by executing `get_receipt.sh` with
the correct parameters. 


## Execution Process to Create a Permissioned Network

### Build Docker Images and Start Services and Network
`./run-private.sh` creates docker images for configuring a network of
Pantheon nodes as well as Orion nodes which include 3 nodes with privacy
enabled.

### Create and Deploy the Contract
`./create_contract.sh` deploys the EventEmitter Smart Contract by
calling eea_sendRawTransaction using as a parameter the given
RLP-encoded signed transaction.

### Change the Value in the Contract
`./set_value.sh` sets value to the contract deployed.

### Acquire the Value
`./get_value.sh` gets value from the Smart Contract deployed which was
set.

### Acquire the Information About the Private Transaction
`./get_value.sh` gets the information about the private transaction,
after the transaction was mined. Receipts for pending transactions the
contract address are not available.

**txHash :** *the transaction hash returned by executing a transaction.*

**orionPubKey :** *the public key with which Orion was started.*

**httpEndpoint :** *the HTTP service endpoint of node.*


```bash tab="Example"
./get_receipt.sh txhash 0x94aa3be946fe44b9a09cfd2b5c8f898e508546e477aa20a9b12ef002357ef5ce orionPubKey A1aVtMxLCUHmBVHXoZzzBgPbW/wj5axDpW9X8l91SGo= httpEndpoint http://localhost:20000
```

### Stop Services and Network
`./stop-private.sh` stops all the docker containers created.

### Stop Services and Network and Remove Docker Images
`./remove-private.sh` stops all the services and docker images created
and delete.

