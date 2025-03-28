#!/bin/bash

besu --data-path=./IbftNet/Node1/Data --genesis-file=./IbftNet/genesis.json --rpc-http-enabled --rpc-http-api=ETH,NET,IBFT --host-allowlist="*" --rpc-http-cors-origins="all" --profile=PRIVATE

echo "Copie a enode URL gerada pelo Node1 para os demais nós."