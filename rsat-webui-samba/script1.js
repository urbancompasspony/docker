        // URL do script CGI
        const CGI_URL = '/cgi-bin/samba-admin.cgi';

        // CONTROLE DE RACE CONDITIONS
        let isNavigating = false;
        let isFormSubmitting = false;
        let lastClickTime = 0;
        const CLICK_DEBOUNCE_MS = 300; // 300ms entre cliques

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

        // Função para prevenir cliques múltiplos rápidos
        function canClick() {
            const now = Date.now();
            if (now - lastClickTime < CLICK_DEBOUNCE_MS) {
                return false;
            }
            lastClickTime = now;
            return true;
        }

        // Função para controlar navegação
        function canNavigate() {
            if (isNavigating) {
                return false;
            }
            return true;
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

        function executeCommand(action) {
            // PREVENIR MÚLTIPLOS COMANDOS
            if (isFormSubmitting) {
                return;
            }

            isFormSubmitting = true;
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
            .then(response => response.text()) // Mudança: usar .text() em vez de .json()
            .then(text => {
                hideLoading();

                // PROCESSAMENTO MELHORADO DO RESULTADO (do script2.js)
                let output;
                try {
                    output = JSON.parse(text);
                } catch {
                    output = { text: text };
                }

                // Determinar se é sucesso ou erro
                const isSuccess = output.status === 'success' || (!output.status && !text.toLowerCase().includes('erro'));

                if (isSuccess) {
                    showAlert('Comando executado com sucesso!', 'success');
                } else {
                    showAlert(output.message || 'Erro ao executar comando', 'error');
                }

                // FORMATAÇÃO MELHORADA DO RESULTADO
                let displayText = '';
                if (output.text) {
                    displayText = output.text.trim();
                } else if (typeof output === 'string') {
                    displayText = output.trim();
                } else if (output.output) {
                    displayText = output.output.trim();
                } else {
                    displayText = text.trim();
                }

                // FORMATAÇÃO ESPECIAL PARA LISTAS (do script2.js)
                if (displayText.includes('\n')) {
                    const lines = displayText.split('\n').filter(line => line.trim());
                    if (lines.length > 1 && lines.every(line => !line.includes('='))) {
                        // Se parece ser uma lista simples, formatar com bullets
                        const formattedList = lines.map(line => `• ${line.trim()}`).join('<br>');
                        showResult(`<div style="font-family: 'Segoe UI', sans-serif; line-height: 1.6;">${formattedList}</div>`, !isSuccess);
                    } else {
                        showResult(`<pre>${displayText}</pre>`, !isSuccess);
                    }
                } else {
                    showResult(`<div style="font-family: monospace; padding: 10px; background: white; border-radius: 5px; font-size: 16px; color: #2c3e50;">${displayText}</div>`, !isSuccess);
                }
            })
            .catch(error => {
                hideLoading();
                showAlert('Erro de conexão: ' + error.message, 'error');
                showResult(`<pre>Erro: ${error.message}</pre>`, true);
                console.error('Erro:', error);
            })
            .finally(() => {
                // LIBERAR SUBMIT
                setTimeout(() => {
                    isFormSubmitting = false;
                }, 500);
            });
        }

        function submitForm(event, formType) {
            event.preventDefault();

            // PREVENIR MÚLTIPLOS SUBMITS
            if (isFormSubmitting) {
                return;
            }

            isFormSubmitting = true;
            showLoading();

            const form = event.target;
            const formData = new FormData(form);
            const params = new URLSearchParams();

            params.append('action', formType);
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
            .then(response => response.text()) // Mudança: usar .text() em vez de .json()
            .then(text => {
                hideLoading();

                // PROCESSAMENTO MELHORADO DO RESULTADO (do script2.js)
                let output;
                try {
                    output = JSON.parse(text);
                } catch {
                    output = { text: text };
                }

                // Determinar se é sucesso ou erro
                const isSuccess = output.status === 'success' || (!output.status && !text.toLowerCase().includes('erro'));

                if (isSuccess) {
                    showAlert('Operação realizada com sucesso!', 'success');
                    form.reset();
                } else {
                    showAlert(output.message || 'Erro na operação', 'error');
                }

                // FORMATAÇÃO MELHORADA DO RESULTADO
                let displayText = '';
                if (output.text) {
                    displayText = output.text.trim();
                } else if (typeof output === 'string') {
                    displayText = output.trim();
                } else if (output.output) {
                    displayText = output.output.trim();
                } else {
                    displayText = text.trim();
                }

                // Exibir resultado formatado
                if (displayText.includes('\n') || displayText.length > 100) {
                    showResult(`<pre>${displayText}</pre>`, !isSuccess);
                } else {
                    showResult(`<div style="font-family: monospace; padding: 10px; background: white; border-radius: 5px;">${displayText}</div>`, !isSuccess);
                }
            })
            .catch(error => {
                hideLoading();
                showAlert('Erro de conexão: ' + error.message, 'error');
                showResult(`<pre>Erro: ${error.message}</pre>`, true);
                console.error('Erro:', error);
            })
            .finally(() => {
                // LIBERAR SUBMIT após delay
                setTimeout(() => {
                    isFormSubmitting = false;
                }, 1000);
            });
        }

        function showSubmenu(submenuId) {
            // PREVENIR RACE CONDITIONS
            if (!canClick() || !canNavigate()) {
                return;
            }

            isNavigating = true;

            try {
                hideAlert();
                hideResult();

                // ESCONDER MENU PRINCIPAL
                document.getElementById('main-menu').style.display = 'none';

                // ESCONDER TODOS OS SUBMENUS (APENAS JavaScript - sem classes)
                document.querySelectorAll('.submenu').forEach(function(sub) {
                    sub.style.display = 'none';
                    sub.classList.remove('active'); // Limpar classe residual
                });

                // ESCONDER TODOS OS FORMULÁRIOS (APENAS JavaScript - sem classes)
                document.querySelectorAll('.form-container').forEach(function(form) {
                    form.style.display = 'none';
                    form.classList.remove('active'); // Limpar classe residual
                });

                // ESCONDER PAINÉIS DE INSTRUÇÃO
                document.querySelectorAll('.instruction-panel').forEach(function(panel) {
                    panel.style.display = 'none';
                });

                // ESCONDER MODAIS se estiverem abertos
                const confirmOverlay = document.getElementById('confirmOverlay');
                if (confirmOverlay) {
                    confirmOverlay.style.display = 'none';
                }

                const folderBrowserModal = document.getElementById('folderBrowserModal');
                if (folderBrowserModal) {
                    folderBrowserModal.style.display = 'none';
                }

                // MOSTRAR O SUBMENU ESPECÍFICO (APENAS JavaScript)
                var submenu = document.getElementById(submenuId);
                if (submenu) {
                    submenu.style.display = 'block';
                }
            } finally {
                // LIBERAR NAVEGAÇÃO após um pequeno delay
                setTimeout(() => {
                    isNavigating = false;
                }, 100);
            }
        }

        function showMainMenu() {
            // PREVENIR RACE CONDITIONS
            if (!canClick() || !canNavigate()) {
                return;
            }

            isNavigating = true;

            try {
                // LIMPEZA COMPLETA DE TODOS OS ELEMENTOS

                // 1. Limpar resultados
                const resultContainer = document.querySelector('.result-container');
                if (resultContainer) {
                    resultContainer.style.display = 'none';
                    resultContainer.innerHTML = '';
                }

                // 2. Limpar loading
                const loading = document.querySelector('.loading');
                if (loading) {
                    loading.style.display = 'none';
                }

                // 3. Limpar alerts
                hideAlert();

                // 4. ESCONDER TODOS OS SUBMENUS (APENAS JavaScript)
                document.querySelectorAll('.submenu').forEach(function(sub) {
                    sub.style.display = 'none';
                    sub.classList.remove('active'); // Limpar qualquer classe residual
                });

                // 5. ESCONDER TODOS OS FORMULÁRIOS (APENAS JavaScript)
                document.querySelectorAll('.form-container').forEach(function(form) {
                    form.style.display = 'none';
                    form.classList.remove('active'); // Limpar qualquer classe residual
                });

                // 6. ESCONDER PAINÉIS DE INSTRUÇÃO
                document.querySelectorAll('.instruction-panel').forEach(function(panel) {
                    panel.style.display = 'none';
                });

                // 7. ESCONDER MODAIS (se estiverem abertos)
                const confirmOverlay = document.getElementById('confirmOverlay');
                if (confirmOverlay) {
                    confirmOverlay.classList.remove('active');
                    confirmOverlay.style.display = 'none';
                }

                const folderBrowserModal = document.getElementById('folderBrowserModal');
                if (folderBrowserModal) {
                    folderBrowserModal.style.display = 'none';
                }

                // 8. MOSTRAR O MENU PRINCIPAL
                const mainMenu = document.getElementById('main-menu');
                if (mainMenu) {
                    mainMenu.style.display = 'grid';
                }

                // 9. LIMPAR CAMPOS DE FORMULÁRIOS (reset completo)
                const inputs = document.querySelectorAll('input[type="text"], input[type="password"], input[type="date"], input[type="number"], textarea, select');
                inputs.forEach(input => {
                    if (input.type === 'radio' || input.type === 'checkbox') {
                        input.checked = input.defaultChecked;
                    } else {
                        input.value = '';
                    }
                    input.style.borderColor = '';
                });

            } finally {
                // LIBERAR NAVEGAÇÃO
                setTimeout(() => {
                    isNavigating = false;
                }, 100);
            }
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
            // PREVENIR RACE CONDITIONS
            if (!canClick() || !canNavigate()) {
                return;
            }

            isNavigating = true;

            try {
                hideAlert();
                hideResult();

                // Remover TODAS as classes active de formulários
                document.querySelectorAll('.form-container').forEach(function(form) {
                    form.classList.remove('active');
                    form.style.display = 'none';
                });

                // Mostrar o formulário específico
                var el = document.getElementById(formName + '-form');
                if (el) {
                    el.style.display = 'block';
                }

                // Esconder painéis de instrução
                document.querySelectorAll('.instruction-panel').forEach(function(panel) {
                    panel.style.display = 'none';
                });
            } finally {
                // LIBERAR NAVEGAÇÃO
                setTimeout(() => {
                    isNavigating = false;
                }, 50); // Menor delay para formulários
            }
        }

        function hideForm() {
            // ESCONDER TODOS OS FORMULÁRIOS (APENAS JavaScript)
            const forms = document.querySelectorAll('.form-container');
            forms.forEach(form => {
                form.style.display = 'none';
                          form.classList.remove('active'); // Limpar classe residual
            });

            // ESCONDER TODOS OS SUBMENUS também (pode ter ficado aberto)
            const submenus = document.querySelectorAll('.submenu');
            submenus.forEach(sub => {
                sub.style.display = 'none';
                sub.classList.remove('active'); // Limpar classe residual
            });

            // ESCONDER MODAIS
            const confirmOverlay = document.getElementById('confirmOverlay');
            if (confirmOverlay) {
                confirmOverlay.style.display = 'none';
                confirmOverlay.classList.remove('active');
            }

            const folderBrowserModal = document.getElementById('folderBrowserModal');
            if (folderBrowserModal) {
                folderBrowserModal.style.display = 'none';
            }

            // Limpar loading
            const loading = document.querySelector('.loading');
            if (loading) {
                loading.style.display = 'none';
            }

            // Limpar campos dos formulários
            const inputs = document.querySelectorAll('input[type="text"], input[type="password"], input[type="date"], input[type="number"], textarea, select');
            inputs.forEach(input => {
                if (input.type === 'radio' || input.type === 'checkbox') {
                    input.checked = input.defaultChecked;
                } else {
                    input.value = '';
                }
                // Limpar estilos de validação
                input.style.borderColor = '';
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
