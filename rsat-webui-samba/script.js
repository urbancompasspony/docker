        // URL do script CGI
        const CGI_URL = '/cgi-bin/samba-admin.cgi';

        // Elementos DOM
        let loadingElement = null;
        let resultContainer = null;
        let alertContainer = null;

        // Inicializar elementos quando DOM carregar
        document.addEventListener('DOMContentLoaded', function() {
            createUIElements();
            showMainMenu();
        });

// Variáveis globais para o browser de pastas
let currentPath = '/mnt';
let folderBrowserCallback = null;

// Abrir browser de pastas
function openFolderBrowser(callback, startPath = '/mnt') {
    folderBrowserCallback = callback;
    currentPath = startPath;
    
    const modal = document.getElementById('folderBrowserModal');
    modal.style.display = 'flex';
    
    updateCurrentPathDisplay();
    loadFolderTree(currentPath);
}

// Fechar browser de pastas
function closeFolderBrowser() {
    const modal = document.getElementById('folderBrowserModal');
    modal.style.display = 'none';
    folderBrowserCallback = null;
}

// Atualizar display do caminho atual
function updateCurrentPathDisplay() {
    document.getElementById('currentBrowsePath').textContent = currentPath;
}

// Carregar árvore de pastas
async function loadFolderTree(path) {
    const treeContainer = document.getElementById('folderTree');
    treeContainer.innerHTML = '<div class="loading-tree">🔄 Carregando pastas...</div>';
    
    try {
        const response = await fetch('/cgi-bin/samba-admin.cgi', {
            method: 'POST',
            body: new URLSearchParams({
                action: 'browse-directories',
                'browse-path': path
            })
        });
        
        const text = await response.text();
        let data;
        
        try {
            data = JSON.parse(text);
        } catch {
            throw new Error('Resposta inválida do servidor');
        }
        
        if (data.error) {
            treeContainer.innerHTML = `<div style="color: #e74c3c;">❌ ${data.error}</div>`;
            return;
        }
        
        // Renderizar árvore
        renderFolderTree(data, treeContainer);
        
    } catch (error) {
        treeContainer.innerHTML = `<div style="color: #e74c3c;">❌ Erro: ${error.message}</div>`;
    }
}

// Renderizar árvore de pastas
function renderFolderTree(data, container) {
    container.innerHTML = '';
    
    // Botão para pasta atual
    const currentFolder = document.createElement('div');
    currentFolder.className = 'folder-item current';
    currentFolder.innerHTML = `
        <div style="padding: 8px; background: #e3f2fd; border-radius: 4px; margin-bottom: 10px; cursor: pointer; border: 2px solid #2196F3;" onclick="selectPath('${data.path}')">
            📁 <strong>${data.path}</strong> (pasta atual)
        </div>
    `;
    container.appendChild(currentFolder);
    
    // Botão "Voltar" se não estiver na raiz
    if (data.path !== '/mnt') {
        const parentPath = data.path.replace(/\/[^\/]*$/, '') || '/mnt';
        const backButton = document.createElement('div');
        backButton.className = 'folder-item back';
        backButton.innerHTML = `
            <div style="padding: 8px; background: #fff3e0; border-radius: 4px; margin-bottom: 5px; cursor: pointer; border: 1px solid #ff9800;" onclick="navigateToPath('${parentPath}')">
                ⬆️ .. (voltar)
            </div>
        `;
        container.appendChild(backButton);
    }
    
    if (data.children && data.children.length > 0) {
        // Agrupar por profundidade
        const byDepth = {};
        data.children.forEach(folder => {
            if (!byDepth[folder.depth]) byDepth[folder.depth] = [];
            byDepth[folder.depth].push(folder);
        });
        
        // Renderizar por profundidade
        Object.keys(byDepth).sort((a, b) => a - b).forEach(depth => {
            byDepth[depth].forEach(folder => {
                const folderDiv = document.createElement('div');
                folderDiv.className = 'folder-item';
                
                const indent = '  '.repeat(folder.depth);
                const icon = folder.empty ? '📂' : '📁';
                const emptyText = folder.empty ? ' (vazia)' : '';
                
                folderDiv.innerHTML = `
                    <div style="padding: 6px; margin: 2px 0; cursor: pointer; border-radius: 3px; border: 1px solid #ddd; font-family: monospace;" 
                         onmouseover="this.style.background='#f0f0f0'" 
                         onmouseout="this.style.background='white'"
                         onclick="navigateToPath('${folder.fullPath}')">
                        ${indent}${icon} ${folder.name}${emptyText}
                    </div>
                `;
                container.appendChild(folderDiv);
            });
        });
    } else {
        const emptyDiv = document.createElement('div');
        emptyDiv.innerHTML = '<div style="color: #666; font-style: italic; padding: 10px;">Nenhuma subpasta encontrada</div>';
        container.appendChild(emptyDiv);
    }
}

// Navegar para uma pasta
function navigateToPath(path) {
    currentPath = path;
    updateCurrentPathDisplay();
    loadFolderTree(path);
}

// Selecionar caminho atual
function selectCurrentPath() {
    selectPath(currentPath);
}

// Selecionar uma pasta específica
function selectPath(path) {
    if (folderBrowserCallback) {
        // Converter caminho absoluto para relativo (/mnt/pasta -> /pasta)
        let relativePath = path.replace(/^\/mnt/, '') || '/';
        folderBrowserCallback(relativePath);
    }
    closeFolderBrowser();
}
        
        // Criar elementos de UI dinâmicos
        function createUIElements() {
            loadingElement = document.querySelector('.loading');
            resultContainer = document.querySelector('.result-container');
            alertContainer = document.querySelector('.alert');
        }

function showLoading() {
    const loading = document.querySelector('.loading');
    if (loading) {
        loading.style.display = 'block';
    }
    hideAlert();
    hideResult();
}

function hideLoading() {
    const loading = document.querySelector('.loading');
    if (loading) {
        loading.style.display = 'none';
    }
}

function showResult(content, isError = false) {
    const resultContainer = document.querySelector('.result-container');
    if (resultContainer) {
        resultContainer.style.display = 'block';
        resultContainer.innerHTML = `<h4>Resultado:</h4><div class="result-content">${content}</div>`;
        
        if (isError) {
            resultContainer.style.borderLeftColor = '#e74c3c';
        } else {
            resultContainer.style.borderLeftColor = '#3498db';
        }
    }
}

function hideResult() {
    const resultContainer = document.querySelector('.result-container');
    if (resultContainer) {
        resultContainer.style.display = 'none';
    }
}

        // Mostrar alerta
        function showAlert(message, type = 'success') {
            alertContainer.textContent = message;
            alertContainer.className = `alert alert-${type} active`;

            // Auto-hide após 5 segundos
            setTimeout(() => {
                hideAlert();
            }, 5000);
        }

        // Ocultar alerta
        function hideAlert() {
            alertContainer.classList.remove('active');
        }

        // Função para executar comandos diretos (sem formulário)
        function executeCommand(action) {
            showLoading();

            const params = new URLSearchParams();
            params.append('action', action);

            fetch(CGI_URL, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: params.toString()
            })
            .then(response => response.json())
            .then(data => {
                hideLoading();

                if (data.status === 'success') {
                    showAlert('Comando executado com sucesso!', 'success');
                    showResult(`<pre>${data.output || data.message}</pre>`);
                } else {
                    showAlert(data.message, 'error');
                    showResult(`<pre>${data.output || 'Erro ao executar comando'}</pre>`, true);
                }
            })
            .catch(error => {
                hideLoading();
                showAlert('Erro de conexão: ' + error.message, 'error');
                console.error('Erro:', error);
            });
        }

        // Função para submeter formulários
        function submitForm(event, formType) {
            event.preventDefault();
            showLoading();

            const form = event.target;
            const formData = new FormData(form);
            const params = new URLSearchParams();

            // Adicionar ação baseada no tipo de formulário
            params.append('action', formType);

            // Adicionar dados do formulário
            for (let [key, value] of formData.entries()) {
                params.append(key, value);
            }

            fetch(CGI_URL, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: params.toString()
            })
            .then(response => response.json())
            .then(data => {
                hideLoading();

                if (data.status === 'success') {
                    showAlert('Operação realizada com sucesso!', 'success');
                    showResult(`<pre>${data.output || data.message}</pre>`);
                    form.reset(); // Limpar formulário
                } else {
                    showAlert(data.message, 'error');
                    showResult(`<pre>${data.output || 'Erro na operação'}</pre>`, true);
                }
            })
            .catch(error => {
                hideLoading();
                showAlert('Erro de conexão: ' + error.message, 'error');
                console.error('Erro:', error);
            });
        }

        // Funções de navegação
        function showSubmenu(submenuId) {
            hideAlert();
            hideResult();

            document.querySelectorAll('.submenu').forEach(function(sub) {
                sub.classList.remove('active');
            });
            document.querySelectorAll('.instruction-panel').forEach(function(panel) {
                panel.style.display = 'none';
            });
            document.getElementById('main-menu').style.display = 'none';

            var submenu = document.getElementById(submenuId);
            if (submenu) submenu.classList.add('active');
        }

function showMainMenu() {
    // LIMPAR RESULTADOS quando voltar ao menu principal
    const resultContainer = document.querySelector('.result-container');
    if (resultContainer) {
        resultContainer.style.display = 'none';
        resultContainer.innerHTML = '';
    }

    // Limpar loading também
    const loading = document.querySelector('.loading');
    if (loading) {
        loading.style.display = 'none';
    }

    hideAlert();

    document.querySelectorAll('.submenu').forEach(function(sub) {
        sub.classList.remove('active');
    });
    document.querySelectorAll('.form-container').forEach(function(form) {
        form.classList.remove('active');
    });
    document.getElementById('main-menu').style.display = 'grid';
    document.querySelectorAll('.instruction-panel').forEach(function(panel) {
        panel.style.display = 'none';
    });
}

        function showInstructionPanel(id) {
            document.querySelectorAll('.instruction-panel').forEach(function(panel) {
                panel.style.display = 'none';
            });
            document.getElementById(id).style.display = 'block';
        }

        function closeInstructionPanel(id) {
            document.getElementById(id).style.display = 'none';
        }

        function showForm(formName) {
            hideAlert();
            hideResult();

            document.querySelectorAll('.form-container').forEach(function(form) {
                form.classList.remove('active');
            });
            var el = document.getElementById(formName + '-form');
            if (el) el.classList.add('active');
            document.querySelectorAll('.instruction-panel').forEach(function(panel) {
                panel.style.display = 'none';
            });
        }

function hideForm() {
    // Esconder todos os formulários
    const forms = document.querySelectorAll('.form-container');
    forms.forEach(form => {
        form.style.display = 'none';
    });

    // Limpar loading
    const loading = document.querySelector('.loading');
    if (loading) {
        loading.style.display = 'none';
    }

    // NÃO MEXER NO resultContainer - deixar resultado visível
    // Comentado: resultContainer.style.display = 'none';
    // Comentado: resultContainer.innerHTML = '';

    // Limpar campos dos formulários
    const inputs = document.querySelectorAll('input[type="text"], input[type="password"], input[type="date"], textarea, select');
    inputs.forEach(input => {
        if (input.type === 'radio' || input.type === 'checkbox') {
            input.checked = input.defaultChecked;
        } else {
            input.value = '';
        }
    });
}

        // Mapeamento de ações para comandos samba-tool
        const commandMapping = {
            'list-users': 'list-users',
            'list-groups': 'list-groups',
            'list-computers': 'list-computers',
            'list-ous': 'list-ous',
            'list-silos': 'list-silos',
            'show-domain-info': 'show-domain-info',
            'show-domain-level': 'show-domain-level',
            'show-fsmo-roles': 'show-fsmo-roles',
            'show-sites': 'show-sites',
            'show-replication-info': 'show-replication-info',
            'active-sessions': 'active-sessions',
            'active-shares': 'active-shares',
            'samba-processes': 'samba-processes',
            'show-shares': 'show-shares',
            'revalidate-shares': 'revalidate-shares',
            'show-password-policy': 'show-password-policy',
            'enable-complexity': 'enable-complexity',
            'disable-complexity': 'disable-complexity',
            'sysvol-check': 'sysvol-check',
            'sysvol-reset': 'sysvol-reset',
            'db-check-general': 'db-check-general',
            'db-check-acls': 'db-check-acls',
        };

        // Funções específicas para validação
        function validateEmail(email) {
            const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            return re.test(email);
        }

        function validateUsername(username) {
            const re = /^[a-zA-Z0-9._-]+$/;
            return re.test(username) && username.length >= 3;
        }

        // Função para confirmar ações destrutivas
        function confirmAndExecute(action, message) {
            if (confirm(message)) {
                executeCommand(action);
            }
        }

        // Função para prompts simples
        function promptAndExecute(action, promptMessage) {
            const input = prompt(promptMessage);
            if (input) {
                showLoading();

                const params = new URLSearchParams();
                params.append('action', action);
                params.append('input', input);

                fetch(CGI_URL, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                    },
                    body: params.toString()
                })
                .then(response => response.json())
                .then(data => {
                    hideLoading();

                    if (data.status === 'success') {
                        showAlert('Operação realizada com sucesso!', 'success');
                        showResult(`<pre>${data.output || data.message}</pre>`);
                    } else {
                        showAlert(data.message, 'error');
                        showResult(`<pre>${data.output || 'Erro na operação'}</pre>`, true);
                    }
                })
                .catch(error => {
                    hideLoading();
                    showAlert('Erro de conexão: ' + error.message, 'error');
                });
            }
        }

        // Adicionar validação em tempo real aos formulários
        document.addEventListener('DOMContentLoaded', function() {
            // Validação de email
            const emailInputs = document.querySelectorAll('input[type="email"]');
            emailInputs.forEach(input => {
                input.addEventListener('blur', function() {
                    if (this.value && !validateEmail(this.value)) {
                        this.style.borderColor = '#e74c3c';
                        showAlert('Formato de email inválido', 'warning');
                    } else {
                        this.style.borderColor = '#ddd';
                    }
                });
            });

            // Validação de username
            const usernameInputs = document.querySelectorAll('input[name="username"]');
            usernameInputs.forEach(input => {
                input.addEventListener('blur', function() {
                    if (this.value && !validateUsername(this.value)) {
                        this.style.borderColor = '#e74c3c';
                        showAlert('Nome de usuário deve ter pelo menos 3 caracteres e conter apenas letras, números, pontos, underscores e hífens', 'warning');
                    } else {
                        this.style.borderColor = '#ddd';
                    }
                });
            });

            // Adicionar validação para campos obrigatórios
            const forms = document.querySelectorAll('form');
            forms.forEach(form => {
                form.addEventListener('submit', function(e) {
                    const requiredFields = this.querySelectorAll('[required]');
                    let hasErrors = false;

                    requiredFields.forEach(field => {
                        if (!field.value.trim()) {
                            field.style.borderColor = '#e74c3c';
                            hasErrors = true;
                        } else {
                            field.style.borderColor = '#ddd';
                        }
                    });

                    if (hasErrors) {
                        e.preventDefault();
                        showAlert('Por favor, preencha todos os campos obrigatórios', 'error');
                    }
                });
            });
        });

        // Função para resetar formulários
        function resetForm(formId) {
            const form = document.getElementById(formId);
            if (form) {
                form.reset();
                // Resetar estilos de validação
                const inputs = form.querySelectorAll('input, select, textarea');
                inputs.forEach(input => {
                    input.style.borderColor = '#ddd';
                });
            }
        }

        // Função para auto-completar campos baseado em dados anteriores
        function setupAutoComplete() {
            // Implementar auto-complete para usuários, grupos, etc.
            // Pode ser expandido conforme necessário
        }

        // Atalhos de teclado
        document.addEventListener('keydown', function(e) {
            // ESC para fechar formulários
            if (e.key === 'Escape') {
                hideForm();
                hideAlert();
            }

            // Ctrl+Home para voltar ao menu principal
            if (e.ctrlKey && e.key === 'Home') {
                showMainMenu();
            }
        });

        // Função para exportar resultados
        function exportResults() {
            const resultContent = resultContainer.querySelector('.result-content');
            if (resultContent && resultContent.textContent) {
                const blob = new Blob([resultContent.textContent], { type: 'text/plain' });
                const url = window.URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.href = url;
                a.download = 'samba-result-' + new Date().toISOString().slice(0, 19).replace(/:/g, '-') + '.txt';
                document.body.appendChild(a);
                a.click();
                document.body.removeChild(a);
                window.URL.revokeObjectURL(url);
            }
        }

        // Função para imprimir resultados
        function printResults() {
            const resultContent = resultContainer.querySelector('.result-content');
            if (resultContent && resultContent.textContent) {
                const printWindow = window.open('', '_blank');
                printWindow.document.write(`
                    <html>
                        <head>
                            <title>Resultado Samba Admin</title>
                            <style>
                                body { font-family: monospace; margin: 20px; }
                                pre { white-space: pre-wrap; }
                            </style>
                        </head>
                        <body>
                            <h1>Resultado Samba Administration</h1>
                            <p>Data: ${new Date().toLocaleString('pt-BR')}</p>
                            <hr>
                            <pre>${resultContent.textContent}</pre>
                        </body>
                    </html>
                `);
                printWindow.document.close();
                printWindow.print();
            }
        }

        // Inicialização final
        window.addEventListener('load', function() {
            setupAutoComplete();
            console.log('Samba Web Admin Interface carregada com sucesso!');
        });

    </script>
<script>
// Substitua a função submitForm por esta versão melhorada:
async function submitForm(event, action) {
    event.preventDefault();

    const form = event.target;
    const formData = new FormData(form);
    formData.append('action', action);

    const resultContainer = document.querySelector('.result-container');
    if(resultContainer) {
        resultContainer.style.display = 'none';
        resultContainer.innerHTML = '';
    }

    const loading = document.querySelector('.loading');
    if(loading) loading.style.display = 'block';

    try {
        const response = await fetch('/cgi-bin/samba-admin.cgi', {
            method: 'POST',
            body: new URLSearchParams(formData)
        });

        let text = await response.text();
        let output;

        try {
            output = JSON.parse(text);
        } catch {
            output = { text: text };
        }

        if(resultContainer) {
            resultContainer.style.display = 'block';

            // Melhor processamento do resultado
            let displayText = '';
            if (output.text) {
                displayText = output.text.trim(); // Remove \n e espaços extras
            } else if (typeof output === 'string') {
                displayText = output.trim();
            } else {
                displayText = JSON.stringify(output, null, 2);
            }

            // Se o resultado tem apenas uma linha, exibe simples, senão usa <pre>
            if (displayText.includes('\n') || displayText.length > 100) {
                resultContainer.innerHTML = `<pre>${displayText}</pre>`;
            } else {
                resultContainer.innerHTML = `<div style="font-family: monospace; padding: 10px; background: white; border-radius: 5px;">${displayText}</div>`;
            }
        }
    } catch(e) {
        if(resultContainer) {
            resultContainer.style.display = 'block';
            resultContainer.innerHTML = `<pre>Erro: ${e}</pre>`;
        }
    }

    if(loading) loading.style.display = 'none';
}

// Substitua a função executeCommand por esta versão melhorada:
async function executeCommand(action) {
    const resultContainer = document.querySelector('.result-container');
    if(resultContainer) {
        resultContainer.style.display = 'none';
        resultContainer.innerHTML = '';
    }

    const loading = document.querySelector('.loading');
    if(loading) loading.style.display = 'block';

    try {
        const response = await fetch('/cgi-bin/samba-admin.cgi', {
            method: 'POST',
            body: new URLSearchParams({action})
        });

        let text = await response.text();
        let output;

        try {
            output = JSON.parse(text);
        } catch {
            output = { text: text };
        }

        if(resultContainer) {
            resultContainer.style.display = 'block';

            // Melhor processamento do resultado
            let displayText = '';
            if (output.text) {
                displayText = output.text.trim(); // Remove \n e espaços extras
            } else if (typeof output === 'string') {
                displayText = output.trim();
            } else {
                displayText = JSON.stringify(output, null, 2);
            }

            // Se o resultado tem múltiplas linhas, usa <pre>, senão exibe simples
            if (displayText.includes('\n')) {
                // Para listas, formatar melhor
                const lines = displayText.split('\n').filter(line => line.trim());
                if (lines.length > 1) {
                    const formattedList = lines.map(line => `• ${line.trim()}`).join('<br>');
                    resultContainer.innerHTML = `<div style="font-family: 'Segoe UI', sans-serif; line-height: 1.6;">${formattedList}</div>`;
                } else {
                    resultContainer.innerHTML = `<div style="font-family: monospace; padding: 10px; background: white; border-radius: 5px;">${displayText}</div>`;
                }
            } else {
                resultContainer.innerHTML = `<div style="font-family: monospace; padding: 10px; background: white; border-radius: 5px; font-size: 16px; color: #2c3e50;">${displayText}</div>`;
            }
        }
    } catch(e) {
        if(resultContainer) {
            resultContainer.style.display = 'block';
            resultContainer.innerHTML = `<pre>Erro: ${e}</pre>`;
        }
    }

    if(loading) loading.style.display = 'none';
}

function showConfirmation(message, callback) {
    const overlay = document.getElementById('confirmOverlay');
    const messageEl = document.getElementById('confirmMessage');
    const yesBtn = document.getElementById('confirmYes');
    const noBtn = document.getElementById('confirmNo');

    messageEl.innerHTML = message;
    overlay.classList.add('active');

    // Remover event listeners anteriores
    yesBtn.onclick = null;
    noBtn.onclick = null;

    yesBtn.onclick = function() {
        overlay.classList.remove('active');
        callback(true);
    };

    noBtn.onclick = function() {
        overlay.classList.remove('active');
        callback(false);
    };
}

// Função para expiração de senha (sim/não direto)
function handlePasswordExpiry(event) {
    event.preventDefault();
    const username = document.getElementById('expiry-username').value;

    if (!username) {
        showAlert('Por favor, digite o nome do usuário', 'error');
        return;
    }

    // Usar o modal de confirmação que já existe
    const overlay = document.getElementById('confirmOverlay');
    const messageEl = document.getElementById('confirmMessage');
    const yesBtn = document.getElementById('confirmYes');
    const noBtn = document.getElementById('confirmNo');

    messageEl.innerHTML = `<strong>CONFIGURAR EXPIRAÇÃO DE SENHA</strong><br><br>Usuário: "${username}"<br><br>A senha deste usuário NÃO deve mais expirar?<br><br>• <strong>SIM</strong> = Senha nunca expira (--noexpiry)<br>• <strong>NÃO</strong> = Senha expira em 90 dias (padrão do domínio)`;
    overlay.classList.add('active');

    // Remover event listeners anteriores para evitar conflitos
    yesBtn.onclick = null;
    noBtn.onclick = null;

    yesBtn.onclick = function() {
        overlay.classList.remove('active');
        
        // Se confirmou SIM, senha não expira
        showLoading();
        
        const formData = new URLSearchParams();
        formData.append('action', 'set-no-expiry');
        formData.append('username', username);

        fetch('/cgi-bin/samba-admin.cgi', {
            method: 'POST',
            body: formData
        })
        .then(response => response.text())
        .then(data => {
            hideLoading();
            showResult(`<pre>${data}</pre>`);
            showAlert(`✓ Senha de "${username}" configurada para NUNCA EXPIRAR`, 'success');
            
            // Limpar o formulário
            document.getElementById('expiry-username').value = '';
        })
        .catch(error => {
            hideLoading();
            showAlert('Erro: ' + error.message, 'error');
        });
    };

    noBtn.onclick = function() {
        overlay.classList.remove('active');
        
        // Se cancelou (NÃO), define prazo padrão
        showLoading();
        
        const formData = new URLSearchParams();
        formData.append('action', 'set-default-expiry');
        formData.append('username', username);

        fetch('/cgi-bin/samba-admin.cgi', {
            method: 'POST',
            body: formData
        })
        .then(response => response.text())
        .then(data => {
            hideLoading();
            showResult(`<pre>${data}</pre>`);
            showAlert(`✓ Senha de "${username}" vai expirar em 90 dias (padrão)`, 'success');
            
            // Limpar o formulário
            document.getElementById('expiry-username').value = '';
        })
        .catch(error => {
            hideLoading();
            showAlert('Erro: ' + error.message, 'error');
        });
    };
}

function confirmDeleteOU(event) {
    event.preventDefault();
    const ou = document.getElementById('delete-ou-name').value;

    showConfirmation(`Excluir a OU "${ou}"?`, function(confirmed) {
        if (confirmed) {
            submitForm(event, 'delete-ou');
        }
    });
}

function confirmDeleteShare(event) {
    event.preventDefault();
    const share = document.getElementById('delete-share-name').value;

    showConfirmation(`Excluir o compartilhamento "${share}"?`, function(confirmed) {
        if (confirmed) {
            submitForm(event, 'delete-share');
        }
    });
}

function confirmDeleteSilo(event) {
    event.preventDefault();
    const silo = document.getElementById('delete-silo-name').value;

    showConfirmation(`Tem certeza que deseja excluir o silo "${silo}"?`, function(confirmed) {
        if (confirmed) {
            submitForm(event, 'delete-silo');
        }
    });
}

function confirmDeleteComputer(event) {
    event.preventDefault();
    const computer = document.getElementById('delete-computer-name').value;

    if (!computer) {
        showAlert('Por favor, digite o nome do computador', 'error');
        return;
    }

    showConfirmation(`Tem certeza que deseja excluir o computador "${computer}"?`, function(confirmed) {
        if (confirmed) {
            submitForm(event, 'delete-computer');
        }
    });
}

function confirmDeleteGroup(event) {
    event.preventDefault();
    const group = document.getElementById('delete-group-name').value;

    if (!group) {
        showAlert('Por favor, digite o nome do grupo', 'error');
        return;
    }

    showConfirmation(`Deseja realmente excluir o grupo "${group}"?`, function(confirmed) {
        if (confirmed) {
            submitForm(event, 'delete-group');
        }
    });
}

function confirmDeleteUser(event) {
    event.preventDefault();
    const username = document.getElementById('delete-username').value;

    if (!username) {
        showAlert('Por favor, digite o nome do usuário', 'error');
        return;
    }

    showConfirmation(`Tem certeza que deseja deletar o usuário "${username}"?`, function(confirmed) {
        if (confirmed) {
            submitForm(event, 'delete-user');
        }
    });
}

// Função para mostrar/ocultar campo de data
function toggleExpiryFields() {
    const dateField = document.getElementById('date-field');
    const expiryType = document.querySelector('input[name="expiry-type"]:checked').value;

    if (expiryType === 'date') {
        dateField.style.display = 'block';
        document.getElementById('account-expiry-date').required = true;
    } else {
        dateField.style.display = 'none';
        document.getElementById('account-expiry-date').required = false;
    }
}

// Função para definir expiração da conta (modificada)
function handleAccountExpiry(event) {
    event.preventDefault();
    const username = document.getElementById('account-expiry-username').value;
    const expiryType = document.querySelector('input[name="expiry-type"]:checked').value;
    let expiryDate = document.getElementById('account-expiry-date').value;

    if (!username) {
        showAlert('Por favor, digite o nome do usuário', 'error');
        return;
    }

    if (expiryType === 'date' && !expiryDate) {
        showAlert('Por favor, selecione a data de expiração', 'error');
        return;
    }

    let confirmMessage;
    if (expiryType === 'never') {
        confirmMessage = `Definir que a CONTA do usuário "${username}" NUNCA expire?`;
        expiryDate = 'never';
    } else {
        // Converter DD/MM/YYYY para YYYY-MM-DD se necessário
        if (expiryDate.includes('/')) {
            const parts = expiryDate.split('/');
            if (parts.length === 3) {
                expiryDate = `${parts[2]}-${parts[1].padStart(2, '0')}-${parts[0].padStart(2, '0')}`;
            }
        }
        confirmMessage = `Definir que a CONTA do usuário "${username}" expire em ${expiryDate}?`;
    }

    showConfirmation(confirmMessage, function(confirmed) {
        if (confirmed) {
            const loading = document.querySelector('.loading');
            if(loading) loading.style.display = 'block';

            const formData = new FormData();
            formData.append('action', 'set-account-expiry');
            formData.append('username', username);
            formData.append('expiry-date', expiryDate);

            fetch('/cgi-bin/samba-admin.cgi', {
                method: 'POST',
                body: new URLSearchParams(formData)
            })
            .then(response => response.text())
            .then(data => {
                if(loading) loading.style.display = 'none';

                const resultContainer = document.querySelector('.result-container');
                if(resultContainer) {
                    resultContainer.style.display = 'block';
                    resultContainer.innerHTML = `<pre>${data}</pre>`;
                }

                showAlert('Comando executado', 'success');
            })
            .catch(error => {
                if(loading) loading.style.display = 'none';
                showAlert('Erro: ' + error.message, 'error');
            });
        }
    });
}

// Função para voltar para Configurações do Domínio
function backToDomainSettings() {
    // Limpar resultados
    const resultContainer = document.querySelector('.result-container');
    if (resultContainer) {
        resultContainer.style.display = 'none';
        resultContainer.innerHTML = '';
    }

    // Limpar loading
    const loading = document.querySelector('.loading');
    if (loading) {
        loading.style.display = 'none';
    }

    hideAlert();

    // Esconder todos os formulários
    document.querySelectorAll('.form-container').forEach(function(form) {
        form.classList.remove('active');
    });

    // Mostrar o submenu de configurações do domínio
    showSubmenu('domain-settings');
}
