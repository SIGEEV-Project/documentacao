# Documentação de API - Módulo de Inscrições (SIGEEV)

## Sumário
- [Documentação de API - Módulo de Inscrições (SIGEEV)](#documentação-de-api---módulo-de-inscrições-sigeev)
  - [Sumário](#sumário)
  - [Visão Geral](#visão-geral)
  - [Convenções](#convenções)
  - [Autenticação \& Autorização](#autenticação--autorização)
  - [Padrão de Envelope](#padrão-de-envelope)
  - [Erros Padrão](#erros-padrão)
  - [Cabeçalhos Importantes](#cabeçalhos-importantes)
  - [Tabela de Endpoints](#tabela-de-endpoints)
  - [Modelos de Dados](#modelos-de-dados)
    - [Inscrição (Resumo)](#inscrição-resumo)
    - [Inscrição com Evento (Minhas Inscrições)](#inscrição-com-evento-minhas-inscrições)
  - [Endpoints Detalhados](#endpoints-detalhados)
    - [POST /inscricoes (Inscrição em Evento)](#post-inscricoes-inscrição-em-evento)
    - [GET /inscricoes/me (Minhas Inscrições)](#get-inscricoesme-minhas-inscrições)
    - [DELETE /inscricoes/{id} (Cancelamento de Inscrição)](#delete-inscricoesid-cancelamento-de-inscrição)
    - [GET /eventos/{id}/inscricoes (Inscrições por Evento)](#get-eventosidinscricoes-inscrições-por-evento)
  - [Códigos de Status HTTP](#códigos-de-status-http)
  - [Controle de Versão](#controle-de-versão)
  - [Evoluções Futuras \& Notas](#evoluções-futuras--notas)

---
## Visão Geral
API responsável por registrar, consultar e cancelar inscrições de usuários em eventos, além de fornecer listagem para promotores.

## Convenções
- Base URL (exemplo): `https://api.sigeev.com`
- JSON UTF-8; datas em UTC ISO 8601 (`YYYY-MM-DDTHH:mm:ssZ`)
- IDs: UUID v4
- Status inscrição: `ativo`, `cancelada`, `pendente` (futuro: pagamento), `expirada` (futuro)

## Autenticação & Autorização
- Todas as operações exigem JWT, exceto nenhuma (todas protegidas) — listagem pública de inscrições não existe.
- `GET /eventos/{id}/inscricoes` restrito ao promotor proprietário ou administrador.

## Padrão de Envelope
```json
{
  "sucesso": true,
  "mensagem": "Descrição de alto nível",
  "dados": {},
  "erros": [ { "campo": "eventoId", "mensagem": "Evento não encontrado." } ],
  "timestamp": "2025-08-30T12:00:00Z",
  "correlationId": "uuid"
}
```
Observações:
- Listagens podem retornar array em `dados` ou objeto com metadados (paginação futura).

## Erros Padrão
| Campo | Descrição |
|-------|-----------|
| campo | Campo relacionado ao erro ou null para geral |
| mensagem | Explicação legível |

## Cabeçalhos Importantes
| Cabeçalho | Direção | Obrigatório | Descrição |
|-----------|---------|-------------|-----------|
| Authorization | → | Sim | JWT Bearer |
| X-Correlation-Id | ↔ | Recomendado | Rastreabilidade |
| Content-Type | → | Sim | `application/json` |
| Accept | → | Opcional | `application/json` |
| Retry-After | ← | Condicional | Rate limit inscrição (se aplicado) |

## Tabela de Endpoints
| Operação | Método | Caminho | Auth | Permissão | Descrição |
|----------|--------|--------|------|-----------|-----------|
| Criar Inscrição | POST | /inscricoes | Sim | Usuário | Inscreve usuário em evento |
| Minhas Inscrições | GET | /inscricoes/me | Sim | Usuário | Lista inscrições do usuário |
| Cancelar Inscrição | DELETE | /inscricoes/{id} | Sim | Usuário dono | Cancela inscrição própria |
| Listar Inscrições Evento | GET | /eventos/{id}/inscricoes | Sim | Promotor dono / Admin | Lista inscrições de um evento |

## Modelos de Dados
### Inscrição (Resumo)
```json
{
  "inscricaoId": "uuid",
  "eventoId": "uuid",
  "usuarioId": "uuid",
  "dataInscricao": "2025-09-01T10:00:00Z",
  "status": "ativo"
}
```
### Inscrição com Evento (Minhas Inscrições)
```json
{
  "inscricaoId": "uuid",
  "eventoId": "uuid",
  "titulo": "Workshop de Segurança",
  "dataInicio": "2025-10-01T09:00:00Z",
  "dataFim": "2025-10-01T18:00:00Z",
  "local": "Recife - PE",
  "statusInscricao": "ativo"
}
```

---
## Endpoints Detalhados
### POST /inscricoes (Inscrição em Evento)
Cria uma inscrição vinculando usuário autenticado a um evento.

Request Body:
```json
{ "eventoId": "a1b2c3d4-e5f6-7890-1234-567890abcdef" }
```
Observação: `usuarioId` derivado do token (não enviado no corpo).

Validações principais:
- Evento existe e status `ativo`
- Vagas disponíveis (capacidade > inscrições ativas)
- Usuário não inscrito previamente
- Usuário ativo

Comportamentos do sistema:
- Sistema dispara notificação de confirmação por e-mail
- Sistema registra auditoria da operação para fins de segurança

Respostas: 201 / 403 (evento inativo) / 404 (evento) / 409 (vagas esgotadas ou já inscrito) / 429 (rate limit, opcional) / 500

Exemplo Sucesso (201):
```json
{
  "sucesso": true,
  "mensagem": "Inscrição realizada com sucesso!",
  "dados": {
    "inscricaoId": "f1e2d3c4-b5a6-7890-1234-567890abcdef",
    "eventoId": "a1b2c3d4-e5f6-7890-1234-567890abcdef",
    "usuarioId": "u1b2c3d4-e5f6-7890-1234-567890abcdef",
    "dataInscricao": "2025-09-01T10:00:00Z",
    "status": "ativo"
  },
  "timestamp": "2025-09-01T10:00:00Z",
  "correlationId": "uuid"
}
```
Conflito (409) - Exemplo:
```json
{
  "sucesso": false,
  "mensagem": "Erro ao realizar inscrição.",
  "erros": [
    { "campo": "vagas", "mensagem": "Vagas esgotadas para este evento." },
    { "campo": "usuarioId", "mensagem": "Usuário já inscrito neste evento." }
  ],
  "timestamp": "2025-09-01T10:00:00Z",
  "correlationId": "uuid"
}
```

### GET /inscricoes/me (Minhas Inscrições)
Lista inscrições do usuário autenticado ordenadas por `dataInicio` do evento ASC.

Comportamentos do sistema:
- Sistema registra acesso para fins de auditoria

Respostas: 200 / 204 / 500

Exemplo Sucesso (200):
```json
{
  "sucesso": true,
  "mensagem": "Lista de inscrições recuperada com sucesso!",
  "dados": [
    {
      "inscricaoId": "f1e2d3c4-b5a6-7890-1234-567890abc001",
      "eventoId": "ev-001",
      "titulo": "Workshop de Segurança",
      "dataInicio": "2025-10-01T09:00:00Z",
      "dataFim": "2025-10-01T18:00:00Z",
      "local": "Recife - PE",
      "statusInscricao": "ativo"
    }
  ],
  "timestamp": "2025-09-05T09:00:00Z",
  "correlationId": "uuid"
}
```
Lista Vazia (204) ou 200 + array vazio:
```json
{ "sucesso": true, "mensagem": "Nenhuma inscrição encontrada.", "dados": [], "timestamp": "2025-09-05T09:00:00Z", "correlationId": "uuid" }
```

### DELETE /inscricoes/{id} (Cancelamento de Inscrição)
Cancela inscrição própria; libera vaga.

Restrições:
- Inscrição deve estar `ativo`
- Evento ainda não iniciado (ou política permitir cancelamento tardio)

Comportamentos do sistema:
- Sistema dispara notificação de cancelamento por e-mail
- Sistema registra auditoria da operação para fins de segurança
- Sistema incrementa vaga disponível no evento (recalcula vagas disponíveis)

Respostas: 200 / 403 (não dono / evento iniciado) / 404 (inscrição) / 409 (já cancelada) / 500

Exemplo Sucesso (200):
```json
{
  "sucesso": true,
  "mensagem": "Inscrição cancelada com sucesso!",
  "dados": { "inscricaoId": "f1e2d3c4-b5a6-7890-1234-567890abcdef", "status": "cancelada", "dataCancelamento": "2025-09-06T10:00:00Z" },
  "timestamp": "2025-09-06T10:00:00Z",
  "correlationId": "uuid"
}
```
Já Cancelada (409):
```json
{ "sucesso": false, "mensagem": "Inscrição não encontrada ou já cancelada.", "erros": [ { "campo": "inscricaoId", "mensagem": "Inscrição já cancelada." } ], "timestamp": "2025-09-06T10:00:00Z", "correlationId": "uuid" }
```

### GET /eventos/{id}/inscricoes (Inscrições por Evento)
Lista inscrições de evento para promotor proprietário. Ordenação por `dataInscricao` DESC.

Comportamentos do sistema:
- Sistema registra acesso para fins de auditoria
- Sistema limita exposição de dados pessoais (apenas nome e email necessários)

Respostas: 200 / 204 / 403 / 404 / 500

Exemplo Sucesso (200):
```json
{
  "sucesso": true,
  "mensagem": "Inscrições do evento recuperadas com sucesso!",
  "dados": [
    { "inscricaoId": "ins-001", "usuarioId": "u-001", "nomeCompleto": "João da Silva", "email": "joao@email.com", "dataInscricao": "2025-10-10T10:00:00Z", "statusInscricao": "confirmada" },
    { "inscricaoId": "ins-002", "usuarioId": "u-002", "nomeCompleto": "Maria Souza", "email": "maria@email.com", "dataInscricao": "2025-10-10T10:15:00Z", "statusInscricao": "pendente" }
  ],
  "timestamp": "2025-10-11T09:30:00Z",
  "correlationId": "uuid"
}
```
Evento Inativo / Não Encontrado (404/403 dependendo política):
```json
{ "sucesso": false, "mensagem": "Evento não encontrado ou inativo.", "erros": [ { "campo": "eventoId", "mensagem": "Evento não encontrado ou inativo." } ], "timestamp": "2025-10-11T09:30:00Z", "correlationId": "uuid" }
```

---
## Códigos de Status HTTP
| Código | Uso |
|--------|-----|
| 200 | Sucesso |
| 201 | Inscrição criada |
| 204 | Lista vazia |
| 400 | Validação (ID inválido, etc.) |
| 401 | Não autenticado |
| 403 | Proibido (evento inativo / não proprietário) |
| 404 | Recurso não encontrado |
| 409 | Conflito (já inscrito / vagas esgotadas / já cancelada) |
| 429 | Rate limit excedido (inscrição) |
| 500 | Erro interno |

## Controle de Versão
Versão inicial v1. Alterações breaking → `/v2`.

## Evoluções Futuras & Notas
- Paginação e filtros (statusInscricao)
- Estados adicionais de pagamento (`pendente`, `confirmada` via módulo financeiro)
- Webhook para confirmação de inscrição
- Lista de espera quando esgotado
- Exportação CSV para promotor
