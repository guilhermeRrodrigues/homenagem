# 🐳 Omenagem - Docker Setup

Aplicação de homenagens containerizada para Ubuntu Server 24.04.2 LTS.

## 📋 Pré-requisitos

- Ubuntu Server 24.04.2 LTS
- Docker 20.10+
- Docker Compose 1.29+
- IP do servidor: 45.70.136.66
- Porta 80 liberada no firewall

## 🚀 Inicialização Rápida

### Opção 1: Script Automático
```bash
./start.sh
```

### Opção 2: Comandos Manuais
```bash
# Criar diretórios necessários
mkdir -p data static/uploads

# Iniciar aplicação
docker-compose up --build -d

# Verificar status
docker-compose ps
```

## 🌐 Acesso

- **Aplicação**: http://45.70.136.66
- **Admin**: http://45.70.136.66/admin
- **API Health**: http://45.70.136.66/api/health
- **API Info**: http://45.70.136.66/api/info

## 🔧 Comandos Úteis

```bash
# Ver logs
docker-compose logs -f

# Parar aplicação
docker-compose down

# Reconstruir e reiniciar
docker-compose up --build -d

# Acessar container
docker-compose exec omenagem-app bash

# Verificar saúde
curl http://45.70.136.66/api/health
```

## 📁 Estrutura de Volumes

- `./data` → Dados das homenagens (persistente)
- `./static/uploads` → Imagens enviadas (persistente)

## 🔒 Configurações de Segurança

- Container roda como usuário não-root
- Health check configurado
- Restart automático configurado
- Volumes montados para persistência

## 🔥 Configuração de Firewall

```bash
# Liberar porta 80 no UFW
sudo ufw allow 80/tcp

# Verificar status do firewall
sudo ufw status

# Se necessário, liberar porta 80 no iptables
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
```

## 🐛 Troubleshooting

### Aplicação não inicia
```bash
# Verificar logs
docker-compose logs

# Verificar se a porta 80 está livre
sudo netstat -tlnp | grep :80

# Verificar se o IP está configurado corretamente
docker-compose ps
```

### Acesso externo não funciona
```bash
# Verificar se a porta 80 está aberta externamente
telnet 45.70.136.66 80

# Verificar configuração de rede
ip addr show

# Verificar se o Docker está escutando no IP correto
sudo netstat -tlnp | grep :80
```

### Problemas de permissão
```bash
# Corrigir permissões
sudo chown -R $USER:$USER data static/uploads
chmod 755 data static/uploads
```

### Reconstruir do zero
```bash
# Parar e remover tudo
docker-compose down -v
docker system prune -f

# Reconstruir
docker-compose up --build -d
```

## 📊 Monitoramento

```bash
# Status dos containers
docker-compose ps

# Uso de recursos
docker stats

# Logs em tempo real
docker-compose logs -f omenagem-app
```
