#!/bin/bash

echo "Iniciando configuração inicial da rede CarbonNet."

# Envs para os diretórios:
ROOT_DIR=$(pwd)  
NODES_BASE="${ROOT_DIR}/IbftNet"
NETWORKS_FILES="${ROOT_DIR}/NetworkFiles"
KEYS_DIR="${NETWORKS_FILES}/keys"

for i in {1..4}; do
    mkdir -p "${NODES_BASE}/Node${i}/Data"
done

besu operator generate-blockchain-config --config-file=ibftConfig.json --to=${NETWORKS_FILES} --private-key-file-name=key

cp "${NETWORKS_FILES}/genesis.json" "${NODES_BASE}/genesis.json"

nodes=("Node1" "Node2" "Node3" "Node4")
i=0

for hex_dir in "$KEYS_DIR"/*; do
    if [ -d "$hex_dir" ]; then
        if [ $i -ge ${#nodes[@]} ]; then
            echo "Pares de chave maiores que a quantia de nós."
            break
        fi
        node="${nodes[$i]}"
        DEST_DIR="${NODES_BASE}/${node}/Data"
        echo "Copiando arquivos de $hex_dir para ${DEST_DIR}"

        cp "$hex_dir/key" "$DEST_DIR/"
        cp "$hex_dir/key.pub" "$DEST_DIR/"

        echo "Arquivos copiados para ${node}."
        i=$((i + 1))
    fi
done

echo "Configuração inicial da rede CarbonNet finalizada."

# chmod +x ${ROOT_DIR}/configBootnode.sh