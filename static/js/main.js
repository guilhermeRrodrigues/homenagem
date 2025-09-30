// JavaScript para Site de Homenagens

let currentTributeIndex = 0;
let tributes = [];

document.addEventListener('DOMContentLoaded', function() {
    // Inicializar baseado na página atual
    if (document.getElementById('tributeCard')) {
        initTributesPage();
    } else if (document.getElementById('addTributeForm')) {
        initAdminPage();
    }
});

// ========== PÁGINA DE HOMENAGENS ==========

async function initTributesPage() {
    try {
        showLoading(true);
        await loadTributes();
        if (tributes.length > 0) {
            showCurrentTribute();
            updateCounter();
        } else {
            showNoTributes();
        }
    } catch (error) {
        console.error('Erro ao carregar homenagens:', error);
        showError('Erro ao carregar homenagens');
    } finally {
        showLoading(false);
    }
}

async function loadTributes() {
    const response = await fetch('/api/tributes');
    if (response.ok) {
        tributes = await response.json();
    } else {
        throw new Error('Erro ao carregar homenagens');
    }
}

function showCurrentTribute() {
    if (tributes.length === 0) return;
    
    const tribute = tributes[currentTributeIndex];
    const messageText = document.getElementById('messageText');
    const messageAuthor = document.getElementById('messageAuthor');
    const imageContainer = document.getElementById('imageContainer');
    const tributeImage = document.getElementById('tributeImage');
    
    // Atualizar mensagem
    messageText.textContent = tribute.message;
    messageAuthor.querySelector('.author-name').textContent = tribute.author;
    
    // Mostrar/ocultar imagem
    if (tribute.image) {
        tributeImage.src = `/static/uploads/${tribute.image}`;
        imageContainer.style.display = 'block';
    } else {
        imageContainer.style.display = 'none';
    }
    
    // Animação de transição
    const card = document.getElementById('tributeCard');
    card.style.opacity = '0';
    card.style.transform = 'translateY(20px)';
    
    setTimeout(() => {
        card.style.opacity = '1';
        card.style.transform = 'translateY(0)';
    }, 150);
}

function updateCounter() {
    document.getElementById('currentIndex').textContent = currentTributeIndex + 1;
    document.getElementById('totalCount').textContent = tributes.length;
}

async function nextTribute() {
    if (tributes.length === 0) return;
    
    try {
        const response = await fetch('/api/tributes/next');
        if (response.ok) {
            const tribute = await response.json();
            currentTributeIndex = tributes.findIndex(t => t.id === tribute.id);
            showCurrentTribute();
            updateCounter();
        }
    } catch (error) {
        console.error('Erro ao navegar para próxima homenagem:', error);
    }
}

async function previousTribute() {
    if (tributes.length === 0) return;
    
    try {
        const response = await fetch('/api/tributes/previous');
        if (response.ok) {
            const tribute = await response.json();
            currentTributeIndex = tributes.findIndex(t => t.id === tribute.id);
            showCurrentTribute();
            updateCounter();
        }
    } catch (error) {
        console.error('Erro ao navegar para homenagem anterior:', error);
    }
}

function showLoading(show) {
    const loading = document.getElementById('loadingIndicator');
    const card = document.getElementById('tributeCard');
    
    if (show) {
        loading.style.display = 'block';
        card.style.display = 'none';
    } else {
        loading.style.display = 'none';
        card.style.display = 'block';
    }
}

function showNoTributes() {
    document.getElementById('tributeCard').style.display = 'none';
    document.getElementById('noTributes').style.display = 'block';
}

// ========== PÁGINA ADMINISTRATIVA ==========

async function initAdminPage() {
    setupFormHandlers();
    await loadTributesList();
}

function setupFormHandlers() {
    const form = document.getElementById('addTributeForm');
    const imageInput = document.getElementById('tributeImage');
    
    form.addEventListener('submit', handleFormSubmit);
    imageInput.addEventListener('change', handleImagePreview);
}

async function handleFormSubmit(e) {
    e.preventDefault();
    
    const formData = new FormData(e.target);
    const author = formData.get('author');
    const message = formData.get('message');
    const imageFile = formData.get('image');
    
    if (!author || !message) {
        showAlert('Por favor, preencha todos os campos obrigatórios', 'error');
        return;
    }
    
    try {
        let imageUrl = null;
        
        // Upload da imagem se houver
        if (imageFile && imageFile.size > 0) {
            const uploadFormData = new FormData();
            uploadFormData.append('file', imageFile);
            
            const uploadResponse = await fetch('/upload', {
                method: 'POST',
                body: uploadFormData
            });
            
            if (uploadResponse.ok) {
                const uploadData = await uploadResponse.json();
                imageUrl = uploadData.filename;
            } else {
                throw new Error('Erro no upload da imagem');
            }
        }
        
        // Adicionar homenagem
        const tributeData = {
            author: author,
            message: message,
            image: imageUrl
        };
        
        const response = await fetch('/api/tributes', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(tributeData)
        });
        
        if (response.ok) {
            showAlert('Homenagem adicionada com sucesso!', 'success');
            clearForm();
            await loadTributesList();
        } else {
            const error = await response.json();
            throw new Error(error.error || 'Erro ao adicionar homenagem');
        }
        
    } catch (error) {
        console.error('Erro ao adicionar homenagem:', error);
        showAlert(error.message || 'Erro ao adicionar homenagem', 'error');
    }
}

function handleImagePreview(e) {
    const file = e.target.files[0];
    const preview = document.getElementById('imagePreview');
    const previewImg = document.getElementById('previewImg');
    
    if (file) {
        const reader = new FileReader();
        reader.onload = function(e) {
            previewImg.src = e.target.result;
            preview.style.display = 'block';
        };
        reader.readAsDataURL(file);
    } else {
        preview.style.display = 'none';
    }
}

function removeImage() {
    const imageInput = document.getElementById('tributeImage');
    const preview = document.getElementById('imagePreview');
    
    imageInput.value = '';
    preview.style.display = 'none';
}

function clearForm() {
    document.getElementById('addTributeForm').reset();
    document.getElementById('imagePreview').style.display = 'none';
}

async function loadTributesList() {
    try {
        const response = await fetch('/api/tributes');
        if (response.ok) {
            const tributes = await response.json();
            displayTributesList(tributes);
        } else {
            throw new Error('Erro ao carregar lista de homenagens');
        }
    } catch (error) {
        console.error('Erro ao carregar lista:', error);
        showAlert('Erro ao carregar lista de homenagens', 'error');
    }
}

function displayTributesList(tributes) {
    const container = document.getElementById('tributesList');
    const countElement = document.getElementById('tributeCount');
    
    countElement.textContent = `(${tributes.length})`;
    
    if (tributes.length === 0) {
        container.innerHTML = `
            <div class="no-tributes">
                <i class="fas fa-heart-broken"></i>
                <h3>Nenhuma homenagem cadastrada</h3>
                <p>Adicione a primeira homenagem usando o formulário acima</p>
            </div>
        `;
        return;
    }
    
    container.innerHTML = tributes.map(tribute => `
        <div class="tribute-item" data-id="${tribute.id}">
            <div class="tribute-item-header">
                <div class="tribute-item-author">${tribute.author}</div>
            </div>
            <div class="tribute-item-message">${tribute.message}</div>
            ${tribute.image ? `<img src="/static/uploads/${tribute.image}" alt="Imagem da homenagem" class="tribute-item-image">` : ''}
            <div class="tribute-item-actions">
                <button class="delete-btn" onclick="deleteTribute(${tribute.id})">
                    <i class="fas fa-trash"></i>
                    Excluir
                </button>
            </div>
        </div>
    `).join('');
}

async function deleteTribute(id) {
    if (!confirm('Tem certeza que deseja excluir esta homenagem?')) {
        return;
    }
    
    try {
        const response = await fetch(`/api/tributes/${id}`, {
            method: 'DELETE'
        });
        
        if (response.ok) {
            showAlert('Homenagem excluída com sucesso!', 'success');
            await loadTributesList();
        } else {
            throw new Error('Erro ao excluir homenagem');
        }
    } catch (error) {
        console.error('Erro ao excluir homenagem:', error);
        showAlert('Erro ao excluir homenagem', 'error');
    }
}

// ========== UTILITÁRIOS ==========

function showAlert(message, type = 'info') {
    const container = document.getElementById('alertContainer');
    if (!container) return;
    
    const alert = document.createElement('div');
    alert.className = `alert alert-${type}`;
    alert.innerHTML = `
        <i class="fas fa-${type === 'success' ? 'check-circle' : type === 'error' ? 'exclamation-triangle' : 'info-circle'}"></i>
        ${message}
    `;
    
    container.appendChild(alert);
    
    // Remover após 5 segundos
    setTimeout(() => {
        if (alert.parentNode) {
            alert.parentNode.removeChild(alert);
        }
    }, 5000);
}

function showError(message) {
    showAlert(message, 'error');
}

// ========== NAVEGAÇÃO POR TECLADO ==========

document.addEventListener('keydown', function(e) {
    // Só funciona na página de homenagens
    if (!document.getElementById('tributeCard')) return;
    
    switch(e.key) {
        case 'ArrowLeft':
            e.preventDefault();
            previousTribute();
            break;
        case 'ArrowRight':
            e.preventDefault();
            nextTribute();
            break;
    }
});
