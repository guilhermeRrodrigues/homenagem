#!/bin/bash

# ==========================================
# Script de Backup - Site de Homenagens
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
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="backup_$DATE.tar.gz"

echo -e "${BLUE}=========================================="
echo "💾 Backup - Site de Homenagens"
echo "==========================================${NC}"

# Criar diretório de backup
mkdir -p $BACKUP_DIR

# Função para log
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

# 1. Backup dos dados da aplicação
log "Criando backup dos dados..."
tar -czf "$BACKUP_DIR/$BACKUP_FILE" \
    -C $APP_DIR \
    static/uploads/ \
    /tmp/tributes_data.json 2>/dev/null || true

# 2. Verificar se o backup foi criado
if [ -f "$BACKUP_DIR/$BACKUP_FILE" ]; then
    log "✅ Backup criado com sucesso: $BACKUP_FILE"
    
    # Mostrar informações do backup
    echo -e "${BLUE}Informações do backup:${NC}"
    echo -e "  • Arquivo: ${YELLOW}$BACKUP_FILE${NC}"
    echo -e "  • Tamanho: ${YELLOW}$(du -h "$BACKUP_DIR/$BACKUP_FILE" | cut -f1)${NC}"
    echo -e "  • Local: ${YELLOW}$BACKUP_DIR/$BACKUP_FILE${NC}"
    
    # 3. Limpar backups antigos (manter apenas os últimos 7)
    log "Limpando backups antigos..."
    cd $BACKUP_DIR
    old_backups=$(ls -t backup_*.tar.gz 2>/dev/null | tail -n +8)
    if [ -n "$old_backups" ]; then
        echo "$old_backups" | xargs rm -f
        log "Backups antigos removidos"
    else
        log "Nenhum backup antigo para remover"
    fi
    
    # 4. Listar backups disponíveis
    echo -e "\n${BLUE}Backups disponíveis:${NC}"
    ls -lh backup_*.tar.gz 2>/dev/null | while read line; do
        echo -e "  ${YELLOW}$line${NC}"
    done
    
    echo -e "\n${GREEN}✅ Backup concluído com sucesso!${NC}"
    
else
    echo -e "${RED}❌ Erro ao criar backup${NC}"
    exit 1
fi
