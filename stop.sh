#!/bin/bash

# Script para parar a aplicação Omenagem

echo "🛑 Parando aplicação Omenagem..."

# Parar processo Python
echo "⏹️  Parando servidor Python..."
pkill -f "python3 app.py"

# Parar Docker se estiver rodando
echo "🐳 Parando containers Docker..."
docker-compose down 2>/dev/null

# Verificar se parou
sleep 2
if pgrep -f "python3 app.py" > /dev/null; then
    echo "⚠️  Aplicação ainda rodando. Forçando parada..."
    pkill -9 -f "python3 app.py"
    sleep 1
fi

# Verificar se realmente parou
if ! pgrep -f "python3 app.py" > /dev/null; then
    echo "✅ Aplicação parada com sucesso!"
    echo "📊 Status: Aplicação não está mais rodando"
else
    echo "❌ Erro ao parar aplicação. Tente:"
    echo "   sudo pkill -9 -f 'python3 app.py'"
fi

echo ""
echo "🔧 Para iniciar novamente:"
echo "   ./start-final.sh"
