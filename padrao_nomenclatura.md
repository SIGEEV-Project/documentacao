# Padrão de Nomenclatura - SIGEEV

## Objetivo
Este documento estabelece os padrões de nomenclatura a serem seguidos em toda a documentação do SIGEEV, garantindo consistência e clareza.

## Entidades Principais

### Usuário
- **usuarioId**: Identificador único do usuário (UUID)
- **primeiroNome**: Primeiro nome do usuário
- **ultimoNome**: Último nome do usuário
- **email**: Email principal do usuário (usado para login)
- **cpf**: Documento CPF do usuário (formato: apenas números)
- **telefone**: Telefone de contato (formato: +55 XX XXXXX-XXXX)
- **dataNascimento**: Data de nascimento (formato ISO-8601)
- **perfil**: Tipo de perfil do usuário (`participante`, `promotor`, `administrador`)
- **status**: Status da conta (`ativo`, `inativo`, `bloqueado`, `excluido`)
- **dataCadastro**: Data de criação da conta (formato ISO-8601)
- **dataUltimaAtualizacao**: Data da última atualização do perfil (formato ISO-8601)

### Evento
- **eventoId**: Identificador único do evento (UUID)
- **promotorId**: Identificador do usuário promotor (UUID)
- **titulo**: Título do evento
- **descricao**: Descrição detalhada do evento
- **dataInicio**: Data e hora de início (formato ISO-8601)
- **dataFim**: Data e hora de término (formato ISO-8601)
- **local**: Local do evento
- **capacidade**: Número máximo de participantes
- **vagasRestantes**: Número de vagas ainda disponíveis
- **bannerUrl**: URL da imagem de banner
- **status**: Status do evento (`rascunho`, `ativo`, `esgotado`, `inativo`)
- **dataCriacao**: Data de criação do evento (formato ISO-8601)

### Inscrição
- **inscricaoId**: Identificador único da inscrição (UUID)
- **usuarioId**: Identificador do usuário inscrito (UUID)
- **eventoId**: Identificador do evento (UUID)
- **precoId**: Identificador do preço selecionado (UUID)
- **dataInscricao**: Data da inscrição (formato ISO-8601)
- **dataCancelamento**: Data de cancelamento, se houver (formato ISO-8601)
- **status**: Status da inscrição (`ativo`, `cancelada`, `pendente`, `expirada`)

### Autenticação
- **accessToken**: Token JWT de acesso
- **refreshToken**: Token de atualização
- **expiresIn**: Tempo de expiração em segundos
- **tokenType**: Tipo de token (sempre "Bearer")

## Convenções Gerais

### Formato de Datas
- Todas as datas devem usar o formato ISO-8601: `YYYY-MM-DDTHH:mm:ssZ`
- Todas as datas devem ser armazenadas e transmitidas em UTC

### Identificadores
- Todos os identificadores únicos devem ser UUID v4
- Nomes de identificadores devem seguir o padrão `entidadeId` (ex: usuarioId, eventoId)

### Nomenclatura de Campos
- Usar camelCase para todos os campos
- Nomes devem ser em português
- Evitar abreviações, exceto quando amplamente reconhecidas (ex: CPF)

### Enumerações
- Valores de enumerações devem ser em minúsculas
- Usar substantivos para status (ex: `ativo`, `inativo`)
- Usar verbos no infinitivo para ações (ex: `criar`, `atualizar`)

### Códigos de Erro
- Códigos HTTP padrão para erros comuns
- Mensagens de erro devem ser claras e específicas
- Incluir sempre o campo afetado quando aplicável

### Versionamento
- APIs devem ser versionadas usando prefixo no path (ex: `/v1/usuarios`)
- Documentação deve indicar claramente a versão atual

## Padrões Específicos por Módulo

### Módulo de Usuários
- Operações sobre o próprio usuário devem usar o endpoint `/me` (ex: `/usuarios/me`)
- Operações administrativas devem usar o ID explícito (ex: `/usuarios/{id}/promover`)

### Módulo de Eventos
- Listagem pública usa GET `/eventos`
- Listagem do promotor usa GET `/eventos/me`
- Filtros complexos usam POST `/eventos/filtrar`

### Módulo de Inscrições
- Inscrições do usuário atual usam GET `/inscricoes/me`
- Inscrições de um evento usam GET `/eventos/{id}/inscricoes`

### Módulo de Autenticação
- Endpoints de autenticação usam o prefixo `/auth`
- Operações de senha usam o prefixo `/auth/password`