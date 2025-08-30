# Documentação de API - Módulo de Eventos (SIGEEV)

## Sumário
- [Documentação de API - Módulo de Eventos (SIGEEV)](#documentação-de-api---módulo-de-eventos-sigeev)
  - [Sumário](#sumário)
  - [Visão Geral](#visão-geral)
  - [Convenções](#convenções)
  - [Autenticação \& Autorização](#autenticação--autorização)
  - [Padrão de Envelope](#padrão-de-envelope)
  - [Erros Padrão](#erros-padrão)
  - [Cabeçalhos Importantes](#cabeçalhos-importantes)
  - [Tabela de Endpoints](#tabela-de-endpoints)
  - [Modelos de Dados](#modelos-de-dados)
    - [Evento (Resumo)](#evento-resumo)
    - [Evento (Detalhe)](#evento-detalhe)
  - [Endpoints Detalhados](#endpoints-detalhados)
    - [POST /eventos (Criação de Evento)](#post-eventos-criação-de-evento)
    - [GET /eventos (Listagem de Eventos)](#get-eventos-listagem-de-eventos)
    - [POST /eventos/filtrar (Pesquisa Avançada)](#post-eventosfiltrar-pesquisa-avançada)
    - [GET /eventos/me (Listar Meus Eventos - Promotor)](#get-eventosme-listar-meus-eventos---promotor)
    - [GET /eventos/{id} (Detalhes do Evento)](#get-eventosid-detalhes-do-evento)
    - [PUT /eventos/{id} (Edição de Evento)](#put-eventosid-edição-de-evento)
    - [DELETE /eventos/{id} (Cancelamento de Evento)](#delete-eventosid-cancelamento-de-evento)
  - [Códigos de Status HTTP](#códigos-de-status-http)
  - [Controle de Versão](#controle-de-versão)
  - [Evoluções Futuras \& Notas](#evoluções-futuras--notas)

---

## Visão Geral
API responsável pelo ciclo de vida de eventos: criação, listagem pública, filtros avançados, listagem do promotor, detalhes, edição e cancelamento lógico.

## Convenções
- Base URL (exemplo): `https://api.sigeev.com` (BFF) / `https://eventos.sigeev.internal` (microserviço).
- Respostas JSON UTF-8.
- Datas/horas em UTC ISO 8601 (`YYYY-MM-DDTHH:mm:ssZ`).
- Identificadores: UUID v4.
- Campos nulos opcionais omitidos.
- Status de evento: `rascunho`, `ativo`, `esgotado`, `inativo`.

## Autenticação & Autorização
- JWT em `Authorization: Bearer <token>`.
- Perfis: `participante`, `promotor`, `administrador`.
- Criar / editar / cancelar / meus eventos: exige perfil `promotor`.
- Consulta pública (listagem, filtros, detalhes) não exige token (apenas leitura), salvo endpoints privados do promotor.
- Pode-se exigir autenticação condicional futuramente para métricas.

## Padrão de Envelope
```json
{
  "sucesso": true,
  "mensagem": "Descrição de alto nível",
  "dados": {},
  "erros": [
    { "campo": "titulo", "mensagem": "Título obrigatório." }
  ],
  "timestamp": "2025-08-28T12:00:00Z",
  "correlationId": "uuid"
}
```
Observações:
- Sempre retornar `timestamp` e `correlationId`.
- Operações sem payload específico retornam `dados: {}`.
- Listas vazias: `dados: []` ou objeto com array vazio.

## Erros Padrão
| Campo    | Descrição                                               |
|----------|---------------------------------------------------------|
| campo    | Nome lógico do campo inválido ou null para erros gerais |
| mensagem | Texto legível explicando o problema                     |

## Cabeçalhos Importantes
| Cabeçalho        | Direção | Obrigatório | Descrição                                       |
|------------------|---------|-------------|-------------------------------------------------|
| Authorization    | →       | Sim (CRUD)  | JWT Bearer para endpoints protegidos            |
| X-Correlation-Id | ↔       | Recomendado | Propaga rastreabilidade                         |
| Content-Type     | →       | Sim         | `application/json`                              |
| Accept           | →       | Opcional    | `application/json`                              |
| Cache-Control    | ←       | Variável    | Pode retornar políticas (ex: listagem 300s)     |
| X-Rate-Limit-Remaining | ← | Condicional | Restante do limite para criação de eventos      |

## Tabela de Endpoints
| Operação            | Método | Caminho              | Autenticação | Permissão    | Descrição Resumida                 |
|---------------------|--------|----------------------|--------------|--------------|------------------------------------|
| Criar Evento        | POST   | /eventos             | Sim          | Promotor     | Cria novo evento (ativo/rascunho)  |
| Listar Eventos      | GET    | /eventos             | Não          | Público      | Lista eventos ativos/esgotados     |
| Filtrar Eventos     | POST   | /eventos/filtrar     | Não          | Público      | Busca avançada com filtros         |
| Meus Eventos        | GET    | /eventos/me          | Sim          | Promotor     | Lista eventos do promotor          |
| Detalhes Evento     | GET    | /eventos/{id}        | Não          | Público      | Detalhes completos                 |
| Editar Evento       | PUT    | /eventos/{id}        | Sim          | Promotor dono| Atualiza dados do evento           |
| Cancelar Evento     | DELETE | /eventos/{id}        | Sim          | Promotor dono| Cancelamento lógico (inativo)      |

## Modelos de Dados
### Evento (Resumo)
```json
{
  "eventoId": "uuid",
  "titulo": "string",
  "dataInicio": "2025-10-01T09:00:00Z",
  "dataFim": "2025-10-01T18:00:00Z",
  "local": "Recife - PE",
  "bannerUrl": "https://..." ,
  "vagasRestantes": 50,
  "capacidade": 100,
  "preco": 50.0,
  "status": "ativo"
}
```
### Evento (Detalhe)
```json
{
  "eventoId": "uuid",
  "titulo": "string",
  "descricao": "string",
  "dataInicio": "...",
  "dataFim": "...",
  "local": "string",
  "capacidade": 100,
  "vagasRestantes": 45,
  "preco": 50.0,
  "bannerUrl": "https://...",
  "status": "ativo",
  "promotor": { "promotorId": "uuid", "nomeCompleto": "string", "email": "string" },
  "dataCriacao": "...",
  "dataUltimaAtualizacao": "..."
}
```

---
## Endpoints Detalhados
### POST /eventos (Criação de Evento)
Cria um evento. Pode publicar imediatamente (`publicar: true`) ou salvar rascunho.

Permissões: Promotor

Request Body:
```json
{
  "titulo": "Workshop de Segurança",
  "descricao": "Evento sobre boas práticas de segurança",
  "dataInicio": "2025-10-01T09:00:00",
  "dataFim": "2025-10-01T18:00:00",
  "local": "Recife - PE",
  "capacidade": 100,
  "preco": 50.0,
  "bannerUrl": "https://s3.aws.com/banner.jpg",
  "publicar": true
}
```
Validações principais:
- Título 5–100; descrição 10–500.
- Datas coerentes (início futuro >= +1h; fim > início).
- Capacidade 1–10000; preço >=0 (<= 9999.99).
- URL de banner válida (JPG/PNG/WebP) ou ausente.
- Perfil promotor.

Respostas: 201 / 400 / 403 / 429 (rate limit) / 500

Exemplo Sucesso:
```json
{
  "sucesso": true,
  "mensagem": "Evento criado com sucesso!",
  "dados": { "eventoId": "uuid", "status": "ativo" },
  "timestamp": "2025-08-17T14:30:00Z",
  "correlationId": "uuid"
}
```

### GET /eventos (Listagem de Eventos)
Lista pública com paginação e cache curto (300s BFF). Retorna eventos com status `ativo` ou `esgotado`.

Query Params:
| Param        | Obrigatório | Default | Limites / Formato | Descrição |
|--------------|-------------|---------|-------------------|-----------|
| pagina       | Não         | 1       | >=1               | Página solicitada |
| tamanho      | Não         | 20      | 1–20              | Itens por página |
| ordenarPor   | Não         | dataInicio | dataInicio|titulo|preco|capacidade | Campo de ordenação |
| direcao      | Não         | ASC     | ASC|DESC          | Direção da ordenação |

Cabeçalhos de resposta relevantes:
| Cabeçalho | Exemplo | Descrição |
|-----------|---------|-----------|
| Cache-Control | public, max-age=300 | Controle de cache BFF |
| X-Total-Items | 42 | Total de eventos disponíveis |
| X-Total-Pages | 3 | Total de páginas |

Exemplo Sucesso (200):
```json
{
  "sucesso": true,
  "mensagem": "Lista de eventos recuperada com sucesso!",
  "dados": [
    {
      "eventoId": "a1b2c3d4-e5f6-7890-1234-567890abcdef",
      "titulo": "Workshop de Segurança",
      "dataInicio": "2025-10-01T09:00:00Z",
      "dataFim": "2025-10-01T18:00:00Z",
      "local": "Recife - PE",
      "bannerUrl": "https://s3.aws.com/banner.jpg",
      "vagasRestantes": 50,
      "capacidade": 100,
      "preco": 50.0,
      "status": "ativo"
    },
    {
      "eventoId": "b2c3d4e5-f6g7-8901-2345-678901bcdefg",
      "titulo": "Palestra sobre Tecnologia",
      "dataInicio": "2025-11-15T14:00:00Z",
      "dataFim": "2025-11-15T16:00:00Z",
      "local": "São Paulo - SP",
      "bannerUrl": null,
      "vagasRestantes": 0,
      "capacidade": 80,
      "preco": 0.0,
      "status": "esgotado"
    }
  ],
  "timestamp": "2025-08-17T14:30:00Z",
  "correlationId": "uuid"
}
```

Exemplo Lista Vazia (204 retornando envelope opcional 200 + array vazio se política preferir 200):
```json
{
  "sucesso": true,
  "mensagem": "Nenhum evento encontrado.",
  "dados": [],
  "timestamp": "2025-08-17T14:30:00Z",
  "correlationId": "uuid"
}
```

Erro Interno (500):
```json
{
  "sucesso": false,
  "mensagem": "Erro interno do servidor.
",
  "erros": [ { "campo": "sistema", "mensagem": "Erro interno do servidor. Tente novamente." } ],
  "timestamp": "2025-08-17T14:30:00Z",
  "correlationId": "uuid"
}
```

Respostas: 200 / 204 / 500

### POST /eventos/filtrar (Pesquisa Avançada)
Permite filtros complexos via payload.

Request Body:
```json
{
  "filtros": {
    "dataInicio": "2025-10-01",
    "dataFim": "2025-12-31",
    "local": "Recife",
    "palavraChave": "segurança",
    "precoMinimo": 0.0,
    "precoMaximo": 100.0,
    "status": ["ativo", "esgotado"]
  },
  "paginacao": { "pagina": 1, "tamanho": 20 },
  "ordenacao": { "campo": "dataInicio", "direcao": "ASC" }
}
```
Exemplo Sucesso (200):
```json
{
  "sucesso": true,
  "mensagem": "Eventos filtrados com sucesso!",
  "dados": {
    "eventos": [
      {
        "eventoId": "a1b2c3d4-e5f6-7890-1234-567890abcdef",
        "titulo": "Workshop de Segurança",
        "dataInicio": "2025-10-01T09:00:00Z",
        "dataFim": "2025-10-01T18:00:00Z",
        "local": "Recife - PE",
        "bannerUrl": "https://s3.aws.com/banner.jpg",
        "vagasRestantes": 50,
        "capacidade": 100,
        "preco": 50.0,
        "status": "ativo"
      }
    ],
    "paginacao": {
      "paginaAtual": 1,
      "totalPaginas": 1,
      "totalEventos": 1,
      "eventosPorPagina": 20
    }
  },
  "timestamp": "2025-08-17T14:30:00Z",
  "correlationId": "uuid"
}
```

Exemplo Nenhum Resultado (204 ou 200 + vazio):
```json
{
  "sucesso": true,
  "mensagem": "Nenhum evento encontrado com os filtros aplicados.",
  "dados": {
    "eventos": [],
    "paginacao": {
      "paginaAtual": 1,
      "totalPaginas": 0,
      "totalEventos": 0,
      "eventosPorPagina": 20
    }
  },
  "timestamp": "2025-08-17T14:30:00Z",
  "correlationId": "uuid"
}
```

Erro Filtros Inválidos (400):
```json
{
  "sucesso": false,
  "mensagem": "Erro ao filtrar eventos.",
  "erros": [
    { "campo": "dataInicio", "mensagem": "Data de início deve estar no formato YYYY-MM-DD." },
    { "campo": "precoMaximo", "mensagem": "Preço máximo deve ser maior ou igual ao mínimo." }
  ],
  "timestamp": "2025-08-17T14:30:00Z",
  "correlationId": "uuid"
}
```

Respostas: 200 / 204 / 400 / 500

### GET /eventos/me (Listar Meus Eventos - Promotor)
Lista todos os eventos do promotor (todos os status). Ordenação default: dataCriacao DESC.

Query Params: `pagina`, `tamanho`, `status` (opcional múltiplo).

Exemplo Sucesso (200):
```json
{
  "sucesso": true,
  "mensagem": "Lista de seus eventos recuperada com sucesso!",
  "dados": {
    "eventos": [
      { "eventoId": "c3d4e5f6-g7h8-9012-3456-789012abcdef", "titulo": "Evento em Rascunho", "dataCriacao": "2025-08-20T10:00:00Z", "status": "rascunho" },
      { "eventoId": "a1b2c3d4-e5f6-7890-1234-567890abcdef", "titulo": "Workshop de Segurança", "dataInicio": "2025-10-01T09:00:00Z", "status": "ativo" }
    ],
    "paginacao": { "paginaAtual": 1, "totalPaginas": 1, "totalEventos": 2, "eventosPorPagina": 20 }
  },
  "timestamp": "2025-08-20T11:00:00Z",
  "correlationId": "uuid"
}
```

Exemplo Vazio (204 ou 200 + vazio):
```json
{
  "sucesso": true,
  "mensagem": "Nenhum evento encontrado para o promotor.",
  "dados": { "eventos": [], "paginacao": { "paginaAtual": 1, "totalPaginas": 0, "totalEventos": 0, "eventosPorPagina": 20 } },
  "timestamp": "2025-08-20T11:00:00Z",
  "correlationId": "uuid"
}
```

Sem Permissão (403):
```json
{
  "sucesso": false,
  "mensagem": "Acesso negado.",
  "erros": [ { "campo": "permissao", "mensagem": "Apenas promotores podem acessar seus eventos." } ],
  "timestamp": "2025-08-20T11:00:00Z",
  "correlationId": "uuid"
}
```

Respostas: 200 / 204 / 403 / 500

### GET /eventos/{id} (Detalhes do Evento)
Retorna detalhes completos (cache 120s). Inclui dados básicos do promotor, nunca dados sensíveis.

Exemplo Sucesso (200):
```json
{
  "sucesso": true,
  "mensagem": "Detalhes do evento recuperados com sucesso!",
  "dados": {
    "eventoId": "a1b2c3d4-e5f6-7890-1234-567890abcdef",
    "titulo": "Workshop de Segurança",
    "descricao": "Evento sobre boas práticas de segurança em desenvolvimento de software.",
    "dataInicio": "2025-10-01T09:00:00Z",
    "dataFim": "2025-10-01T18:00:00Z",
    "local": "Recife - PE",
    "capacidade": 100,
    "vagasRestantes": 45,
    "preco": 50.0,
    "bannerUrl": "https://s3.aws.com/banner.jpg",
    "status": "ativo",
    "promotor": { "promotorId": "b2c3d4e5-f6g7-8901-2345-678901bcdefg", "nomeCompleto": "Maria Silva Santos", "email": "maria.promotora@email.com" },
    "dataCriacao": "2025-08-15T10:30:00Z",
    "dataUltimaAtualizacao": "2025-08-16T14:45:00Z"
  },
  "timestamp": "2025-08-17T14:30:00Z",
  "correlationId": "uuid"
}
```

ID Inválido (400):
```json
{
  "sucesso": false,
  "mensagem": "Erro ao recuperar detalhes do evento.",
  "erros": [ { "campo": "eventoId", "mensagem": "ID do evento deve ser um UUID válido." } ],
  "timestamp": "2025-08-17T14:30:00Z",
  "correlationId": "uuid"
}
```

Não Encontrado (404):
```json
{
  "sucesso": false,
  "mensagem": "Evento não encontrado.",
  "erros": [ { "campo": "eventoId", "mensagem": "Evento não encontrado ou foi removido." } ],
  "timestamp": "2025-08-17T14:30:00Z",
  "correlationId": "uuid"
}
```

Respostas: 200 / 400 / 404 / 500

### PUT /eventos/{id} (Edição de Evento)
Atualiza campos do evento. Capacidade não pode ficar abaixo de inscrições existentes. Atualizações críticas enviam notificações.
Request Body (exemplo):
```json
{
  "titulo": "Workshop de Segurança Avançado",
  "descricao": "Conteúdo atualizado",
  "dataInicio": "2025-10-01T09:00:00Z",
  "dataFim": "2025-10-01T18:00:00Z",
  "local": "Recife - PE",
  "capacidade": 80,
  "preco": 75.0,
  "bannerUrl": "https://s3.aws.com/banner-novo.jpg"
}
```

Exemplo Sucesso (200):
```json
{
  "sucesso": true,
  "mensagem": "Evento atualizado com sucesso!",
  "dados": { "eventoId": "uuid", "status": "ativo", "dataUltimaAtualizacao": "2025-08-17T14:30:00Z" },
  "timestamp": "2025-08-17T14:30:00Z",
  "correlationId": "uuid"
}
```

Capacidade Inválida (400):
```json
{
  "sucesso": false,
  "mensagem": "Erro ao atualizar evento.",
  "erros": [ { "campo": "capacidade", "mensagem": "Capacidade não pode ser menor que inscrições existentes." } ],
  "timestamp": "2025-08-17T14:30:00Z",
  "correlationId": "uuid"
}
```

Não Proprietário (403):
```json
{
  "sucesso": false,
  "mensagem": "Acesso negado.",
  "erros": [ { "campo": "permissao", "mensagem": "Apenas o promotor do evento pode editá-lo." } ],
  "timestamp": "2025-08-17T14:30:00Z",
  "correlationId": "uuid"
}
```

Conflito (409):
```json
{
  "sucesso": false,
  "mensagem": "Conflito ao atualizar evento.",
  "erros": [ { "campo": "versao", "mensagem": "Versão desatualizada. Recarregue o evento." } ],
  "timestamp": "2025-08-17T14:30:00Z",
  "correlationId": "uuid"
}
```

Respostas: 200 / 400 / 403 / 404 / 409 / 500

### DELETE /eventos/{id} (Cancelamento de Evento)
Cancelamento lógico. Requer zero inscrições ativas; senão 409.
Exemplo Sucesso (200):
```json
{
  "sucesso": true,
  "mensagem": "Evento cancelado com sucesso!",
  "dados": {},
  "timestamp": "2025-08-17T14:30:00Z",
  "correlationId": "uuid"
}
```

Inscrições Ativas (409):
```json
{
  "sucesso": false,
  "mensagem": "Não é possível cancelar o evento.",
  "erros": [ { "campo": "inscricoes", "mensagem": "Evento possui inscrições ativas." } ],
  "timestamp": "2025-08-17T14:30:00Z",
  "correlationId": "uuid"
}
```

Sem Permissão (403):
```json
{
  "sucesso": false,
  "mensagem": "Acesso negado.",
  "erros": [ { "campo": "permissao", "mensagem": "Apenas o promotor do evento pode cancelá-lo." } ],
  "timestamp": "2025-08-17T14:30:00Z",
  "correlationId": "uuid"
}
```

Respostas: 200 / 403 / 404 / 409 / 500

---
## Códigos de Status HTTP
| Código | Uso                                            |
|--------|------------------------------------------------|
| 200    | Operação concluída com sucesso                 |
| 201    | Recurso criado                                 |
| 204    | Sem conteúdo (lista vazia)                     |
| 400    | Erros de validação                             |
| 403    | Autenticado sem permissão / perfil inadequado  |
| 404    | Recurso não encontrado                         |
| 409    | Conflito de negócio (capacidade, inscrições)   |
| 429    | Limite de criação excedido                     |
| 500    | Erro interno                                   |

## Controle de Versão
Versão inicial v1. Alterações incompatíveis futuras → `/v2`.

## Evoluções Futuras & Notas
- PATCH parcial para otimização mobile.
- Suporte a reservas prévias / lista de espera.
- Webhooks para atualização em tempo real em apps parceiros.
- Indexação full-text avançada (Elastic / OpenSearch) para busca.
