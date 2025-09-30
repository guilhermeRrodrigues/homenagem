# 🚀 Deploy Final - Site de Homenagens 7º Ano

## 📋 **Resumo do Projeto**
- **Aplicação**: Site de Homenagens com navegação por setas
- **Tecnologia**: Flask + Docker + Nginx
- **Porta**: 8080 (configurada para evitar problemas de porta privilegiada)
- **Persistência**: JSON file em `/tmp/tributes_data.json`

## 🔧 **Arquivos Principais**

### **1. Estrutura do Projeto**
```
omenagem/
├── app.py                 # Aplicação Flask principal
├── requirements.txt       # Dependências Python
├── Dockerfile            # Configuração Docker
├── docker-compose.yml    # Orquestração de containers
├── nginx-prod.conf       # Configuração Nginx
├── deploy-final.sh       # Script de deploy automatizado
├── test-deploy.sh        # Script de teste
└── templates/            # Templates HTML
    ├── base.html
    ├── tributes.html
    └── admin.html
└── static/               # Arquivos estáticos
    ├── css/style.css
    ├── js/main.js
    └── uploads/          # Diretório de imagens
```

## 🚀 **Deploy Rápido no Servidor**

### **Passo 1: Conectar ao Servidor**
```bash
ssh usuario@45.70.136.66
```

### **Passo 2: Executar Script de Deploy**
```bash
# Baixar e executar o script de deploy
curl -sSL https://raw.githubusercontent.com/guilhermeRrodrigues/omenagem/main/deploy-final.sh | bash

# OU se preferir baixar primeiro:
wget https://raw.githubusercontent.com/guilhermeRrodrigues/omenagem/main/deploy-final.sh
chmod +x deploy-final.sh
./deploy-final.sh
```

### **Passo 3: Verificar Deploy**
```bash
# Testar localmente no servidor
curl http://localhost:8080/api/health

# Verificar status
docker-compose ps

# Ver logs
docker-compose logs -f web
```

## 🌐 **Acessar a Aplicação**

- **URL Principal**: `http://45.70.136.66:8080`
- **Página Admin**: `http://45.70.136.66:8080/admin`
- **API Health**: `http://45.70.136.66:8080/api/health`
- **API Debug**: `http://45.70.136.66:8080/api/debug`

## 🔧 **Configurações Importantes**

### **Portas e Firewall**
- **Porta da Aplicação**: 8080
- **Firewall**: UFW configurado automaticamente
- **Docker**: Configurado para escutar em 0.0.0.0:8080

### **Persistência de Dados**
- **Arquivo de Dados**: `/tmp/tributes_data.json`
- **Uploads**: `static/uploads/`
- **Backup Automático**: A cada 6 horas

### **Logs e Monitoramento**
- **Logs da Aplicação**: `docker-compose logs web`
- **Logs do Sistema**: `journalctl -u omenagem.service`
- **Monitoramento**: Script `monitor.sh` incluído

## 🛠️ **Comandos de Gerenciamento**

### **Gerenciar Aplicação**
```bash
# Iniciar
docker-compose up -d

# Parar
docker-compose down

# Reiniciar
docker-compose restart

# Ver status
docker-compose ps

# Ver logs
docker-compose logs -f web
```

### **Gerenciar Serviço Systemd**
```bash
# Iniciar serviço
sudo systemctl start omenagem

# Parar serviço
sudo systemctl stop omenagem

# Reiniciar serviço
sudo systemctl restart omenagem

# Ver status
sudo systemctl status omenagem

# Habilitar inicialização automática
sudo systemctl enable omenagem
```

### **Backup e Restore**
```bash
# Backup manual
./backup.sh

# Restore
./restore.sh backup_YYYYMMDD_HHMMSS.tar.gz
```

## 🔍 **Troubleshooting**

### **Problema: Site não abre externamente**
```bash
# 1. Verificar se está rodando
docker-compose ps

# 2. Verificar firewall
sudo ufw status

# 3. Verificar portas
ss -tulpn | grep :8080

# 4. Testar localmente
curl http://localhost:8080/api/health
```

### **Problema: Erro de permissão**
```bash
# Corrigir permissões
sudo chown -R $USER:$USER .
sudo chmod +x *.sh
```

### **Problema: Container não inicia**
```bash
# Ver logs detalhados
docker-compose logs web

# Reconstruir container
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## 📊 **Monitoramento**

### **Scripts Incluídos**
- `monitor.sh` - Monitora status da aplicação
- `test-deploy.sh` - Testa todos os endpoints
- `backup.sh` - Backup automático dos dados

### **Endpoints de Monitoramento**
- `/api/health` - Status da aplicação
- `/api/debug` - Informações detalhadas de debug
- `/api/info` - Informações da aplicação

## 🔒 **Segurança**

### **Configurações Aplicadas**
- ✅ Usuário não-root no container
- ✅ Firewall UFW configurado
- ✅ Apenas portas necessárias abertas
- ✅ Validação de uploads de imagem
- ✅ Sanitização de nomes de arquivo

### **Recomendações Adicionais**
- Configure SSL/HTTPS com Let's Encrypt
- Configure backup automático
- Monitore logs regularmente
- Mantenha o sistema atualizado

## 📞 **Suporte**

### **Logs Importantes**
```bash
# Logs da aplicação
docker-compose logs web

# Logs do sistema
journalctl -u omenagem.service -f

# Logs do Docker
journalctl -u docker.service -f
```

### **Informações do Sistema**
```bash
# Status geral
./test-deploy.sh

# Informações detalhadas
curl http://localhost:8080/api/debug
```

---

## 🎯 **Checklist de Deploy**

- [ ] Servidor acessível via SSH
- [ ] Docker e Docker Compose instalados
- [ ] Firewall configurado (porta 8080)
- [ ] Aplicação rodando (`docker-compose ps`)
- [ ] Teste local funcionando (`curl localhost:8080/api/health`)
- [ ] Acesso externo funcionando (`http://45.70.136.66:8080`)
- [ ] Página admin acessível (`http://45.70.136.66:8080/admin`)
- [ ] Upload de imagens funcionando
- [ ] Persistência de dados funcionando
- [ ] Serviço systemd configurado
- [ ] Backup automático configurado

**✅ Deploy concluído com sucesso!**
