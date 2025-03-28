#!/bin/bash

echo "Configurando o bootnode..."

# Envs para os diretórios:
ROOT_DIR=$(pwd)  
NODES_BASE="${ROOT_DIR}/IbftNet"
BOOTNODE="Node1"
HOST="127.0.0.1"
P2P_PORT="30303"
# Caso a porta UDP de descoberta seja diferente, defina discport (opcional)
# DISC_PORT="30301"
# Se for o caso, a enode URL ficaria:
# ENODE_URL="enode://${NODE_PUB_KEY}@${HOST}:${P2P_PORT}?discport=${DISC_PORT

besu \
  --data-path="${NODES_BASE}/${BOOTNODE}/Data" \
  --genesis-file="${NODES_BASE}/genesis.json" \
  --rpc-http-enabled \
  --rpc-http-api=ETH,NET,IBFT \
  --host-allowlist="*" \
  --rpc-http-cors-origins="all" \
  --profile=PRIVATE &

sleep 10

NODE_PUB_KEY=$(cat "${NODES_BASE}/${BOOTNODE}/Data/key.pub")

NODE_PUB_KEY="${NODE_PUB_KEY#0x}"

ENODE_URL="enode://${NODE_PUB_KEY}@${HOST}:${P2P_PORT}"

JSON_FILE="${ROOT_DIR}/enodes.json"
echo "[\"${ENODE_URL}\"]" > "$JSON_FILE"


echo "Enode URL: ${ENODE_URL}"

echo "Bootnode configurado com sucesso."
