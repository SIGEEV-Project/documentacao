# 📄 Requisitos Não Funcionais — Usuários

## **RNF-001 — Validação de E-mail**
**Descrição:**  
O sistema deve validar o e-mail informado pelo usuário conforme o padrão **RFC 5322**, garantindo que tenha entre **5 e 100 caracteres** e que seja único no sistema.

**Critério de Aceitação:**
- Testes com e-mails válidos e inválidos confirmam a aplicação da regra.
- Tentativa de cadastro com e-mail já existente retorna erro **409 Conflict**.

---

## **RNF-002 — Validação de CPF**
**Descrição:**  
O sistema deve validar o CPF segundo o algoritmo oficial, garantindo unicidade e armazenamento seguro. O CPF deve ser exibido mascarado nas consultas.

**Critério de Aceitação:**
- Cadastro com CPF inválido retorna erro **400 Bad Request**.
- Cadastro com CPF já existente retorna erro **409 Conflict**.
- Consultas retornam CPF no formato `123.***.***-00`.

---

## **RNF-003 — Validação de Telefone**
**Descrição:**  
O telefone deve seguir o formato brasileiro com **DDD**, conter apenas números e ter **10 ou 11 dígitos**.

**Critério de Aceitação:**
- Cadastro com telefone fora do padrão retorna erro **400 Bad Request**.
- Telefone válido é armazenado corretamente.

---

## **RNF-004 — Validação de CEP**
**Descrição:**  
O CEP deve seguir o formato `XXXXX-XXX`, contendo apenas números e hífen.

**Critério de Aceitação:**
- Cadastro com CEP inválido retorna erro **400 Bad Request**.
- CEP válido é armazenado corretamente.

---

## **RNF-005 — Validação de Estado**
**Descrição:**  
O campo Estado deve conter apenas **2 caracteres** (sigla oficial da UF), em letras maiúsculas.

**Critério de Aceitação:**
- Cadastro com estado inválido retorna erro **400 Bad Request**.
- Cadastro com estado válido é aceito.

---

## **RNF-006 — Restrições de Conteúdo e Tamanho**
**Descrição:**  
Campos devem seguir as seguintes regras:
- Primeiro nome: apenas letras, 2–50 caracteres.
- Último nome: apenas letras, 2–100 caracteres.
- Logradouro: letras, números e espaços, 3–100 caracteres.
- Cidade: apenas letras e espaços, 2–50 caracteres.
- Número do endereço: numérico válido.

**Critério de Aceitação:**
- Testes com valores fora dos limites retornam erro **400 Bad Request**.
- Valores válidos são aceitos e armazenados.

---

## **RNF-007 — Segurança e Auditoria**
**Descrição:**  
Todas as operações críticas devem registrar data/hora, ID do responsável e correlationId. O CPF deve ser mascarado nas respostas e logs de auditoria devem ser mantidos.

**Critério de Aceitação:**
- Logs de auditoria contêm todas as informações exigidas.
- Consultas retornam CPF mascarado.

---

## **RNF-008 — Integração com Microserviço de Notificações**
**Descrição:**  
O sistema deve enviar e-mails automáticos para eventos de cadastro, alteração, promoção, rebaixamento e exclusão de conta, de forma assíncrona.

**Critério de Aceitação:**
- Cada evento dispara uma chamada ao microserviço de notificações.
- O envio de e-mail não impacta o tempo de resposta da API.

---

## **RNF-009 — Restrições de Idade**
**Descrição:**  
O usuário deve ter pelo menos **18 anos** na data do cadastro.

**Critério de Aceitação:**
- Cadastro com data de nascimento que indique idade inferior a 18 anos retorna erro **400 Bad Request**.

---

## **RNF-010 — Exclusão de Conta**
**Descrição:**  
A exclusão deve ser lógica, mantendo dados pelo período definido na política de retenção. Após exclusão, o login deve ser bloqueado.

**Critério de Aceitação:**
- Conta excluída não permite autenticação.
- Dados permanecem acessíveis apenas para fins administrativos durante o período de retenção.

---

## **RNF-011 — Desempenho**
**Descrição:**  
Consultas de perfil devem responder em até **2 segundos** e operações de cadastro/atualização em até **3 segundos** sob carga normal.

**Critério de Aceitação:**
- Testes de desempenho confirmam tempos de resposta dentro dos limites.

---

## **RNF-012 — Conformidade**
**Descrição:**  
O sistema deve estar em conformidade com a **LGPD**, permitindo exportação e exclusão de dados pessoais mediante solicitação do titular.

**Critério de Aceitação:**
- Solicitações de exportação e exclusão são atendidas conforme prazos legais.
- Dados pessoais são tratados segundo as diretrizes da LGPD.

---