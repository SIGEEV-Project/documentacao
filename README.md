# SIGEEV - Sistema de Gerenciamento de Eventos

## Visão Geral
O SIGEEV é uma aplicação para gerenciamento de eventos, baseada em arquitetura de microserviços, com foco em escalabilidade, segurança e experiência do usuário. O sistema permite o cadastro de usuários, criação e inscrição em eventos, além de gerenciamento de perfis e notificações.

## Estrutura da Documentação

### Arquitetura
- **[Arquitetura de Solução](./Arquitetura/ArquiteturaDeSolucao.md)**: Descrição detalhada da arquitetura de microserviços, BFF e fluxo de comunicação.
- **[Diagrama de Arquitetura](./Arquitetura/ArquiteturaDeSolucao.puml)**: Representação visual da arquitetura do sistema.
- **[Diagrama de Banco de Dados](./Arquitetura/diagrama_bd.puml)**: Modelo de dados com entidades, relacionamentos e atributos.

### Requisitos Funcionais
- **[Autenticação](./Requisitos%20Funcionais/autenticacao_funcionais.md)**: Requisitos para login, renovação de token, troca e recuperação de senha.
- **[Usuários](./Requisitos%20Funcionais/usuarios_funcionais.md)**: Requisitos para cadastro, consulta, atualização e exclusão de usuários.
- **[Eventos](./Requisitos%20Funcionais/eventos_funcionais.md)**: Requisitos para criação, listagem, edição e cancelamento de eventos.
- **[Inscrições](./Requisitos%20Funcionais/inscricoes_funcionais.md)**: Requisitos para inscrição, listagem e cancelamento de inscrições.

### Requisitos Não Funcionais
- **[Autenticação](./Requisitos%20Não%20Funcionais/autenticacao_nao_funcionais.md)**: Requisitos não funcionais para o módulo de autenticação.
- **[Usuários](./Requisitos%20Não%20Funcionais/usuarios_nao_funcionais.md)**: Requisitos não funcionais para o módulo de usuários.
- **[Eventos](./Requisitos%20Não%20Funcionais/eventos_nao_funcionais.md)**: Requisitos não funcionais para o módulo de eventos.
- **[Inscrições](./Requisitos%20Não%20Funcionais/inscricoes_nao_funcionais.md)**: Requisitos não funcionais para o módulo de inscrições.

### Documentação de API
- **[Autenticação](./api/autenticacao_api.md)**: Endpoints para login, renovação de token, troca e recuperação de senha.
- **[Usuários](./api/usuarios_api.md)**: Endpoints para cadastro, consulta, atualização e exclusão de usuários.
- **[Eventos](./api/eventos_api.md)**: Endpoints para criação, listagem, edição e cancelamento de eventos.
- **[Inscrições](./api/inscricoes_api.md)**: Endpoints para inscrição, listagem e cancelamento de inscrições.

### Análise de Inconsistências
- **[Autenticação](./inconsistencias/autenticacao_inconsistencias.md)**: Inconsistências entre requisitos e API de autenticação.
- **[Usuários](./inconsistencias/usuarios_inconsistencias.md)**: Inconsistências entre requisitos e API de usuários.
- **[Eventos](./inconsistencias/eventos_inconsistencias.md)**: Inconsistências entre requisitos e API de eventos.
- **[Inscrições](./inconsistencias/inscricoes_inconsistencias.md)**: Inconsistências entre requisitos e API de inscrições.
- **[Arquitetura](./inconsistencias/arquitetura_inconsistencias.md)**: Inconsistências entre diagrama e descrição da arquitetura.

### Scripts
- **[Script de Criação do Banco de Dados](./Scripts/scriptCriacaoDB.sql)**: Script SQL para criação das tabelas e tipos.
- **[Script de Inserção de Dados](./Scripts/ScriptDeInsercaoDeDados.sql)**: Script SQL para inserção de dados de exemplo.

### Outros
- **[Glossário de Termos](./glossario_termos.md)**: Definições dos termos utilizados na documentação.
- **[Padrão de Nomenclatura](./padrao_nomenclatura.md)**: Convenções de nomenclatura adotadas no projeto.
- **[Visão Geral de Casos de Uso](./Casos%20de%20Uso%20e%20Requisitos/visao_geral.md)**: Visão geral dos casos de uso do sistema.

## Principais Módulos e Casos de Uso
- **Usuários**: Cadastro, login, perfil, segurança, histórico de promoções.
- **Eventos**: Criação, edição, listagem, exclusão, controle de preços e capacidade.
- **Inscrições**: Inscrição em eventos, controle de vagas, registro de inscrições.
- **Notificações**: Envio de e-mails de confirmação e recuperação de senha.

## Estrutura do Banco de Dados
- Tabelas principais: Usuários, Eventos, Inscrições, Preços de Eventos, Histórico de Promoções, Senhas.
- Tipos enumerados para perfis de usuário, status de inscrição/evento e logs de promoção.
- Uso de UUIDs como chave primária.

## Como Executar
1. Clone o repositório e acesse a pasta do projeto.
2. Execute o script `scriptCriacaoDB.sql` para criar o banco de dados PostgreSQL.
3. Utilize Docker para subir os serviços (BFF, microserviços e banco de dados).
4. Acesse a aplicação pelo frontend.
