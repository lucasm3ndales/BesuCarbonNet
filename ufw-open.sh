#!/bin/bash

echo "Abrindo portas no UFW..."

PORTS=(8545 8546 25000 26000 9090 3000)

for port in "${PORTS[@]}"; do
    sudo ufw allow $port/tcp
done

# Garantir que o SSH permaneça aberto para acesso remoto
sudo ufw allow ssh

# Ativar o UFW caso ainda não esteja ativo
sudo ufw enable

echo "Todas as portas foram abertas com sucesso!"
sudo ufw status numbered
