#!/bin/bash

# Script SIMPLES para iniciar a aplicação Omenagem
# Funciona diretamente com Python (sem Docker)

echo "🚀 Iniciando aplicação Omenagem (Modo Simples)..."
echo "📍 URL: http://45.70.136.66:5000"
echo "📍 Admin: http://45.70.136.66:5000/admin"
echo "⏹️  Para parar: Ctrl+C"
echo "-" * 50

# Criar diretórios necessários
mkdir -p data static/uploads
chmod 755 data static/uploads

# Verificar se Python está instalado
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 não encontrado. Instale Python3 primeiro."
    exit 1
fi

# Verificar se as dependências estão instaladas
if ! python3 -c "import flask" 2>/dev/null; then
    echo "📦 Instalando dependências..."
    pip3 install -r requirements.txt
fi

# Configurar variáveis de ambiente
export FLASK_ENV=production
export FLASK_APP=app.py

# Iniciar aplicação
echo "🌐 Iniciando servidor..."
echo "✅ Aplicação rodando em: http://45.70.136.66:5000"
echo "✅ Admin em: http://45.70.136.66:5000/admin"
echo ""

# Executar aplicação
python3 app.py
