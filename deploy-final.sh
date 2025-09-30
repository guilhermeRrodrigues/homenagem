#!/bin/bash

# ==========================================
# Script de Deploy Final - Site de Homenagens
# ==========================================

set -e  # Parar em caso de erro

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configurações
APP_NAME="omenagem"
APP_PORT="8080"
REPO_URL="https://github.com/guilhermeRrodrigues/omenagem.git"
SERVICE_NAME="omenagem.service"

echo -e "${BLUE}=========================================="
echo "🚀 Deploy Final - Site de Homenagens 7º Ano"
echo "==========================================${NC}"

# Função para log
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERRO] $1${NC}"
    exit 1
}

warning() {
    echo -e "${YELLOW}[AVISO] $1${NC}"
}

# Verificar se é root
if [ "$EUID" -eq 0 ]; then
    error "Não execute este script como root. Use um usuário com sudo."
fi

# 1. Atualizar sistema
log "Atualizando sistema..."
sudo apt update && sudo apt upgrade -y

# 2. Instalar dependências
log "Instalando dependências..."
sudo apt install -y curl wget git ufw

# 3. Instalar Docker
log "Instalando Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    log "Docker instalado com sucesso"
else
    log "Docker já está instalado"
fi

# 4. Instalar Docker Compose
log "Instalando Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    log "Docker Compose instalado com sucesso"
else
    log "Docker Compose já está instalado"
fi

# 5. Configurar firewall
log "Configurando firewall..."
sudo ufw --force enable
sudo ufw allow ssh
sudo ufw allow $APP_PORT
sudo ufw allow 80
sudo ufw allow 443
log "Firewall configurado"

# 6. Clonar/atualizar repositório
log "Configurando aplicação..."
if [ -d "$APP_NAME" ]; then
    log "Atualizando repositório existente..."
    cd $APP_NAME
    git pull origin main
else
    log "Clonando repositório..."
    git clone $REPO_URL
    cd $APP_NAME
fi

# 7. Configurar permissões
log "Configurando permissões..."
chmod +x *.sh 2>/dev/null || true
sudo chown -R $USER:$USER .

# 8. Parar containers existentes
log "Parando containers existentes..."
docker-compose down 2>/dev/null || true

# 9. Construir e iniciar aplicação
log "Construindo e iniciando aplicação..."
docker-compose build --no-cache
docker-compose up -d

# 10. Aguardar aplicação inicializar
log "Aguardando aplicação inicializar..."
sleep 10

# 11. Testar aplicação
log "Testando aplicação..."
if curl -s http://localhost:$APP_PORT/api/health > /dev/null; then
    log "✅ Aplicação funcionando localmente"
else
    error "❌ Aplicação não está funcionando localmente"
fi

# 12. Configurar serviço systemd
log "Configurando serviço systemd..."
sudo tee /etc/systemd/system/$SERVICE_NAME > /dev/null <<EOF
[Unit]
Description=Site de Homenagens 7º Ano
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$(pwd)
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

# 13. Habilitar e iniciar serviço
log "Habilitando serviço systemd..."
sudo systemctl daemon-reload
sudo systemctl enable $SERVICE_NAME
sudo systemctl start $SERVICE_NAME

# 14. Configurar backup automático
log "Configurando backup automático..."
cat > backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/home/$USER/backups"
APP_DIR="$(pwd)"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Backup dos dados
tar -czf "$BACKUP_DIR/backup_$DATE.tar.gz" \
    -C $APP_DIR \
    static/uploads/ \
    /tmp/tributes_data.json 2>/dev/null || true

# Manter apenas os últimos 7 backups
cd $BACKUP_DIR
ls -t backup_*.tar.gz | tail -n +8 | xargs -r rm

echo "Backup criado: backup_$DATE.tar.gz"
EOF

chmod +x backup.sh

# 15. Configurar cron para backup
log "Configurando backup automático..."
(crontab -l 2>/dev/null; echo "0 */6 * * * cd $(pwd) && ./backup.sh") | crontab -

# 16. Criar script de monitoramento
log "Criando script de monitoramento..."
cat > monitor.sh << 'EOF'
#!/bin/bash
echo "=== Status da Aplicação ==="
docker-compose ps
echo ""
echo "=== Health Check ==="
curl -s http://localhost:8080/api/health | python3 -m json.tool 2>/dev/null || curl -s http://localhost:8080/api/health
echo ""
echo "=== Uso de Recursos ==="
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"
EOF

chmod +x monitor.sh

# 17. Teste final
log "Executando teste final..."
./monitor.sh

# 18. Informações finais
echo -e "\n${GREEN}=========================================="
echo "🎉 Deploy concluído com sucesso!"
echo "==========================================${NC}"
echo -e "${BLUE}URLs de acesso:${NC}"
echo -e "  • Site Principal: ${YELLOW}http://45.70.136.66:$APP_PORT${NC}"
echo -e "  • Página Admin: ${YELLOW}http://45.70.136.66:$APP_PORT/admin${NC}"
echo -e "  • API Health: ${YELLOW}http://45.70.136.66:$APP_PORT/api/health${NC}"
echo ""
echo -e "${BLUE}Comandos úteis:${NC}"
echo -e "  • Ver status: ${YELLOW}./monitor.sh${NC}"
echo -e "  • Ver logs: ${YELLOW}docker-compose logs -f web${NC}"
echo -e "  • Reiniciar: ${YELLOW}docker-compose restart${NC}"
echo -e "  • Backup: ${YELLOW}./backup.sh${NC}"
echo ""
echo -e "${BLUE}Serviço systemd:${NC}"
echo -e "  • Status: ${YELLOW}sudo systemctl status $SERVICE_NAME${NC}"
echo -e "  • Reiniciar: ${YELLOW}sudo systemctl restart $SERVICE_NAME${NC}"
echo ""
echo -e "${GREEN}✅ Aplicação rodando e acessível!${NC}"
