#!/bin/bash

besu operator generate-blockchain-config --config-file=ibftConfig.json --to=NetworkFiles --private-key-file-name=key

cp ./NetworkFiles/genesis.json ./IbftNet/genesis.json

echo "Copie cada par de chaves gerado para cada nó na pasta IbftNet."