# 🚀 Deploy no Vercel - Omenagem

## 📋 Pré-requisitos

1. Conta no Vercel (gratuita)
2. Vercel CLI instalado
3. Git configurado

## 🔧 Instalação do Vercel CLI

```bash
# Instalar Vercel CLI
npm install -g vercel

# Ou usar npx
npx vercel
```

## 🚀 Deploy Rápido

### Opção 1: Via Vercel CLI
```bash
# 1. Fazer login
vercel login

# 2. Deploy
vercel

# 3. Seguir as instruções na tela
```

### Opção 2: Via GitHub (Recomendado)
```bash
# 1. Criar repositório no GitHub
git init
git add .
git commit -m "Deploy para Vercel"
git push origin main

# 2. Conectar no Vercel
# - Acesse vercel.com
# - Import Project
# - Conecte seu GitHub
# - Deploy automático
```

## ⚙️ Configuração

### Arquivos Necessários:
- `vercel.json` - Configuração do Vercel
- `api/index.py` - Aplicação Flask
- `requirements-vercel.txt` - Dependências
- `templates/` - Páginas HTML
- `static/` - CSS e JavaScript

### Variáveis de Ambiente:
```bash
# No painel do Vercel, adicione:
SECRET_KEY=sua-chave-secreta-aqui
FLASK_ENV=production
```

## 🌐 URLs Após Deploy

- **Aplicação**: `https://seu-projeto.vercel.app`
- **Admin**: `https://seu-projeto.vercel.app/admin`
- **API Health**: `https://seu-projeto.vercel.app/api/health`

## 🔧 Comandos Úteis

```bash
# Deploy
vercel

# Deploy para produção
vercel --prod

# Ver logs
vercel logs

# Remover deploy
vercel remove
```

## ⚠️ Limitações do Vercel

- **Upload de arquivos**: Limitado (use serviços externos)
- **Armazenamento**: Temporário (use banco de dados)
- **Timeout**: 10 segundos por requisição

## 🎯 Vantagens

- ✅ Gratuito
- ✅ Deploy automático
- ✅ HTTPS automático
- ✅ CDN global
- ✅ Fácil de usar

## 🐛 Troubleshooting

### Erro 404:
- Verifique se `vercel.json` está correto
- Confirme se `api/index.py` existe

### Erro de dependências:
- Use `requirements-vercel.txt`
- Verifique versões compatíveis

### Erro de templates:
- Confirme se `templates/` está na pasta `api/`
