# 🐳 Omenagem - Docker Setup

Aplicação de homenagens containerizada para Ubuntu Server 24.04.2 LTS.

## 📋 Pré-requisitos

- Ubuntu Server 24.04.2 LTS
- Docker 20.10+
- Docker Compose 1.29+

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

- **Aplicação**: http://localhost
- **Admin**: http://localhost/admin
- **API Health**: http://localhost/api/health
- **API Info**: http://localhost/api/info

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
curl http://localhost/api/health
```

## 📁 Estrutura de Volumes

- `./data` → Dados das homenagens (persistente)
- `./static/uploads` → Imagens enviadas (persistente)

## 🔒 Configurações de Segurança

- Container roda como usuário não-root
- Health check configurado
- Restart automático configurado
- Volumes montados para persistência

## 🐛 Troubleshooting

### Aplicação não inicia
```bash
# Verificar logs
docker-compose logs

# Verificar se a porta 80 está livre
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
