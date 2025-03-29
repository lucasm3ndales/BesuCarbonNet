bash
Copy
#!/bin/bash

echo "Subindo CarbonNet..."

# Envs para os diretórios:
ROOT_DIR=$(pwd)  
NODES_BASE="${ROOT_DIR}/IbftNet"
NODE1="Node1"
NODE2="Node2"
NODE3="Node3"
NODE4="Node4"
HOST="0.0.0.0"  # Alterado para permitir conexões externas
RPC_WS_PORT="864" 
RPC_HTTP_PORT="854"
P2P_PORT="3030"

# Verificar se o UFW está ativo
UFW_STATUS=$(sudo ufw status | grep -i active)

if [[ $UFW_STATUS != *"inactive"* ]]; then
    echo "Configurando regras UFW para as portas necessárias..."
    
    # Liberar portas para cada nó usando as variáveis definidas
    # Node 1
    sudo ufw allow ${RPC_HTTP_PORT}5/tcp comment "CarbonNet ${NODE1} HTTP"
    sudo ufw allow ${RPC_WS_PORT}5/tcp comment "CarbonNet ${NODE1} WS"
    sudo ufw allow ${P2P_PORT}3/tcp comment "CarbonNet ${NODE1} P2P"
    
    # Node 2
    sudo ufw allow ${RPC_HTTP_PORT}6/tcp comment "CarbonNet ${NODE2} HTTP"
    sudo ufw allow ${RPC_WS_PORT}6/tcp comment "CarbonNet ${NODE2} WS"
    sudo ufw allow ${P2P_PORT}4/tcp comment "CarbonNet ${NODE2} P2P"
    
    # Node 3
    sudo ufw allow ${RPC_HTTP_PORT}7/tcp comment "CarbonNet ${NODE3} HTTP"
    sudo ufw allow ${RPC_WS_PORT}7/tcp comment "CarbonNet ${NODE3} WS"
    sudo ufw allow ${P2P_PORT}5/tcp comment "CarbonNet ${NODE3} P2P"
    
    # Node 4
    sudo ufw allow ${RPC_HTTP_PORT}8/tcp comment "CarbonNet ${NODE4} HTTP"
    sudo ufw allow ${RPC_WS_PORT}8/tcp comment "CarbonNet ${NODE4} WS"
    sudo ufw allow ${P2P_PORT}6/tcp comment "CarbonNet ${NODE4} P2P"
    
    # Liberar porta UDP para descoberta P2P (opcional)
    # sudo ufw allow ${DISC_PORT}/udp comment "CarbonNet Discovery"
    
    # Recarregar UFW para aplicar as regras
    sudo ufw reload
    echo "Regras UFW aplicadas com sucesso"
else
    echo "AVISO: UFW não está ativo. As portas não serão configuradas automaticamente."
fi

# Node 1 (Bootnode)
besu \
  --data-path="${NODES_BASE}/${NODE1}/Data" \
  --genesis-file="${NODES_BASE}/genesis.json" \
  --rpc-http-enabled \
  --rpc-http-api=ETH,NET,IBFT,WEB3 \
  --rpc-http-port="${RPC_HTTP_PORT}5" \
  --rpc-http-cors-origins="all" \
  --host-allowlist="*" \
  --p2p-port="${P2P_PORT}3" \
  --rpc-ws-enabled \
  --rpc-ws-api=ETH,NET,IBFT,WEB3 \
  --rpc-ws-port="${RPC_WS_PORT}5" \
  --profile=PRIVATE &

sleep 10

NODE_PUB_KEY=$(cat "${NODES_BASE}/${NODE1}/Data/key.pub")

NODE_PUB_KEY="${NODE_PUB_KEY#0x}"

ENODE_URL="enode://${NODE_PUB_KEY}@${HOST}:${P2P_PORT}"

JSON_FILE="${ROOT_DIR}/enodes.json"
echo "[\"${ENODE_URL}\"]" > "$JSON_FILE"


echo "Enode URL: ${ENODE_URL}"

# Node 2
besu \
  --data-path="${NODES_BASE}/${NODE2}/Data" \
  --genesis-file="${NODES_BASE}/genesis.json" \
  --rpc-http-enabled \
  --rpc-http-api=ETH,NET,IBFT,WEB3 \
  --rpc-http-port="${RPC_HTTP_PORT}6" \
  --rpc-http-cors-origins="all" \
  --host-allowlist="*" \
  --p2p-port="${P2P_PORT}4" \
  --rpc-ws-enabled \
  --rpc-ws-api=ETH,NET,IBFT,WEB3 \
  --rpc-ws-port="${RPC_WS_PORT}6" \
  --bootnodes="${ENODE_URL}" \
  --profile=PRIVATE &

sleep 10

# Node 3
besu \
  --data-path="${NODES_BASE}/${NODE3}/Data" \
  --genesis-file="${NODES_BASE}/genesis.json" \
  --rpc-http-enabled \
  --rpc-http-api=ETH,NET,IBFT,WEB3 \
  --rpc-http-port="${RPC_HTTP_PORT}7" \
  --rpc-http-cors-origins="all" \
  --host-allowlist="*" \
  --p2p-port="${P2P_PORT}5"\
  --rpc-ws-enabled \
  --rpc-ws-api=ETH,NET,IBFT,WEB3 \
  --rpc-ws-port="${RPC_WS_PORT}7" \
  --bootnodes="${ENODE_URL}" \
  --profile=PRIVATE &

sleep 10

# Node 4
besu \
  --data-path="${NODES_BASE}/${NODE4}/Data" \
  --genesis-file="${NODES_BASE}/genesis.json" \
  --rpc-http-enabled \
  --rpc-http-api=ETH,NET,IBFT,WEB3 \
  --rpc-http-port="${RPC_HTTP_PORT}8" \
  --rpc-http-cors-origins="all" \
  --host-allowlist="*" \
  --p2p-port="${P2P_PORT}6" \
  --rpc-ws-enabled \
  --rpc-ws-api=ETH,NET,IBFT,WEB3 \
  --rpc-ws-port="${RPC_WS_PORT}8" \
  --bootnodes="${ENODE_URL}" \
  --profile=PRIVATE &

sleep 10

echo "CarbonNet executando."

echo "Pare a rede com o comando: ./stop.sh"