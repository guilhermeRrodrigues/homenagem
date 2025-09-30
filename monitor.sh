#!/bin/bash

# ==========================================
# Script de Monitoramento - Site de Homenagens
# ==========================================

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================="
echo "📊 Monitoramento - Site de Homenagens"
echo "==========================================${NC}"

# Função para verificar status
check_status() {
    local service=$1
    local description=$2
    
    if systemctl is-active --quiet $service; then
        echo -e "${GREEN}✓ $description${NC}"
        return 0
    else
        echo -e "${RED}✗ $description${NC}"
        return 1
    fi
}

# 1. Status dos containers
echo -e "\n${BLUE}=== STATUS DOS CONTAINERS ===${NC}"
docker-compose ps

# 2. Status dos serviços
echo -e "\n${BLUE}=== STATUS DOS SERVIÇOS ===${NC}"
check_status "docker.service" "Docker Service"
check_status "omenagem.service" "Aplicação (Systemd)"

# 3. Verificação de portas
echo -e "\n${BLUE}=== PORTAS EM USO ===${NC}"
ss -tulpn | grep -E ":(80|8080|5000)" | while read line; do
    echo -e "${GREEN}✓ $line${NC}"
done

# 4. Health check da aplicação
echo -e "\n${BLUE}=== HEALTH CHECK ===${NC}"
if curl -s http://localhost:8080/api/health > /dev/null; then
    echo -e "${GREEN}✓ Aplicação respondendo${NC}"
    
    # Mostrar informações detalhadas
    echo -e "\n${YELLOW}Informações da aplicação:${NC}"
    curl -s http://localhost:8080/api/health | python3 -m json.tool 2>/dev/null || curl -s http://localhost:8080/api/health
else
    echo -e "${RED}✗ Aplicação não está respondendo${NC}"
fi

# 5. Uso de recursos
echo -e "\n${BLUE}=== USO DE RECURSOS ===${NC}"
echo -e "${YELLOW}Containers:${NC}"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"

# 6. Espaço em disco
echo -e "\n${YELLOW}Espaço em disco:${NC}"
df -h / | tail -1 | awk '{print "Uso: " $5 " (" $3 "/" $2 ")"}'

# 7. Verificação de arquivos importantes
echo -e "\n${BLUE}=== ARQUIVOS IMPORTANTES ===${NC}"
if [ -f "/tmp/tributes_data.json" ]; then
    echo -e "${GREEN}✓ Arquivo de dados existe${NC}"
    tribute_count=$(cat /tmp/tributes_data.json | grep -o '"id"' | wc -l)
    echo -e "  • Homenagens: ${YELLOW}$tribute_count${NC}"
else
    echo -e "${RED}✗ Arquivo de dados não encontrado${NC}"
fi

if [ -d "static/uploads" ]; then
    echo -e "${GREEN}✓ Diretório de uploads existe${NC}"
    upload_count=$(find static/uploads -type f | wc -l)
    echo -e "  • Imagens: ${YELLOW}$upload_count${NC}"
else
    echo -e "${RED}✗ Diretório de uploads não encontrado${NC}"
fi

# 8. Logs recentes
echo -e "\n${BLUE}=== LOGS RECENTES ===${NC}"
echo -e "${YELLOW}Últimas 5 linhas dos logs da aplicação:${NC}"
docker-compose logs --tail=5 web

# 9. Status do firewall
echo -e "\n${BLUE}=== FIREWALL ===${NC}"
sudo ufw status | grep -E "(8080|80|443)" | while read line; do
    echo -e "${GREEN}✓ $line${NC}"
done

# 10. Conectividade externa
echo -e "\n${BLUE}=== CONECTIVIDADE EXTERNA ===${NC}"
if timeout 5 curl -s http://45.70.136.66:8080/api/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Acesso externo funcionando${NC}"
else
    echo -e "${YELLOW}⚠ Acesso externo pode não estar funcionando${NC}"
fi

# 11. Resumo
echo -e "\n${BLUE}=========================================="
echo "📋 RESUMO"
echo "==========================================${NC}"

# Contar problemas
problems=0

if ! docker-compose ps | grep -q "Up"; then
    ((problems++))
fi

if ! curl -s http://localhost:8080/api/health > /dev/null; then
    ((problems++))
fi

if [ $problems -eq 0 ]; then
    echo -e "${GREEN}🎉 Tudo funcionando perfeitamente!${NC}"
    echo -e "\n${BLUE}URLs de acesso:${NC}"
    echo -e "  • Site: ${YELLOW}http://45.70.136.66:8080${NC}"
    echo -e "  • Admin: ${YELLOW}http://45.70.136.66:8080/admin${NC}"
else
    echo -e "${RED}⚠ $problems problema(s) detectado(s)${NC}"
    echo -e "\n${YELLOW}Comandos para diagnóstico:${NC}"
    echo -e "  • Ver logs: ${YELLOW}docker-compose logs -f web${NC}"
    echo -e "  • Reiniciar: ${YELLOW}docker-compose restart${NC}"
    echo -e "  • Teste completo: ${YELLOW}./test-deploy.sh${NC}"
fi

echo -e "\n${BLUE}==========================================${NC}"