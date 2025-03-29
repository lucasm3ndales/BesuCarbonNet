#!/bin/bash

echo "Interrompendo a rede CarbonNet..."

# Carregar variáveis de ambiente consistentes
ROOT_DIR=$(pwd)  
NODES_BASE="${ROOT_DIR}/IbftNet"
RPC_HTTP_PORT="854"
RPC_WS_PORT="864" 
P2P_PORT="3030"

# Encerrar a sessão tmux
tmux kill-session -t carbonnet 2>/dev/null

# Verificar e matar quaisquer processos besu remanescentes
pkill -f "besu.*Data/Node" 2>/dev/null

# Remover regras UFW usando as mesmas variáveis
if command -v ufw &> /dev/null; then
    echo "Removendo regras UFW específicas..."
    
    # Remove portas para cada nó
    for PORT_SUFFIX in 5 6 7 8; do
        sudo ufw delete allow ${RPC_HTTP_PORT}${PORT_SUFFIX}/tcp 2>/dev/null
        sudo ufw delete allow ${RPC_WS_PORT}${PORT_SUFFIX}/tcp 2>/dev/null
    done
    
    for PORT_SUFFIX in 3 4 5 6; do
        sudo ufw delete allow ${P2P_PORT}${PORT_SUFFIX}/tcp 2>/dev/null
    done
    
    # Remove porta UDP de descoberta (se usada)
    # sudo ufw delete allow ${DISC_PORT}/udp 2>/dev/null
    
    sudo ufw reload
    echo "Regras UFW removidas"
fi

echo "Rede CarbonNet parada."