# Documentação de API - Módulo de Usuários (SIGEEV)

## Sumário
- [Visão Geral](#visão-geral)
- [Convenções](#convenções)
- [Autenticação & Autorização](#autenticação--autorização)
- [Padrão de Envelope](#padrão-de-envelope)
- [Erros Padrão](#erros-padrão)
- [Cabeçalhos Importantes](#cabeçalhos-importantes)
- [Tabela de Endpoints](#tabela-de-endpoints)
- [Endpoints Detalhados](#endpoints-detalhados)
    - [POST /usuarios (Cadastro de Usuário)](#post-usuarios-cadastro-de-usuário)
    - [GET /usuarios/me (Consulta de Perfil)](#get-usuariosme-consulta-de-perfil)
    - [PUT /usuarios/me (Atualização de Perfil)](#put-usuariosme-atualização-de-perfil)
    - [POST /usuarios/{id}/promover (Promoção de Perfil)](#post-usuariosidpromover-promoção-de-perfil)
    - [POST /usuarios/{id}/rebaixar (Rebaixar Perfil)](#post-usuariosidrebaixar-rebaixar-perfil)
    - [DELETE /usuarios/me (Exclusão de Conta)](#delete-usuariosme-exclusão-de-conta)
- [Códigos de Status HTTP](#códigos-de-status-http)
- [Controle de Versão](#controle-de-versão)
- [Evolução Futuras & Notas](#evolução-futuras--notas)

---

## Visão Geral
API responsável pelo ciclo de vida de usuários: cadastro, consulta, atualização de perfil, alteração de papel (promoção/rebaixamento) e exclusão lógica de conta.

## Convenções
- Base URL (exemplo): `https://api.sigeev.com` (BFF) / `https://usuarios.sigeev.internal` (microserviço).
- Todas as respostas usam JSON UTF-8.
- Data/hora em UTC no formato ISO 8601 (`YYYY-MM-DDTHH:mm:ssZ`).
- Identificadores usam UUID v4.
- Campos opcionais omitidos quando nulos (exceto onde explicitamente listado).

## Autenticação & Autorização
- JWT emitido pelo Módulo de Autenticação enviado em `Authorization: Bearer <token>`.
- Escopos/perfis relevantes: `participante`, `promotor`, `administrador`.
- Promoção e rebaixamento exigem perfil `administrador`.
- Operações sobre o próprio usuário usam `me` para reduzir risco de IDOR (Insecure Direct Object Reference).

## Padrão de Envelope
```json
{
  "sucesso": true,
  "mensagem": "Descrição de alto nível",
  "dados": {},
  "erros": [
    {
      "campo": "email",
      "mensagem": "E-mail já cadastrado."
    }
  ],
  "timestamp": "2025-08-28T12:00:00Z",
  "correlationId": "uuid-gerado-em-cada-request"
}
```
Observações:
- Sempre retornar `timestamp` e `correlationId`.
- Em sucesso sem conteúdo específico (ex: promoções), retornar `dados: {}`.
- Para listas vazias, retornar `dados: []` ou objeto com array vazio.

## Erros Padrão
| Campo    | Descrição                                               |
|----------|---------------------------------------------------------|
| campo    | Nome lógico do campo inválido ou null para erros gerais |
| mensagem | Texto legível explicando o problema                     |

## Cabeçalhos Importantes
| Cabeçalho        | Direção | Obrigatório           | Descrição                                  |
|------------------|---------|-----------------------|--------------------------------------------|
| Authorization    | →       | Sim (exceto cadastro) | JWT Bearer                                 |
| X-Correlation-Id | ↔       | Recomendado           | Propaga rastreabilidade; gerado se ausente |
| Content-Type     | →       | Sim                   | `application/json`                         |
| Accept           | →       | Opcional              | `application/json`                         |

## Tabela de Endpoints
| Operação         | Método | Caminho                 | Autenticação | Permissão           | Descrição Resumida                 |
|------------------|--------|-------------------------|--------------|---------------------|------------------------------------|
| Cadastro         | POST   | /usuarios               | Não          | -                   | Cria novo usuário                  |
| Consultar Perfil | GET    | /usuarios/me            | Sim          | Usuário autenticado | Retorna dados do próprio perfil    |
| Atualizar Perfil | PUT    | /usuarios/me            | Sim          | Usuário autenticado | Atualiza dados pessoais e endereço |
| Promover Usuário | POST   | /usuarios/{id}/promover | Sim          | Administrador       | Altera perfil para promotor        |
| Rebaixar Usuário | POST   | /usuarios/{id}/rebaixar | Sim          | Administrador       | Altera perfil para participante    |
| Excluir Conta    | DELETE | /usuarios/me            | Sim          | Usuário autenticado | Exclusão lógica da conta           |

---

## Endpoints Detalhados
### POST /usuarios (Cadastro de Usuário)
Cria um novo usuário. Não requer autenticação.

Permissões: Público

Request Body:
```json
{
  "usuario": {
    "primeiroNome": "Lucas",
    "ultimoNome": "Benjamin de Araújo Farias A. Costa",
    "documento": { "tipo": "CPF", "numero": "12345678900" },
    "credenciais": { "email": "lucas@email.com", "senha": "Senha@123" },
    "contato": { "telefone": "81987654321", "emailContato": "lucas@email.com" },
    "dataNascimento": "1986-04-05"
  },
  "endereco": {
    "logradouro": "Rua das Flores",
    "numero": "123",
    "cidade": "Recife",
    "estado": "PE",
    "cep": "50000-000"
  }
}
```
Validações principais:
- Nome, email, CPF, senha, dataNascimento obrigatórios.
- CPF válido e único; email válido e único.
- Senha: mínimo 8 caracteres; maiúscula, minúscula, número e caractere especial.
- Usuário >= 18 anos.

Comportamentos do sistema:
- O sistema envia e-mail de confirmação de cadastro para o endereço informado.
- O sistema gera e retorna um token JWT para autenticação imediata.

Respostas:
- 201 Created (sucesso)
- 400 Bad Request (erros de validação)
- 409 Conflict (CPF ou email já cadastrado)
- 500 Internal Server Error

Exemplo Sucesso:
```json
{
  "sucesso": true,
  "mensagem": "Usuário Lucas Benjamin cadastrado com sucesso!",
  "dados": {
    "usuarioId": "a1b2c3d4-e5f6-7890-1234-567890abcdef",
    "nomeCompleto": "Lucas Benjamin de Araújo Farias A. Costa",
    "email": "lucas@email.com",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  },
  "timestamp": "2025-08-28T12:01:00Z",
  "correlationId": "uuid"
}
```
Exemplo Erro (409):
```json
{
  "sucesso": false,
  "mensagem": "Erro ao cadastrar usuário.",
  "erros": [
    { "campo": "cpf", "mensagem": "CPF já cadastrado." },
    { "campo": "email", "mensagem": "E-mail já cadastrado." }
  ],
  "timestamp": "2025-08-28T12:01:02Z",
  "correlationId": "uuid"
}
```

---
### GET /usuarios/me (Consulta de Perfil)
Retorna dados do próprio usuário.

Permissões: Autenticado

Comportamentos do sistema:
- O sistema registra data/hora da consulta para fins de auditoria.
- O CPF é mascarado na resposta conforme regra RNF-004 (exibindo apenas alguns dígitos e ocultando os demais com asteriscos).

Respostas:
- 200 OK
- 401 Unauthorized (token ausente/inválido)
- 404 Not Found (usuário não encontrado)
- 410 Gone (usuário excluído logicamente – se política aplicável)

Exemplo Sucesso:
```json
{
  "sucesso": true,
  "mensagem": "Perfil consultado com sucesso!",
  "dados": {
    "usuario": {
      "usuarioId": "a1b2c3d4-e5f6-7890-1234-567890abcdef",
      "primeiroNome": "Lucas",
      "ultimoNome": "Benjamin de Araújo Farias A. Costa",
      "documento": { "tipo": "CPF", "numero": "***456789**" },
      "credenciais": { "email": "lucas@email.com", "perfil": "participante" },
      "contato": { "telefone": "81987654321", "emailContato": "lucas@email.com" },
      "dataNascimento": "1986-04-05",
      "dataCadastro": "2025-08-12T10:30:00Z",
      "status": "ativo"
    },
    "endereco": {
      "logradouro": "Rua das Flores",
      "numero": "123",
      "cidade": "Recife",
      "estado": "PE",
      "cep": "50000-000"
    }
  },
  "timestamp": "2025-08-28T12:02:00Z",
  "correlationId": "uuid"
}
```

---
### PUT /usuarios/me (Atualização de Perfil)
Atualiza dados pessoais e endereço. Email e CPF não podem ser alterados aqui.

Permissões: Autenticado

Comportamentos do sistema:
- O sistema envia e-mail de confirmação das alterações realizadas.
- O sistema registra data/hora da alteração para fins de auditoria.

Request Body (exemplo):
```json
{
  "usuario": {
    "primeiroNome": "Lucas",
    "ultimoNome": "Benjamin de Araújo Farias A. Costa",
    "contato": { "telefone": "81987654321" },
    "dataNascimento": "1985-01-20"
  },
  "endereco": {
    "logradouro": "Rua das Flores",
    "numero": "123",
    "cidade": "Recife",
    "estado": "PE",
    "cep": "50000-000"
  }
}
```
Respostas:
- 200 OK
- 400 Bad Request (validação / tentativa de alterar email/CPF)
- 404 Not Found (usuário não existe)
- 409 Conflict (conflito de versão / concorrência)
- 500 Internal Server Error

Exemplo Sucesso:
```json
{
  "sucesso": true,
  "mensagem": "Usuário Lucas Benjamin alterado com sucesso!",
  "dados": {},
  "timestamp": "2025-08-28T12:03:10Z",
  "correlationId": "uuid"
}
```

---
### POST /usuarios/{id}/promover (Promoção de Perfil)
Altera perfil de participante para promotor.

Permissões: Administrador

Path Params:
- `id` (UUID do usuário alvo)

Comportamentos do sistema:
- O sistema registra ID do administrador e data/hora da promoção para fins de auditoria.
- O sistema envia e-mail de notificação ao usuário promovido.

Request Body:
```json
{ "novoPerfil": "promotor" }
```
Respostas:
- 200 OK
- 400 Bad Request (perfil inválido)
- 403 Forbidden (sem permissão)
- 404 Not Found (usuário)
- 409 Conflict (já é promotor)
- 410 Gone (excluído)

Exemplo Sucesso:
```json
{
  "sucesso": true,
  "mensagem": "Usuário promovido a promotor com sucesso!",
  "dados": {},
  "timestamp": "2025-08-28T12:04:00Z",
  "correlationId": "uuid"
}
```

---
### POST /usuarios/{id}/rebaixar (Rebaixar Perfil)
Altera perfil de promotor para participante.

Permissões: Administrador

Comportamentos do sistema:
- O sistema registra ID do administrador e data/hora do rebaixamento para fins de auditoria.
- O sistema envia e-mail de notificação ao usuário rebaixado.

Request Body:
```json
{ "novoPerfil": "participante" }
```
Respostas:
- 200 OK
- 400 Bad Request (perfil inválido)
- 403 Forbidden
- 404 Not Found
- 409 Conflict (já participante)
- 410 Gone (excluído)

Exemplo Sucesso:
```json
{
  "sucesso": true,
  "mensagem": "Usuário rebaixado para participante com sucesso!",
  "dados": {},
  "timestamp": "2025-08-28T12:05:00Z",
  "correlationId": "uuid"
}
```

---
### DELETE /usuarios/me (Exclusão de Conta)
Exclusão lógica da própria conta.

Permissões: Autenticado

Comportamentos do sistema:
- O sistema solicita confirmação da intenção de exclusão antes de processar (via parâmetro de confirmação na requisição).
- O sistema envia e-mail de confirmação da exclusão.
- O sistema impede futuros logins com as credenciais após a exclusão.
- Os dados são retidos conforme política de retenção (exclusão lógica).

Request Body:
```json
{ "confirmacao": "CONFIRMAR" }
```

Respostas:
- 200 OK
- 401 Unauthorized
- 404 Not Found
- 409 Conflict (já inativa)
- 500 Internal Server Error

Exemplo Sucesso:
```json
{
  "sucesso": true,
  "mensagem": "Conta excluída com sucesso!",
  "dados": {},
  "timestamp": "2025-08-28T12:06:30Z",
  "correlationId": "uuid"
}
```

---
## Códigos de Status HTTP
| Código | Uso                                           |
|--------|-----------------------------------------------|
| 200    | Operação concluída com sucesso                |
| 201    | Recurso criado (cadastro)                     |
| 400    | Erros de validação / campos inválidos         |
| 401    | Falta de autenticação ou token inválido       |
| 403    | Autenticado mas sem permissão (RBAC)          |
| 404    | Recurso não encontrado                        |
| 409    | Conflito de estado de negócio                 |
| 410    | Recurso removido logicamente (quando adotado) |
| 500    | Erro interno inesperado                       |

## Controle de Versão
Versão inicial da API: v1. Futuras alterações incompatíveis deverão introduzir `/v2`.

## Evolução Futuras & Notas
- Endpoint para reativação de conta (pendente de especificação de governança de dados).
- Suporte a PATCH para atualizações parciais (ganho de eficiência para apps móveis).
- Paginação em consultas de usuários (lista administrativa em outro módulo).
