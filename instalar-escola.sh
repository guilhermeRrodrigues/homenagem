#!/bin/bash

# Script para instalar na escola - FUNCIONA EM QUALQUER COMPUTADOR
# Execute este script no computador da escola

echo "🏫 INSTALAÇÃO NA ESCOLA - Omenagem"
echo "=================================="

# Verificar se é root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Execute como root: sudo ./instalar-escola.sh"
    exit 1
fi

# Atualizar sistema
echo "📦 Atualizando sistema..."
apt update -y

# Instalar dependências
echo "🐍 Instalando Python e dependências..."
apt install -y python3 python3-pip python3-venv

# Criar diretório da aplicação
echo "📁 Criando diretório da aplicação..."
mkdir -p /opt/omenagem
cd /opt/omenagem

# Copiar arquivos (você precisa copiar os arquivos aqui)
echo "📋 Copiando arquivos da aplicação..."
echo "⚠️  IMPORTANTE: Copie todos os arquivos da aplicação para /opt/omenagem/"

# Criar usuário para a aplicação
echo "👤 Criando usuário da aplicação..."
useradd -r -s /bin/false omenagem 2>/dev/null || true

# Instalar dependências Python
echo "📦 Instalando dependências Python..."
pip3 install -r requirements.txt

# Criar diretórios
mkdir -p data static/uploads
chown -R omenagem:omenagem /opt/omenagem

# Criar serviço systemd
echo "⚙️  Configurando serviço automático..."
cat > /etc/systemd/system/omenagem.service << 'EOF'
[Unit]
Description=Omenagem App
After=network.target

[Service]
Type=simple
User=omenagem
WorkingDirectory=/opt/omenagem
Environment=FLASK_ENV=production
Environment=FLASK_APP=app.py
ExecStart=/usr/bin/python3 app.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Habilitar e iniciar serviço
echo "🚀 Iniciando serviço..."
systemctl daemon-reload
systemctl enable omenagem
systemctl start omenagem

# Configurar firewall
echo "🔥 Configurando firewall..."
ufw allow 5000/tcp

# Obter IP do servidor
SERVER_IP=$(hostname -I | awk '{print $1}')

# Verificar se está funcionando
sleep 3
if systemctl is-active --quiet omenagem; then
    echo ""
    echo "✅ SUCESSO! Aplicação instalada na escola!"
    echo "=========================================="
    echo "🌐 URL: http://$SERVER_IP:5000"
    echo "🔧 Admin: http://$SERVER_IP:5000/admin"
    echo ""
    echo "📋 A aplicação vai iniciar automaticamente quando ligar o computador!"
    echo "🔧 Comandos úteis:"
    echo "   Status: sudo systemctl status omenagem"
    echo "   Parar: sudo systemctl stop omenagem"
    echo "   Iniciar: sudo systemctl start omenagem"
    echo "   Logs: sudo journalctl -u omenagem -f"
else
    echo "❌ Erro na instalação. Verifique os logs:"
    echo "sudo journalctl -u omenagem -f"
fi
