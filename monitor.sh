#!/bin/bash

# Script de Monitoramento - Site de Homenagens 7º Ano
# Execute com: bash monitor.sh

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  Monitor do Site de Homenagens  ${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_status() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
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

# Verificar se Docker está rodando
check_docker() {
    if ! systemctl is-active --quiet docker; then
        print_error "Docker não está rodando!"
        return 1
    fi
    return 0
}

# Verificar status dos containers
check_containers() {
    print_status "Verificando containers..."
    
    if docker-compose ps | grep -q "Up"; then
        print_success "Containers estão rodando"
        docker-compose ps
    else
        print_error "Alguns containers não estão rodando!"
        docker-compose ps
        return 1
    fi
}

# Verificar uso de recursos
check_resources() {
    print_status "Verificando uso de recursos..."
    
    echo "=== Uso de Memória ==="
    free -h
    
    echo -e "\n=== Uso de Disco ==="
    df -h
    
    echo -e "\n=== Uso de CPU e Memória dos Containers ==="
    docker stats --no-stream
}

# Verificar logs de erro
check_logs() {
    print_status "Verificando logs de erro..."
    
    if docker-compose logs --tail=50 web | grep -i error; then
        print_warning "Encontrados erros nos logs"
    else
        print_success "Nenhum erro encontrado nos logs recentes"
    fi
}

# Verificar conectividade
check_connectivity() {
    print_status "Verificando conectividade..."
    
    if curl -s -f http://localhost:5000/api/health > /dev/null; then
        print_success "API está respondendo"
    else
        print_error "API não está respondendo!"
        return 1
    fi
}

# Verificar arquivo de dados
check_data_file() {
    print_status "Verificando arquivo de dados..."
    
    if [ -f "/tmp/tributes_data.json" ]; then
        print_success "Arquivo de dados existe"
        
        # Verificar se é um JSON válido
        if python3 -m json.tool /tmp/tributes_data.json > /dev/null 2>&1; then
            print_success "Arquivo de dados é um JSON válido"
            
            # Contar homenagens
            count=$(python3 -c "import json; data=json.load(open('/tmp/tributes_data.json')); print(len(data['messages']))")
            print_status "Número de homenagens: $count"
        else
            print_error "Arquivo de dados não é um JSON válido!"
        fi
    else
        print_warning "Arquivo de dados não existe"
    fi
}

# Verificar espaço em disco
check_disk_space() {
    print_status "Verificando espaço em disco..."
    
    usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    
    if [ "$usage" -gt 90 ]; then
        print_error "Espaço em disco crítico: ${usage}% usado"
    elif [ "$usage" -gt 80 ]; then
        print_warning "Espaço em disco baixo: ${usage}% usado"
    else
        print_success "Espaço em disco OK: ${usage}% usado"
    fi
}

# Verificar portas
check_ports() {
    print_status "Verificando portas..."
    
    if netstat -tuln | grep -q ":80 "; then
        print_success "Porta 80 está em uso"
    else
        print_warning "Porta 80 não está em uso"
    fi
    
    if netstat -tuln | grep -q ":5000 "; then
        print_success "Porta 5000 está em uso"
    else
        print_warning "Porta 5000 não está em uso"
    fi
}

# Fazer backup automático se necessário
auto_backup() {
    print_status "Verificando necessidade de backup..."
    
    # Fazer backup se o arquivo foi modificado nas últimas 24h
    if [ -f "/tmp/tributes_data.json" ]; then
        if find /tmp/tributes_data.json -mtime -1 | grep -q .; then
            print_status "Fazendo backup automático..."
            ./backup.sh
        else
            print_status "Arquivo não foi modificado recentemente, backup não necessário"
        fi
    fi
}

# Reiniciar se necessário
auto_restart() {
    print_status "Verificando se reinicialização é necessária..."
    
    # Verificar se a API está respondendo
    if ! curl -s -f http://localhost:5000/api/health > /dev/null; then
        print_warning "API não está respondendo, tentando reiniciar..."
        docker-compose restart web
        sleep 10
        
        if curl -s -f http://localhost:5000/api/health > /dev/null; then
            print_success "Reinicialização bem-sucedida"
        else
            print_error "Falha na reinicialização"
        fi
    else
        print_success "API está funcionando normalmente"
    fi
}

# Relatório completo
full_report() {
    print_header
    check_docker
    check_containers
    check_resources
    check_logs
    check_connectivity
    check_data_file
    check_disk_space
    check_ports
    auto_backup
    auto_restart
    echo -e "${BLUE}================================${NC}"
}

# Menu interativo
interactive_menu() {
    while true; do
        echo -e "\n${BLUE}Menu de Monitoramento:${NC}"
        echo "1. Status dos containers"
        echo "2. Uso de recursos"
        echo "3. Ver logs"
        echo "4. Testar conectividade"
        echo "5. Verificar arquivo de dados"
        echo "6. Relatório completo"
        echo "7. Fazer backup"
        echo "8. Reiniciar aplicação"
        echo "9. Sair"
        
        read -p "Escolha uma opção (1-9): " choice
        
        case $choice in
            1) check_containers ;;
            2) check_resources ;;
            3) docker-compose logs -f web ;;
            4) check_connectivity ;;
            5) check_data_file ;;
            6) full_report ;;
            7) ./backup.sh ;;
            8) docker-compose restart ;;
            9) echo "Saindo..."; exit 0 ;;
            *) echo "Opção inválida" ;;
        esac
    done
}

# Verificar argumentos
if [ "$1" = "interactive" ] || [ "$1" = "-i" ]; then
    interactive_menu
elif [ "$1" = "report" ] || [ "$1" = "-r" ]; then
    full_report
else
    echo "Uso: $0 {interactive|report}"
    echo "  interactive, -i: Menu interativo"
    echo "  report, -r: Relatório completo"
    exit 1
fi
