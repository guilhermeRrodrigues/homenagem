#!/bin/bash

echo "=========================================="
echo "Teste de Portas - Diagnóstico de Conectividade"
echo "=========================================="

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para testar porta
test_port() {
    local port=$1
    local description=$2
    
    echo -e "\n${YELLOW}Testando porta $port: $description${NC}"
    
    # Testar conectividade TCP
    timeout 5 bash -c "echo > /dev/tcp/45.70.136.66/$port" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Porta $port está aberta e acessível${NC}"
        
        # Testar HTTP se a porta estiver aberta
        response=$(curl -s --connect-timeout 5 "http://45.70.136.66:$port/api/health" 2>/dev/null)
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ HTTP funcionando na porta $port${NC}"
            echo "Resposta: $response"
        else
            echo -e "${YELLOW}⚠ Porta $port aberta mas HTTP não responde${NC}"
        fi
    else
        echo -e "${RED}✗ Porta $port está fechada ou bloqueada${NC}"
    fi
}

# Testar portas comuns
echo -e "\n${BLUE}=== TESTANDO PORTAS COMUNS ===${NC}"
test_port 80 "HTTP padrão"
test_port 443 "HTTPS padrão"
test_port 8080 "Nossa aplicação"
test_port 3000 "Porta alternativa 1"
test_port 5000 "Porta alternativa 2"
test_port 8000 "Porta alternativa 3"

# Verificar status do firewall local
echo -e "\n${BLUE}=== STATUS DO FIREWALL LOCAL ===${NC}"
sudo ufw status

# Verificar portas em uso localmente
echo -e "\n${BLUE}=== PORTAS EM USO LOCALMENTE ===${NC}"
ss -tulpn | grep -E ":(80|8080|3000|5000|8000)"

# Verificar se o container está rodando
echo -e "\n${BLUE}=== STATUS DO CONTAINER ===${NC}"
docker-compose ps

# Testar conectividade local
echo -e "\n${BLUE}=== TESTE LOCAL ===${NC}"
curl -s http://localhost:8080/api/health && echo -e "\n${GREEN}✓ Aplicação funcionando localmente${NC}" || echo -e "\n${RED}✗ Aplicação não está funcionando localmente${NC}"

echo -e "\n${GREEN}=========================================="
echo "Diagnóstico concluído!"
echo "==========================================${NC}"
