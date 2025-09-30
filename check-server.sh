#!/bin/bash

# Script para verificar se o servidor está pronto para acesso externo
# IP: 45.70.136.66

echo "🔍 Verificando configuração do servidor..."
echo "📍 IP: 45.70.136.66"
echo "📍 Porta: 80"
echo "-" * 50

# Verificar se o Docker está rodando
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker não está rodando"
    exit 1
fi

# Verificar se o container está rodando
if ! docker-compose ps | grep -q "omenagem-app.*Up"; then
    echo "❌ Container não está rodando. Execute: ./start.sh"
    exit 1
fi

# Verificar se a porta 80 está sendo usada pelo container
if ! docker-compose ps | grep -q "45.70.136.66:80->3000/tcp"; then
    echo "❌ Porta 80 não está mapeada corretamente"
    exit 1
fi

# Verificar se a aplicação responde localmente
echo "⏳ Testando aplicação localmente..."
if curl -f http://45.70.136.66/api/health > /dev/null 2>&1; then
    echo "✅ Aplicação respondendo localmente"
else
    echo "❌ Aplicação não responde localmente"
    exit 1
fi

# Verificar firewall
echo "⏳ Verificando firewall..."
if command -v ufw > /dev/null 2>&1; then
    if ufw status | grep -q "80/tcp.*ALLOW"; then
        echo "✅ Porta 80 liberada no UFW"
    else
        echo "⚠️  Porta 80 pode não estar liberada no UFW"
        echo "   Execute: sudo ufw allow 80/tcp"
    fi
else
    echo "⚠️  UFW não encontrado, verifique iptables manualmente"
fi

# Verificar se o IP está configurado na interface de rede
echo "⏳ Verificando configuração de rede..."
if ip addr show | grep -q "45.70.136.66"; then
    echo "✅ IP 45.70.136.66 configurado na interface de rede"
else
    echo "⚠️  IP 45.70.136.66 pode não estar configurado na interface de rede"
    echo "   Verifique: ip addr show"
fi

echo ""
echo "🌐 URLs de acesso:"
echo "   Aplicação: http://45.70.136.66"
echo "   Admin: http://45.70.136.66/admin"
echo "   API Health: http://45.70.136.66/api/health"
echo ""
echo "✅ Servidor configurado para acesso externo!"
