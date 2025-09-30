# 🔧 Como Usar a Porta 80 (Opcional)

Por padrão, a aplicação está configurada para usar a porta **8080** para evitar problemas de permissão com Docker rootless.

## 🚀 Solução Rápida (Porta 8080)

A aplicação já está funcionando na porta 8080:
- **URL**: http://45.70.136.66:8080
- **Admin**: http://45.70.136.66:8080/admin

## 🔧 Para Usar a Porta 80

Se você quiser usar a porta 80 (sem o :8080), siga estes passos:

### Opção 1: Configurar Docker para Portas Privilegiadas

```bash
# Adicionar ao /etc/sysctl.conf
echo 'net.ipv4.ip_unprivileged_port_start=80' | sudo tee -a /etc/sysctl.conf

# Aplicar configuração
sudo sysctl -p

# Reiniciar Docker
sudo systemctl restart docker
```

### Opção 2: Usar Docker com Root

```bash
# Parar Docker rootless
systemctl --user stop docker

# Iniciar Docker com root
sudo systemctl start docker

# Alterar docker-compose.yml para usar porta 80
# Trocar: "45.70.136.66:8080:3000"
# Por:    "45.70.136.66:80:3000"
```

### Opção 3: Usar Proxy Reverso (Recomendado)

```bash
# Instalar nginx
sudo apt update
sudo apt install nginx

# Criar configuração
sudo tee /etc/nginx/sites-available/omenagem << EOF
server {
    listen 80;
    server_name 45.70.136.66;
    
    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Ativar site
sudo ln -s /etc/nginx/sites-available/omenagem /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

## ⚠️ Importante

- A **porta 8080** funciona perfeitamente e é mais segura
- A porta 80 requer configurações adicionais de segurança
- Para produção, considere usar HTTPS com certificado SSL

## 🌐 URLs Finais

Com qualquer uma das opções acima:
- **Aplicação**: http://45.70.136.66
- **Admin**: http://45.70.136.66/admin
