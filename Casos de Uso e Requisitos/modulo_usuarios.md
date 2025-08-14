
# Especificação de Requisitos - Módulo de Usuários (SIGEEV)

## Índice

- [Especificação de Requisitos - Módulo de Usuários (SIGEEV)](#especificação-de-requisitos---módulo-de-usuários-sigeev)
  - [Índice](#índice)
  - [Introdução](#introdução)
  - [Objetivos do Módulo](#objetivos-do-módulo)
  - [Responsabilidades dos Serviços - Visão geral](#responsabilidades-dos-serviços---visão-geral)
  - [Casos de uso](#casos-de-uso)
    - [Caso de Uso 01 – Cadastro de Usuário](#caso-de-uso-01--cadastro-de-usuário)
    - [Caso de Uso 02 – Consulta de Perfil](#caso-de-uso-02--consulta-de-perfil)
    - [Caso de Uso 03 – Atualização de Perfil](#caso-de-uso-03--atualização-de-perfil)
    - [Caso de Uso 04 – Promoção de Perfil](#caso-de-uso-04--promoção-de-perfil)
    - [Caso de Uso 05 – Rebaixar Perfil de Promotor para Participante](#caso-de-uso-05--rebaixar-perfil-de-promotor-para-participante)
    - [Caso de Uso 06 – Exclusão de Conta](#caso-de-uso-06--exclusão-de-conta)
  - [Convenções e Padrões Específicos do Módulo de Usuários](#convenções-e-padrões-específicos-do-módulo-de-usuários)
    - [1. Modelo de Dados do Usuário](#1-modelo-de-dados-do-usuário)
    - [2. Validações de Dados](#2-validações-de-dados)
      - [2.1 Dados Pessoais](#21-dados-pessoais)
      - [2.2 Endereço](#22-endereço)
    - [3. Controle de Acesso](#3-controle-de-acesso)
      - [3.1 Perfis de Usuário](#31-perfis-de-usuário)
      - [3.2 Operações por Perfil](#32-operações-por-perfil)
    - [4. Políticas de Dados e Segurança](#4-políticas-de-dados-e-segurança)
      - [4.1 Auditoria](#41-auditoria)
      - [4.2 Privacidade e Retenção](#42-privacidade-e-retenção)
      - [4.3 Rate Limits Específicos](#43-rate-limits-específicos)

## Introdução

O módulo de usuários é um componente fundamental do Sistema de Gerenciamento de Eventos (SIGEEV), responsável por gerenciar todo o ciclo de vida dos usuários na plataforma. Este documento detalha os requisitos técnicos, casos de uso e regras de negócio relacionados ao cadastro, atualização, consulta e gestão dos perfis de usuários do sistema.

Este módulo é implementado como parte da arquitetura de microserviços do SIGEEV, onde o BFF (Backend for Frontend) atua como intermediário entre o frontend e o microserviço de usuários, oferecendo funcionalidades como cadastro de novos usuários, atualização de perfil, gestão de endereços e manutenção dos dados pessoais.

## Objetivos do Módulo

- Gerenciar o ciclo de vida completo dos usuários na plataforma
- Manter dados cadastrais atualizados e consistentes
- Garantir a unicidade e integridade das informações dos usuários
- Prover interfaces para atualização e consulta de perfis
- Integrar com outros módulos para fornecer informações necessárias
- Implementar políticas de privacidade e proteção de dados pessoais
- Manter histórico de alterações para fins de auditoria

## Responsabilidades dos Serviços - Visão geral

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

----

## Casos de uso

### Caso de Uso 01 – Cadastro de Usuário

**Requisito Funcional: RF001**

**Descrição resumida**
O usuário deve ser capaz de se registrar no sistema fornecendo os seus dados pessoais. O sistema deve validar a unicidade do CPF e do email, retornando um token JWT para autenticação.

**Critérios de Aceite (BDD)**

* **Eu como** novo usuário
* **Quero** me registrar no sistema com os meus dados pessoais
* **Quando** eu enviar um formulário com dados válidos e únicos
* **Então** minha conta deve ser criada e um token JWT retornado

**Payload de Entrada/Requisição**

```json
{
  "usuario": {
    "primeiroNome": "Lucas",
    "ultimoNome": "Benjamin de Araújo Farias A. Costa",
    "documento": {
      "tipo": "CPF",
      "numero": "12345678900"
    },
    "credenciais": {
      "email": "lucas@email.com",
      "senha": "senha@123"
    },
    "contato": {
      "telefone": "81987654321",
      "emailContato": "lucas@email.com"
    },
    "dataNascimento": "1986-04-05T00:00:00Z"
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

**Respostas Possíveis**

* Sucesso: 201 Created + JWT Token
* CPF já cadastrado com outro email: 409 Conflict
* Email já cadastrado com outro CPF: 409 Conflict
* Dados inválidos: 400 Bad Request
* Erro interno: 500 Internal Server Error

**Payload de Resposta de sucesso**
```json
{
  "sucesso": true,
  "mensagem": "Usuário Lucas Benjamin cadastrado com sucesso!",
  "dados": {
    "usuarioId": "a1b2c3d4-e5f6-7890-1234-567890abcdef",
    "nomeCompleto": "Lucas Benjamin de Araújo Farias A. Costa",
    "email": "lucas@email.com",
    "tokenAcesso": "eyJhbGciOiJIUzI1NiIsInR5cCI6..."
  },
  "timestamp": "2025-08-13T21:45:00Z",
  "correlationId": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Payload de Resposta de Erro**
```json
{
  "sucesso": false,
  "mensagem": "Erro ao cadastrar usuário.",
  "erros": [
    {
      "campo": "cpf",
      "mensagem": "CPF já cadastrado."
    },
    {
      "campo": "email",
      "mensagem": "E-mail já cadastrado."
    }
  ],
  "timestamp": "2025-08-13T21:47:00Z",
  "correlationId": "550e8400-e29b-41d4-a716-446655440001"
}
```

**Regras de Negócio:**
* O primeiro nome deve conter apenas letras e ter entre 2 e 50 caracteres.
* O último nome deve conter apenas letras e ter entre 2 e 100 caracteres.
* O CPF deve ser válido e único no sistema.
* O email deve ser válido, único e ter entre 5 e 100 caracteres.
* A senha deve ter pelo menos 8 caracteres, incluindo letras maiúsculas, minúsculas, números e caracteres especiais.
* O telefone deve seguir o formato brasileiro (com DDD).
* A data de nascimento deve ser válida e o usuário deve ter pelo menos 18 anos.
* O logradouro deve conter apenas letras, números e espaços, e ter entre 3 e 100 caracteres.
* O número do endereço deve ser um valor numérico válido.
* A cidade deve conter apenas letras e espaços, e ter entre 2 e 50 caracteres.
* O estado deve ser uma sigla válida de dois caracteres (ex: PE, SP, RJ).
* O CEP deve seguir o formato brasileiro (XXXXX-XXX) e ser válido.
* O sistema deve registrar a data e hora do cadastro do usuário.
* O microserviço de usuários deve solicitar ao microserviço de notificações o envio de email de confirmação após o cadastro, contendo um link para ativação da conta.

----

### Caso de Uso 02 – Consulta de Perfil

**Requisito Funcional: RF002**

**Descrição resumida**
O usuário deve ser capaz de consultar os dados do seu perfil no sistema, incluindo informações pessoais, endereço e configurações da conta.

**Critérios de Aceite (BDD)**

* **Eu como** usuário cadastrado
* **Quero** visualizar meus dados pessoais
* **Quando** eu acessar meu perfil
* **Então** devo ver todas as minhas informações cadastradas

**Payload de Entrada/Requisição**
Não é necessário payload, apenas o token de autenticação no header.

**Respostas Possíveis**
* Sucesso: 200 OK + Dados do perfil
* Não autorizado: 401 Unauthorized
* Usuário não encontrado: 404 Not Found
* Erro interno: 500 Internal Server Error

**Payload de Resposta de sucesso**
```json
{
  "sucesso": true,
  "mensagem": "Perfil consultado com sucesso!",
  "dados": {
    "usuario": {
      "usuarioId": "a1b2c3d4-e5f6-7890-1234-567890abcdef",
      "primeiroNome": "Lucas",
      "ultimoNome": "Benjamin de Araújo Farias A. Costa",
      "documento": {
        "tipo": "CPF",
        "numero": "***456789**"
      },
      "credenciais": {
        "email": "lucas@email.com",
        "perfil": "participante"
      },
      "contato": {
        "telefone": "81987654321",
        "emailContato": "lucas@email.com"
      },
      "dataNascimento": "1986-04-05T00:00:00Z",
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
  "timestamp": "2025-08-13T21:48:00Z",
  "correlationId": "550e8400-e29b-41d4-a716-446655440003"
}
```

**Regras de Negócio:**
* O usuário deve estar autenticado para consultar seu perfil
* O CPF deve ser parcialmente mascarado por questões de segurança
* O sistema deve registrar a data e hora da consulta para fins de auditoria
* Apenas o próprio usuário pode visualizar seus dados completos
* Administradores podem visualizar dados básicos de qualquer usuário

----

### Caso de Uso 03 – Atualização de Perfil

**Requisito Funcional: RF003**

**Descrição resumida**
O usuário deve ser capaz de atualizar os dados pessoais do seu perfil, incluindo nome, telefone, data de nascimento e endereço.
O sistema deve validar as alterações e garantir a integridade dos dados.

**Critérios de Aceite (BDD)**

* **Eu como** usuário logado
* **Quero** alterar meus dados pessoais
* **Quando** eu enviar os novos dados válidos
* **Então** meu perfil deve ser atualizado corretamente

**Payload de Entrada/Requisição**
```json
{
  "usuario": {
    "usuarioId": "a1b2c3d4-e5f6-7890-1234-567890abcdef",
    "primeiroNome": "Lucas",
    "ultimoNome": "Benjamin de Araújo Farias A. Costa",
    "contato": {
      "telefone": "81987654321"
    },
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

**Respostas Possíveis**
* Sucesso: 200 OK
* Dados inválidos: 400 Bad Request
* Erro interno: 500 Internal Server Error

**Payload de Resposta de sucesso**
````json
{
  "sucesso": true,
  "mensagem": "Usuário Lucas Benjamin alterado com sucesso!",
  "dados": {},
  "timestamp": "2025-08-13T21:51:00Z",
  "correlationId": "550e8400-e29b-41d4-a716-446655440008"
}
````
**Payload de Resposta de Erro**
```json
{
  "sucesso": false,
  "mensagem": "Erro ao alterar usuário.",
  "erros": [
    {
      "campo": "telefone",
      "mensagem": "Telefone inválido."
    }
  ],
  "timestamp": "2025-08-13T14:30:00Z",
  "correlationId": "550e8400-e29b-41d4-a716-446655440000"
}
```
**Regras de Negócio**
* O primeiro nome deve conter apenas letras e ter entre 2 e 50 caracteres.
* O último nome deve conter apenas letras e ter entre 2 e 100 caracteres.
* O telefone deve seguir o formato brasileiro (com DDD).
* A data de nascimento deve ser válida e o usuário deve ter pelo menos 18 anos.
* O logradouro deve conter apenas letras, números e espaços, e ter entre 3 e 100 caracteres.
* O número do endereço deve ser um valor numérico válido.
* A cidade deve conter apenas letras e espaços, e ter entre 2 e 50 caracteres.
* O estado deve ser uma sigla válida de dois caracteres (ex: PE, SP, RJ).
* O CEP deve seguir o formato brasileiro (XXXXX-XXX) e ser válido.
* O sistema deve registrar a data e hora da alteração do perfil do usuário.
* O sistema deve enviar um email de notificação ao usuário informando sobre a alteração dos seus dados pessoais.
* O sistema deve garantir que o usuário não possa alterar o seu email ou CPF, apenas os dados pessoais e de contato.

### Caso de Uso 04 – Promoção de Perfil

**Requisito Funcional: RF004**

**Descrição resumida**
O administrador deve ser capaz de promover um usuário a promotor de evento, alterando o seu perfil para "promotor".
O sistema deve validar se o usuário existe e atualizar o seu perfil corretamente.

**Critérios de Aceite**

* **Eu como** administrador
* **Quero** promover um usuário a promotor de evento
* **Quando** eu enviar o ID do usuário e o novo perfil
* **Então** o perfil do usuário deve ser atualizado corretamente

**Payload de Entrada/Requisição**

```json
{
  "usuarioId": "uuid-do-usuario",
  "novoPerfil": "promotor"
}
```
**Respostas Possíveis**
* Sucesso: 200 OK
* Usuário não encontrado: 404 Not Found
* Erro interno: 500 Internal Server Error
* Perfil inválido: 400 Bad Request
* Usuário já é promotor: 409 Conflict
* Usuário inativo: 403 Forbidden
* Usuário excluído: 410 Gone

**Payload de Resposta de sucesso**
```json
{
  "sucesso": true,
  "mensagem": "Usuário promovido a promotor com sucesso!",
  "dados": {},
  "timestamp": "2025-08-13T21:49:00Z",
  "correlationId": "550e8400-e29b-41d4-a716-446655440004"
}
```

**Payload de Resposta de Erro**
```json
{
  "sucesso": false,
  "mensagem": "Erro ao promover usuário.",
  "erros": [
    {
      "campo": "usuarioId",
      "mensagem": "Usuário não encontrado."
    }
  ],
  "timestamp": "2025-08-13T21:49:30Z",
  "correlationId": "550e8400-e29b-41d4-a716-446655440005"
}
```
**Regras de Negócio**
* O usuário deve existir no sistema e estar ativo.
* O novo perfil deve ser "promotor" ou "participante".
* O sistema deve registrar a data e hora da promoção do usuário.
* O sistema deve enviar um email de notificação ao usuário informando sobre a promoção do seu perfil.
* O sistema deve garantir que apenas administradores possam promover usuários.
* O sistema deve verificar se o usuário já é promotor antes de tentar promover novamente.
* O sistema deve garantir que o usuário não possa promover a si mesmo, apenas administradores podem fazer isso.
* O sistema deve registrar logs de auditoria para todas as promoções de usuários.
* O Sistema deve registar o ID do administrador que realizou a promoção.

---

### Caso de Uso 05 – Rebaixar Perfil de Promotor para Participante

**Requisito Funcional: RF005**

**Descrição resumida**
O administrador deve ser capaz de rebaixar um usuário de promotor para participante, alterando o seu perfil.
O sistema deve validar se o usuário existe e atualizar o seu perfil corretamente.

**Critérios de Aceite**
* **Eu como** administrador
* **Quero** rebaixar um promotor para participante
* **Quando** eu enviar o ID do usuário e o novo perfil
* **Então** o perfil do usuário deve ser atualizado corretamente

**Payload de Entrada/Requisição**

```json
{
  "usuarioId": "uuid-do-usuario",
  "novoPerfil": "participante"
}
```
**Respostas Possíveis**
* Sucesso: 200 OK
* Usuário não encontrado: 404 Not Found
* Erro interno: 500 Internal Server Error
* Perfil inválido: 400 Bad Request
* Usuário já é participante: 409 Conflict
* Usuário inativo: 403 Forbidden
* Usuário excluído: 410 Gone

**Payload de Resposta de sucesso**
```json
{
  "sucesso": true,
  "mensagem": "Usuário rebaixado para participante com sucesso!",
  "dados": {},
  "timestamp": "2025-08-13T21:50:00Z",
  "correlationId": "550e8400-e29b-41d4-a716-446655440006"
}
``` 

**Payload de Resposta de Erro**
```json
{
  "sucesso": false,
  "mensagem": "Erro ao rebaixar usuário.",
  "erros": [
    {
      "campo": "usuarioId",
      "mensagem": "Usuário não encontrado."
    }
  ],
  "timestamp": "2025-08-13T21:50:30Z",
  "correlationId": "550e8400-e29b-41d4-a716-446655440007"
}
```

**Regras de Negócio**
* O usuário deve existir no sistema e estar ativo.
* O novo perfil deve ser "participante".
* O sistema deve registrar a data e hora do rebaixamento do usuário.
* O sistema deve enviar um email de notificação ao usuário informando sobre o rebaixamento do seu perfil.
* O sistema deve garantir que apenas administradores possam rebaixar usuários.
* O sistema deve verificar se o usuário já é participante antes de tentar rebaixar novamente.
* O sistema deve garantir que o usuário não possa rebaixar a si mesmo, apenas administradores podem fazer isso.
* O sistema deve registrar logs de auditoria para todas as rebaixamentos de usuários.
* O sistema deve registrar o ID do administrador que realizou o rebaixamento.

### Caso de Uso 06 – Exclusão de Conta

**Requisito Funcional: RF006**

**Descrição resumida**
O usuário deve ser capaz de solicitar a exclusão da sua conta.
O sistema deve marcar a conta como inativa, realizando uma exclusão lógica.

**Critérios de Aceite:**

* **Eu como** usuário logado
* **Quero** excluir minha conta
* **Quando** eu solicitar a exclusão
* **Então** minha conta deve ser marcada como inativa (exclusão lógica)

**Payload de Entrada/Requisição**
```json
{
  "usuarioId": "uuid-do-usuario"
}
```
**Respostas Possíveis**
* Sucesso: 200 OK
* Usuário não encontrado: 404 Not Found
* Erro interno: 500 Internal Server Error
* Conta já inativa: 409 Conflict

**Payload de Resposta de sucesso**
```json
{
  "sucesso": true,
  "mensagem": "Conta excluída com sucesso!"
}
```

**Payload de Resposta de Erro**
```json
{
  "sucesso": false,
  "mensagem": "Erro ao excluir conta.",
  "erros": [
    {
      "campo": "usuarioId",
      "mensagem": "Usuário não encontrado."
    }
  ]
}
```

**Regras de Negócio:**
* O usuário deve existir no sistema e estar ativo.
* O sistema deve registrar a data e hora da solicitação de exclusão.
* O microserviço de usuários deve solicitar ao microserviço de notificações o envio de email de confirmação sobre a exclusão da conta.
* O sistema deve realizar uma exclusão lógica, mantendo os dados do usuário pelo período definido nas políticas de retenção.
* O sistema deve garantir que o usuário não possa realizar login após a exclusão.
* O sistema deve registrar logs de auditoria para todas as solicitações de exclusão de contas.
* O sistema deve registrar o ID do usuário que solicitou a exclusão e o motivo, se fornecido.
* A exclusão é definitiva e não pode ser revertida.

----


## Convenções e Padrões Específicos do Módulo de Usuários

> **Nota**: Para convenções e padrões comuns do sistema (estrutura de respostas, headers padrão básicos, formato de timestamps, IDs de correlação), consulte o documento de Autenticação.

### 1. Modelo de Dados do Usuário
```json
{
  "usuario": {
    "usuarioId": "UUID",
    "primeiroNome": "string",
    "ultimoNome": "string",
    "documento": {
      "tipo": "CPF",
      "numero": "string"
    },
    "credenciais": {
      "email": "string",
      "perfil": "enum(participante, promotor, admin)"
    },
    "contato": {
      "telefone": "string",
      "emailContato": "string"
    },
    "dataNascimento": "ISO-8601",
    "dataCadastro": "ISO-8601",
    "dataUltimaAtualizacao": "ISO-8601",
    "status": "enum(ativo, inativo, bloqueado, excluido)"
  },
  "endereco": {
    "logradouro": "string",
    "numero": "string",
    "complemento": "string",
    "cidade": "string",
    "estado": "string",
    "cep": "string"
  }
}
```
### 2. Validações de Dados

#### 2.1 Dados Pessoais
- **Nome**: 2-50 caracteres, apenas letras e espaços
- **CPF**: Formato válido com dígitos verificadores
- **Email**: RFC 5322, máximo 100 caracteres
- **Telefone**: Formato BR (+55 XX XXXXX-XXXX)
- **Data de Nascimento**: ISO-8601, mínimo 18 anos

#### 2.2 Endereço
- **CEP**: Formato BR (XXXXX-XXX)
- **Estado**: Siglas válidas BR (2 caracteres)
- **Cidade**: 2-50 caracteres, apenas letras e espaços
- **Logradouro**: 3-100 caracteres
- **Número**: Valor numérico válido

### 3. Controle de Acesso

#### 3.1 Perfis de Usuário
- **Participante**: Acesso básico (padrão)
- **Promotor**: Pode criar e gerenciar eventos
- **Admin**: Acesso total ao sistema

#### 3.2 Operações por Perfil
- **Participante**: Leitura e atualização do próprio perfil
- **Promotor**: Mesmo que participante + criar eventos
- **Admin**: Todas as operações, incluindo gestão de usuários

### 4. Políticas de Dados e Segurança

#### 4.1 Auditoria
- Registro detalhado de todas as alterações em dados pessoais
- Histórico completo de mudanças de perfil (promoção/rebaixamento)
- Log de alterações de status da conta

#### 4.2 Privacidade e Retenção
- Mascaramento de CPF em respostas públicas
- Retenção de dados pessoais por 5 anos após exclusão da conta
- Logs de auditoria retidos por 1 ano
- Exportação de dados pessoais sob demanda (LGPD)
- Backup diário incremental dos dados de usuários

#### 4.3 Rate Limits Específicos
> Complementares aos limites globais definidos no módulo de Autenticação
- Alteração de dados pessoais: 10 por usuário/hora
- Operações administrativas em perfis: 50 por admin/hora
