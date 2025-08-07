### **Arquitetura de Solução (SIGEEV)**

A solução proposta é baseada em uma arquitetura de **Microserviços**, orquestrada por uma camada de **BFF (Backend for Frontend)** e seguindo a arquitetura **Hexagonal** em cada serviço. Isso garante o desacoplamento, a escalabilidade e a resiliência do sistema.

#### **1. Camadas da Arquitetura**

A solução será dividida em três camadas principais, cada uma com responsabilidades bem definidas:

1.  **Frontend**: A interface do usuário, responsável pela experiência e interação. Ele se comunica exclusivamente com o BFF.

2.  **BFF (Backend for Frontend)**: Atua como uma camada de API Gateway otimizado para o frontend. Suas responsabilidades incluem:
    * **Agregação de Dados**: Consolida múltiplas chamadas de microserviços em uma única requisição.
    * **Validação Inicial**: Realiza validações básicas de formato e campos obrigatórios para proteger os microserviços.
    * **Gerenciamento de Tokens**: Autentica o usuário e gerencia o ciclo de vida dos tokens de acesso e refresh tokens, abstraindo essa complexidade do frontend.
    * **Adaptação de Payloads**: Transforma os payloads para o formato ideal do frontend, como na listagem de eventos.

3.  **Microserviços (Backend)**: São os serviços independentes que contêm a lógica de negócio principal. Cada serviço segue a arquitetura **Hexagonal** para garantir o desacoplamento e a testabilidade.
    * **Serviço de Usuários**: Responsável por todo o ciclo de vida do usuário: cadastro, login, perfil e segurança (incluindo gerenciamento de senhas e histórico de promoções).
    * **Serviço de Eventos**: Gerencia a criação, edição, listagem e exclusão de eventos, incluindo seus preços e capacidade.
    * **Serviço de Inscrições**: Gerencia a inscrição dos usuários em eventos, garantindo a atomicidade das operações (diminuição de vagas) e o registro das inscrições.
    * **Serviço de Notificações**: (Futura expansão) Encarregado de enviar e-mails de recuperação de senha ou confirmação de inscrição.

#### **2. Fluxo de Comunicação**

O fluxo de comunicação segue uma rota bem definida, garantindo a separação de responsabilidades:

1.  **Requisição do Frontend**: O usuário interage com a interface. Uma requisição de login, por exemplo, é enviada para o BFF.
2.  **BFF**: O BFF recebe a requisição, realiza validações iniciais e, se tudo estiver correto, a encaminha para o **Serviço de Usuários**.
3.  **Microserviço (Backend)**: O Serviço de Usuários processa a lógica de negócio (ex: autenticação de credenciais no banco de dados) e retorna a resposta para o BFF.
4.  **Resposta do BFF**: O BFF recebe a resposta, consolida os dados, se necessário, e retorna um payload otimizado e seguro (contendo os tokens) para o frontend.
5.  **Interação do Frontend**: O frontend armazena os tokens de forma segura e os utiliza para todas as requisições subsequentes, enviando o token de acesso no cabeçalho.

#### **3. Infraestrutura e Tecnologias**

* **Contêineres**: Todos os serviços (BFF, Microserviços e Banco de Dados) devem ser conteinerizados usando **Docker** para facilitar o desenvolvimento, o deploy e o gerenciamento.
* **Orquestração**: Para ambientes de produção, um orquestrador como **Kubernetes** é recomendado para gerenciar a escalabilidade, o balanceamento de carga e a resiliência dos microserviços.
* **Banco de Dados**: Cada microserviço deve ter seu próprio banco de dados **PostgreSQL** para garantir o máximo de desacoplamento. No entanto, para um MVP, é aceitável que todos os serviços compartilhem uma única instância do PostgreSQL com bases de dados separadas.
* **Comunicação Interna**: A comunicação entre os microserviços pode ser síncrona (REST) ou assíncrona (via Message Broker como RabbitMQ ou Kafka), dependendo dos requisitos de negócio (por exemplo, o envio de e-mails pode ser assíncrono).

#### **4. Vantagens da Arquitetura**

* **Desacoplamento**: Cada serviço pode ser desenvolvido, implantado e escalado de forma independente.
* **Manutenibilidade**: A lógica de negócio está isolada em serviços específicos, facilitando a manutenção e a adição de novas funcionalidades.
* **Performance**: A agregação de dados no BFF reduz a latência e a carga no frontend, melhorando a experiência do usuário.
* **Segurança**: O BFF age como um portão de segurança, protegendo os microserviços de requisições inválidas e centralizando a lógica de autenticação.