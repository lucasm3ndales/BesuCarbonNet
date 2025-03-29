#!/bin/bash

echo "Subindo CarbonNet..."

# Envs para os diretórios:
ROOT_DIR=$(pwd)  
NODES_BASE="${ROOT_DIR}/IbftNet"
NODE1="Node1"
NODE2="Node2"
NODE3="Node3"
NODE4="Node4"
HOST="0.0.0.0"
RPC_WS_PORT="864" 
RPC_HTTP_PORT="854"
P2P_PORT="3030"

# Verificar se o UFW está ativo
UFW_STATUS=$(sudo ufw status | grep -i active)

if [[ $UFW_STATUS != *"inactive"* ]]; then
    echo "Configurando regras UFW..."
    
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
    
    sudo ufw reload
    echo "Regras UFW aplicadas com sucesso"
else
    echo "AVISO: UFW não está ativo. As portas não serão configuradas automaticamente."
fi

# Função para iniciar nós em sessões screen
start_node() {
    local node_name=$1
    local node_num=$2
    local p2p_port=$3
    local rpc_http_port=$4
    local rpc_ws_port=$5
    local bootnodes=$6

    screen -S "besu-${node_name}" -dm bash -c \
        "besu \
        --data-path=\"${NODES_BASE}/${node_name}/Data\" \
        --genesis-file=\"${NODES_BASE}/genesis.json\" \
        --rpc-http-enabled \
        --rpc-http-api=ETH,NET,IBFT,WEB3 \
        --rpc-http-port=\"${rpc_http_port}\" \
        --rpc-http-cors-origins=\"all\" \
        --host-allowlist=\"*\" \
        --p2p-port=\"${p2p_port}\" \
        --rpc-ws-enabled \
        --rpc-ws-api=ETH,NET,IBFT,WEB3 \
        --rpc-ws-port=\"${rpc_ws_port}\" \
        ${bootnodes:+--bootnodes=\"${bootnodes}\"} \
        --profile=PRIVATE 2>&1 | tee \"${NODES_BASE}/${node_name}/besu.log\""
}

# Node 1 (Bootnode)
start_node "${NODE1}" 1 "${P2P_PORT}3" "${RPC_HTTP_PORT}5" "${RPC_WS_PORT}5"
sleep 10

# Obter enode URL do Node1
NODE_PUB_KEY=$(cat "${NODES_BASE}/${NODE1}/Data/key.pub")
NODE_PUB_KEY="${NODE_PUB_KEY#0x}"
ENODE_URL="enode://${NODE_PUB_KEY}@${HOST}:${P2P_PORT}3"
echo "[\"${ENODE_URL}\"]" > "${ROOT_DIR}/enodes.json"
echo "Enode URL: ${ENODE_URL}"

# Nodes subsequentes
start_node "${NODE2}" 2 "${P2P_PORT}4" "${RPC_HTTP_PORT}6" "${RPC_WS_PORT}6" "${ENODE_URL}"
sleep 5

start_node "${NODE3}" 3 "${P2P_PORT}5" "${RPC_HTTP_PORT}7" "${RPC_WS_PORT}7" "${ENODE_URL}"
sleep 5

start_node "${NODE4}" 4 "${P2P_PORT}6" "${RPC_HTTP_PORT}8" "${RPC_WS_PORT}8" "${ENODE_URL}"
sleep 5

# Listar sessões screen ativas
echo -e "\nSessões screen ativas:"
screen -list

echo -e "\nCarbonNet executando em sessões screen."
echo "Para acessar um nó específico: screen -r besu-NodeX"
echo "Para desanexar da sessão: Ctrl+A, D"
echo "Pare a rede com o comando: ./stop.sh"