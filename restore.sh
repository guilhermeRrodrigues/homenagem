#!/bin/bash

# ==========================================
# Script de Restore - Site de Homenagens
# ==========================================

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configurações
BACKUP_DIR="/home/$USER/backups"
APP_DIR="$(pwd)"

echo -e "${BLUE}=========================================="
echo "🔄 Restore - Site de Homenagens"
echo "==========================================${NC}"

# Função para log
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERRO] $1${NC}"
    exit 1
}

# Verificar se foi fornecido um arquivo de backup
if [ $# -eq 0 ]; then
    echo -e "${YELLOW}Uso: $0 <arquivo_de_backup>${NC}"
    echo -e "\n${BLUE}Backups disponíveis:${NC}"
    ls -lh $BACKUP_DIR/backup_*.tar.gz 2>/dev/null | while read line; do
        echo -e "  ${YELLOW}$line${NC}"
    done
    exit 1
fi

BACKUP_FILE="$1"

# Verificar se o arquivo existe
if [ ! -f "$BACKUP_FILE" ]; then
    # Tentar no diretório de backups
    if [ -f "$BACKUP_DIR/$BACKUP_FILE" ]; then
        BACKUP_FILE="$BACKUP_DIR/$BACKUP_FILE"
    else
        error "Arquivo de backup não encontrado: $BACKUP_FILE"
    fi
fi

log "Restaurando backup: $BACKUP_FILE"

# Parar aplicação
log "Parando aplicação..."
docker-compose down

# Fazer backup do estado atual (caso algo dê errado)
log "Criando backup de segurança do estado atual..."
CURRENT_BACKUP="backup_before_restore_$(date +%Y%m%d_%H%M%S).tar.gz"
tar -czf "$BACKUP_DIR/$CURRENT_BACKUP" \
    -C $APP_DIR \
    static/uploads/ \
    /tmp/tributes_data.json 2>/dev/null || true

# Restaurar dados
log "Restaurando dados..."
cd $APP_DIR

# Extrair backup
if tar -tzf "$BACKUP_FILE" > /dev/null 2>&1; then
    tar -xzf "$BACKUP_FILE"
    log "✅ Dados restaurados com sucesso"
else
    error "Arquivo de backup inválido ou corrompido"
fi

# Verificar se os arquivos foram restaurados
if [ -f "/tmp/tributes_data.json" ]; then
    log "✅ Arquivo de dados restaurado"
else
    log "⚠ Arquivo de dados não encontrado após restore"
fi

if [ -d "static/uploads" ]; then
    log "✅ Diretório de uploads restaurado"
else
    log "⚠ Diretório de uploads não encontrado após restore"
fi

# Reiniciar aplicação
log "Reiniciando aplicação..."
docker-compose up -d

# Aguardar aplicação inicializar
log "Aguardando aplicação inicializar..."
sleep 10

# Testar aplicação
log "Testando aplicação..."
if curl -s http://localhost:8080/api/health > /dev/null; then
    log "✅ Aplicação funcionando após restore"
    
    # Mostrar informações do restore
    echo -e "\n${BLUE}Informações do restore:${NC}"
    echo -e "  • Backup restaurado: ${YELLOW}$(basename $BACKUP_FILE)${NC}"
    echo -e "  • Backup de segurança: ${YELLOW}$CURRENT_BACKUP${NC}"
    echo -e "  • Aplicação: ${GREEN}Funcionando${NC}"
    
    # Mostrar dados restaurados
    if [ -f "/tmp/tributes_data.json" ]; then
        tribute_count=$(cat /tmp/tributes_data.json | grep -o '"id"' | wc -l)
        echo -e "  • Homenagens restauradas: ${YELLOW}$tribute_count${NC}"
    fi
    
    echo -e "\n${GREEN}✅ Restore concluído com sucesso!${NC}"
    
else
    error "❌ Aplicação não está funcionando após restore"
fi
