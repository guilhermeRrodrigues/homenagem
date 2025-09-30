from flask import Flask, render_template, request, jsonify, redirect, url_for, flash
import os
import json
from datetime import datetime
from werkzeug.utils import secure_filename

app = Flask(__name__)

# Configuração da aplicação
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'dev-secret-key-change-in-production')
app.config['UPLOAD_FOLDER'] = 'static/uploads'
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max file size

# Criar diretório de uploads se não existir
os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)

# Extensões permitidas para imagens
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'webp'}

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

# Arquivo para persistência de dados
DATA_FILE = '/tmp/tributes_data.json'

def load_tributes_data():
    """Carrega dados do arquivo JSON"""
    try:
        if os.path.exists(DATA_FILE):
            with open(DATA_FILE, 'r', encoding='utf-8') as f:
                data = json.load(f)
                return data
        else:
            # Criar arquivo inicial se não existir
            initial_data = {
                'messages': [],
                'current_index': 0
            }
            save_tributes_data(initial_data)
            return initial_data
    except Exception as e:
        print(f"Erro ao carregar dados: {e}")
        return {
            'messages': [],
            'current_index': 0
        }

def save_tributes_data(data):
    """Salva dados no arquivo JSON"""
    try:
        with open(DATA_FILE, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        return True
    except Exception as e:
        print(f"Erro ao salvar dados: {e}")
        return False

# Carregar dados iniciais
tributes_data = load_tributes_data()

@app.route('/')
def index():
    """Página inicial de homenagens"""
    return render_template('tributes.html', tributes=tributes_data['messages'])

@app.route('/admin')
def admin():
    """Página administrativa"""
    return render_template('admin.html', tributes=tributes_data['messages'])

@app.route('/api/tributes')
def get_tributes():
    """API para obter todas as homenagens"""
    # Recarregar dados do arquivo para garantir consistência
    global tributes_data
    tributes_data = load_tributes_data()
    return jsonify(tributes_data['messages'])

@app.route('/api/tributes/current')
def get_current_tribute():
    """API para obter homenagem atual"""
    # Recarregar dados do arquivo para garantir consistência
    global tributes_data
    tributes_data = load_tributes_data()
    
    if tributes_data['messages']:
        current_index = tributes_data['current_index']
        return jsonify(tributes_data['messages'][current_index])
    return jsonify({'message': 'Nenhuma homenagem disponível'})

@app.route('/api/tributes/next')
def next_tribute():
    """Próxima homenagem"""
    # Recarregar dados do arquivo para garantir consistência
    global tributes_data
    tributes_data = load_tributes_data()
    
    if tributes_data['messages']:
        tributes_data['current_index'] = (tributes_data['current_index'] + 1) % len(tributes_data['messages'])
        save_tributes_data(tributes_data)  # Salvar mudança de índice
        return jsonify(tributes_data['messages'][tributes_data['current_index']])
    return jsonify({'message': 'Nenhuma homenagem disponível'})

@app.route('/api/tributes/previous')
def previous_tribute():
    """Homenagem anterior"""
    # Recarregar dados do arquivo para garantir consistência
    global tributes_data
    tributes_data = load_tributes_data()
    
    if tributes_data['messages']:
        tributes_data['current_index'] = (tributes_data['current_index'] - 1) % len(tributes_data['messages'])
        save_tributes_data(tributes_data)  # Salvar mudança de índice
        return jsonify(tributes_data['messages'][tributes_data['current_index']])
    return jsonify({'message': 'Nenhuma homenagem disponível'})

@app.route('/api/tributes', methods=['POST'])
def add_tribute():
    """Adicionar nova homenagem"""
    # Recarregar dados do arquivo para garantir consistência
    global tributes_data
    tributes_data = load_tributes_data()
    
    data = request.get_json()
    
    if not data or 'message' not in data or 'author' not in data:
        return jsonify({'error': 'Dados inválidos'}), 400
    
    # Gerar ID único baseado no maior ID existente + 1
    max_id = max([t['id'] for t in tributes_data['messages']], default=0)
    
    new_tribute = {
        'id': max_id + 1,
        'message': data['message'],
        'author': data['author'],
        'image': data.get('image'),
        'created_at': datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    }
    
    tributes_data['messages'].append(new_tribute)
    save_tributes_data(tributes_data)  # Salvar nova homenagem
    
    return jsonify({'success': True, 'tribute': new_tribute})

@app.route('/api/tributes/<int:tribute_id>', methods=['DELETE'])
def delete_tribute(tribute_id):
    """Deletar homenagem"""
    # Recarregar dados do arquivo para garantir consistência
    global tributes_data
    tributes_data = load_tributes_data()
    
    # Filtrar mensagens, mantendo apenas as que não têm o ID a ser excluído
    original_count = len(tributes_data['messages'])
    tributes_data['messages'] = [t for t in tributes_data['messages'] if t['id'] != tribute_id]
    
    # Verificar se alguma mensagem foi realmente removida
    if len(tributes_data['messages']) == original_count:
        return jsonify({'error': 'Homenagem não encontrada'}), 404
    
    # Ajustar índice atual se necessário
    if tributes_data['current_index'] >= len(tributes_data['messages']) and len(tributes_data['messages']) > 0:
        tributes_data['current_index'] = len(tributes_data['messages']) - 1
    
    save_tributes_data(tributes_data)  # Salvar após exclusão
    return jsonify({'success': True})

@app.route('/upload', methods=['POST'])
def upload_file():
    """Upload de imagem"""
    if 'file' not in request.files:
        return jsonify({'error': 'Nenhum arquivo enviado'}), 400
    
    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'Nenhum arquivo selecionado'}), 400
    
    if file and allowed_file(file.filename):
        filename = secure_filename(file.filename)
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S_')
        filename = timestamp + filename
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(filepath)
        return jsonify({'success': True, 'filename': filename})
    
    return jsonify({'error': 'Tipo de arquivo não permitido'}), 400

@app.route('/api/health')
def health_check():
    """Endpoint de verificação de saúde da aplicação"""
    return jsonify({
        'status': 'healthy',
        'message': 'Aplicação Flask funcionando corretamente'
    })

@app.route('/api/info')
def app_info():
    """Informações da aplicação"""
    return jsonify({
        'app_name': 'Site de Homenagens',
        'version': '1.0.0',
        'environment': os.environ.get('FLASK_ENV', 'development')
    })

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    debug = os.environ.get('FLASK_ENV') == 'development'
    app.run(host='0.0.0.0', port=port, debug=debug)
