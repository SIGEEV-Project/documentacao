# Especificação de Requisitos com Critérios de Aceite (SIGEEV)

---

## 1. Módulo de Usuários e Autenticação

### Caso de Uso 01 – Cadastro de Usuário

**Descrição resumida**

O usuário deve ser capaz de se registrar no sistema fornecendo os seus dados pessoais. O sistema deve validar a unicidade do CPF e do email, retornando um token JWT para autenticação.

**Requisito Funcional: RF001**

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
  }
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

  ]
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
* O sistema deve enviar um email de confirmação após o cadastro, contendo um link para ativação da conta.
* O sistema deve registrar a data e hora do cadastro do usuário.

----

### Caso de Uso 02 – Login de Usuário

**Requisito Funcional: RF002**

**Descrição resumida**
O usuário deve ser capaz de fazer login no sistema utilizando o seu email e senha.
O sistema deve validar as credenciais e retornar um token JWT para autenticação.

**Critérios de Aceite**

* **Eu como** usuário registrado e ativo
* **Quero** fazer login com meu email e senha
* **Quando** as credenciais forem válidas
* **Então** devo receber um token JWT de autenticação

**Payload de Entrada/Requisição**

```json
{
  "email": "lucas@email.com",
  "senha": "Senha@123"
}
```
***Respostas Possíveis**
* Sucesso: 200 OK + JWT Token
* Email ou senha inválidos: 401 Unauthorized
* Conta inativa: 403 Forbidden
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
    "expiraEm": 3600
  }
}
```
***Payload de Resposta de Erro**

```json
{
  "sucesso": false,
  "mensagem": "Erro ao fazer login.",
  "erros": [
    {
      "campo": "email",
      "mensagem": "Email ou senha inválidos."
    }
  ]
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

-----

### Caso de Uso 02.1 – Renovação de Token (Refresh Token)

**Requisito Funcional: RF002.1**

**Descrição resumida**
O usuário deve ser capaz de renovar o seu token de autenticação sem precisar fazer login novamente, utilizando um refresh token. O sistema deve validar o refresh token e, se for válido, gerar um novo token de acesso e um novo refresh token.

**Critérios de Aceite (BDD)**

* **Eu como** usuário logado
* **Quero** renovar o meu token de autenticação
* **Quando** eu enviar um refresh token válido e não expirado
* **Então** devo receber um novo token de acesso e um novo refresh token
* **E** o token de acesso antigo e o refresh token antigo devem ser invalidados

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
    "refreshToken": "novo_refresh_token",
    "expiraEm": 3600
  }
}
```

**Payload de Resposta de Erro**

```json
{
  "sucesso": false,
  "mensagem": "Sessão expirada. Por favor, faça login novamente."
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

### Caso de uso 03 - Alteração de Perfil

**Requisito Funcional: RF003**

**Descrição resumida**
O usuário deve ser capaz de alterar os dados pessoais do seu perfil tais como:nome, telefone, data de nascimento e endereço.
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
  "mensagem": "Usuário Lucas Benjamin alterado com sucesso!"
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
  ]
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
  "mensagem": "Usuário promovido a promotor com sucesso!"
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
  ]
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
  "mensagem": "Usuário rebaixado para participante com sucesso!"
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
  ]
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
* O sistema deve enviar um email de confirmação ao usuário informando sobre a exclusão da conta.
* O sistema deve garantir que a exclusão seja lógica, mantendo os dados do usuário para fins de auditoria.
* O sistema deve garantir que o usuário não possa realizar login após a exclusão.
* O sistema deve registrar logs de auditoria para todas as solicitações de exclusão de contas.
* O sistema deve permitir que o usuário reative a conta dentro de um período de 30 dias após a exclusão, caso deseje voltar a utilizar o sistema.
* O sistema deve registrar o ID do usuário que solicitou a exclusão e o motivo, se fornecido.

----

### Caso de Uso 07 – Trocar Senha

**Requisito Funcional: RF007**

**Descrição resumida**
O usuário deve ser capaz de trocar a sua senha atual por uma nova.
O sistema deve validar a senha atual e garantir que a nova senha atenda aos critérios de segurança

**Critérios de Aceite:**
* **Eu como** usuário logado
* **Quero** trocar minha senha
* **Quando** eu enviar a senha atual e a nova senha
* **Então** minha senha deve ser atualizada se a senha atual for válida

**Payload de Entrada/Requisição**
```json
{
  "usuarioId": "uuid-do-usuario",
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
  ]
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

### Caso de Uso 08 – Esqueci miha Senha

**Requisito Funcional: RF008**

**Descrição resumida**
O usuário deve ser capaz de solicitar a recuperação da senha caso tenha esquecido.
O sistema deve enviar um email com um link para redefinir a senha.

**Critérios de Aceite:**
* **Eu como** usuário que esqueceu a senha
* **Quero** solicitar a recuperação da senha
* **Quando** eu enviar meu email cadastrado
* **Então** devo receber um email com instruções para redefinir minha senha
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
  ]
}
```

**Regras de Negócio:**
* O email deve ser válido e cadastrado no sistema.
* O sistema deve gerar um token de recuperação com validade de 1 hora.
* O sistema deve enviar um email com um link contendo o token de recuperação.
* O link deve direcionar o usuário para uma página onde ele pode definir uma nova senha.
* O sistema deve garantir que o token de recuperação não possa ser reutilizado após a troca de senha.
* O sistema deve registrar logs de auditoria para todas as solicitações de recuperação de senha.

----

## 2. Módulo de Eventos

### Caso de Uso 09 – Criação de Evento

**Requisito Funcional: RF009**

**Descrição resumida**
O promotor deve ser capaz de criar um evento, fornecendo informações como título, descrição, data, local, capacidade e preço.
O sistema deve validar os dados e salvar o evento com status "ativo".

**Critérios de Aceite:**
* **Eu como** promotor de evento
* **Quero** cadastrar um novo evento
* **Quando** preencher o formulário corretamente
* **Então** o evento deve ser salvo com status "ativo"
* **E** o evento deve ser visível na lista de eventos abertos

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
* Sucesso: 201 Created + Detalhes do evento
* Dados inválidos: 400 Bad Request
* Erro interno: 500 Internal Server Error

**Payload de Resposta de sucesso**
```json
{
  "sucesso": true,
  "mensagem": "Evento criado com sucesso!",
  "dados": {
    "eventoId": "uuid-do-evento",
    "titulo": "Workshop de Segurança",
    "descricao": "Evento sobre boas práticas de segurança",
    "dataInicio": "2025-10-01T09:00:00",
    "dataFim": "2025-10-01T18:00:00",
    "local": "Recife - PE",
    "capacidade": 100,
    "preco": 50.0,
    "bannerUrl": "https://s3.aws.com/banner.jpg",
    "status": "ativo"
  }
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
  ]
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
O sistema deve retornar os eventos com resumo (título, data, local e banner).

**Critérios de Aceite:**
* **Eu como** qualquer usuário
* **Quero** ver a lista de eventos abertos
* **Quando** acessar a página inicial
* **Então** devo receber os eventos com resumo (título, data, local e banner)
* **E** os eventos devem estar ordenados por data de início
* **E** os eventos com vagas esgotadas devem ser exibidos, mas com aviso de esgotado

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
  "dados": [
    {
      "eventoId": "uuid-do-evento-1",
      "titulo": "Workshop de Segurança",
      "dataInicio": "2025-10-01T09:00:00",
      "dataFim": "2025-10-01T18:00:00",
      "local": "Recife - PE",
      "bannerUrl": "https://s3.aws.com/banner.jpg",
      "vagasRestantes": 50,
      "status": "ativo"
    },
    {
      "eventoId": "uuid-do-evento-2",
      "titulo": "Palestra sobre Tecnologia",
      "dataInicio": "2025-11-15T14:00:00",
      "dataFim": "2025-11-15T16:00:00",
      "local": "São Paulo - SP",
      "bannerUrl": null,
      "vagasRestantes": 0,
      "status": "esgotado"
    }
  ]
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
  ]
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
O sistema deve retornar os eventos que atendem aos critérios de filtro.

**Critérios de Aceite:**
* **Eu como** usuário
* **Quero** filtrar a lista de eventos
* **Quando** eu enviar os critérios de filtro
* **Então** devo receber apenas os eventos que atendem aos critérios
* **E** os eventos devem estar ordenados por data de início

**Payload de Entrada/Requisição**
```json
{
  "filtros": {
    "dataInicio": "2025-10-01",
    "dataFim": "2025-12-31",
    "local": "Recife",
    "palavraChave": "segurança"
  }
}
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
  "dados": [
    {
      "eventoId": "uuid-do-evento-1",
      "titulo": "Workshop de Segurança",
      "dataInicio": "2025-10-01T09:00:00",
      "dataFim": "2025-10-01T18:00:00",
      "local": "Recife - PE",
      "bannerUrl": "https://s3.aws.com/banner.jpg",
      "vagasRestantes": 50,
      "status": "ativo"
    }
  ]
}
```

**Payload de Resposta de Erro**
```json
{
  "sucesso": false,
  "mensagem": "Erro ao filtrar eventos.",
  "erros": [
    {
      "campo": "sistema",
      "mensagem": "Erro interno do servidor."
    }
  ]
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

**Critérios de Aceite:**
* **Eu como** usuário
* **Quero** ver os detalhes de um evento
* **Quando** eu solicitar os detalhes do evento
* **Então** devo receber todas as informações do evento
* **E** o evento deve estar ativo ou esgotado

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
    "eventoId": "uuid-do-evento",
    "titulo": "Workshop de Segurança",
    "descricao": "Evento sobre boas práticas de segurança",
    "dataInicio": "2025-10-01T09:00:00",
    "dataFim": "2025-10-01T18:00:00",
    "local": "Recife - PE",
    "capacidade": 100,
    "preco": 50.0,
    "bannerUrl": "https://s3.aws.com/banner.jpg",
    "status": "ativo"
  }
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
  ]
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

**Critérios de Aceite:**
* **Eu como** promotor de evento
* **Quero** editar um evento existente
* **Quando** eu enviar as novas informações do evento
* **Então** o evento deve ser atualizado com sucesso
* **E** o evento deve continuar ativo ou ser marcado como esgotado se não houver vagas restantes

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
    "eventoId": "uuid-do-evento",
    "titulo": "Workshop de Segurança Avançado",
    "descricao": "Evento sobre boas práticas avançadas de segurança",
    "dataInicio": "2025-10-01T09:00:00",
    "dataFim": "2025-10-01T18:00:00",
    "local": "Recife - PE",
    "capacidade": 50,
    "preco": 75.0,
    "bannerUrl": "https://s3.aws.com/banner-novo.jpg",
    "status": "ativo"
  }
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
      "mensagem": "Capacidade deve ser maior que zero."
    }
  ]
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

**Critérios de Aceite:**
* **Eu como** promotor de evento
* **Quero** excluir um evento existente
* **Quando** eu solicitar a exclusão do evento
* **Então** o evento deve ser marcado como inativo (exclusão lógica)


**Payload de Entrada/Requisição**
```json
{
  "eventoId": "uuid-do-evento"
}
```

**Respostas Possíveis**
* Sucesso: 200 OK
* Evento não encontrado: 404 Not Found
* Erro interno: 500 Internal Server Error
* Evento já inativo: 409 Conflict

**Payload de Resposta de sucesso**
```json
{
  "sucesso": true,
  "mensagem": "Evento excluído com sucesso!"
}
```

**Payload de Resposta de Erro**
```json
{
  "sucesso": false,
  "mensagem": "Erro ao excluir evento.",
  "erros": [
    {
      "campo": "eventoId",
      "mensagem": "Evento não encontrado."
    }
  ]
}
```

**Regras de Negócio:**
* O evento deve existir no sistema e estar ativo.
* O sistema deve registrar a data e hora da solicitação de exclusão.
* O sistema deve enviar um email de confirmação ao promotor informando sobre a exclusão do evento.
* O sistema deve garantir que a exclusão seja lógica, mantendo os dados do evento para fins de auditoria.
* O sistema deve garantir que o promotor não possa excluir eventos que já estejam inativos.
* O sistema deve registrar logs de auditoria para todas as solicitações de exclusão de eventos.
* O sistema deve garantir que apenas o promotor do evento possa excluí-lo.

----

## 3. Módulo de Inscrições

### Caso de Uso 15 – Inscrição em Evento

**Requisito Funcional: RF015**

**Descrição resumida**
O usuário deve ser capaz de se inscrever em um evento.
O sistema deve validar se o evento está ativo, se há vagas disponíveis e se o usuário não está inscrito no evento.
Se a inscrição for bem-sucedida, o sistema deve atualizar o número de vagas restantes e enviar um email de confirmação ao usuário.

**Critérios de Aceite:**
* **Eu como** usuário registrado
* **Quero** me inscrever em um evento
* **Quando** eu enviar o ID do evento
* **Então** devo ser inscrito no evento se houver vagas disponíveis
* **E** o número de vagas restantes deve ser atualizado
* **E** devo receber um email de confirmação da inscrição

**Payload de Entrada/Requisição**
```json
{
  "usuarioId": "uuid-do-usuario",
  "eventoId": "uuid-do-evento"
}
```

**Respostas Possíveis**
* Sucesso: 201 Created + Detalhes da inscrição
* Evento não encontrado: 404 Not Found
* Evento inativo: 403 Forbidden
* Vagas esgotadas: 409 Conflict
* Usuário já inscrito: 409 Conflict
* Erro interno: 500 Internal Server Error

**Payload de Resposta de sucesso**
```json
{
  "sucesso": true,
  "mensagem": "Inscrição realizada com sucesso!",
  "dados": {
    "inscricaoId": "uuid-da-inscricao",
    "usuarioId": "uuid-do-usuario",
    "eventoId": "uuid-do-evento",
    "dataInscricao": "2025-09-01T10:00:00",
    "status": "ativo"
  }
}
```

**Payload de Resposta de Erro**
```json
{
  "sucesso": false,
  "mensagem": "Erro ao realizar inscrição.",
  "erros": [
    {
      "campo": "eventoId",
      "mensagem": "Evento não encontrado ou inativo."
    },
    {
      "campo": "vagas",
      "mensagem": "Vagas esgotadas para este evento."
    },
    {
      "campo": "usuarioId",
      "mensagem": "Usuário já inscrito neste evento."
    }
  ]
}
```

**Regras de Negócio:**
* O evento deve existir no sistema e estar ativo.
* O evento deve ter vagas disponíveis (capacidade > número de inscrições).
* O usuário deve estar registrado e ativo no sistema.
* O usuário não pode estar inscrito no mesmo evento mais de uma vez.
* O sistema deve atualizar o número de vagas restantes do evento após a inscrição.
* O sistema deve enviar um email de confirmação ao usuário informando sobre a inscrição no evento.
* O sistema deve registrar logs de auditoria para todas as inscrições em eventos.
* O sistema deve garantir que apenas usuários registrados possam se inscrever em eventos.

----

### Caso de Uso 16 – Listagem de Minhas Inscrições

**Requisito Funcional: RF016**

**Descrição resumida**
O usuário deve ser capaz de visualizar a lista de suas inscrições em eventos.
O sistema deve retornar os eventos nos quais o usuário está inscrito, com detalhes como título, data, local e status da inscrição.

**Critérios de Aceite:**
* **Eu como** usuário registrado
* **Quero** ver minhas inscrições em eventos
* **Quando** eu solicitar a lista de minhas inscrições
* **Então** devo receber os eventos nos quais estou inscrito
* **E** os eventos devem estar ordenados por data de início

**Payload de Entrada/Requisição**
* Não há payload necessário para esta requisição, apenas uma chamada GET para a rota de inscrições

**Respostas Possíveis**
* Sucesso: 200 OK + Lista de inscrições
* Nenhuma inscrição encontrada: 204 No Content
* Erro interno: 500 Internal Server Error

**Payload de Resposta de sucesso**
```json
{
  "sucesso": true,
  "mensagem": "Lista de inscrições recuperada com sucesso!",
  "dados": [
    {
      "inscricaoId": "uuid-da-inscricao-1",
      "eventoId": "uuid-do-evento-1",
      "titulo": "Workshop de Segurança",
      "dataInicio": "2025-10-01T09:00:00",
      "dataFim": "2025-10-01T18:00:00",
      "local": "Recife - PE",
      "statusInscricao": "ativo"
    },
    {
      "inscricaoId": "uuid-da-inscricao-2",
      "eventoId": "uuid-do-evento-2",
      "titulo": "Palestra sobre Tecnologia",
      "dataInicio": "2025-11-15T14:00:00",
      "dataFim": "2025-11-15T16:00:00",
      "local": "São Paulo - SP",
      "statusInscricao": "ativo"
    }
  ]
}
```

**Payload de Resposta de Erro**
```json
{
  "sucesso": false,
  "mensagem": "Erro ao recuperar inscrições.",
  "erros": [
    {
      "campo": "sistema",
      "mensagem": "Erro interno do servidor."
    }
  ]
}
```

**Regras de Negócio:**
* O usuário deve estar registrado e ativo no sistema.
* O sistema deve retornar todas as inscrições ativas do usuário.
* As inscrições devem ser ordenadas por data de início do evento, do mais próximo para o mais distante.
* O sistema deve retornar detalhes do evento, incluindo título, data de início, data de fim, local e status da inscrição.
* O sistema deve registrar a data e hora da solicitação de listagem de inscrições.
* O sistema deve garantir que apenas o usuário inscrito possa visualizar suas próprias inscrições.

----

### Caso de Uso 17 – Cancelamento de Inscrição

**Requisito Funcional: RF017**

**Descrição resumida**
O usuário deve ser capaz de cancelar sua inscrição em um evento.
O sistema deve validar se o usuário está inscrito no evento e, se estiver, marcar a inscrição como cancelada.
O sistema deve atualizar o número de vagas restantes do evento e enviar um email de confirmação ao usuário.

**Critérios de Aceite:**
* **Eu como** usuário inscrito em um evento
* **Quero** cancelar minha inscrição
* **Quando** eu solicitar o cancelamento da minha inscrição
* **Então** minha inscrição deve ser cancelada se eu estiver inscrito
* **E** o número de vagas restantes do evento deve ser atualizado
* **E** devo receber um email de confirmação do cancelamento

**Payload de Entrada/Requisição**
```json
{
  "usuarioId": "uuid-do-usuario",
  "inscricaoId": "uuid-da-inscricao"
}
```

**Respostas Possíveis**
* Sucesso: 200 OK + Detalhes da inscrição cancelada
* Inscrição não encontrada: 404 Not Found
* Usuário não inscrito no evento: 403 Forbidden
* Erro interno: 500 Internal Server Error

**Payload de Resposta de sucesso**
```json
{
  "sucesso": true,
  "mensagem": "Inscrição cancelada com sucesso!",
  "dados": {
    "inscricaoId": "uuid-da-inscricao",
    "usuarioId": "uuid-do-usuario",
    "eventoId": "uuid-do-evento",
    "dataCancelamento": "2025-09-01T10:00:00",
    "status": "cancelada"
  }
}
```

**Payload de Resposta de Erro**
```json
{
  "sucesso": false,
  "mensagem": "Erro ao cancelar inscrição.",
  "erros": [
    {
      "campo": "inscricaoId",
      "mensagem": "Inscrição não encontrada ou já cancelada."
    },
    {
      "campo": "usuarioId",
      "mensagem": "Usuário não está inscrito neste evento."
    }
  ]
}
```

**Regras de Negócio:**
* O usuário deve estar inscrito no evento para poder cancelá-lo.
* O sistema deve atualizar o número de vagas restantes do evento após o cancelamento da inscrição.
* O sistema deve enviar um email de confirmação ao usuário informando sobre o cancelamento da inscrição.
* O sistema deve garantir que apenas o usuário inscrito possa cancelar sua própria inscrição.
* O sistema deve registrar logs de auditoria para todas as solicitações de cancelamento de inscrições
* O sistema deve garantir que a inscrição não possa ser cancelada se já estiver cancelada ou se o evento já tiver ocorrido.

----

### Caso de Uso 18 – Listagem de Inscrições por Evento

**Requisito Funcional: RF018**

**Descrição resumida**
O promotor deve ser capaz de visualizar a lista de inscrições em um evento específico.
O sistema deve retornar os usuários inscritos no evento, com detalhes como nome, email e status da inscrição.

**Critérios de Aceite:**
* **Eu como** promotor de evento
* **Quero** ver as inscrições de um evento
* **Quando** eu solicitar a lista de inscrições do evento
* **Então** devo receber os usuários inscritos no evento
* **E** os usuários devem estar ordenados por data de inscrição

**Payload de Entrada/Requisição**
```json
{
  "eventoId": "uuid-do-evento"
}
```

**Respostas Possíveis**
* Sucesso: 200 OK + Lista de inscrições
* Evento não encontrado: 404 Not Found
* Evento inativo: 403 Forbidden
* Nenhuma inscrição encontrada: 204 No Content
* Erro interno: 500 Internal Server Error

**Payload de Resposta de sucesso**
```json
[
  {
    "inscricaoId": "inscricao-uuid-1",
    "usuarioId": "usuario-uuid-1",
    "nomeCompleto": "João da Silva",
    "email": "joao.silva@email.com",
    "dataInscricao": "2025-10-10T10:00:00Z",
    "statusInscricao": "confirmada"
  },
  {
    "inscricaoId": "inscricao-uuid-2",
    "usuarioId": "usuario-uuid-2",
    "nomeCompleto": "Maria de Souza",
    "email": "maria.souza@email.com",
    "dataInscricao": "2025-10-10T10:15:00Z",
    "statusInscricao": "pendente"
  },
  {
    "inscricaoId": "inscricao-uuid-3",
    "usuarioId": "usuario-uuid-3",
    "nomeCompleto": "Pedro Santos",
    "email": "pedro.santos@email.com",
    "dataInscricao": "2025-10-11T09:30:00Z",
    "statusInscricao": "confirmada"
  }
]


````

**Payload de Resposta de Erro**
```json
{
  "sucesso": false,
  "mensagem": "Erro ao recuperar inscrições do evento.",
  "erros": [
    {
      "campo": "eventoId",
      "mensagem": "Evento não encontrado ou inativo."
    }
  ]
}
```

**Regras de Negócio:**
* O evento deve existir no sistema e estar ativo.
* O sistema deve retornar todas as inscrições ativas do evento.
* As inscrições devem ser ordenadas por data de inscrição, do mais recente para o mais antigo.
* O sistema deve retornar detalhes do usuário, incluindo nome completo, email, data da inscrição e status da inscrição.
* O sistema deve registrar a data e hora da solicitação de listagem de inscrições do evento.
* O sistema deve garantir que apenas o promotor do evento possa visualizar as inscrições.

---- 





