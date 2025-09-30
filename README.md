# Site de Homenagens 7º Ano

## Instalação Rápida

```bash
# 1. Instalar Python
sudo apt update
sudo apt install -y python3 python3-pip

# 2. Instalar dependências
pip3 install -r requirements.txt

# 3. Configurar firewall
sudo ufw allow 8080

# 4. Executar
python3 run.py
```

## Acessar

- **Site**: http://45.70.136.66:8080
- **Admin**: http://45.70.136.66:8080/admin

## Executar em background

```bash
nohup python3 run.py > app.log 2>&1 &
```

## Parar

```bash
pkill -f "python3 run.py"
```