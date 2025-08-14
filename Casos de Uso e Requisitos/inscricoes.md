
# Especificação de Requisitos (SIGEEV)

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