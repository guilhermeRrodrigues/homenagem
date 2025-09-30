#!/bin/bash

# Script para criar pacote completo para a escola

echo "📦 CRIANDO PACOTE PARA A ESCOLA"
echo "================================"

# Criar pasta do pacote
PACOTE_DIR="omenagem-escola"
mkdir -p $PACOTE_DIR

# Copiar arquivos necessários
echo "📋 Copiando arquivos..."
cp app.py $PACOTE_DIR/
cp requirements.txt $PACOTE_DIR/
cp -r templates $PACOTE_DIR/
cp -r static $PACOTE_DIR/
cp start-escola.sh $PACOTE_DIR/
cp start-escola.bat $PACOTE_DIR/
cp COMO-USAR-NA-ESCOLA.md $PACOTE_DIR/

# Criar README simples
cat > $PACOTE_DIR/README.txt << 'EOF'
🏫 APLICAÇÃO DE HOMENAGENS - ESCOLA
===================================

COMO USAR:
1. Instale Python (se necessário): https://python.org/downloads
2. Execute: start-escola.bat (Windows) ou start-escola.sh (Linux/Mac)
3. Acesse: http://localhost:5000

ARQUIVOS:
- start-escola.bat = Para Windows
- start-escola.sh = Para Linux/Mac
- COMO-USAR-NA-ESCOLA.md = Instruções detalhadas

SUPORTE:
- Se der erro, verifique se Python está instalado
- Reinicie o computador se necessário
- Use Ctrl+C para parar a aplicação
EOF

# Criar arquivo de instalação automática
cat > $PACOTE_DIR/instalar.bat << 'EOF'
@echo off
echo Instalando Python...
echo Baixe Python em: https://python.org/downloads
echo Depois execute: start-escola.bat
pause
EOF

# Criar arquivo de instalação Linux
cat > $PACOTE_DIR/instalar.sh << 'EOF'
#!/bin/bash
echo "Instalando dependências..."
sudo apt update
sudo apt install python3 python3-pip
echo "Pronto! Execute: ./start-escola.sh"
EOF

chmod +x $PACOTE_DIR/instalar.sh

# Criar ZIP do pacote
echo "📦 Criando arquivo ZIP..."
zip -r omenagem-escola.zip $PACOTE_DIR/

echo ""
echo "✅ PACOTE CRIADO COM SUCESSO!"
echo "============================="
echo "📁 Pasta: $PACOTE_DIR/"
echo "📦 ZIP: omenagem-escola.zip"
echo ""
echo "🚀 Para usar na escola:"
echo "1. Copie a pasta ou ZIP para o PC da escola"
echo "2. Execute start-escola.bat (Windows) ou start-escola.sh (Linux/Mac)"
echo "3. Acesse http://localhost:5000"
echo ""
echo "📋 Arquivos incluídos:"
ls -la $PACOTE_DIR/
