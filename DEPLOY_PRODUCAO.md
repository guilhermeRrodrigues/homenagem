# 🚀 Deploy em Produção - Site de Homenagens 7º Ano

## 📋 Configuração para Servidor 45.70.136.66

### 1. Conectar ao Servidor

```bash
ssh joao@45.70.136.66
```

### 2. Atualizar Sistema e Instalar Docker

```bash
# Atualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar dependências
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Adicionar repositório Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Instalar Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Instalar Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER

# Fazer logout e login novamente
exit
ssh joao@45.70.136.66
```

### 3. Criar Diretório do Projeto

```bash
# Criar diretório
mkdir -p ~/homenagens-producao
cd ~/homenagens-producao
```

### 4. Fazer Upload dos Arquivos

#### Opção A: Via SCP (do seu computador local)
```bash
# No seu computador local, execute:
scp -r /docker/omenagem/* joao@45.70.136.66:~/homenagens-producao/
```

#### Opção B: Criar arquivos manualmente no servidor
```bash
# Criar todos os arquivos necessários
nano app.py
# Cole o conteúdo do app.py

nano requirements.txt
# Cole o conteúdo do requirements.txt

nano Dockerfile
# Cole o conteúdo do Dockerfile

nano docker-compose.yml
# Cole o conteúdo do docker-compose.yml

# Criar diretórios
mkdir -p templates static/css static/js static/uploads
```

### 5. Configurar docker-compose.yml para Produção

```bash
nano docker-compose.yml
```

Conteúdo:
```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "80:5000"  # Mapear para porta 80 (HTTP padrão)
    environment:
      - FLASK_ENV=production
      - SECRET_KEY=homenagens-7ano-super-secret-key-2024
    volumes:
      - ./static/uploads:/app/static/uploads
      - /tmp/tributes_data.json:/tmp/tributes_data.json
    restart: unless-stopped
    networks:
      - app-network
    # Configurações de produção
    deploy:
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M

networks:
  app-network:
    driver: bridge
```

### 6. Configurar Firewall

```bash
# Instalar UFW
sudo apt install ufw -y

# Configurar regras
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 443

# Ativar firewall
sudo ufw enable

# Verificar status
sudo ufw status
```

### 7. Construir e Executar em Background

```bash
# Construir a imagem
docker-compose build

# Executar em background (modo daemon)
docker-compose up -d

# Verificar se está rodando
docker-compose ps
```

### 8. Verificar se Está Funcionando

```bash
# Verificar logs
docker-compose logs -f web

# Testar localmente no servidor
curl http://localhost/api/health

# Verificar se está rodando na porta 80
sudo netstat -tulpn | grep :80
```

### 9. Configurar Inicialização Automática

```bash
# Criar script de inicialização
sudo nano /etc/systemd/system/homenagens.service
```

Conteúdo do arquivo:
```ini
[Unit]
Description=Site de Homenagens 7º Ano
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/joao/homenagens-producao
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
```

```bash
# Ativar serviço
sudo systemctl enable homenagens.service
sudo systemctl start homenagens.service

# Verificar status
sudo systemctl status homenagens.service
```

### 10. Configurar Backup Automático

```bash
# Criar script de backup
nano ~/backup-homenagens.sh
```

Conteúdo:
```bash
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
```

```bash
# Tornar executável
chmod +x ~/backup-homenagens.sh

# Adicionar ao crontab (backup diário às 2h)
crontab -e
# Adicionar esta linha:
0 2 * * * /home/joao/backup-homenagens.sh
```

### 11. Script de Monitoramento

```bash
# Criar script de monitoramento
nano ~/monitor-homenagens.sh
```

Conteúdo:
```bash
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
```

```bash
# Tornar executável
chmod +x ~/monitor-homenagens.sh

# Executar monitoramento
./monitor-homenagens.sh
```

### 12. Comandos Úteis

```bash
# Ver logs em tempo real
docker-compose logs -f web

# Reiniciar aplicação
docker-compose restart

# Parar aplicação
docker-compose down

# Iniciar aplicação
docker-compose up -d

# Ver status
docker-compose ps

# Atualizar aplicação
docker-compose down
docker-compose build
docker-compose up -d

# Verificar uso de recursos
docker stats

# Limpar imagens não utilizadas
docker system prune -a
```

### 13. Acessar o Site

Após configurar tudo, o site estará disponível em:

- **URL Principal**: `http://45.70.136.66`
- **Administração**: `http://45.70.136.66/admin`

### 14. Configurar Domínio (Opcional)

Se quiser usar um domínio personalizado:

```bash
# Instalar Nginx
sudo apt install nginx -y

# Criar configuração
sudo nano /etc/nginx/sites-available/homenagens
```

Conteúdo:
```nginx
server {
    listen 80;
    server_name seu-dominio.com www.seu-dominio.com;

    location / {
        proxy_pass http://localhost:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```bash
# Ativar site
sudo ln -s /etc/nginx/sites-available/homenagens /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### 15. Verificação Final

```bash
# Verificar se tudo está funcionando
curl http://45.70.136.66/api/health

# Verificar se está rodando 24/7
sudo systemctl status homenagens.service

# Verificar logs
docker-compose logs web
```

## 🎉 Resultado Final

Após seguir todos os passos:

✅ **Site rodando 24/7** em background  
✅ **Acessível via IP**: `http://45.70.136.66`  
✅ **Reinicialização automática** em caso de falha  
✅ **Backup automático** diário  
✅ **Monitoramento** configurado  
✅ **Firewall** configurado  

O site estará **100% funcional** e **sempre online**! 🚀
