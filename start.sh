#!/bin/bash

# Script de inicialização da aplicação Omenagem
# Compatível com Ubuntu Server 24.04.2 LTS

echo "🚀 Iniciando aplicação Omenagem..."
echo "📍 URL: http://localhost"
echo "📍 Admin: http://localhost/admin"
echo "⏹️  Para parar: Ctrl+C ou 'docker-compose down'"
echo "-" * 50

# Criar diretórios necessários
mkdir -p data static/uploads

# Definir permissões corretas
chmod 755 data static/uploads

# Verificar se o Docker está rodando
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker não está rodando. Inicie o Docker primeiro."
    exit 1
fi

# Verificar se o docker-compose está disponível
if ! command -v docker-compose &> /dev/null; then
    echo "❌ docker-compose não encontrado. Instale o docker-compose primeiro."
    exit 1
fi

# Parar containers existentes (se houver)
echo "🛑 Parando containers existentes..."
docker-compose down

# Construir e iniciar a aplicação
echo "🔨 Construindo e iniciando aplicação..."
docker-compose up --build -d

# Verificar se a aplicação está rodando
echo "⏳ Aguardando aplicação inicializar..."
sleep 10

# Verificar saúde da aplicação
if curl -f http://localhost/api/health > /dev/null 2>&1; then
    echo "✅ Aplicação iniciada com sucesso!"
    echo "🌐 Acesse: http://localhost"
    echo "🔧 Admin: http://localhost/admin"
    echo "📊 Status: http://localhost/api/health"
else
    echo "❌ Erro ao iniciar aplicação. Verifique os logs:"
    echo "docker-compose logs"
fi
