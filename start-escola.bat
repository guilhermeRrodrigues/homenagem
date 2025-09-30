@echo off
REM Script para iniciar no PC da ESCOLA (Windows)
REM Funciona em qualquer computador Windows

echo 🏫 INICIANDO APLICAÇÃO NA ESCOLA
echo ================================

REM Verificar se Python está instalado
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python não encontrado!
    echo 📥 Instale Python primeiro: https://python.org/downloads
    pause
    exit /b 1
)

echo 🐍 Python encontrado!

REM Criar diretórios necessários
echo 📁 Criando diretórios...
if not exist "data" mkdir data
if not exist "static\uploads" mkdir static\uploads

REM Instalar dependências
echo 📦 Instalando dependências...
python -m pip install --user -r requirements.txt

REM Obter IP do computador
echo 📍 Obtendo IP do computador...
for /f "tokens=2 delims=:" %%i in ('ipconfig ^| findstr "IPv4"') do (
    set SERVER_IP=%%i
    goto :found_ip
)
:found_ip
set SERVER_IP=%SERVER_IP: =%

if "%SERVER_IP%"=="" set SERVER_IP=localhost

echo 📍 IP do computador: %SERVER_IP%

REM Configurar variáveis de ambiente
set FLASK_ENV=production
set FLASK_APP=app.py

REM Iniciar aplicação
echo.
echo 🚀 INICIANDO APLICAÇÃO...
echo =========================
echo 🌐 URL: http://%SERVER_IP%:5000
echo 🔧 Admin: http://%SERVER_IP%:5000/admin
echo 📊 Status: http://%SERVER_IP%:5000/api/health
echo.
echo ⏹️  Para parar: Ctrl+C
echo =========================

REM Executar aplicação
python app.py
