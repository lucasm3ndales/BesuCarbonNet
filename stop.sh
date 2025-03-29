#!/bin/bash

echo "Interrompendo a rede CarbonNet..."

# Carregar variáveis de ambiente
ROOT_DIR=$(pwd)  
NODES_BASE="${ROOT_DIR}/IbftNet"
NODE_NAMES=("Node1" "Node2" "Node3" "Node4")
RPC_HTTP_PORT="854"
RPC_WS_PORT="864" 
P2P_PORT="3030"

# 1. Encerrar sessões screen dos nós
echo "Encerrando sessões screen..."
for NODE in "${NODE_NAMES[@]}"; do
    screen -S "besu-${NODE}" -X quit 2>/dev/null && echo "Sessão besu-${NODE} encerrada"
done

# 2. Matar todos os processos Besu remanescentes
echo "Encerrando processos Besu..."
pkill -f "besu.*Data/Node" 2>/dev/null

# Verificação e força de encerramento se necessário
if pgrep -f "besu.*Data/Node" >/dev/null; then
    echo "Aviso: Alguns processos Besu ainda estão em execução"
    echo "Forçando encerramento..."
    pkill -9 -f "besu.*Data/Node" 2>/dev/null
fi

# 3. Remover regras UFW
if command -v ufw &> /dev/null && sudo ufw status | grep -q "active"; then
    echo "Removendo regras UFW..."
    
    # Portas RPC HTTP
    for PORT_SUFFIX in 5 6 7 8; do
        sudo ufw delete allow ${RPC_HTTP_PORT}${PORT_SUFFIX}/tcp 2>/dev/null
    done
    
    # Portas WebSocket
    for PORT_SUFFIX in 5 6 7 8; do
        sudo ufw delete allow ${RPC_WS_PORT}${PORT_SUFFIX}/tcp 2>/dev/null
    done
    
    # Portas P2P
    for PORT_SUFFIX in 3 4 5 6; do
        sudo ufw delete allow ${P2P_PORT}${PORT_SUFFIX}/tcp 2>/dev/null
    done
    
    sudo ufw reload
fi

# 4. Verificação final
echo -e "\nStatus final:"
if ! screen -list | grep -q "besu-Node"; then
    echo "✔ Todas as sessões screen foram encerradas"
else
    echo "✖ Algumas sessões ainda podem estar ativas:"
    screen -list | grep "besu-Node"
fi

if ! pgrep -f "besu.*Data/Node" >/dev/null; then
    echo "✔ Todos os processos Besu foram encerrados"
else
    echo "✖ Alguns processos Besu ainda estão em execução"
    pgrep -fl "besu.*Data/Node"
fi

echo -e "\nRede CarbonNet parada com sucesso."