# Flask Docker App

Uma aplicação web moderna construída com Python Flask e containerizada com Docker.

## 🚀 Tecnologias

- **Python 3.11** - Linguagem de programação
- **Flask 2.3.3** - Framework web
- **Docker** - Containerização
- **Docker Compose** - Orquestração de containers
- **Bootstrap 5** - Framework CSS
- **Gunicorn** - Servidor WSGI

## 📋 Pré-requisitos

- Docker
- Docker Compose

## 🛠️ Como Executar

### Desenvolvimento

```bash
# Clonar o repositório
git clone <url-do-repositorio>
cd omenagem

# Executar com Docker Compose
docker-compose up --build

# A aplicação estará disponível em: http://localhost:5000
```

### Produção

```bash
# Executar em modo produção
docker-compose -f docker-compose.prod.yml up -d
```

## 📁 Estrutura do Projeto

```
omenagem/
├── app.py                 # Aplicação Flask principal
├── requirements.txt       # Dependências Python
├── Dockerfile            # Configuração do container
├── docker-compose.yml    # Orquestração para desenvolvimento
├── docker-compose.prod.yml # Orquestração para produção
├── nginx.conf            # Configuração do Nginx
├── .dockerignore         # Arquivos ignorados pelo Docker
├── templates/            # Templates HTML
│   ├── base.html
│   ├── index.html
│   └── about.html
└── static/              # Arquivos estáticos
    ├── css/
    │   └── style.css
    └── js/
        └── main.js
```

## 🔗 Endpoints da API

- `GET /` - Página inicial
- `GET /about` - Página sobre
- `GET /api/health` - Health check da aplicação
- `GET /api/info` - Informações da aplicação

## 🐳 Comandos Docker Úteis

```bash
# Construir a imagem
docker build -t flask-docker-app .

# Executar o container
docker run -p 5000:5000 flask-docker-app

# Ver logs
docker-compose logs -f web

# Parar os containers
docker-compose down

# Reconstruir e executar
docker-compose up --build --force-recreate
```

## 🔧 Configuração

As variáveis de ambiente podem ser configuradas no arquivo `.env`:

```env
FLASK_ENV=development
SECRET_KEY=your-secret-key
PORT=5000
```

## 📝 Desenvolvimento

Para desenvolvimento local sem Docker:

```bash
# Criar ambiente virtual
python -m venv venv
source venv/bin/activate  # Linux/Mac
# ou
venv\Scripts\activate     # Windows

# Instalar dependências
pip install -r requirements.txt

# Executar aplicação
python app.py
```

## 🚀 Deploy

Para fazer deploy em produção:

1. Configure as variáveis de ambiente
2. Use `docker-compose.prod.yml`
3. Configure um proxy reverso (Nginx)
4. Configure SSL/TLS

## 📄 Licença

Este projeto está sob a licença MIT.