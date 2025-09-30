#!/bin/bash

# Script para iniciar como serviço do sistema
# SOLUÇÃO MAIS RÁPIDA E FUNCIONAL

echo "🚀 Configurando aplicação Omenagem como serviço..."

# Parar Docker se estiver rodando
docker-compose down 2>/dev/null

# Criar diretórios
mkdir -p data static/uploads
chmod 755 data static/uploads

# Instalar dependências
echo "📦 Instalando dependências..."
pip3 install -r requirements.txt

# Criar arquivo de serviço systemd
sudo tee /etc/systemd/system/omenagem.service << EOF
[Unit]
Description=Omenagem App
After=network.target

[Service]
Type=simple
User=joao
WorkingDirectory=/home/joao/docker/omenagem
Environment=FLASK_ENV=production
Environment=FLASK_APP=app.py
ExecStart=/usr/bin/python3 app.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Recarregar systemd
sudo systemctl daemon-reload

# Habilitar e iniciar serviço
sudo systemctl enable omenagem
sudo systemctl start omenagem

# Verificar status
sleep 3
if sudo systemctl is-active --quiet omenagem; then
    echo "✅ Serviço iniciado com sucesso!"
    echo "🌐 URL: http://45.70.136.66:5000"
    echo "🔧 Admin: http://45.70.136.66:5000/admin"
    echo ""
    echo "📋 Comandos úteis:"
    echo "   Ver status: sudo systemctl status omenagem"
    echo "   Ver logs: sudo journalctl -u omenagem -f"
    echo "   Parar: sudo systemctl stop omenagem"
    echo "   Iniciar: sudo systemctl start omenagem"
else
    echo "❌ Erro ao iniciar serviço. Verifique os logs:"
    echo "sudo journalctl -u omenagem -f"
fi
