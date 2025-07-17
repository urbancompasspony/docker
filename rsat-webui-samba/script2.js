 function showConfirmation(message, callback) {
     const overlay = document.getElementById('confirmOverlay');
     const messageEl = document.getElementById('confirmMessage');
     const yesBtn = document.getElementById('confirmYes');
     const noBtn = document.getElementById('confirmNo');

     messageEl.innerHTML = message;
     overlay.style.display = 'flex'; // APENAS JavaScript
     overlay.classList.remove('active'); // Limpar classe se existir

     // MÉTODO SEGURO: Clonar elementos para remover TODOS os event listeners
     const newYesBtn = yesBtn.cloneNode(true);
     const newNoBtn = noBtn.cloneNode(true);

     yesBtn.parentNode.replaceChild(newYesBtn, yesBtn);
     noBtn.parentNode.replaceChild(newNoBtn, noBtn);

     // Adicionar novos event listeners aos elementos clonados
     newYesBtn.addEventListener('click', function() {
         overlay.style.display = 'none';
         document.removeEventListener('keydown', window.currentEscHandler); // Limpar ESC
         callback(true);
     });

     newNoBtn.addEventListener('click', function() {
         overlay.style.display = 'none';
         document.removeEventListener('keydown', window.currentEscHandler); // Limpar ESC
         callback(false);
     });

     // BACKUP: ESC para fechar (com proteção contra duplicatas)
     const escHandler = function(e) {
         if (e.key === 'Escape') {
             overlay.style.display = 'none';
             document.removeEventListener('keydown', escHandler);
             callback(false);
         }
     };

     // REMOVER QUALQUER HANDLER ESC ANTERIOR antes de adicionar novo
     document.removeEventListener('keydown', window.currentEscHandler);
     window.currentEscHandler = escHandler;
     document.addEventListener('keydown', escHandler);
 }

 function handlePasswordExpiry(event) {
     event.preventDefault();
     const username = document.getElementById('expiry-username').value;

     if (!username) {
         showAlert('Por favor, digite o nome do usuário', 'error');
         return;
     }

     // USAR A FUNÇÃO SEGURA showConfirmation()
     const message = `<strong>CONFIGURAR EXPIRAÇÃO DE SENHA</strong><br><br>Usuário: "${username}"<br><br>A senha deste usuário NÃO deve mais expirar?<br><br>• <strong>SIM</strong> = Senha nunca expira (--noexpiry)<br>• <strong>NÃO</strong> = Senha expira em 90 dias (padrão do domínio)`;

     showConfirmation(message, function(confirmed) {
         if (confirmed) {
             // SIM - senha não expira
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
                 document.getElementById('expiry-username').value = '';
             })
             .catch(error => {
                 hideLoading();
                 showAlert('Erro: ' + error.message, 'error');
             });
         } else {
             // NÃO - define prazo padrão
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
                 document.getElementById('expiry-username').value = '';
             })
             .catch(error => {
                 hideLoading();
                 showAlert('Erro: ' + error.message, 'error');
             });
         }
     });
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

 function toggleExpiryFields() {
     // PROTEÇÃO CONTRA CLIQUES RÁPIDOS
     if (!canClick()) {
         return;
     }

     try {
         const dateField = document.getElementById('date-field');
         const expiryTypeElement = document.querySelector('input[name="expiry-type"]:checked');

         // VALIDAÇÃO DE ELEMENTOS
         if (!dateField || !expiryTypeElement) {
             return;
         }

         const expiryType = expiryTypeElement.value;

         if (expiryType === 'date') {
             dateField.style.display = 'block';
             const dateInput = document.getElementById('account-expiry-date');
             if (dateInput) {
                 dateInput.required = true;
             }
         } else {
             dateField.style.display = 'none';
             const dateInput = document.getElementById('account-expiry-date');
             if (dateInput) {
                 dateInput.required = false;
                 dateInput.value = ''; // Limpar valor se não for usado
             }
         }
     } catch (error) {
         return;
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

     // USAR showConfirmation() PADRONIZADA
     let confirmMessage;
     if (expiryType === 'never') {
         confirmMessage = `Definir que a CONTA do usuário "${username}" NUNCA expire?`;
         expiryDate = 'never';
     } else {
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
                 showAlert('Configuração aplicada', 'success');
             })
             .catch(error => {
                 if(loading) loading.style.display = 'none';
                 showAlert('Erro: ' + error.message, 'error');
             });
         }
     });
 }

 function backToDomainSettings() {
     // USAR PROTEÇÕES PADRÃO COMO OUTRAS FUNÇÕES DE NAVEGAÇÃO
     if (!canClick() || !canNavigate()) {
         return;
     }

     isNavigating = true;

     try {
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

         // ESCONDER TODOS OS FORMULÁRIOS (padrão JavaScript)
         document.querySelectorAll('.form-container').forEach(function(form) {
             form.style.display = 'none';
             form.classList.remove('active');
         });

         // ESCONDER TODOS OS SUBMENUS
         document.querySelectorAll('.submenu').forEach(function(sub) {
             sub.style.display = 'none';
             sub.classList.remove('active');
         });

         // MOSTRAR O SUBMENU DE CONFIGURAÇÕES (padrão JavaScript)
         const domainSettings = document.getElementById('domain-settings');
         if (domainSettings) {
             domainSettings.style.display = 'block';
         }
     } finally {
         // LIBERAR NAVEGAÇÃO
         setTimeout(() => {
             isNavigating = false;
         }, 100);
     }
 }


