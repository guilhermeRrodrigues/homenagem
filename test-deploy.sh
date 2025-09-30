#!/bin/bash

# ==========================================
# Script de Teste - Site de Homenagens
# ==========================================

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================="
echo "🧪 Teste Completo - Site de Homenagens"
echo "==========================================${NC}"

# Contadores
TESTS_PASSED=0
TESTS_FAILED=0

# Função para testar endpoint
test_endpoint() {
    local url=$1
    local description=$2
    local expected_status=${3:-200}
    
    echo -e "\n${YELLOW}Testando: $description${NC}"
    echo "URL: $url"
    
    response=$(curl -s -w "\n%{http_code}" "$url" 2>/dev/null)
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" -eq "$expected_status" ]; then
        echo -e "${GREEN}✓ Sucesso (HTTP $http_code)${NC}"
        echo "Resposta: $body"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗ Falhou (HTTP $http_code)${NC}"
        echo "Resposta: $body"
        ((TESTS_FAILED++))
        return 1
    fi
}

# 1. Verificar se Docker está rodando
echo -e "\n${BLUE}=== VERIFICAÇÃO DO DOCKER ===${NC}"
if docker --version > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Docker instalado${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗ Docker não encontrado${NC}"
    ((TESTS_FAILED++))
fi

if docker-compose --version > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Docker Compose instalado${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗ Docker Compose não encontrado${NC}"
    ((TESTS_FAILED++))
fi

# 2. Verificar containers
echo -e "\n${BLUE}=== STATUS DOS CONTAINERS ===${NC}"
if docker-compose ps | grep -q "Up"; then
    echo -e "${GREEN}✓ Container rodando${NC}"
    docker-compose ps
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗ Nenhum container rodando${NC}"
    docker-compose ps
    ((TESTS_FAILED++))
fi

# 3. Verificar portas
echo -e "\n${BLUE}=== VERIFICAÇÃO DE PORTAS ===${NC}"
if ss -tulpn | grep -q ":8080"; then
    echo -e "${GREEN}✓ Porta 8080 está escutando${NC}"
    ss -tulpn | grep ":8080"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗ Porta 8080 não está escutando${NC}"
    ((TESTS_FAILED++))
fi

# 4. Verificar firewall
echo -e "\n${BLUE}=== VERIFICAÇÃO DO FIREWALL ===${NC}"
if sudo ufw status | grep -q "8080"; then
    echo -e "${GREEN}✓ Porta 8080 liberada no firewall${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${YELLOW}⚠ Porta 8080 pode não estar liberada no firewall${NC}"
    sudo ufw status
fi

# 5. Testar endpoints locais
echo -e "\n${BLUE}=== TESTES LOCAIS ===${NC}"
test_endpoint "http://localhost:8080/api/health" "Health Check"
test_endpoint "http://localhost:8080/api/debug" "Debug Info"
test_endpoint "http://localhost:8080/api/info" "App Info"
test_endpoint "http://localhost:8080/api/tributes" "Listar Homenagens"
test_endpoint "http://localhost:8080/" "Página Principal"
test_endpoint "http://localhost:8080/admin" "Página Admin"

# 6. Testar funcionalidades da API
echo -e "\n${BLUE}=== TESTE DE FUNCIONALIDADES ===${NC}"

# Testar adicionar homenagem
echo -e "\n${YELLOW}Testando: Adicionar Homenagem${NC}"
add_response=$(curl -s -X POST http://localhost:8080/api/tributes \
    -H "Content-Type: application/json" \
    -d '{"message": "Teste de homenagem", "author": "Sistema de Teste"}')

if echo "$add_response" | grep -q "success"; then
    echo -e "${GREEN}✓ Homenagem adicionada com sucesso${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗ Falha ao adicionar homenagem${NC}"
    echo "Resposta: $add_response"
    ((TESTS_FAILED++))
fi

# Testar navegação
test_endpoint "http://localhost:8080/api/tributes/current" "Homenagem Atual"
test_endpoint "http://localhost:8080/api/tributes/next" "Próxima Homenagem"
test_endpoint "http://localhost:8080/api/tributes/previous" "Homenagem Anterior"

# 7. Verificar arquivos de dados
echo -e "\n${BLUE}=== VERIFICAÇÃO DE DADOS ===${NC}"
if [ -f "/tmp/tributes_data.json" ]; then
    echo -e "${GREEN}✓ Arquivo de dados existe${NC}"
    echo "Conteúdo: $(cat /tmp/tributes_data.json | head -c 100)..."
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗ Arquivo de dados não encontrado${NC}"
    ((TESTS_FAILED++))
fi

if [ -d "static/uploads" ]; then
    echo -e "${GREEN}✓ Diretório de uploads existe${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${RED}✗ Diretório de uploads não encontrado${NC}"
    ((TESTS_FAILED++))
fi

# 8. Verificar serviço systemd
echo -e "\n${BLUE}=== VERIFICAÇÃO DO SERVIÇO ===${NC}"
if systemctl is-active --quiet omenagem.service; then
    echo -e "${GREEN}✓ Serviço systemd ativo${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${YELLOW}⚠ Serviço systemd não está ativo${NC}"
    sudo systemctl status omenagem.service
fi

# 9. Teste de conectividade externa (opcional)
echo -e "\n${BLUE}=== TESTE DE CONECTIVIDADE EXTERNA ===${NC}"
echo -e "${YELLOW}Testando acesso externo...${NC}"
if timeout 5 curl -s http://45.70.136.66:8080/api/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Acesso externo funcionando${NC}"
    ((TESTS_PASSED++))
else
    echo -e "${YELLOW}⚠ Acesso externo pode não estar funcionando${NC}"
    echo "Isso pode ser normal se estiver testando de uma máquina externa"
fi

# 10. Resumo final
echo -e "\n${BLUE}=========================================="
echo "📊 RESUMO DOS TESTES"
echo "==========================================${NC}"
echo -e "${GREEN}Testes aprovados: $TESTS_PASSED${NC}"
echo -e "${RED}Testes falharam: $TESTS_FAILED${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}🎉 Todos os testes passaram! Aplicação funcionando perfeitamente.${NC}"
    echo -e "\n${BLUE}URLs de acesso:${NC}"
    echo -e "  • Site: ${YELLOW}http://45.70.136.66:8080${NC}"
    echo -e "  • Admin: ${YELLOW}http://45.70.136.66:8080/admin${NC}"
    exit 0
else
    echo -e "\n${RED}❌ Alguns testes falharam. Verifique os erros acima.${NC}"
    exit 1
fi
