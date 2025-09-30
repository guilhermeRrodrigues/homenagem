#!/bin/bash

# Script de Instalação Automática - Site de Homenagens 7º Ano
# Execute com: bash install.sh

set -e  # Parar em caso de erro

echo "🚀 Iniciando instalação do Site de Homenagens 7º Ano..."

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para imprimir mensagens coloridas
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
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
    print_error "Não execute este script como root! Use um usuário normal com sudo."
    exit 1
fi

# Verificar se sudo está disponível
if ! command -v sudo &> /dev/null; then
    print_error "sudo não está instalado. Instale primeiro: apt install sudo"
    exit 1
fi

print_status "Atualizando sistema..."
sudo apt update && sudo apt upgrade -y

print_status "Instalando dependências..."
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common git

print_status "Instalando Docker..."
# Adicionar chave GPG do Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Adicionar repositório do Docker
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" -y

# Instalar Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

print_status "Instalando Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

print_status "Configurando usuário para Docker..."
sudo usermod -aG docker $USER

print_status "Criando diretório do projeto..."
PROJECT_DIR="$HOME/homenagens-7ano"
mkdir -p $PROJECT_DIR
cd $PROJECT_DIR

print_status "Criando arquivos de configuração..."

# Criar docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  web:
    build: .
    ports:
      - "80:5000"
    environment:
      - FLASK_ENV=production
      - SECRET_KEY=${SECRET_KEY:-homenagens-7ano-secret-key-2024}
    volumes:
      - ./static/uploads:/app/static/uploads
    restart: unless-stopped
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
EOF

# Criar Dockerfile
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

RUN adduser --disabled-password --gecos '' appuser && chown -R appuser:appuser /app
RUN chmod -R 755 /app/static/uploads
USER appuser

EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "4", "app:app"]
EOF

# Criar requirements.txt
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

print_status "Criando diretórios necessários..."
mkdir -p templates static/css static/js static/uploads

print_status "Baixando arquivos do projeto..."

# Aqui você precisaria fazer upload dos arquivos ou usar git
print_warning "IMPORTANTE: Você precisa fazer upload dos seguintes arquivos:"
echo "  - app.py"
echo "  - templates/base.html"
echo "  - templates/tributes.html"
echo "  - templates/admin.html"
echo "  - static/css/style.css"
echo "  - static/js/main.js"

print_status "Configurando firewall..."
sudo ufw --force enable
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80

print_status "Criando script de backup..."
cat > backup.sh << 'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$HOME/backups"
PROJECT_DIR="$HOME/homenagens-7ano"

mkdir -p $BACKUP_DIR

# Backup do arquivo de dados
if [ -f "$PROJECT_DIR/static/uploads/tributes_data.json" ]; then
    cp "$PROJECT_DIR/static/uploads/tributes_data.json" "$BACKUP_DIR/tributes_data_$DATE.json"
fi

# Backup das imagens
if [ -d "$PROJECT_DIR/static/uploads" ]; then
    tar -czf "$BACKUP_DIR/uploads_$DATE.tar.gz" -C "$PROJECT_DIR" static/uploads/
fi

# Manter apenas os últimos 7 backups
find $BACKUP_DIR -name "tributes_data_*.json" -mtime +7 -delete
find $BACKUP_DIR -name "uploads_*.tar.gz" -mtime +7 -delete

echo "Backup realizado em $DATE"
EOF

chmod +x backup.sh

print_success "Instalação base concluída!"
print_warning "Próximos passos:"
echo "1. Faça upload dos arquivos do projeto para $PROJECT_DIR"
echo "2. Execute: cd $PROJECT_DIR"
echo "3. Execute: docker-compose up --build -d"
echo "4. Acesse: http://$(curl -s ifconfig.me)"

print_status "Configurando backup automático..."
(crontab -l 2>/dev/null; echo "0 2 * * * $PROJECT_DIR/backup.sh") | crontab -

print_success "Backup automático configurado (diário às 2h)"

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
    *)
        echo "Uso: $0 {start|stop|restart|logs|status|update|backup}"
        exit 1
        ;;
esac
EOF

chmod +x manage.sh

print_success "Script de gerenciamento criado!"
print_status "Comandos disponíveis:"
echo "  ./manage.sh start    - Iniciar aplicação"
echo "  ./manage.sh stop     - Parar aplicação"
echo "  ./manage.sh restart  - Reiniciar aplicação"
echo "  ./manage.sh logs     - Ver logs"
echo "  ./manage.sh status   - Ver status"
echo "  ./manage.sh update   - Atualizar aplicação"
echo "  ./manage.sh backup   - Fazer backup"

print_success "🎉 Instalação concluída!"
print_warning "IMPORTANTE: Faça logout e login novamente para aplicar as permissões do Docker"
print_status "Depois disso, faça upload dos arquivos e execute: ./manage.sh start"
