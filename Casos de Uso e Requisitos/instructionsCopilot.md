```yaml
applyTo: '**'
```

# **Instruções para Implementação de Microserviço com Spring Boot**

## **0. Objetivo**

Desenvolver um microserviço que gerencia eventos e inscrições, seguindo os princípios da arquitetura Hexagonal.
Deve ser capaz de persistir os dados e ler as informações de um banco de dados PostgreSQL conforme as especificações do projeto no documento de banco de dados.
Ele se comunica com outros serviços via API RESTful com um BFF (Backend for Frontend) que atua como
intermediário, otimizando a comunicação e garantindo a segurança e a consistência dos dados e 
persistindo as informações num banco de dados PostgreSQL.

## **1. Visão Geral do Projeto**

- Este serviço é parte de uma arquitetura de microserviços e deve seguir a arquitetura Hexagonal.
- A aplicação deve ser construída com **Spring Boot** e **Java 21**, utilizando **Maven** para gerenciamento de dependências.
- A comunicação com outros serviços deve ser via **API RESTful** com payloads **JSON**.

## **2. Padrões e Tecnologias**

- **Arquitetura**: Hexagonal (Ports and Adapters).
- **Linguagem**: Java 21.
- **Framework**: Spring Boot 3.4.7.
- **ORM**: Spring Data JPA.
- **Banco de Dados**: PostgreSQL.
- **Ferramentas**: Lombok, MapStruct.
- **Testes**: JUnit, Mockito, Testcontainers (opcional).

## **3. Estrutura de Pacotes (Arquitetura Hexagonal)**

A estrutura de pacotes deve ser estritamente seguida para manter o desacoplamento das camadas.

```
src/main/java/com/meuprojeto/api
 ├── domain
 │    ├── entities       -> Entidades e Value Objects
 │    └── ports          -> Interfaces (Ports de entrada e saída)
 ├── application
 │    └── services       -> Implementações dos Casos de Uso
 ├── adapters
 │    ├── inbound        -> Controladores REST (Ports de entrada)
 │    └── outbound       -> Repositórios JPA (Ports de saída)
 ├── infrastructure
 │    ├── config         -> Configurações de segurança, banco, etc.
 │    └── mappers        -> Classes de mapeamento com MapStruct
```

## **4. Sequência de Implementação**

Crie o código em uma ordem que respeite as dependências entre as camadas.

1.  **Setup Inicial**: Crie o `pom.xml` com as dependências essenciais.
2.  **Domain**: Defina as entidades de negócio e as interfaces (ports) para os casos de uso e para os repositórios.
3.  **Adapters/outbound**: Crie as entidades de persistência (JPA Entities) e os repositórios (JPA Repositories).
4.  **Application**: Implemente os serviços de aplicação (use cases) que usam as interfaces de repositório.
5.  **Adapters/inbound**: Implemente os controladores REST que usam as interfaces de serviço de aplicação.
6.  **DTOs e Mappers**: Crie os DTOs de entrada/saída e os mappers com MapStruct para a comunicação entre as camadas.
7.  **Configuração**: Implemente as classes de configuração do Spring Boot, como segurança e banco de dados.

## **5. Padrões de Código e Convenções**

- **DTOs**: Use o sufixo `DTO` para todas as classes de Data Transfer Objects.
- **Mapeamento**: O mapeamento entre entidades e DTOs deve ser feito exclusivamente com **MapStruct**.
- **Exceções**: Implemente classes de exceção personalizadas para erros de negócio. O `ControllerAdvice` deve ser usado para centralizar o tratamento dessas exceções.
- **Validação**: Utilize a especificação Bean Validation (Jakarta Validation) para validar os DTOs de entrada nos controladores.

## **6. Qualidade e Testes**

- **Compilação**: O código deve compilar após cada etapa de implementação.
- **Cobertura de Testes**: A cobertura de testes unitários em `application/services` e `adapters/outbound` deve ser de **no mínimo 80%**.
- **Tipos de Testes**: Incluir testes unitários para a lógica de negócio, testes de integração para controladores (com `MockMvc`) e testes de persistência (com H2 ou Testcontainers).

## **7. Configuração da Aplicação**

- As configurações sensíveis (senhas, chaves) devem ser carregadas de variáveis de ambiente.
- As demais configurações do Spring Boot devem estar no arquivo `application.yml`.

```