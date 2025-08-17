
# Especificação de Requisitos - Módulo de Eventos (SIGEEV)

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