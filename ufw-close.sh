#!/bin/bash

echo "Fechando portas no UFW..."

PORTS=(8545 8546 25000 26000 9090 3000)

for port in "${PORTS[@]}"; do
    sudo ufw deny $port/tcp
done

echo "Todas as portas foram fechadas!"
sudo ufw status numbered
