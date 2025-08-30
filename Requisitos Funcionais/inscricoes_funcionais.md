# 📄 Requisitos Funcionais — Inscrições

## **INS-RF-001 — Realizar Inscrição em Evento**
**Descrição:**  
Permitir que usuário autenticado se inscreva em evento ativo com vagas disponíveis.

**Atores:**
- Usuário autenticado
- Serviço de Eventos
- Serviço de Notificações

**Pré-condições:**
- Usuário ativo.
- Evento existente e status `ativo`.
- Vagas disponíveis (capacidade > inscrições ativas).
- Usuário não inscrito previamente.

**Fluxo principal:**
1. Usuário solicita inscrição fornecendo eventoId.
2. Sistema valida existência e status do evento.
3. Sistema verifica vagas (consulta contagem atual de inscrições).
4. Sistema confirma inexistência de inscrição anterior do usuário.
5. Sistema cria inscrição (`ativo`).
6. Sistema atualiza contagem/vagas (ou recalcula sob demanda).
7. Sistema dispara notificação de confirmação.

**Fluxos alternativos:**
- A1: Evento inexistente → 404.
- A2: Evento inativo → 403.
- A3: Vagas esgotadas → 409.
- A4: Usuário já inscrito → 409.

**Pós-condições:**
- Inscrição registrada e auditada.

**Regras de negócio associadas:**
- Retentativa idempotente (mesmo usuário/evento) retorna 409.

---
## **INS-RF-002 — Listar Minhas Inscrições**
**Descrição:**  
Permitir que o usuário veja suas inscrições ativas ordenadas por data de início do evento.

**Atores:**
- Usuário autenticado
- Serviço de Eventos

**Pré-condições:**
- Usuário autenticado.

**Fluxo principal:**
1. Usuário solicita listagem.
2. Sistema recupera inscrições do usuário.
3. Sistema agrega dados de eventos (título, datas, local).
4. Sistema ordena por `dataInicio` ASC.
5. Sistema retorna lista.

**Fluxos alternativos:**
- A1: Nenhuma inscrição → 204.

**Pós-condições:**
- Acesso registrado (auditoria).

**Regras de negócio associadas:**
- Apenas o próprio usuário acessa.

---
## **INS-RF-003 — Cancelar Inscrição**
**Descrição:**  
Permitir que usuário cancele inscrição ativa antes de início do evento (política padrão).

**Atores:**
- Usuário autenticado
- Serviço de Eventos
- Serviço de Notificações

**Pré-condições:**
- Inscrição existe e pertence ao usuário.
- Status atual `ativo`.
- Evento não iniciado (ou política permite cancelamento tardio).

**Fluxo principal:**
1. Usuário solicita cancelamento.
2. Sistema valida propriedade e status.
3. Sistema marca inscrição `cancelada` e registra dataCancelamento.
4. Sistema (opcional) incrementa vaga disponível / recalcula.
5. Sistema dispara notificação.

**Fluxos alternativos:**
- A1: Inscrição inexistente → 404.
- A2: Já cancelada → 409.
- A3: Evento iniciado (sem política de exceção) → 403.

**Pós-condições:**
- Inscrição cancelada e auditada.

**Regras de negócio associadas:**
- Não permitir reativar inscrição por este endpoint.

---
## **INS-RF-004 — Listar Inscrições de Evento (Promotor)**
**Descrição:**  
Permitir que promotor proprietário visualize inscrições de seu evento.

**Atores:**
- Promotor autenticado / Administrador
- Serviço de Eventos

**Pré-condições:**
- Evento existe e pertence ao promotor (ou perfil admin).

**Fluxo principal:**
1. Promotor solicita listagem pelo eventoId.
2. Sistema valida propriedade e status.
3. Sistema recupera inscrições e ordena por `dataInscricao` DESC.
4. Sistema retorna dados agregados (nome, email, status, dataInscricao).

**Fluxos alternativos:**
- A1: Evento inexistente/inativo → 404 ou 403.
- A2: Sem inscrições → 204.

**Pós-condições:**
- Acesso registrado para auditoria.

**Regras de negócio associadas:**
- Exposição limitada de dados (somente nome/email necessários).

---
