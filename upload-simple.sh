#!/bin/bash

# Script simples para fazer upload dos arquivos para o servidor
# Execute no seu computador local: bash upload-simple.sh

set -e

# Configurações
SERVER="joao@45.70.136.66"
REMOTE_DIR="~/homenagens-producao"
LOCAL_DIR="$(pwd)"

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  Upload para Servidor de Produção ${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_status() {
    echo -e "${BLUE}[$(date '+%H:%M:%S')]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header

# Verificar se o diretório local existe
if [ ! -d "$LOCAL_DIR" ]; then
    print_error "Diretório local não encontrado: $LOCAL_DIR"
    exit 1
fi

# Verificar se SSH está disponível
if ! command -v scp &> /dev/null; then
    print_error "SCP não está instalado. Instale: sudo apt install openssh-client"
    exit 1
fi

print_status "Fazendo upload dos arquivos para $SERVER:$REMOTE_DIR"

# Fazer upload dos arquivos principais
print_status "Enviando arquivos principais..."
scp $LOCAL_DIR/app.py $SERVER:$REMOTE_DIR/
scp $LOCAL_DIR/requirements.txt $SERVER:$REMOTE_DIR/
scp $LOCAL_DIR/Dockerfile $SERVER:$REMOTE_DIR/
scp $LOCAL_DIR/docker-compose.yml $SERVER:$REMOTE_DIR/

# Fazer upload dos templates
print_status "Enviando templates..."
scp -r $LOCAL_DIR/templates/ $SERVER:$REMOTE_DIR/

# Fazer upload dos arquivos estáticos
print_status "Enviando arquivos estáticos..."
scp -r $LOCAL_DIR/static/ $SERVER:$REMOTE_DIR/

# Fazer upload do script de deploy
print_status "Enviando script de deploy..."
scp $LOCAL_DIR/deploy-producao.sh $SERVER:$REMOTE_DIR/

print_success "Upload concluído!"

print_warning "Próximos passos:"
echo "1. Conecte ao servidor: ssh $SERVER"
echo "2. Execute: cd $REMOTE_DIR"
echo "3. Execute: chmod +x deploy-producao.sh"
echo "4. Execute: bash deploy-producao.sh"
echo "5. Execute: ./manage.sh start"
echo ""
print_status "Acesse: http://45.70.136.66"
print_status "Administração: http://45.70.136.66/admin"
