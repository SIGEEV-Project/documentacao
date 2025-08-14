
# Especificação de Requisitos - Módulo de Autenticação (SIGEEV)

## Índice

- [Introdução](#introdução)
  - [Objetivos do Módulo](#objetivos-do-módulo)
  - [Responsabilidades dos Serviços - Visão geral](#responsabilidades-dos-serviços---visão-geral)
- [Casos de uso](#casos-de-uso)
  - [Caso de Uso 01 – Login de Usuário](#caso-de-uso-01--login-de-usuário)
  - [Caso de Uso 02 – Renovação de Token (Refresh Token)](#caso-de-uso-02--renovação-de-token-refresh-token)
  - [Caso de Uso 03 – Troca de Senha](#caso-de-uso-03--troca-de-senha)
  - [Caso de Uso 04 – Solicitar Recuperação de Senha](#caso-de-uso-04--solicitar-recuperação-de-senha)
  - [Caso de Uso 05 – Redefinir Senha](#caso-de-uso-05--redefinir-senha)
- [Convenções e Padrões](#convenções-e-padrões)
  - [Estrutura de Respostas](#estrutura-de-respostas)
  - [Headers Padrão](#headers-padrão)
  - [Tokens e Segurança](#tokens-e-segurança)
  - [Rate Limiting e Retry](#rate-limiting-e-retry)

## Introdução

O módulo de autenticação é um componente crítico do Sistema de Gerenciamento de Eventos (SIGEEV), responsável por garantir a segurança e o controle de acesso em toda a aplicação. Este documento detalha os requisitos técnicos, casos de uso e regras de negócio relacionados à autenticação, autorização e gestão de identidade dos usuários.

Este módulo é implementado como parte da arquitetura de microserviços do SIGEEV, onde o BFF (Backend for Frontend) atua como intermediário entre o frontend e o microserviço de autenticação, oferecendo funcionalidades como login, renovação de tokens, gestão de senhas e recuperação de acesso.

### Objetivos do Módulo

- Prover autenticação segura e eficiente para todos os usuários do sistema
- Gerenciar tokens de acesso e renovação
- Implementar políticas de segurança e proteção contra ataques
- Oferecer mecanismos de recuperação de acesso
- Manter registro de atividades para auditoria


### Responsabilidades dos Serviços - Visão geral

* **BFF (Backend For Frontend)**
  - Extrair `usuarioId` do JWT para operações autenticadas
  - Encaminhar atualizações de último login ao serviço de usuários
  - Injetar headers padrão: correlation ID, timestamp
  - Validar tokens JWT
  - Implementar rate limiting por IP
  - Padronizar envelope de respostas
  
* **Microserviço de Autenticação**
  - Gerenciar tokens (JWT e refresh tokens)
  - Validar credenciais
  - Gerenciar bloqueios por tentativas falhas
  - Notificar serviço de notificações sobre eventos de segurança
  - Registrar logs de operações sensíveis

* **Microserviço de Usuários**
  - Armazenar data/hora do último login
  - Gerenciar status da conta (ativo/inativo)
  - Manter dados do perfil do usuário

* **Microserviço de Notificações**
  - Enviar emails de confirmação
  - Enviar alertas de segurança
  - Gerenciar templates de email

* **Microserviço de Eventos**
  - Gerenciar ciclo de vida dos eventos (criação, edição, exclusão)
  - Controlar status dos eventos (ativo/inativo)
  - Validar capacidade e disponibilidade de vagas
  - Manter informações detalhadas dos eventos
  - Integrar com serviço de upload de imagens para banners
  - Fornecer endpoints de busca e listagem de eventos

* **Microserviço de Inscrições**
  - Gerenciar processo de inscrição em eventos
  - Validar regras de negócio (vagas disponíveis, duplicidade)
  - Atualizar contadores de vagas em tempo real
  - Registrar histórico de inscrições por usuário
  - Notificar serviço de notificações sobre novas inscrições
  - Manter status das inscrições
  - Fornecer endpoints de consulta de inscrições

---

## Casos de uso

### Caso de Uso 01 – Login de Usuário

**Requisito Funcional: RF001**

**Descrição resumida**
O usuário deve ser capaz de fazer login no sistema utilizando seu email e senha. O sistema valida as credenciais e retorna um token JWT.

**Critérios de Aceite (BDD)**

*Cenário: Login com sucesso*
* **Dado que** sou um usuário registrado e ativo
* **Quando** eu fizer login com credenciais válidas
* **Então** devo receber um token JWT de autenticação
* **E** um refresh token para renovação

*Cenário: Credenciais inválidas*
* **Dado que** inseri credenciais incorretas
* **Quando** eu tentar fazer login
* **Então** devo receber erro 401
* **E** o número de tentativas deve ser incrementado

*Cenário: Usuário bloqueado*
* **Dado que** atingi 5 tentativas de login inválidas
* **Quando** eu tentar fazer login
* **Então** devo receber erro 429
* **E** uma mensagem informando o tempo de bloqueio

*Cenário: Conta inativa*
* **Dado que** minha conta está inativa
* **Quando** eu tentar fazer login
* **Então** devo receber erro 403
* **E** uma mensagem para contatar o suporte

**Payload de Entrada/Requisição**
```json
{
  "email": "lucas@email.com",
  "senha": "Senha@123"
}
```

**Respostas Possíveis**
* Sucesso: 200 OK + JWT Token
* Email ou senha inválidos: 401 Unauthorized
* Conta inativa: 403 Forbidden
* Conta bloqueada por tentativas: 429 Too Many Requests
* Erro interno: 500 Internal Server Error

**Payload de Resposta de sucesso**
```json
{
  "sucesso": true,
  "mensagem": "Login realizado com sucesso!",
  "dados": {
    "usuarioId": "a1b2c3d4-e5f6-7890-1234-567890abcdef",
    "perfil": "usuario",
    "nomeCompleto": "Lucas Benjamin de Araújo Farias A. Costa",
    "email": "lucas@email.com",
    "tokenAcesso": "eyJhbGciOiJIUzI1NiI...",
    "expiraEmAcesso": 3600,
    "refreshToken": "eyJhbGciOiJIUzI1NiI...",
    "expiraEmRefresh": 604800
  }
}
```

**Payloads de Resposta de Erro**

*401 Unauthorized - Credenciais inválidas*
```json
{
  "sucesso": false,
  "mensagem": "Erro ao fazer login.",
  "erros": [
    {
      "campo": "credenciais",
      "mensagem": "Email ou senha inválidos."
    }
  ],
  "timestamp": "2025-08-12T14:30:00Z",
  "correlationId": "550e8400-e29b-41d4-a716-446655440000"
}
```

*429 Too Many Requests - Bloqueio temporário*
```json
{
  "sucesso": false,
  "mensagem": "Conta temporariamente bloqueada.",
  "erros": [
    {
      "campo": "conta",
      "mensagem": "Conta bloqueada por excesso de tentativas. Tente novamente em 15 minutos."
    }
  ],
  "timestamp": "2025-08-12T14:30:00Z",
  "correlationId": "550e8400-e29b-41d4-a716-446655440000"
}
```

*403 Forbidden - Conta inativa*
```json
{
  "sucesso": false,
  "mensagem": "Acesso negado.",
  "erros": [
    {
      "campo": "conta",
      "mensagem": "Conta inativa. Contate o suporte."
    }
  ],
  "timestamp": "2025-08-12T14:30:00Z",
  "correlationId": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Regras de Negócio:**
* O email deve ser válido e registrado no sistema.
* A senha deve corresponder àquela cadastrada para o email informado.
* O usuário deve estar ativo (não inativo ou excluído).
* O token JWT deve ser gerado com um tempo de expiração configurável (ex: 1 hora).
* O token deve conter as informações do usuário, como ID, perfil e nome completo.
* O token deve ser assinado com uma chave secreta para garantir sua integridade e autenticidade.
* O sistema deve registrar a data e hora do último login do usuário.
* O sistema deve permitir tentativas de login com no máximo 5 falhas consecutivas antes de bloquear temporariamente o usuário por 15 minutos.
* O sistema deve registrar logs de acesso para auditoria e segurança.

----

### Caso de Uso 02 – Renovação de Token (Refresh Token)

**Requisito Funcional: RF002**

**Descrição resumida**
Permite ao usuário renovar seu token de acesso sem precisar fazer login novamente, utilizando um refresh token válido.

**Critérios de Aceite (BDD)**

*Cenário: Renovação com sucesso*
* **Dado que** sou um usuário com refresh token válido
* **Quando** eu solicitar a renovação dos tokens
* **Então** devo receber novos tokens de acesso e refresh
* **E** os tokens antigos devem ser invalidados

*Cenário: Refresh token expirado*
* **Dado que** meu refresh token está expirado
* **Quando** eu tentar renovar os tokens
* **Então** devo receber erro 401
* **E** uma mensagem informando que o token expirou

*Cenário: Refresh token revogado*
* **Dado que** meu refresh token foi revogado
* **Quando** eu tentar renovar os tokens
* **Então** devo receber erro 401
* **E** uma mensagem informando que o token é inválido

**Payload de Entrada/Requisição**
```json
{
  "refreshToken": "seu_refresh_token_aqui"
}
```

**Respostas Possíveis**
* Sucesso: 200 OK + Novos tokens
* Token inválido ou expirado: 401 Unauthorized
* Erro interno: 500 Internal Server Error

**Payload de Resposta de sucesso**
```json
{
  "sucesso": true,
  "mensagem": "Tokens renovados com sucesso!",
  "dados": {
    "tokenAcesso": "novo_token_de_acesso",
    "expiraEmAcesso": 3600,
    "refreshToken": "novo_refresh_token",
    "expiraEmRefresh": 604800
  },
  "timestamp": "2025-08-12T14:30:00Z",
  "correlationId": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Payloads de Resposta de Erro**

*401 Unauthorized - Token expirado*
```json
{
  "sucesso": false,
  "mensagem": "Erro ao renovar tokens.",
  "erros": [
    {
      "campo": "refreshToken",
      "mensagem": "Token expirado."
    }
  ],
  "timestamp": "2025-08-12T14:30:00Z",
  "correlationId": "550e8400-e29b-41d4-a716-446655440000"
}
```

*401 Unauthorized - Token revogado*
```json
{
  "sucesso": false,
  "mensagem": "Erro ao renovar tokens.",
  "erros": [
    {
      "campo": "refreshToken",
      "mensagem": "Token inválido ou foi revogado."
    }
  ],
  "timestamp": "2025-08-12T14:30:00Z",
  "correlationId": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Regras de Negócio:**
* O refresh token deve ser gerado no momento do login do usuário e ter uma validade maior que o token de acesso (ex: 7 dias).
* O refresh token deve ser único e armazenado no banco de dados, associado ao usuário.
* O sistema deve validar se o refresh token enviado existe no banco de dados e se não está expirado ou revogado.
* Se o refresh token for válido, o sistema deve gerar um novo par de `tokenAcesso` e `refreshToken`.
* O refresh token antigo deve ser invalidado no banco de dados após a emissão de um novo token.
* A nova data de expiração (`expiraEm`) deve ser retornada no payload de sucesso.
* O sistema deve registrar logs de auditoria para todas as tentativas de renovação de token.

----

### Caso de Uso 03 – Troca de Senha

**Requisito Funcional: RF003**

**Descrição resumida**
Permite ao usuário logado alterar sua senha atual por uma nova, desde que a senha atual seja válida.

**Critérios de Aceite (BDD)**

*Cenário: Troca de senha com sucesso*
* **Dado que** sou um usuário logado
* **Quando** eu enviar a senha atual e uma nova senha válida
* **Então** minha senha deve ser atualizada
* **E** devo receber uma confirmação por email

*Cenário: Senha atual incorreta*
* **Dado que** informei uma senha atual incorreta
* **Quando** eu tentar trocar a senha
* **Então** devo receber erro 401
* **E** a senha não deve ser alterada

*Cenário: Nova senha não atende critérios*
* **Dado que** informei uma nova senha que não atende aos requisitos mínimos
* **Quando** eu tentar trocar a senha
* **Então** devo receber erro 400
* **E** um detalhamento dos critérios não atendidos

**Payload de Entrada/Requisição**
```json
{
  "senhaAtual": "Senha@123",
  "novaSenha": "NovaSenha@456"
}
```

**Respostas Possíveis**
* Sucesso: 200 OK
* Senha atual inválida: 401 Unauthorized
* Nova senha inválida: 400 Bad Request
* Erro interno: 500 Internal Server Error

**Payload de Resposta de sucesso**
```json
{
  "sucesso": true,
  "mensagem": "Senha alterada com sucesso!"
}
```

**Payload de Resposta de Erro**
```json
{
  "sucesso": false,
  "mensagem": "Erro ao trocar senha.",
  "erros": [
    {
      "campo": "senhaAtual",
      "mensagem": "Senha atual inválida."
    }
  ],
  "timestamp": "2025-08-12T14:30:00Z",
  "correlationId": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Regras de Negócio:**
* O usuário deve existir no sistema e estar ativo.
* A senha atual deve ser válida e corresponder àquela cadastrada.
* A nova senha deve atender aos critérios de segurança (mínimo de 8 caracteres, incluindo letras maiúsculas, minúsculas, números e caracteres especiais).
* O sistema deve enviar um email de notificação ao usuário informando sobre a troca de senha.
* O sistema deve garantir que o usuário não possa reutilizar a senha atual como nova senha.
* O sistema deve registrar logs de auditoria para todas as trocas de senha.

----

### Caso de Uso 04 – Solicitar Recuperação de Senha

**Requisito Funcional: RF004**

**Descrição resumida**
Permite ao usuário solicitar a recuperação da senha. O sistema envia um email com um link para redefinição.

**Critérios de Aceite (BDD)**
* **Eu como** usuário que esqueceu a senha
* **Quero** solicitar a recuperação
* **Quando** eu enviar meu email cadastrado
* **Então** devo receber um email com instruções
* **E** o link deve expirar em 1 hora

**Payload de Entrada/Requisição**
```json
{
  "email": "lucas@email.com"
}
```

**Respostas Possíveis**
* Sucesso: 200 OK
* Email não cadastrado: 404 Not Found
* Erro interno: 500 Internal Server Error

**Payload de Resposta de sucesso**
```json
{
  "sucesso": true,
  "mensagem": "Email enviado com instruções para redefinir a senha."
}
```

**Payload de Resposta de Erro**
```json
{
  "sucesso": false,
  "mensagem": "Erro ao solicitar recuperação de senha.",
  "erros": [
    {
      "campo": "email",
      "mensagem": "Email não cadastrado."
    }
  ],
  "timestamp": "2025-08-12T14:30:00Z",
  "correlationId": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Regras de Negócio:**
* O email deve ser válido e cadastrado no sistema.
* O sistema deve gerar um token de recuperação com validade de 1 hora.
* O token de recuperação deve ser único e armazenado no banco.
* O microserviço de autenticação deve solicitar ao serviço de notificações o envio do email.
* O email deve conter um link com o token de recuperação.
* O token deve ser invalidado após o uso.
* O sistema deve invalidar todos os refresh tokens ativos após a redefinição.
* O BFF deve implementar rate limiting de 3 tentativas por email a cada 60 minutos.
* Os logs devem incluir: IP, user agent, correlation ID, timestamp.

----

### Caso de Uso 05 – Redefinir Senha

**Requisito Funcional: RF005**

**Descrição resumida**
Permite ao usuário definir uma nova senha usando o token de recuperação recebido por email.

**Critérios de Aceite (BDD)**
* **Eu como** usuário com token de recuperação
* **Quero** definir uma nova senha
* **Quando** eu enviar o token e a nova senha
* **Então** minha senha deve ser atualizada

**Payload de Entrada/Requisição**
```json
{
  "token": "token-de-recuperacao",
  "novaSenha": "NovaSenha@456"
}
```

**Respostas Possíveis**
* Sucesso: 200 OK
* Token inválido/expirado: 401 Unauthorized
* Nova senha inválida: 400 Bad Request
* Erro interno: 500 Internal Server Error

**Payload de Resposta de sucesso**
```json
{
  "sucesso": true,
  "mensagem": "Senha redefinida com sucesso!"
}
```

**Payload de Resposta de Erro**
```json
{
  "sucesso": false,
  "mensagem": "Erro ao redefinir senha.",
  "erros": [
    {
      "campo": "token",
      "mensagem": "Token inválido ou expirado."
    }
  ]
}
```

**Regras de Negócio:**
* O token de recuperação deve existir e estar dentro da validade (1 hora).
* A nova senha deve ter 8+ caracteres, letras maiúsculas/minúsculas, números e caracteres especiais.
* O sistema deve invalidar o token após o uso.
* O sistema deve invalidar todos os refresh tokens ativos do usuário.
* O sistema deve enviar email confirmando a redefinição da senha.
* Os logs devem incluir: IP, user agent, correlation ID, timestamp.

----

## Convenções e Padrões

### Estrutura de Respostas

Todas as respostas da API devem seguir a estrutura:

```json
{
  "sucesso": "true | false",
  "mensagem": "Mensagem descritiva da operação",
  "dados": {                    // apenas em respostas 2xx
      
  },
  "erros": [                   // apenas em respostas 5xx
    {
      "campo": "senhaAtual",
      "mensagem": "Senha atual incorreta."
    }
  ],
  "timestamp": "2025-08-12T14:30:00Z",
  "correlationId": "550e8400-e29b-41d4-a716-446655440000"
}
```

*Exemplo: 400 Bad Request - Nova senha inválida*
```json
{
  "sucesso": false,
  "mensagem": "Erro ao alterar senha.",
  "erros": [
    {
      "campo": "novaSenha",
      "mensagem": "A nova senha deve conter pelo menos 8 caracteres, incluindo letras maiúsculas, minúsculas, números e caracteres especiais."
    }
  ],
  "timestamp": "2025-08-12T14:30:00Z",
  "correlationId": "550e8400-e29b-41d4-a716-446655440000"
}  
```

### Headers Padrão

* `X-Correlation-ID`: UUID v4 para rastreamento da requisição
* `Authorization`: Bearer token para endpoints autenticados
* `User-Agent`: Identificação do cliente
* `X-Forwarded-For`: IP original do cliente

### Tokens e Segurança

* **Access Token (JWT)**
  - Validade: 1 hora
  - Assinatura: RS256
  - Claims obrigatórias: `sub` (usuarioId), `roles`, `name`, `exp`, `iat`, `iss`

* **Refresh Token**
  - Validade: 7 dias
  - Armazenamento: Banco de dados
  - Um usuário pode ter múltiplos refresh tokens ativos

### Rate Limiting e Retry

* **Rate Limits**
  - Login: 5 tentativas por IP a cada 15 minutos
  - Recuperação de senha: 3 tentativas por email a cada 60 minutos
  - Demais endpoints: 100 requisições por minuto por IP

* **Retry**
  - Backoff exponencial: 1s, 2s, 4s, 8s, 16s
  - Máximo de 5 tentativas
  - Apenas para erros 5xx