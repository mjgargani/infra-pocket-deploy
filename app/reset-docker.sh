#!/bin/bash

echo "Iniciando reset total do Docker..."

# Passo 1: Parar todos os containers
echo "Parando containers..."
docker stop $(docker ps -aq) 2>/dev/null

# Passo 2: Remover todos os containers
echo "Removendo containers..."
docker rm $(docker ps -aq) 2>/dev/null

# Passo 3: Remover todas as imagens
echo "Removendo imagens..."
docker rmi -f $(docker images -q) 2>/dev/null

# Passo 4: Remover todos os volumes (dados persistentes de bancos, etc.)
echo "Removendo volumes (isso apaga dados de bancos!)..."
docker volume rm $(docker volume ls -q) 2>/dev/null

# Passo 5: Remover redes personalizadas
echo "Removendo redes Docker personalizadas..."
docker network rm $(docker network ls --filter type=custom -q) 2>/dev/null

# Passo 6: Limpeza geral de sistema (cache, builders, etc.)
echo "Executando prune final..."
docker system prune -a --volumes -f

echo "Docker zerado com sucesso."
