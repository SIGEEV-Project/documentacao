
### **Requisitos do BFF (Backend for Frontend)**

O BFF deve atuar como uma camada intermediária entre o front-end e o backend principal, otimizando a comunicação e garantindo a segurança e a consistência dos dados.

#### **1. Autenticação e Autorização**

* **RF-BFF-001 - Gerenciamento de Autenticação:**
    * **Descrição:** O BFF deve interceptar as requisições de login (`/login`) e cadastro (`/cadastro`) do frontend. Após a validação do backend, o BFF deve ser responsável por gerenciar o ciclo de vida dos tokens de autenticação (JWT) e refresh tokens.
    * **Critério de Aceite:**
        * **Quando** o frontend enviar as credenciais, **então** o BFF deve repassar para o backend.
        * **Quando** o backend retornar os tokens, **então** o BFF deve enviá-los ao frontend no corpo da resposta.
        * **Quando** o frontend enviar um `refreshToken` expirado, **então** o BFF deve retornar um erro `401 Unauthorized`.
* **RF-BFF-002 - Validação de Autorização:**
    * **Descrição:** O BFF deve verificar se o usuário autenticado possui as permissões necessárias para acessar determinados endpoints antes de encaminhar a requisição para o backend.
    * **Critério de Aceite:**
        * **Quando** um usuário com perfil `"participante"` tentar acessar um endpoint de promotor (ex: `/eventos/{id}/inscricoes`), **então** o BFF deve retornar um erro `403 Forbidden` sem consultar o backend.
        * **Quando** um usuário com perfil `"administrador"` tentar acessar um endpoint de promotor ou usuário comum, **então** o BFF deve permitir a requisição.

---

#### **2. Agregação e Transformação de Dados**

* **RF-BFF-003 - Listagem de Eventos e Vagas:**
    * **Descrição:** O BFF deve consolidar a lógica de cálculo de vagas restantes para a listagem de eventos. Em vez do backend ter que calcular isso em cada requisição, o BFF pode pegar a capacidade total do evento e o número de inscrições do backend e calcular as vagas restantes antes de enviar a resposta para o frontend.
    * **Critério de Aceite:**
        * **Quando** o frontend solicitar a listagem de eventos, **então** o BFF deve retornar um único payload com os dados consolidados, incluindo `vagasRestantes` e `status` (ativo ou esgotado).
* **RF-BFF-004 - Payload de Detalhes do Evento:**
    * **Descrição:** O BFF deve agregar os dados de um evento específico e de suas respectivas inscrições.
    * **Critério de Aceite:**
        * **Quando** o promotor de evento solicitar os detalhes de um evento, **então** o BFF deve chamar o endpoint de detalhes do evento e, em seguida, o endpoint de inscrições desse mesmo evento, consolidando a resposta em um único payload para o frontend.

---

#### **3. Validação e Segurança de Entrada**

* **RF-BFF-005 - Pré-validação de Dados:**
    * **Descrição:** O BFF deve ser a primeira linha de defesa, validando formatos básicos de dados (e-mail, CPF, UUIDs) antes de encaminhar a requisição para o backend.
    * **Critério de Aceite:**
        * **Quando** o frontend enviar um e-mail com formato inválido (`"lucas.email.com"`), **então** o BFF deve retornar um `400 Bad Request` antes de contatar o backend.
* **RF-BFF-006 - Sanitização de Dados:**
    * **Descrição:** O BFF deve sanitizar os campos de entrada para prevenir ataques como XSS.
    * **Critério de Aceite:**
        * **Quando** o frontend enviar um payload com tags HTML em campos de texto (ex: `"<script>alert('xss')</script>"`), **então** o BFF deve remover ou escapar essas tags antes de enviar para o backend.

---

#### **4. Otimização de Performance**

* **RF-BFF-007 - Cache de Listagem de Eventos:**
    * **Descrição:** O BFF deve implementar um cache de dados para a listagem de eventos abertos (`RF010`) para reduzir a carga no backend e acelerar a resposta para o frontend.
    * **Critério de Aceite:**
        * **Quando** a primeira requisição para a listagem de eventos for feita, **então** o BFF deve armazenar a resposta em cache por um período de tempo configurável (ex: 5 minutos).
        * **Quando** requisições subsequentes chegarem dentro desse período, **então** o BFF deve retornar a resposta do cache.


* **RF-BFF-008 - Limitação de Taxa (Rate Limiting):**
    * **Descrição:** O BFF deve implementar uma limitação de taxa para proteger os endpoints de requisições excessivas, especialmente para endpoints críticos como login e listagem de eventos.
    * **Critério de Aceite:**
        * **Quando** um usuário fizer mais de 10 requisições em 1 minuto, **então** o BFF deve retornar um erro `429 Too Many Requests` e bloquear novas requisições por um período de tempo configurável (ex: 1 minuto).
          * **Quando** o usuário tentar novamente após o período de bloqueio, **então** o BFF deve permitir novas requisições.
