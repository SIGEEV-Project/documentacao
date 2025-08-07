# SIGEEV - Sistema de Gerenciamento de Eventos

## Visão Geral
O SIGEEV é uma aplicação para gerenciamento de eventos, baseada em arquitetura de microserviços, com foco em escalabilidade, segurança e experiência do usuário. O sistema permite o cadastro de usuários, criação e inscrição em eventos, além de gerenciamento de perfis e notificações.

## Arquitetura
- **Microserviços**: Cada domínio (usuários, eventos, inscrições, notificações) é um serviço independente, seguindo arquitetura hexagonal.
- **BFF (Backend for Frontend)**: Camada intermediária entre frontend e backend, responsável por agregação de dados, validação, autenticação e adaptação de payloads.
- **Frontend**: Interface do usuário, comunica-se apenas com o BFF.
- **Infraestrutura**: Serviços conteinerizados com Docker, recomendação de uso de Kubernetes em produção. Banco de dados PostgreSQL.

## Principais Módulos e Casos de Uso
- **Usuários**: Cadastro, login, perfil, segurança, histórico de promoções.
- **Eventos**: Criação, edição, listagem, exclusão, controle de preços e capacidade.
- **Inscrições**: Inscrição em eventos, controle de vagas, registro de inscrições.
- **Notificações**: (Futuro) Envio de e-mails de confirmação e recuperação de senha.

### Exemplo de Caso de Uso: Cadastro de Usuário
- O usuário se registra informando dados pessoais.
- O sistema valida unicidade de CPF e e-mail.
- Retorna token JWT para autenticação.

## Requisitos do BFF
- Gerenciamento de autenticação e ciclo de vida dos tokens (JWT e refresh token).
- Validação de permissões antes de encaminhar requisições ao backend.
- Agregação e transformação de dados (ex: cálculo de vagas restantes em eventos).
- Pré-validação e sanitização de dados de entrada.
- Otimização de performance (ex: cache de listagem de eventos).

## Estrutura do Banco de Dados
- Tabelas principais: Usuários, Eventos, Inscrições, Preços de Eventos, Histórico de Promoções, Senhas.
- Tipos enumerados para perfis de usuário, status de inscrição/evento e logs de promoção.
- Uso de UUIDs como chave primária.

## Como Executar
1. Clone o repositório e acesse a pasta do projeto.
2. Execute o script `scriptCriacaoDB.sql` para criar o banco de dados PostgreSQL.
3. Utilize Docker para subir os serviços (BFF, microserviços e banco de dados).
4. Acesse a aplicação pelo frontend.

## Observações
- Para detalhes de endpoints, payloads e critérios de aceite, consulte os arquivos `casosDeUso.md` e `requisitosBFF.md`.
- Para visualizar a arquitetura e o modelo de dados, veja os diagramas `.puml`.
- O sistema é extensível para novos microserviços e integrações.
