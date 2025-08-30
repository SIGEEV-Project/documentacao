# Documentação de API - Módulo de Autenticação (SIGEEV)

## Sumário
- [Documentação de API - Módulo de Autenticação (SIGEEV)](#documentação-de-api---módulo-de-autenticação-sigeev)
  - [Sumário](#sumário)
  - [Visão Geral](#visão-geral)
  - [Convenções](#convenções)
  - [Autenticação \& Escopo](#autenticação--escopo)
  - [Padrão de Envelope](#padrão-de-envelope)
  - [Erros Padrão](#erros-padrão)
  - [Cabeçalhos Importantes](#cabeçalhos-importantes)
  - [Tabela de Endpoints](#tabela-de-endpoints)
  - [Modelos de Dados](#modelos-de-dados)
    - [Resposta Login](#resposta-login)
    - [Resposta Renovação](#resposta-renovação)
  - [Endpoints Detalhados](#endpoints-detalhados)
    - [POST /auth/login (Login)](#post-authlogin-login)
    - [POST /auth/refresh (Renovar Tokens)](#post-authrefresh-renovar-tokens)
    - [POST /auth/password/change (Troca de Senha)](#post-authpasswordchange-troca-de-senha)
    - [POST /auth/password/recovery (Solicitar Recuperação)](#post-authpasswordrecovery-solicitar-recuperação)
    - [POST /auth/password/reset (Redefinir Senha)](#post-authpasswordreset-redefinir-senha)
  - [Códigos de Status HTTP](#códigos-de-status-http)
  - [Controle de Versão](#controle-de-versão)
  - [Evoluções Futuras \& Notas](#evoluções-futuras--notas)

---
## Visão Geral
API de autenticação responsável por emissão e renovação de tokens JWT, troca e recuperação de senhas e mecanismos de proteção contra abuso (brute force / rate limit).

## Convenções
- Base URL (exemplo): `https://api.sigeev.com` (BFF) / `https://auth.sigeev.internal` (microserviço)
- JSON UTF-8
- Timestamp em UTC ISO 8601 (`YYYY-MM-DDTHH:mm:ssZ`)
- IDs: UUID v4
- Senhas nunca retornadas
- Tokens JWT assinado (HS256 ou RS256) contendo `sub` (usuarioId), `perfil`, `nome`, `iat`, `exp`

## Autenticação & Escopo
- Endpoints de login e recuperação pública (sem JWT): `/auth/login`, `/auth/password/recovery`, `/auth/password/reset`
- Renovação exige apenas refresh token válido (no corpo) — não precisa header Authorization
- Troca de senha exige JWT de acesso válido
- Perfis: `participante`, `promotor`, `administrador` (informativos para autorização em outros módulos)

## Padrão de Envelope
```json
{
  "sucesso": true,
  "mensagem": "Descrição de alto nível",
  "dados": {},
  "erros": [ { "campo": "email", "mensagem": "Email inválido." } ],
  "timestamp": "2025-08-30T12:00:00Z",
  "correlationId": "uuid"
}
```
Observações:
- Sempre retornar `timestamp` e `correlationId`
- Em erros de autenticação usar 401 / 403 conforme sem credenciais vs proibido
- Em brute force usar 429 com `Retry-After`

## Erros Padrão
| Campo | Descrição |
|-------|-----------|
| campo | Campo relacionado ao erro ou null para geral |
| mensagem | Texto legível explicando o problema |

## Cabeçalhos Importantes
| Cabeçalho | Direção | Obrigatório | Descrição |
|-----------|---------|-------------|-----------|
| Authorization | → | Sim (troca de senha) | `Bearer <tokenAcesso>` |
| X-Correlation-Id | ↔ | Recomendado | Rastreabilidade distribuída |
| Content-Type | → | Sim | `application/json` |
| Accept | → | Opcional | `application/json` |
| Retry-After | ← | Condicional | Retornado em 429 (segundos) |
| X-Rate-Limit-Remaining | ← | Condicional | Tentativas restantes de login |

## Tabela de Endpoints
| Operação | Método | Caminho | Auth | Descrição Resumida |
|----------|--------|--------|------|--------------------|
| Login | POST | /auth/login | Não | Gera tokens de acesso e refresh |
| Renovar Tokens | POST | /auth/refresh | Não (usa refresh) | Emite novo par de tokens |
| Troca de Senha | POST | /auth/password/change | JWT | Alterar senha logado |
| Solicitar Recuperação | POST | /auth/password/recovery | Não | Envia email com token de recuperação |
| Redefinir Senha | POST | /auth/password/reset | Não | Define nova senha via token recuperação |

## Modelos de Dados
### Resposta Login
```json
{
  "usuarioId": "uuid",
  "perfil": "participante",
  "nomeCompleto": "Nome Sobrenome",
  "email": "user@email.com",
  "tokenAcesso": "jwt...",
  "expiraEmAcesso": 3600,
  "refreshToken": "jwtRefresh...",
  "expiraEmRefresh": 604800
}
```
### Resposta Renovação
```json
{
  "tokenAcesso": "jwtNovo...",
  "expiraEmAcesso": 3600,
  "refreshToken": "jwtRefreshNovo...",
  "expiraEmRefresh": 604800
}
```

---
## Endpoints Detalhados
### POST /auth/login (Login)
Autentica usuário por email + senha.

Request Body:
```json
{ "email": "user@email.com", "senha": "Senha@123" }
```
Validações:
- Email sintaxe válida; senha obrigatória
- Máx 5 falhas consecutivas antes de bloqueio 15 min

Respostas: 200 / 401 / 403 / 429 / 500

Exemplo Sucesso (200):
```json
{
  "sucesso": true,
  "mensagem": "Login realizado com sucesso!",
  "dados": {
    "usuarioId": "a1b2c3d4-e5f6-7890-1234-567890abcdef",
    "perfil": "participante",
    "nomeCompleto": "Lucas Benjamin",
    "email": "user@email.com",
    "tokenAcesso": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiraEmAcesso": 3600,
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiraEmRefresh": 604800
  },
  "timestamp": "2025-08-30T12:00:00Z",
  "correlationId": "uuid"
}
```
Credenciais Inválidas (401):
```json
{
  "sucesso": false,
  "mensagem": "Erro ao fazer login.",
  "erros": [ { "campo": "credenciais", "mensagem": "Email ou senha inválidos." } ],
  "timestamp": "2025-08-30T12:00:00Z",
  "correlationId": "uuid"
}
```
Bloqueio Temporário (429):
```json
{
  "sucesso": false,
  "mensagem": "Conta temporariamente bloqueada.",
  "erros": [ { "campo": "conta", "mensagem": "Excesso de tentativas. Tente novamente em 15 minutos." } ],
  "timestamp": "2025-08-30T12:00:00Z",
  "correlationId": "uuid"
}
```
Conta Inativa (403):
```json
{
  "sucesso": false,
  "mensagem": "Acesso negado.",
  "erros": [ { "campo": "conta", "mensagem": "Conta inativa. Contate o suporte." } ],
  "timestamp": "2025-08-30T12:00:00Z",
  "correlationId": "uuid"
}
```

### POST /auth/refresh (Renovar Tokens)
Usa refresh token para gerar novo par.

Request Body:
```json
{ "refreshToken": "tokenRefreshAtual" }
```
Validações:
- Refresh token existente, não expirado, não revogado

Respostas: 200 / 401 / 500

Exemplo Sucesso (200):
```json
{
  "sucesso": true,
  "mensagem": "Tokens renovados com sucesso!",
  "dados": {
    "tokenAcesso": "novoJwt...",
    "expiraEmAcesso": 3600,
    "refreshToken": "novoRefresh...",
    "expiraEmRefresh": 604800
  },
  "timestamp": "2025-08-30T12:05:00Z",
  "correlationId": "uuid"
}
```
Token Expirado / Revogado (401):
```json
{
  "sucesso": false,
  "mensagem": "Erro ao renovar tokens.",
  "erros": [ { "campo": "refreshToken", "mensagem": "Token inválido ou expirado." } ],
  "timestamp": "2025-08-30T12:05:00Z",
  "correlationId": "uuid"
}
```

### POST /auth/password/change (Troca de Senha)
Requer JWT válido. Não invalida sessão se falhar.

Request Body:
```json
{ "senhaAtual": "Senha@123", "novaSenha": "NovaSenha@456" }
```
Validações:
- Senha atual confere
- Nova senha atende política (8+, maiúscula, minúscula, número, especial) e diferente da atual

Respostas: 200 / 400 / 401 / 500

Sucesso (200):
```json
{ "sucesso": true, "mensagem": "Senha alterada com sucesso!", "dados": {}, "timestamp": "2025-08-30T12:10:00Z", "correlationId": "uuid" }
```
Senha Atual Incorreta (401):
```json
{ "sucesso": false, "mensagem": "Erro ao trocar senha.", "erros": [ { "campo": "senhaAtual", "mensagem": "Senha atual inválida." } ], "timestamp": "2025-08-30T12:10:00Z", "correlationId": "uuid" }
```
Nova Senha Inválida (400):
```json
{ "sucesso": false, "mensagem": "Erro ao trocar senha.", "erros": [ { "campo": "novaSenha", "mensagem": "Não atende aos critérios mínimos." } ], "timestamp": "2025-08-30T12:10:00Z", "correlationId": "uuid" }
```

### POST /auth/password/recovery (Solicitar Recuperação)
Gera token de recuperação (1h) e envia email. Rate limit: 3 requisições / email / 60min.

Request Body:
```json
{ "email": "user@email.com" }
```
Respostas: 200 / 404 / 429 / 500

Sucesso (200):
```json
{ "sucesso": true, "mensagem": "Email enviado com instruções para redefinir a senha.", "dados": {}, "timestamp": "2025-08-30T12:15:00Z", "correlationId": "uuid" }
```
Email Não Cadastrado (404):
```json
{ "sucesso": false, "mensagem": "Erro ao solicitar recuperação de senha.", "erros": [ { "campo": "email", "mensagem": "Email não cadastrado." } ], "timestamp": "2025-08-30T12:15:00Z", "correlationId": "uuid" }
```
Rate Limit (429):
```json
{ "sucesso": false, "mensagem": "Muitas solicitações.", "erros": [ { "campo": "email", "mensagem": "Limite de solicitações alcançado. Tente novamente mais tarde." } ], "timestamp": "2025-08-30T12:15:00Z", "correlationId": "uuid" }
```

### POST /auth/password/reset (Redefinir Senha)
Aplica nova senha usando token de recuperação.

Request Body:
```json
{ "token": "token-de-recuperacao", "novaSenha": "NovaSenha@456" }
```
Validações:
- Token válido (existente, não expirado, não utilizado)
- Nova senha atende política

Respostas: 200 / 400 / 401 / 500

Sucesso (200):
```json
{ "sucesso": true, "mensagem": "Senha redefinida com sucesso!", "dados": {}, "timestamp": "2025-08-30T12:20:00Z", "correlationId": "uuid" }
```
Token Inválido / Expirado (401):
```json
{ "sucesso": false, "mensagem": "Erro ao redefinir senha.", "erros": [ { "campo": "token", "mensagem": "Token inválido ou expirado." } ], "timestamp": "2025-08-30T12:20:00Z", "correlationId": "uuid" }
```
Nova Senha Inválida (400):
```json
{ "sucesso": false, "mensagem": "Erro ao redefinir senha.", "erros": [ { "campo": "novaSenha", "mensagem": "Não atende aos critérios mínimos." } ], "timestamp": "2025-08-30T12:20:00Z", "correlationId": "uuid" }
```

---
## Códigos de Status HTTP
| Código | Uso |
|--------|-----|
| 200 | Sucesso |
| 400 | Erro de validação (nova senha etc.) |
| 401 | Credenciais / token inválido ou expirado |
| 403 | Conta inativa / acesso negado |
| 404 | Email não cadastrado (recuperação) |
| 409 | Conflito (ex: reutilização senha futura se aplicável) |
| 429 | Rate / brute force excedido |
| 500 | Erro interno |

## Controle de Versão
Versão inicial v1. Alterações breaking → `/v2`.

## Evoluções Futuras & Notas
- Suporte MFA (TOTP / WebAuthn)
- Lista de revogação distribuída (cache + store) para tokens de refresh
- Notificação push de login suspeito
- Endpoint de logout / revogação explícita
- Rotação automática de chave JWT (kid no header)
