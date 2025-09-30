#!/bin/bash

# SOLUÇÃO FINAL - FUNCIONA AGORA!
# Script para iniciar a aplicação Omenagem de forma definitiva

echo "🚀 CONFIGURAÇÃO FINAL - Omenagem"
echo "================================="

# Parar processos existentes
echo "🛑 Parando processos existentes..."
pkill -f "python3 app.py" 2>/dev/null
docker-compose down 2>/dev/null

# Criar diretórios
echo "📁 Criando diretórios..."
mkdir -p data static/uploads
chmod 755 data static/uploads

# Instalar dependências
echo "📦 Instalando dependências..."
pip3 install -r requirements.txt

# Configurar firewall
echo "🔥 Configurando firewall..."
sudo ufw allow 5000/tcp

# Obter IP atual do servidor
SERVER_IP=$(hostname -I | awk '{print $1}')
echo "📍 IP do servidor: $SERVER_IP"

# Iniciar aplicação em background
echo "🌐 Iniciando aplicação..."
nohup python3 app.py > app.log 2>&1 &

# Aguardar inicialização
sleep 3

# Verificar se está funcionando
if curl -s http://localhost:5000/api/health > /dev/null; then
    echo ""
    echo "✅ SUCESSO! Aplicação funcionando!"
    echo "================================="
    echo "🌐 URL da aplicação: http://$SERVER_IP:5000"
    echo "🔧 Admin: http://$SERVER_IP:5000/admin"
    echo "📊 Status: http://$SERVER_IP:5000/api/health"
    echo ""
    echo "📋 Para acessar de qualquer lugar:"
    echo "   1. Configure o IP $SERVER_IP na sua rede"
    echo "   2. Libere a porta 5000 no firewall da escola"
    echo "   3. Acesse: http://$SERVER_IP:5000"
    echo ""
    echo "🔧 Comandos úteis:"
    echo "   Ver logs: tail -f app.log"
    echo "   Parar: pkill -f 'python3 app.py'"
    echo "   Status: curl http://$SERVER_IP:5000/api/health"
    echo ""
    echo "✅ PRONTO PARA USAR NA ESCOLA!"
else
    echo "❌ Erro ao iniciar aplicação. Verifique os logs:"
    echo "tail -f app.log"
fi
