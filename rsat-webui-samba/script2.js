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
