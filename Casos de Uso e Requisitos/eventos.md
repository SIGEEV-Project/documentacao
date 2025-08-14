
# Especificação de Requisitos - Módulo de Eventos (SIGEEV)

## Índice

- [Especificação de Requisitos - Módulo de Eventos (SIGEEV)](#especificação-de-requisitos---módulo-de-eventos-sigeev)
  - [Índice](#índice)
  - [Introdução](#introdução)
  - [Objetivos do Módulo](#objetivos-do-módulo)
  - [Responsabilidades dos Serviços - Visão geral](#responsabilidades-dos-serviços---visão-geral)
  - [Convenções de API](#convenções-de-api)
    - [1. Endpoints e Métodos HTTP](#1-endpoints-e-métodos-http)
    - [2. Cabeçalhos Padrão](#2-cabeçalhos-padrão)
    - [3. Códigos de Resposta](#3-códigos-de-resposta)
    - [4. Paginação e Ordenação](#4-paginação-e-ordenação)
    - [5. Versionamento](#5-versionamento)
    - [Caso de Uso 09 – Criação de Evento](#caso-de-uso-09--criação-de-evento)
    - [Caso de Uso 10 – Listagem de Eventos](#caso-de-uso-10--listagem-de-eventos)
    - [Caso de Uso 11 – Filtrar eventos, Pesquisa avançada](#caso-de-uso-11--filtrar-eventos-pesquisa-avançada)
    - [Caso de Uso 12 – Detalhes do Evento](#caso-de-uso-12--detalhes-do-evento)
    - [Caso de Uso 13 – Edição de Evento](#caso-de-uso-13--edição-de-evento)
    - [Caso de Uso 14 – Exclusão de Evento](#caso-de-uso-14--exclusão-de-evento)

## Introdução

O módulo de eventos é um componente central do Sistema de Gerenciamento de Eventos (SIGEEV), responsável por todo o ciclo de vida dos eventos na plataforma. Este documento detalha os requisitos técnicos, casos de uso, regras de negócio e padrões de API relacionados à criação, atualização, consulta e gestão dos eventos do sistema.

## Objetivos do Módulo

- Gerenciar o ciclo de vida completo dos eventos na plataforma
- Manter dados dos eventos atualizados e consistentes
- Garantir a integridade das informações dos eventos
- Prover interfaces REST padronizadas para operações CRUD
- Integrar com outros módulos do sistema
- Implementar controles de acesso baseados em perfis
- Manter histórico de alterações para fins de auditoria

## Responsabilidades dos Serviços - Visão geral

* **BFF (Backend For Frontend)**
  - Extrair `usuarioId` e perfil do JWT
  - Validar permissões por operação
  - Encaminhar uploads de banner ao serviço de storage
  - Injetar headers padrão: correlation ID, timestamp
  - Implementar rate limiting por IP/usuário
  - Padronizar envelope de respostas
  
* **Microserviço de Eventos**
  - Gerenciar ciclo de vida dos eventos
  - Controlar status e capacidade
  - Validar regras de negócio
  - Manter dados do evento
  - Integrar com serviço de storage para banners
  - Notificar alterações relevantes

* **Microserviço de Notificações**
  - Enviar emails de confirmação
  - Notificar alterações em eventos
  - Gerenciar templates de email

* **Microserviço de Storage**
  - Gerenciar upload de banners
  - Validar tipos de arquivo
  - Gerar URLs públicas
  - Implementar política de retenção

## Convenções de API

### 1. Endpoints e Métodos HTTP

| Operação         | Método | Endpoint                  | Descrição                                    |
|-----------------|---------|---------------------------|----------------------------------------------|
| Criar Evento    | POST    | /v1/eventos              | Criar um novo evento                         |
| Listar Eventos  | GET     | /v1/eventos              | Listar eventos com paginação                 |
| Filtrar Eventos | GET     | /v1/eventos?params...    | Buscar eventos com filtros                   |
| Ver Detalhes    | GET     | /v1/eventos/{eventoId}   | Obter detalhes de um evento específico      |
| Editar Evento   | PUT     | /v1/eventos/{eventoId}   | Atualizar todas as informações do evento    |
| Edição Parcial  | PATCH   | /v1/eventos/{eventoId}   | Atualizar campos específicos do evento      |
| Excluir Evento  | DELETE  | /v1/eventos/{eventoId}   | Marcar evento como inativo (exclusão lógica)|

### 2. Cabeçalhos Padrão

**Requisição:**
```http
Authorization: Bearer {jwt-token}
Content-Type: application/json
Accept: application/json
Version: v1
```

**Resposta:**
```http
Content-Type: application/json
Version: v1
Warning: 299 - {mensagem-relevante} # quando aplicável
```

### 3. Códigos de Resposta

| Código | Descrição               | Uso                                         |
|--------|------------------------|---------------------------------------------|
| 200    | OK                    | Sucesso na operação                         |
| 201    | Created               | Recurso criado com sucesso                  |
| 204    | No Content            | Sucesso, sem conteúdo para retornar        |
| 400    | Bad Request           | Erros de sintaxe no payload                |
| 401    | Unauthorized          | Token ausente ou inválido                  |
| 403    | Forbidden             | Token válido, mas sem permissão            |
| 404    | Not Found             | Recurso não encontrado                     |
| 409    | Conflict              | Conflito com estado atual do recurso       |
| 422    | Unprocessable Entity  | Payload válido mas com regras violadas     |
| 500    | Internal Server Error | Erro interno do servidor                   |

### 4. Paginação e Ordenação

**Parâmetros de Query:**
```
page={número-página}&size={itens-por-página}&sort={campo},{asc|desc}
```

**Exemplo:**
```
GET /v1/eventos?page=0&size=20&sort=dataInicio,asc
```

**Resposta:**
```json
{
  "dados": [...],
  "paginacao": {
    "paginaAtual": 0,
    "itensPorPagina": 20,
    "totalItens": 50,
    "totalPaginas": 3
  }
}
```

### 5. Versionamento

- Todas as rotas são prefixadas com número da versão: `/v1/eventos`
- Versão também incluída nos headers: `Version: v1`
- Mudanças breaking changes geram nova versão maior
- Adições retrocompatíveis usam mesma versão

### Caso de Uso 09 – Criação de Evento

**Requisito Funcional: RF009**

**Descrição resumida**
O promotor deve ser capaz de criar um evento, fornecendo informações como título, descrição, data, local, capacidade e preço.
O sistema deve validar os dados e salvar o evento com status "ativo".

**Endpoint:** POST /v1/eventos

**Cabeçalhos Requeridos:**
```http
Authorization: Bearer {jwt-token}
Content-Type: application/json
Accept: application/json
Version: v1
```

**Critérios de Aceite:**
* **Eu como** promotor de evento
* **Quero** cadastrar um novo evento
* **Quando** preencher o formulário corretamente
* **Então** o evento deve ser salvo com status "ativo"
* **E** o evento deve ser visível na lista de eventos abertos

**Exemplo de chamada curl:**
```bash
curl -X POST "http://api.sigeev.com/v1/eventos" \
     -H "Authorization: Bearer {jwt-token}" \
     -H "Content-Type: application/json" \
     -H "Accept: application/json" \
     -H "Version: v1" \
     -d '{
       "titulo": "Workshop de Segurança",
       "descricao": "Evento sobre boas práticas de segurança",
       "dataInicio": "2025-10-01T09:00:00Z",
       "dataFim": "2025-10-01T18:00:00Z",
       "local": "Recife - PE",
       "capacidade": 100,
       "preco": 50.0,
       "bannerUrl": "https://s3.aws.com/banner.jpg"
     }'
```

**Payload de Entrada/Requisição**
```json
{
  "titulo": "Workshop de Segurança",
  "descricao": "Evento sobre boas práticas de segurança",
  "dataInicio": "2025-10-01T09:00:00",
  "dataFim": "2025-10-01T18:00:00",
  "local": "Recife - PE",
  "capacidade": 100,
  "preco": 50.0,
  "bannerUrl": "https://s3.aws.com/banner.jpg"
}
```

**Respostas Possíveis**
* `201 Created` - Evento criado com sucesso
* `401 Unauthorized` - Token ausente ou inválido
* `403 Forbidden` - Usuário sem perfil promotor
* `422 Unprocessable Entity` - Dados inválidos ou regras violadas
* `409 Conflict` - Conflito com evento existente
* `500 Internal Server Error` - Erro interno no servidor

**Payload de Resposta de sucesso**
```json
{
  "sucesso": true,
  "mensagem": "Evento criado com sucesso!",
  "dados": {
    "eventoId": "550e8400-e29b-41d4-a716-446655440000",
    "titulo": "Workshop de Segurança",
    "descricao": "Evento sobre boas práticas de segurança",
    "dataInicio": "2025-10-01T09:00:00Z",
    "dataFim": "2025-10-01T18:00:00Z",
    "local": "Recife - PE",
    "capacidade": 100,
    "preco": 50.0,
    "bannerUrl": "https://s3.aws.com/banner.jpg",
    "promotorId": "a1b2c3d4-e5f6-7890-1234-567890abcdef",
    "dataCriacao": "2025-08-13T21:45:00Z",
    "status": "ativo"
  },
  "timestamp": "2025-08-13T21:45:00Z",
  "correlationId": "550e8400-e29b-41d4-a716-446655440001"
}
```

**Payload de Resposta de Erro**
```json
{
  "sucesso": false,
  "mensagem": "Erro ao criar evento.",
  "erros": [
    {
      "campo": "dataInicio",
      "mensagem": "Data de início deve ser futura."
    },
    {
      "campo": "capacidade",
      "mensagem": "Capacidade deve ser maior que zero."
    }
  ],
  "timestamp": "2025-08-13T21:45:30Z",
  "correlationId": "550e8400-e29b-41d4-a716-446655440002"
}
```

**Regras de Negócio:**
* O título do evento deve ter entre 5 e 100 caracteres.
* A descrição deve ter entre 10 e 500 caracteres.
* A data de início deve ser uma data futura.
* A data de fim deve ser posterior à data de início.
* O local deve conter apenas letras, números e espaços, e ter entre 3 e 100 caracteres.
* A capacidade deve ser um número inteiro maior que zero.
* O preço deve ser um número decimal maior ou igual a zero.
* O banner deve ser uma URL válida de imagem.
* O evento deve ser salvo com status "ativo" por padrão.
* O sistema deve registrar a data e hora da criação do evento.
* O sistema deve enviar um email de confirmação ao promotor informando sobre a criação do evento.
* O sistema deve garantir que o promotor tenha permissão para criar eventos (perfil "promotor").

----

### Caso de Uso 10 – Listagem de Eventos

**Requisito Funcional: RF010**

**Descrição resumida**

O usuário deve ser capaz de visualizar a lista de eventos abertos.
O sistema deve retornar os eventos com resumo (título, data, local e banner) de forma paginada.

**Endpoint:** GET /v1/eventos

**Cabeçalhos Requeridos:**
```http
Accept: application/json
Version: v1
```

**Parâmetros de Query:**
```
page={número-página}&size={itens-por-página}&sort={campo},{asc|desc}
```

**Exemplo:**
```
GET /v1/eventos?page=0&size=20&sort=dataInicio,asc
```

**Critérios de Aceite:**
* **Eu como** qualquer usuário
* **Quero** ver a lista de eventos abertos
* **Quando** acessar a página inicial
* **Então** devo receber os eventos com resumo (título, data, local e banner)
* **E** os eventos devem estar ordenados por data de início
* **E** os eventos devem ser retornados de forma paginada
* **E** os eventos com vagas esgotadas devem ser exibidos, mas com aviso de esgotado

**Exemplo de chamada curl:**
```bash
curl -X GET "http://api.sigeev.com/v1/eventos?page=0&size=20&sort=dataInicio,asc" \
     -H "Accept: application/json" \
     -H "Version: v1"
```

**Payload de Entrada/Requisição**

* Não há payload necessário para esta requisição, apenas uma chamada GET para a rota de eventos.

**Respostas Possíveis**
* Sucesso: 200 OK + Lista de eventos
* Nenhum evento encontrado: 204 No Content
* Erro interno: 500 Internal Server Error

**Payload de Resposta de sucesso**
```json
{
  "sucesso": true,
  "mensagem": "Lista de eventos recuperada com sucesso!",
  "dados": {
    "eventos": [
      {
        "eventoId": "550e8400-e29b-41d4-a716-446655440010",
        "titulo": "Workshop de Segurança",
        "dataInicio": "2025-10-01T09:00:00Z",
        "dataFim": "2025-10-01T18:00:00Z",
        "local": "Recife - PE",
        "bannerUrl": "https://s3.aws.com/banner.jpg",
        "vagasRestantes": 50,
        "esgotado": false
      },
      {
        "eventoId": "550e8400-e29b-41d4-a716-446655440011",
        "titulo": "Palestra sobre Tecnologia",
        "dataInicio": "2025-11-15T14:00:00Z",
        "dataFim": "2025-11-15T16:00:00Z",
        "local": "São Paulo - SP",
        "bannerUrl": null,
        "vagasRestantes": 0,
        "esgotado": true
      }
    ],
    "paginacao": {
      "paginaAtual": 0,
      "itensPorPagina": 20,
      "totalItens": 45,
      "totalPaginas": 3
    }
  },
  "timestamp": "2025-08-13T21:46:00Z",
  "correlationId": "550e8400-e29b-41d4-a716-446655440003"
}
```

**Payload de Resposta de Erro**
```json
{
  "sucesso": false,
  "mensagem": "Erro ao recuperar eventos.",
  "erros": [
    {
      "campo": "sistema",
      "mensagem": "Erro interno do servidor."
    }
  ],
  "timestamp": "2025-08-13T21:46:30Z",
  "correlationId": "550e8400-e29b-41d4-a716-446655440004"
}
```

**Regras de Negócio:**
* O sistema deve retornar todos os eventos com status "ativo" ou "esgotado".
* Os eventos devem ser ordenados por data de início, do mais próximo para o mais distante.
* O sistema deve exibir o número de vagas restantes para eventos ativos.
* Para eventos esgotados, o sistema deve exibir uma mensagem indicando que as vagas estão esgotadas.
* O banner do evento deve ser uma URL válida ou nulo se não houver banner.

----

### Caso de Uso 11 – Filtrar eventos, Pesquisa avançada

**Requisito Funcional: RF011**

**Descrição resumida**

O usuário deve ser capaz de filtrar a lista de eventos por data, local e palavras-chave.
O sistema deve retornar os eventos que atendem aos critérios de filtro de forma paginada.

**Endpoint:** GET /v1/eventos

**Cabeçalhos Requeridos:**
```http
Accept: application/json
Version: v1
```

**Parâmetros de Query:**
```
dataInicio={YYYY-MM-DD}
dataFim={YYYY-MM-DD}
local={cidade}
keyword={termo}
page={número-página}
size={itens-por-página}
sort={campo},{asc|desc}
```

**Exemplo:**
```
GET /v1/eventos?dataInicio=2025-10-01&dataFim=2025-12-31&local=Recife&keyword=segurança&page=0&size=20&sort=dataInicio,asc
```

**Critérios de Aceite:**
* **Eu como** usuário
* **Quero** filtrar a lista de eventos
* **Quando** eu enviar os critérios de filtro
* **Então** devo receber apenas os eventos que atendem aos critérios
* **E** os eventos devem estar ordenados por data de início
* **E** os resultados devem ser paginados

**Exemplo de chamada curl:**
```bash
curl -X GET "http://api.sigeev.com/v1/eventos?dataInicio=2025-10-01&dataFim=2025-12-31&local=Recife&keyword=segurança&page=0&size=20&sort=dataInicio,asc" \
     -H "Accept: application/json" \
     -H "Version: v1"
```

**Respostas Possíveis**
* Sucesso: 200 OK + Lista de eventos filtrados
* Nenhum evento encontrado: 204 No Content
* Erro interno: 500 Internal Server Error

**Payload de Resposta de sucesso**
```json
{
  "sucesso": true,
  "mensagem": "Eventos filtrados com sucesso!",
  "dados": {
    "eventos": [
      {
        "eventoId": "550e8400-e29b-41d4-a716-446655440020",
        "titulo": "Workshop de Segurança",
        "dataInicio": "2025-10-01T09:00:00Z",
        "dataFim": "2025-10-01T18:00:00Z",
        "local": "Recife - PE",
        "bannerUrl": "https://s3.aws.com/banner.jpg",
        "vagasRestantes": 50,
        "esgotado": false
      }
    ],
    "paginacao": {
      "paginaAtual": 0,
      "itensPorPagina": 20,
      "totalItens": 1,
      "totalPaginas": 1
    },
    "filtros": {
      "dataInicio": "2025-10-01",
      "dataFim": "2025-12-31",
      "local": "Recife",
      "keyword": "segurança"
    }
  },
  "timestamp": "2025-08-13T21:47:00Z",
  "correlationId": "550e8400-e29b-41d4-a716-446655440005"
}
```

**Payload de Resposta de Erro**
```json
{
  "sucesso": false,
  "mensagem": "Erro ao filtrar eventos.",
  "erros": [
    {
      "campo": "dataInicio",
      "mensagem": "Data inicial é posterior à data final"
    },
    {
      "campo": "local",
      "mensagem": "Local deve conter apenas letras e espaços"
    }
  ],
  "timestamp": "2025-08-13T21:47:30Z",
  "correlationId": "550e8400-e29b-41d4-a716-446655440006"
}
```

**Regras de Negócio:**
* O sistema deve permitir filtrar por data de início e fim, local e palavras-chave no título ou descrição do evento.
* A data de início deve ser uma data futura e a data de fim deve ser posterior à data de início.
* O local deve ser uma string que pode conter letras, números e espaços.
* A palavra-chave deve ser uma string que pode conter letras e números.
* O sistema deve retornar apenas os eventos que atendem a pelo menos um dos critérios de filtro.
* Os eventos filtrados devem ser ordenados por data de início, do mais próximo para o mais distante.
* O sistema deve retornar uma lista vazia se nenhum evento atender aos critérios de filtro.

----

### Caso de Uso 12 – Detalhes do Evento

**Requisito Funcional: RF012**

**Descrição resumida**

O usuário deve ser capaz de visualizar os detalhes de um evento específico.
O sistema deve retornar todas as informações do evento, incluindo título, descrição, data, local, capacidade, preço, banner e status.

**Endpoint:** GET /v1/eventos/{eventoId}

**Cabeçalhos Requeridos:**
```http
Accept: application/json
Version: v1
```

**Exemplo:**
```
GET /v1/eventos/550e8400-e29b-41d4-a716-446655440020
```

**Critérios de Aceite:**
* **Eu como** usuário
* **Quero** ver os detalhes de um evento
* **Quando** eu solicitar os detalhes do evento
* **Então** devo receber todas as informações do evento
* **E** o evento deve estar ativo ou esgotado

**Exemplo de chamada curl:**
```bash
curl -X GET "http://api.sigeev.com/v1/eventos/550e8400-e29b-41d4-a716-446655440020" \
     -H "Accept: application/json" \
     -H "Version: v1"
```

**Payload de Entrada/Requisição**

* Não há payload necessário para esta requisição, apenas uma chamada GET para a rota de detalhes do evento.

**Respostas Possíveis**
* Sucesso: 200 OK + Detalhes do evento
* Evento não encontrado: 404 Not Found
* Erro interno: 500 Internal Server Error

**Payload de Resposta de sucesso**
```json
{
  "sucesso": true,
  "mensagem": "Detalhes do evento recuperados com sucesso!",
  "dados": {
    "eventoId": "550e8400-e29b-41d4-a716-446655440020",
    "titulo": "Workshop de Segurança",
    "descricao": "Evento sobre boas práticas de segurança",
    "dataInicio": "2025-10-01T09:00:00Z",
    "dataFim": "2025-10-01T18:00:00Z",
    "local": "Recife - PE",
    "capacidade": 100,
    "vagasRestantes": 50,
    "preco": 50.0,
    "bannerUrl": "https://s3.aws.com/banner.jpg",
    "promotor": {
      "id": "a1b2c3d4-e5f6-7890-1234-567890abcdef",
      "nome": "Lucas Benjamin",
      "email": "lucas@email.com"
    },
    "dataCriacao": "2025-08-13T21:45:00Z",
    "dataUltimaAtualizacao": "2025-08-13T21:45:00Z",
    "esgotado": false
  },
  "timestamp": "2025-08-13T21:48:00Z",
  "correlationId": "550e8400-e29b-41d4-a716-446655440007"
}
```

**Payload de Resposta de Erro**
```json
{
  "sucesso": false,
  "mensagem": "Erro ao recuperar detalhes do evento.",
  "erros": [
    {
      "campo": "eventoId",
      "mensagem": "Evento não encontrado."
    }
  ],
  "timestamp": "2025-08-13T21:48:30Z",
  "correlationId": "550e8400-e29b-41d4-a716-446655440008"
}
```

**Regras de Negócio:**
* O evento deve existir no sistema e estar ativo ou esgotado.
* O sistema deve retornar todas as informações do evento, incluindo título, descrição, data de início, data de fim, local, capacidade, preço, banner e status.
* O banner do evento deve ser uma URL válida ou nulo se não houver banner.
* O sistema deve registrar a data e hora da solicitação de detalhes do evento.
* O sistema deve garantir que apenas eventos com status "ativo" ou "esgotado" possam ser visualizados.

----

### Caso de Uso 13 – Edição de Evento

**Requisito Funcional: RF013**

**Descrição resumida**
O promotor deve ser capaz de editar as informações de um evento existente.
O sistema deve validar os dados e atualizar o evento com as novas informações.

**Endpoints:**
- PUT /v1/eventos/{eventoId} (atualização completa)
- PATCH /v1/eventos/{eventoId} (atualização parcial)

**Cabeçalhos Requeridos:**
```http
Authorization: Bearer {jwt-token}
Content-Type: application/json
Accept: application/json
Version: v1
```

**Critérios de Aceite:**
* **Eu como** promotor de evento
* **Quero** editar um evento existente
* **Quando** eu enviar as novas informações do evento
* **Então** o evento deve ser atualizado com sucesso
* **E** o evento deve continuar ativo ou ser marcado como esgotado se não houver vagas restantes

**Exemplo de chamada curl (PUT):**
```bash
curl -X PUT "http://api.sigeev.com/v1/eventos/550e8400-e29b-41d4-a716-446655440020" \
     -H "Authorization: Bearer {jwt-token}" \
     -H "Content-Type: application/json" \
     -H "Accept: application/json" \
     -H "Version: v1" \
     -d '{
       "titulo": "Workshop de Segurança Avançado",
       "descricao": "Evento sobre boas práticas avançadas de segurança",
       "dataInicio": "2025-10-01T09:00:00Z",
       "dataFim": "2025-10-01T18:00:00Z",
       "local": "Recife - PE",
       "capacidade": 50,
       "preco": 75.0,
       "bannerUrl": "https://s3.aws.com/banner-novo.jpg"
     }'
```

**Exemplo de chamada curl (PATCH):**
```bash
curl -X PATCH "http://api.sigeev.com/v1/eventos/550e8400-e29b-41d4-a716-446655440020" \
     -H "Authorization: Bearer {jwt-token}" \
     -H "Content-Type: application/json" \
     -H "Accept: application/json" \
     -H "Version: v1" \
     -d '{
       "titulo": "Workshop de Segurança Avançado",
       "preco": 75.0
     }'
```

**Payload de Entrada/Requisição**
```json
{
  "eventoId": "uuid-do-evento",
  "titulo": "Workshop de Segurança Avançado",
  "descricao": "Evento sobre boas práticas avançadas de segurança",
  "dataInicio": "2025-10-01T09:00:00",
  "dataFim": "2025-10-01T18:00:00",
  "local": "Recife - PE",
  "capacidade": 50,
  "preco": 75.0,
  "bannerUrl": "https://s3.aws.com/banner-novo.jpg"
}
```

**Respostas Possíveis**
* Sucesso: 200 OK + Detalhes do evento atualizado
* Evento não encontrado: 404 Not Found
* Dados inválidos: 400 Bad Request
* Erro interno: 500 Internal Server Error

**Payload de Resposta de sucesso**
```json
{
  "sucesso": true,
  "mensagem": "Evento atualizado com sucesso!",
  "dados": {
    "eventoId": "550e8400-e29b-41d4-a716-446655440020",
    "titulo": "Workshop de Segurança Avançado",
    "descricao": "Evento sobre boas práticas avançadas de segurança",
    "dataInicio": "2025-10-01T09:00:00Z",
    "dataFim": "2025-10-01T18:00:00Z",
    "local": "Recife - PE",
    "capacidade": 50,
    "vagasRestantes": 25,
    "preco": 75.0,
    "bannerUrl": "https://s3.aws.com/banner-novo.jpg",
    "promotor": {
      "id": "a1b2c3d4-e5f6-7890-1234-567890abcdef",
      "nome": "Lucas Benjamin",
      "email": "lucas@email.com"
    },
    "dataCriacao": "2025-08-13T21:45:00Z",
    "dataUltimaAtualizacao": "2025-08-13T21:49:00Z",
    "esgotado": false
  },
  "timestamp": "2025-08-13T21:49:00Z",
  "correlationId": "550e8400-e29b-41d4-a716-446655440009"
}
```

**Payload de Resposta de Erro**
```json
{
  "sucesso": false,
  "mensagem": "Erro ao atualizar evento.",
  "erros": [
    {
      "campo": "eventoId",
      "mensagem": "Evento não encontrado."
    },
    {
      "campo": "capacidade",
      "mensagem": "Nova capacidade (50) é menor que número de ingressos vendidos (75)."
    }
  ],
  "timestamp": "2025-08-13T21:49:30Z",
  "correlationId": "550e8400-e29b-41d4-a716-446655440010"
}
```

**Regras de Negócio:**
* O evento deve existir no sistema e estar ativo.
* O título do evento deve ter entre 5 e 100 caracteres.
* A descrição deve ter entre 10 e 500 caracteres.
* A data de início deve ser uma data futura.
* A data de fim deve ser posterior à data de início.
* O local deve conter apenas letras, números e espaços, e ter entre 3 e 100 caracteres.
* A capacidade deve ser um número inteiro maior que zero.
* O preço deve ser um número decimal maior ou igual a zero.
* O banner deve ser uma URL válida de imagem.
* O evento deve ser atualizado com status "ativo" por padrão, a menos que a capacidade seja zero, caso em que o status deve ser "esgotado".
* O sistema deve registrar a data e hora da atualização do evento.
* O sistema deve enviar um email de notificação ao promotor informando sobre a atualização do evento.
* O sistema deve garantir que apenas o promotor do evento possa editá-lo.
* O sistema deve registrar logs de auditoria para todas as edições de eventos.
* O sistema deve garantir que o promotor não possa alterar o ID do evento

----

### Caso de Uso 14 – Exclusão de Evento

**Requisito Funcional: RF014**

**Descrição resumida**
O promotor deve ser capaz de excluir um evento existente.
O sistema deve validar se o evento existe e marcar o evento como inativo (exclusão lógica).

**Endpoint:** DELETE /v1/eventos/{eventoId}

**Cabeçalhos Requeridos:**
```http
Authorization: Bearer {jwt-token}
Accept: application/json
Version: v1
```

**Cabeçalhos de Resposta:**
```http
Warning: 299 - Evento marcado como inativo
```

**Critérios de Aceite:**
* **Eu como** promotor de evento
* **Quero** excluir um evento existente
* **Quando** eu solicitar a exclusão do evento
* **Então** o evento deve ser marcado como inativo (exclusão lógica)
* **E** os serviços downstream devem ser notificados via header Warning

**Exemplo de chamada curl:**
```bash
curl -X DELETE "http://api.sigeev.com/v1/eventos/550e8400-e29b-41d4-a716-446655440020" \
     -H "Authorization: Bearer {jwt-token}" \
     -H "Accept: application/json" \
     -H "Version: v1"
```


**Respostas Possíveis**
* `204 No Content` - Evento excluído (inativado) com sucesso
* `401 Unauthorized` - Token ausente ou inválido
* `403 Forbidden` - Usuário não é o promotor do evento
* `404 Not Found` - Evento não encontrado
* `409 Conflict` - Evento com inscrições ativas ou já inativo
* `500 Internal Server Error` - Erro interno no servidor

**Payload de Resposta de Erro**
```json
{
  "sucesso": false,
  "mensagem": "Erro ao excluir evento.",
  "erros": [
    {
      "campo": "eventoId",
      "mensagem": "Não é possível excluir evento com inscrições ativas."
    }
  ],
  "timestamp": "2025-08-13T21:50:00Z",
  "correlationId": "550e8400-e29b-41d4-a716-446655440011"
}
```

Nota: Em caso de sucesso (204 No Content), nenhum corpo é retornado na resposta, apenas o header Warning.

**Regras de Negócio:**
* O evento deve existir no sistema e estar ativo.
* O sistema deve registrar a data e hora da solicitação de exclusão.
* O sistema deve enviar um email de confirmação ao promotor informando sobre a exclusão do evento.
* O sistema deve garantir que a exclusão seja lógica, mantendo os dados do evento para fins de auditoria.
* O sistema deve garantir que o promotor não possa excluir eventos que já estejam inativos.
* O sistema deve registrar logs de auditoria para todas as solicitações de exclusão de eventos.
* O sistema deve garantir que apenas o promotor do evento possa excluí-lo.

----