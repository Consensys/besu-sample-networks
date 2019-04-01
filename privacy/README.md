# Pantheon Permissioned Network Quickstart

`./run-private.sh` creates docker images for configuring a network of Pantheon nodes as well as Orion nodes which
includes 3 nodes with privacy enabled.

## Verification

We need RLP-encoded signed transactions to perform `eea_sendRawTransaction`. Currently we have hardcoded the 
3 transactions to verify the working of the private network. Its WIP to bring up a client to do the same.


All the scripts are a part of the `scripts` folder and can be executed only once and in the order of
`create_contract.sh` `set_value.sh` `get_value.sh`.

The transaction receipts of the corresponding transaction can be viewed by executing `get_receipt.sh` with
the correct parameters. 


