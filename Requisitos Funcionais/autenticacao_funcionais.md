# 📄 Requisitos Funcionais — Autenticação

## **AUT-RF-001 — Login de Usuário**
**Descrição:**  
Permitir login via email e senha válidos retornando token de acesso (JWT) e refresh token.

**Atores:**
- Usuário
- Serviço de Autenticação

**Pré-condições:**
- Usuário cadastrado, ativo e não bloqueado.

**Fluxo principal:**
1. Usuário envia email e senha.
2. Sistema valida credenciais e status da conta.
3. Sistema gera token de acesso e refresh token.
4. Sistema retorna dados básicos e tempos de expiração.
5. Sistema registra último login e zera contador de falhas.

**Fluxos alternativos:**
- A1: Credenciais inválidas → 401 e incrementa falhas.
- A2: 5ª falha consecutiva → bloqueio 15 min (429).
- A3: Conta inativa → 403.

**Pós-condições:**
- Tokens emitidos e armazenado refresh token (persistência / cache).

**Regras de negócio associadas:**
- Política de senha vigente.
- Limite de tentativas (ver RNF rate limiting).

---
## **AUT-RF-002 — Renovação de Token**
**Descrição:**  
Permitir emissão de novo par de tokens a partir de refresh token válido.

**Atores:**
- Usuário

**Pré-condições:**
- Refresh token existente, não expirado, não revogado.

**Fluxo principal:**
1. Cliente envia refresh token.
2. Sistema valida integridade, expiração e revogação.
3. Sistema gera novos tokens e invalida o anterior.
4. Sistema retorna novos tempos de expiração.

**Fluxos alternativos:**
- A1: Token expirado/revogado → 401.

**Pós-condições:**
- Refresh token antigo marcado como inválido.

**Regras de negócio associadas:**
- Janela de validade (ex: 7 dias).

---
## **AUT-RF-003 — Troca de Senha**
**Descrição:**  
Permitir usuário autenticado alterar senha informando senha atual e nova senha.

**Atores:**
- Usuário autenticado

**Pré-condições:**
- JWT válido.
- Senha atual correta.

**Fluxo principal:**
1. Usuário envia senha atual e nova senha.
2. Sistema valida senha atual.
3. Sistema valida nova senha (critérios segurança).
4. Sistema atualiza hash da senha.
5. Sistema envia notificação de alteração.

**Fluxos alternativos:**
- A1: Senha atual incorreta → 401.
- A2: Nova senha inválida → 400.

**Pós-condições:**
- Senha substituída, auditoria registrada.

**Regras de negócio associadas:**
- Política de complexidade.
- Não reutilizar senha atual.

---
## **AUT-RF-004 — Solicitar Recuperação de Senha**
**Descrição:**  
Permitir solicitação de email com link/token de recuperação válido por 1 hora.

**Atores:**
- Usuário
- Serviço de Notificações

**Pré-condições:**
- Email cadastrado.
- Dentro do limite de solicitações.

**Fluxo principal:**
1. Usuário envia email.
2. Sistema gera token recuperação (1h) e persiste.
3. Sistema dispara email via notificações.

**Fluxos alternativos:**
- A1: Email não encontrado → 404.
- A2: Rate limit excedido → 429.

**Pós-condições:**
- Token armazenado aguardando uso.

**Regras de negócio associadas:**
- Invalidação após uso ou expiração.

---
## **AUT-RF-005 — Redefinir Senha**
**Descrição:**  
Permitir redefinir senha com token de recuperação válido.

**Atores:**
- Usuário

**Pré-condições:**
- Token válido, não expirado, não usado.

**Fluxo principal:**
1. Usuário envia token + nova senha.
2. Sistema valida token.
3. Sistema valida nova senha.
4. Sistema atualiza senha e invalida token.
5. Sistema invalida refresh tokens ativos.
6. Sistema envia notificação de confirmação.

**Fluxos alternativos:**
- A1: Token expirado/ inválido → 401.
- A2: Nova senha inválida → 400.

**Pós-condições:**
- Senha redefinida e tokens antigos invalidados.

**Regras de negócio associadas:**
- Política de complexidade.

---
