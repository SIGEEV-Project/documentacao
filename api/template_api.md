# Documentação de API - Módulo de [NOME_MODULO] (SIGEEV)

## Sumário
- [Documentação de API - Módulo de [NOME_MODULO] (SIGEEV)](#documentação-de-api---módulo-de-nome_modulo-sigeev)
  - [Sumário](#sumário)
  - [Visão Geral](#visão-geral)
  - [Convenções](#convenções)
  - [Autenticação & Autorização](#autenticação--autorização)
  - [Padrão de Envelope](#padrão-de-envelope)
  - [Erros Padrão](#erros-padrão)
  - [Cabeçalhos Importantes](#cabeçalhos-importantes)
  - [Tabela de Endpoints](#tabela-de-endpoints)
  - [Modelos de Dados](#modelos-de-dados)
    - [Modelo 1](#modelo-1)
    - [Modelo 2](#modelo-2)
  - [Endpoints Detalhados](#endpoints-detalhados)
    - [Endpoint 1](#endpoint-1)
    - [Endpoint 2](#endpoint-2)
  - [Códigos de Status HTTP](#códigos-de-status-http)
  - [Controle de Versão](#controle-de-versão)
  - [Evoluções Futuras & Notas](#evoluções-futuras--notas)

---

## Visão Geral
[Descrição breve do módulo e suas responsabilidades]

## Convenções
- Base URL (exemplo): `https://api.sigeev.com` (BFF) / `https://[modulo].sigeev.internal` (microserviço)
- Respostas JSON UTF-8
- Datas/horas em UTC ISO 8601 (`YYYY-MM-DDTHH:mm:ssZ`)
- Identificadores: UUID v4
- Campos nulos opcionais omitidos
- [Outras convenções específicas do módulo]

## Autenticação & Autorização
- JWT em `Authorization: Bearer <token>`
- Perfis: `participante`, `promotor`, `administrador`
- [Requisitos específicos de autenticação/autorização do módulo]

## Padrão de Envelope
```json
{
  "sucesso": true,
  "mensagem": "Descrição de alto nível",
  "dados": {},
  "erros": [ { "campo": "campo", "mensagem": "Mensagem de erro." } ],
  "timestamp": "2025-08-30T12:00:00Z",
  "correlationId": "uuid"
}
```

## Erros Padrão
| Código | Descrição | Exemplo |
|--------|-----------|--------|
| 400 | Requisição inválida | Campos obrigatórios ausentes, formato inválido |
| 401 | Não autenticado | Token ausente ou inválido |
| 403 | Não autorizado | Perfil sem permissão para a operação |
| 404 | Recurso não encontrado | ID inexistente |
| 409 | Conflito | Recurso já existe, regra de negócio violada |
| 429 | Muitas requisições | Rate limit excedido |
| 500 | Erro interno | Falha no servidor |

## Cabeçalhos Importantes
| Cabeçalho | Descrição | Obrigatório |
|-----------|-----------|------------|
| Authorization | Bearer token JWT | Sim* |
| X-Correlation-ID | ID de correlação para rastreamento | Não |
| Content-Type | application/json | Sim |
| Accept-Language | Idioma preferido (ex: pt-BR) | Não |

*Exceto endpoints públicos

## Tabela de Endpoints
| Método | Endpoint | Descrição | Autenticação | Perfis |
|--------|----------|-----------|--------------|--------|
| POST | /[recurso] | Criar [recurso] | Sim | [perfis] |
| GET | /[recurso] | Listar [recursos] | [Sim/Não] | [perfis] |
| GET | /[recurso]/{id} | Detalhar [recurso] | [Sim/Não] | [perfis] |
| PUT | /[recurso]/{id} | Atualizar [recurso] | Sim | [perfis] |
| DELETE | /[recurso]/{id} | Excluir [recurso] | Sim | [perfis] |

## Modelos de Dados

### Modelo 1
```json
{
  "id": "uuid",
  "campo1": "valor",
  "campo2": 123,
  "campo3": true
}
```

### Modelo 2
```json
{
  "id": "uuid",
  "campo1": "valor",
  "campo2": 123,
  "campo3": true
}
```

## Endpoints Detalhados

### Endpoint 1
**Descrição**: [Descrição detalhada do endpoint]

**Método**: POST

**URL**: `/[recurso]`

**Autenticação**: [Sim/Não]

**Perfis**: [perfis]

**Payload**:
```json
{
  "campo1": "valor",
  "campo2": 123
}
```

**Resposta (200 OK)**:
```json
{
  "sucesso": true,
  "mensagem": "[Recurso] criado com sucesso",
  "dados": {
    "id": "uuid",
    "campo1": "valor",
    "campo2": 123
  },
  "timestamp": "2025-08-30T12:00:00Z",
  "correlationId": "uuid"
}
```

**Erros Possíveis**:
- 400: Campos inválidos
- 401: Não autenticado
- 403: Sem permissão
- 409: Conflito (já existe)

### Endpoint 2
[Seguir mesmo formato do Endpoint 1]

## Códigos de Status HTTP
[Lista de códigos HTTP utilizados e seus significados específicos para este módulo]

## Controle de Versão
- Versão atual: v1
- Formato de versionamento: [Descrição da estratégia de versionamento]

## Evoluções Futuras & Notas
- [Lista de melhorias planejadas]
- [Notas importantes sobre o módulo]