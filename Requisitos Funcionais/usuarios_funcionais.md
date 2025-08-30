# 📄 Requisitos Funcionais — Usuários

## **USU-RF-001 — Cadastro de Usuário**
**Descrição:**  
Permitir o cadastro de um novo usuário no sistema, armazenando dados pessoais, endereço e credenciais de acesso, com validação de unicidade de CPF e e-mail.

**Atores:**
- Usuário não autenticado (novo cadastro)
- Sistema de autenticação

**Pré-condições:**
- O usuário não deve possuir cadastro prévio com o mesmo CPF ou e-mail.
- Todos os campos obrigatórios devem ser informados.

**Fluxo principal:**
1. O usuário acessa a tela de cadastro.
2. Informa todos os dados obrigatórios (nome, CPF, e-mail, senha, telefone, data de nascimento, endereço).
3. O sistema valida os dados e verifica unicidade de CPF e e-mail.
4. O sistema cria o registro do usuário.
5. O sistema gera e retorna um token JWT.
6. O sistema envia e-mail de confirmação de cadastro.

**Fluxos alternativos:**
- **A1:** CPF já cadastrado → Sistema retorna erro 409.
- **A2:** E-mail já cadastrado → Sistema retorna erro 409.
- **A3:** Dados inválidos → Sistema retorna erro 400.

**Pós-condições:**
- Usuário cadastrado e autenticado.
- Registro de data/hora do cadastro e correlationId.

**Regras de negócio associadas:**
- RNF-001: E-mail deve seguir padrão RFC 5322.
- RNF-002: CPF deve ser válido e único.
- RNF-003: Usuário deve ter pelo menos 18 anos.

---

## **USU-RF-002 — Consulta de Perfil**
**Descrição:**  
Permitir que o usuário autenticado consulte seu próprio perfil.

**Atores:**
- Usuário autenticado
- Sistema de autenticação

**Pré-condições:**
- Usuário deve estar autenticado com token JWT válido.

**Fluxo principal:**
1. O usuário solicita consulta de perfil.
2. O sistema valida o token JWT.
3. O sistema retorna dados pessoais e endereço.

**Fluxos alternativos:**
- **A1:** Token inválido ou ausente → Sistema retorna erro 401.
- **A2:** Usuário não encontrado → Sistema retorna erro 404.

**Pós-condições:**
- Registro de data/hora da consulta para auditoria.

**Regras de negócio associadas:**
- RNF-004: CPF deve ser mascarado na resposta.

---

## **USU-RF-003 — Atualização de Perfil**
**Descrição:**  
Permitir que o usuário atualize seus dados pessoais e endereço.

**Atores:**
- Usuário autenticado

**Pré-condições:**
- Usuário deve estar autenticado.
- Dados enviados devem ser válidos.

**Fluxo principal:**
1. O usuário acessa a tela de edição de perfil.
2. Informa os novos dados.
3. O sistema valida os dados.
4. O sistema atualiza o registro.
5. O sistema envia e-mail de confirmação de alteração.

**Fluxos alternativos:**
- **A1:** Dados inválidos → Sistema retorna erro 400.
- **A2:** Usuário não encontrado → Sistema retorna erro 404.

**Pós-condições:**
- Dados atualizados no banco.
- Registro de data/hora da alteração.

**Regras de negócio associadas:**
- RNF-001, RNF-002, RNF-005 (validações de formato e integridade).

---

## **USU-RF-004 — Promoção de Perfil**
**Descrição:**  
Permitir que administradores promovam um usuário para o perfil **Promotor**.

**Atores:**
- Administrador
- Usuário autenticado (destinatário da promoção)

**Pré-condições:**
- Administrador autenticado com permissão para promover usuários.
- Usuário alvo deve existir no sistema.

**Fluxo principal:**
1. Administrador solicita promoção de um usuário.
2. O sistema valida permissões.
3. O sistema altera o perfil do usuário para **Promotor**.
4. O sistema registra ID do administrador e data/hora.
5. O sistema envia e-mail de notificação ao usuário.

**Fluxos alternativos:**
- **A1:** Administrador sem permissão → Sistema retorna erro 403.
- **A2:** Usuário não encontrado → Sistema retorna erro 404.

**Pós-condições:**
- Perfil do usuário atualizado para **Promotor**.

**Regras de negócio associadas:**
- RNF-006: Registro de auditoria obrigatório.

---

## **USU-RF-005 — Rebaixamento de Perfil**
**Descrição:**  
Permitir que administradores rebaixem um usuário de **Promotor** para **Participante**.

**Atores:**
- Administrador
- Usuário autenticado (destinatário do rebaixamento)

**Pré-condições:**
- Administrador autenticado com permissão para rebaixar usuários.
- Usuário alvo deve existir no sistema.

**Fluxo principal:**
1. Administrador solicita rebaixamento de um usuário.
2. O sistema valida permissões.
3. O sistema altera o perfil do usuário para **Participante**.
4. O sistema registra ID do administrador e data/hora.
5. O sistema envia e-mail de notificação ao usuário.

**Fluxos alternativos:**
- **A1:** Administrador sem permissão → Sistema retorna erro 403.
- **A2:** Usuário não encontrado → Sistema retorna erro 404.

**Pós-condições:**
- Perfil do usuário atualizado para **Participante**.

**Regras de negócio associadas:**
- RNF-006: Registro de auditoria obrigatório.

---

## **USU-RF-006 — Exclusão de Conta**
**Descrição:**  
Permitir que o usuário solicite exclusão de conta.

**Atores:**
- Usuário autenticado

**Pré-condições:**
- Usuário deve estar autenticado.
- Solicitação deve ser confirmada pelo usuário.

**Fluxo principal:**
1. O usuário solicita exclusão da conta.
2. O sistema confirma a intenção.
3. O sistema marca o registro como excluído (exclusão lógica).
4. O sistema envia e-mail de confirmação.
5. O sistema impede futuros logins com as credenciais.

**Fluxos alternativos:**
- **A1:** Usuário não encontrado → Sistema retorna erro 404.

**Pós-condições:**
- Conta marcada como excluída.
- Dados retidos conforme política de retenção.

**Regras de negócio associadas:**
- RNF-007: Exclusão é lógica, mantendo dados pelo período definido.

