#!/bin/bash

# Script de Deploy Automático - Site de Homenagens 7º Ano
# Execute no servidor: bash deploy-producao.sh

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  Deploy em Produção - Homenagens ${NC}"
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

# Verificar se é root
if [ "$EUID" -eq 0 ]; then
    print_error "Não execute como root! Use um usuário normal com sudo."
    exit 1
fi

print_header

# 1. Atualizar sistema
print_status "Atualizando sistema..."
sudo apt update && sudo apt upgrade -y

# 2. Instalar Docker se não estiver instalado
if ! command -v docker &> /dev/null; then
    print_status "Instalando Docker..."
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" -y
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io
    sudo usermod -aG docker $USER
    print_success "Docker instalado"
else
    print_success "Docker já está instalado"
fi

# 3. Instalar Docker Compose se não estiver instalado
if ! command -v docker-compose &> /dev/null; then
    print_status "Instalando Docker Compose..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    print_success "Docker Compose instalado"
else
    print_success "Docker Compose já está instalado"
fi

# 4. Criar diretório do projeto
PROJECT_DIR="$HOME/homenagens-producao"
print_status "Criando diretório do projeto: $PROJECT_DIR"
mkdir -p $PROJECT_DIR
cd $PROJECT_DIR

# 5. Criar docker-compose.yml para produção
print_status "Criando docker-compose.yml para produção..."
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  web:
    build: .
    ports:
      - "80:5000"
    environment:
      - FLASK_ENV=production
      - SECRET_KEY=homenagens-7ano-super-secret-key-2024
    volumes:
      - ./static/uploads:/app/static/uploads
      - /tmp/tributes_data.json:/tmp/tributes_data.json
    restart: unless-stopped
    networks:
      - app-network
    deploy:
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M

networks:
  app-network:
    driver: bridge
EOF

# 6. Criar Dockerfile
print_status "Criando Dockerfile..."
cat > Dockerfile << 'EOF'
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV FLASK_ENV=production

WORKDIR /app

RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN mkdir -p /app/static/uploads
RUN adduser --disabled-password --gecos '' appuser && chown -R appuser:appuser /app
RUN chmod -R 755 /app/static/uploads
USER appuser

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "4", "app:app"]
EOF

# 7. Criar requirements.txt
print_status "Criando requirements.txt..."
cat > requirements.txt << 'EOF'
Flask==2.3.3
Werkzeug==2.3.7
Jinja2==3.1.2
MarkupSafe==2.1.3
itsdangerous==2.1.2
click==8.1.7
blinker==1.6.2
gunicorn==21.2.0
python-dotenv==1.0.0
EOF

# 8. Criar diretórios necessários
print_status "Criando diretórios necessários..."
mkdir -p templates static/css static/js static/uploads

print_warning "IMPORTANTE: Você precisa fazer upload dos seguintes arquivos:"
echo "  - app.py"
echo "  - templates/base.html"
echo "  - templates/tributes.html"
echo "  - templates/admin.html"
echo "  - static/css/style.css"
echo "  - static/js/main.js"

# 9. Configurar firewall
print_status "Configurando firewall..."
sudo ufw --force enable
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 443
print_success "Firewall configurado"

# 10. Criar script de backup
print_status "Criando script de backup..."
cat > backup.sh << 'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$HOME/backups"
PROJECT_DIR="$HOME/homenagens-producao"

mkdir -p $BACKUP_DIR

# Backup do arquivo de dados
if [ -f "/tmp/tributes_data.json" ]; then
    cp /tmp/tributes_data.json $BACKUP_DIR/tributes_data_$DATE.json
fi

# Backup das imagens
if [ -d "$PROJECT_DIR/static/uploads" ]; then
    tar -czf $BACKUP_DIR/uploads_$DATE.tar.gz -C $PROJECT_DIR static/uploads/
fi

# Manter apenas os últimos 7 backups
find $BACKUP_DIR -name "tributes_data_*.json" -mtime +7 -delete
find $BACKUP_DIR -name "uploads_*.tar.gz" -mtime +7 -delete

echo "Backup realizado em $DATE"
EOF

chmod +x backup.sh

# 11. Criar script de monitoramento
print_status "Criando script de monitoramento..."
cat > monitor.sh << 'EOF'
#!/bin/bash

echo "=== Status do Site de Homenagens ==="
echo "Data: $(date)"
echo ""

# Verificar containers
echo "=== Containers ==="
docker-compose ps

echo ""
echo "=== Uso de Recursos ==="
docker stats --no-stream

echo ""
echo "=== Teste de Conectividade ==="
if curl -s -f http://localhost/api/health > /dev/null; then
    echo "✅ API está respondendo"
else
    echo "❌ API não está respondendo"
fi

echo ""
echo "=== Espaço em Disco ==="
df -h | grep -E "(Filesystem|/dev/)"

echo ""
echo "=== Logs Recentes ==="
docker-compose logs --tail=10 web
EOF

chmod +x monitor.sh

# 12. Criar script de gerenciamento
print_status "Criando script de gerenciamento..."
cat > manage.sh << 'EOF'
#!/bin/bash

case "$1" in
    start)
        echo "Iniciando aplicação..."
        docker-compose up -d
        ;;
    stop)
        echo "Parando aplicação..."
        docker-compose down
        ;;
    restart)
        echo "Reiniciando aplicação..."
        docker-compose restart
        ;;
    logs)
        echo "Mostrando logs..."
        docker-compose logs -f web
        ;;
    status)
        echo "Status da aplicação..."
        docker-compose ps
        ;;
    update)
        echo "Atualizando aplicação..."
        docker-compose down
        docker-compose build
        docker-compose up -d
        ;;
    backup)
        echo "Fazendo backup..."
        ./backup.sh
        ;;
    monitor)
        echo "Executando monitoramento..."
        ./monitor.sh
        ;;
    *)
        echo "Uso: $0 {start|stop|restart|logs|status|update|backup|monitor}"
        exit 1
        ;;
esac
EOF

chmod +x manage.sh

# 13. Configurar backup automático
print_status "Configurando backup automático..."
(crontab -l 2>/dev/null; echo "0 2 * * * $PROJECT_DIR/backup.sh") | crontab -

# 14. Criar serviço systemd
print_status "Criando serviço systemd..."
sudo tee /etc/systemd/system/homenagens.service > /dev/null << EOF
[Unit]
Description=Site de Homenagens 7º Ano
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$PROJECT_DIR
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable homenagens.service

print_success "Serviço systemd criado e habilitado"

print_success "🎉 Deploy base concluído!"
print_warning "Próximos passos:"
echo "1. Faça upload dos arquivos do projeto para $PROJECT_DIR"
echo "2. Execute: cd $PROJECT_DIR"
echo "3. Execute: ./manage.sh start"
echo "4. Acesse: http://$(curl -s ifconfig.me)"

print_status "Comandos disponíveis:"
echo "  ./manage.sh start    - Iniciar aplicação"
echo "  ./manage.sh stop     - Parar aplicação"
echo "  ./manage.sh restart  - Reiniciar aplicação"
echo "  ./manage.sh logs     - Ver logs"
echo "  ./manage.sh status   - Ver status"
echo "  ./manage.sh update   - Atualizar aplicação"
echo "  ./manage.sh backup   - Fazer backup"
echo "  ./manage.sh monitor  - Executar monitoramento"

print_warning "IMPORTANTE: Faça logout e login novamente para aplicar as permissões do Docker"
print_status "Depois disso, faça upload dos arquivos e execute: ./manage.sh start"
