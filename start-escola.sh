#!/bin/bash

# Script para iniciar no PC da ESCOLA
# Funciona em qualquer computador Windows/Linux

echo "🏫 INICIANDO APLICAÇÃO NA ESCOLA"
echo "================================"

# Verificar se Python está instalado
if ! command -v python3 &> /dev/null && ! command -v python &> /dev/null; then
    echo "❌ Python não encontrado!"
    echo "📥 Instale Python primeiro:"
    echo "   Windows: https://python.org/downloads"
    echo "   Linux: sudo apt install python3"
    exit 1
fi

# Usar python3 ou python
PYTHON_CMD="python3"
if ! command -v python3 &> /dev/null; then
    PYTHON_CMD="python"
fi

echo "🐍 Usando: $PYTHON_CMD"

# Criar diretórios necessários
echo "📁 Criando diretórios..."
mkdir -p data static/uploads
chmod 755 data static/uploads 2>/dev/null || true

# Instalar dependências
echo "📦 Instalando dependências..."
$PYTHON_CMD -m pip install --user -r requirements.txt

# Obter IP do computador
if command -v hostname &> /dev/null; then
    SERVER_IP=$(hostname -I | awk '{print $1}' 2>/dev/null || echo "localhost")
else
    SERVER_IP="localhost"
fi

# Se estiver no Windows, tentar obter IP
if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    SERVER_IP=$(ipconfig | grep "IPv4" | head -1 | awk '{print $NF}' 2>/dev/null || echo "localhost")
fi

echo "📍 IP do computador: $SERVER_IP"

# Configurar variáveis de ambiente
export FLASK_ENV=production
export FLASK_APP=app.py

# Iniciar aplicação
echo ""
echo "🚀 INICIANDO APLICAÇÃO..."
echo "========================="
echo "🌐 URL: http://$SERVER_IP:5000"
echo "🔧 Admin: http://$SERVER_IP:5000/admin"
echo "📊 Status: http://$SERVER_IP:5000/api/health"
echo ""
echo "⏹️  Para parar: Ctrl+C"
echo "========================="

# Executar aplicação
$PYTHON_CMD app.py
