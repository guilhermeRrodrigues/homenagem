#!/usr/bin/env python3
"""
Executar aplicação Flask
"""

import os
import sys

# Configurar ambiente
os.environ['FLASK_ENV'] = 'production'
os.environ['FLASK_APP'] = 'app.py'

# Importar e executar
from app import app

if __name__ == "__main__":
    print("🚀 Site de Homenagens 7º Ano")
    print("📍 URL: http://localhost:8080")
    print("📍 Admin: http://localhost:8080/admin")
    print("⏹️  Para parar: Ctrl+C")
    print("-" * 50)
    
    app.run(host='0.0.0.0', port=8080, debug=False)
