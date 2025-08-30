# 📄 Requisitos Funcionais — Eventos

## **EVT-RF-001 — Criação de Evento**
**Descrição:**  
Permitir que um usuário com perfil Promotor crie um evento fornecendo título, descrição, datas de início/fim, local, capacidade, preço opcional, banner e defina se publica imediatamente ou salva como rascunho.

**Atores:**
- Promotor autenticado
- Serviço de Notificações (assíncrono)

**Pré-condições:**
- Usuário autenticado com perfil `promotor`.
- Payload com campos obrigatórios válidos.

**Fluxo principal:**
1. Promotor envia dados do evento (incluindo flag publicar).
2. Sistema valida campos e regras de negócio.
3. Sistema persiste evento com status `ativo` (se publicar=true) ou `rascunho`.
4. Sistema registra auditoria e data/hora de criação.
5. Sistema dispara notificação (se publicado).

**Fluxos alternativos:**
- A1: Dados inválidos → 400.
- A2: Usuário não é promotor → 403.
- A3: Rate limit excedido → 429.

**Pós-condições:**
- Evento criado e armazenado.
- Notificação enviada quando publicado.

**Regras de negócio associadas:**
- Ver seção RNF (validações de formato, limites, auditoria, cache, rate limit).

---
## **EVT-RF-002 — Listagem Pública de Eventos**
**Descrição:**  
Disponibilizar listagem paginada de eventos com status `ativo` ou `esgotado`, exibindo resumo (título, datas, local, preços, vagas restantes, banner, status).

**Atores:**
- Usuário público (autenticado ou não)

**Pré-condições:**
- Existência opcional de eventos ativos.

**Fluxo principal:**
1. Cliente solicita lista.
2. Sistema aplica ordenação padrão (dataInicio ASC) e paginação.
3. Sistema retorna lista de eventos ou indica ausência.

**Fluxos alternativos:**
- A1: Nenhum evento → 204.
- A2: Erro interno → 500.

**Pós-condições:**
- Acesso registrado para métricas/auditoria.

**Regras de negócio associadas:**
- Paginação máx. 20 itens.
- Cache curto (BFF) de 5 minutos.

---
## **EVT-RF-003 — Pesquisa Avançada / Filtrar Eventos**
**Descrição:**  
Permitir filtros por intervalo de datas, local (parcial), palavra-chave (título/descrição), faixa de preço, status e ordenação parametrizável.

**Atores:**
- Usuário público

**Pré-condições:**
- Filtros opcionais no payload.

**Fluxo principal:**
1. Cliente envia filtros.
2. Sistema valida formatos e combinações.
3. Sistema aplica filtros e paginação.
4. Sistema retorna eventos e metadados de paginação.

**Fluxos alternativos:**
- A1: Filtros inválidos → 400.
- A2: Nenhum resultado → 204.

**Pós-condições:**
- Métricas de filtros atualizadas.

**Regras de negócio associadas:**
- Ordenação default dataInicio ASC.
- Campos permitidos: dataInicio, titulo, preco, capacidade.

---
## **EVT-RF-004 — Listar Meus Eventos (Promotor)**
**Descrição:**  
Permitir que o promotor visualize todos seus eventos (todos os status) com paginação e ordenação por data de criação desc.

**Atores:**
- Promotor autenticado

**Pré-condições:**
- Perfil `promotor` válido.

**Fluxo principal:**
1. Promotor solicita "meus eventos".
2. Sistema autentica e identifica promotor.
3. Sistema retorna eventos do promotor com paginação.

**Fluxos alternativos:**
- A1: Sem eventos → 204.
- A2: Usuário não é promotor → 403.

**Pós-condições:**
- Acesso registrado.

**Regras de negócio associadas:**
- Retorna status: rascunho, ativo, esgotado, inativo.

---
## **EVT-RF-005 — Detalhes do Evento**
**Descrição:**  
Permitir a consulta detalhada de um evento público (ativo ou esgotado) incluindo metadados do promotor (não sensíveis) e vagas restantes calculadas.

**Atores:**
- Usuário público
- Serviço de Inscrições (para cálculo de vagas)

**Pré-condições:**
- Evento existente e não inativo.

**Fluxo principal:**
1. Cliente solicita detalhes por ID.
2. Sistema valida UUID.
3. Sistema busca evento e calcula vagas restantes.
4. Sistema retorna detalhes completos.

**Fluxos alternativos:**
- A1: ID inválido → 400.
- A2: Evento inexistente/inativo → 404.

**Pós-condições:**
- Log de acesso armazenado.

**Regras de negócio associadas:**
- Cache 2 minutos (BFF/microserviço).

---
## **EVT-RF-006 — Edição de Evento**
**Descrição:**  
Permitir que o promotor proprietário atualize campos de um evento ativo(esgotado) respeitando regras de capacidade, datas e restrições.

**Atores:**
- Promotor autenticado
- Serviço de Notificações
- Serviço de Inscrições

**Pré-condições:**
- Promotor autenticado e dono do evento.
- Evento ativo ou esgotado.

**Fluxo principal:**
1. Promotor envia novos dados.
2. Sistema valida regras (capacidade >= inscrições etc.).
3. Sistema atualiza e registra auditoria.
4. Sistema dispara notificações quando campos críticos mudam.

**Fluxos alternativos:**
- A1: Evento não encontrado → 404.
- A2: Não proprietário → 403.
- A3: Dados inválidos → 400.
- A4: Conflito capacidade/inscrições → 409.

**Pós-condições:**
- Evento atualizado e auditado.

**Regras de negócio associadas:**
- Notificar inscritos se data/local/capacidade alterados.

---
## **EVT-RF-007 — Cancelamento de Evento**
**Descrição:**  
Permitir cancelamento lógico (status inativo) de um evento sem inscrições ativas.

**Atores:**
- Promotor autenticado
- Serviço de Notificações
- Serviço de Inscrições

**Pré-condições:**
- Evento ativo ou esgotado.
- Zero inscrições ativas.
- Promotor proprietário.

**Fluxo principal:**
1. Promotor solicita cancelamento.
2. Sistema valida propriedade, status e inscrições.
3. Sistema marca como inativo e registra auditoria.
4. Sistema dispara notificações.

**Fluxos alternativos:**
- A1: Evento inexistente/inativo → 404.
- A2: Inscrições ativas → 409.
- A3: Não proprietário → 403.

**Pós-condições:**
- Evento fora de listagens públicas.

**Regras de negócio associadas:**
- Retenção de dados para auditoria.

---
