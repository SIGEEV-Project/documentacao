# Glossário de Termos - SIGEEV

## A

**Administrador**: Perfil de usuário com permissões para gerenciar outros usuários, incluindo promoção e rebaixamento de perfis.

**API (Application Programming Interface)**: Conjunto de regras e protocolos que permite a comunicação entre diferentes softwares.

**Autenticação**: Processo de verificação da identidade de um usuário, geralmente através de credenciais como email e senha.

**Autorização**: Processo de verificação das permissões de um usuário autenticado para acessar determinados recursos ou executar determinadas ações.

## B

**Backend**: Parte do sistema que processa a lógica de negócio e interage com o banco de dados, não visível diretamente ao usuário final.

**BFF (Backend For Frontend)**: Camada intermediária entre o frontend e os microserviços, responsável por agregar dados, validar requisições e adaptar payloads para o frontend.

## C

**Capacidade**: Número máximo de participantes que um evento pode comportar.

**Correlation ID**: Identificador único que acompanha uma requisição através de todos os serviços, permitindo rastreamento e depuração.

## E

**Evento**: Acontecimento organizado por um promotor, com data, local, capacidade e possivelmente preço definidos.

**Envelope de Resposta**: Estrutura padronizada para respostas da API, contendo campos como sucesso, mensagem, dados, erros, timestamp e correlationId.

## F

**Frontend**: Interface com a qual o usuário interage diretamente, responsável pela apresentação visual e interação com o usuário.

## I

**Inscrição**: Registro de participação de um usuário em um evento específico.

## J

**JWT (JSON Web Token)**: Padrão para transmissão segura de informações entre partes como um objeto JSON, utilizado para autenticação e autorização.

## M

**Microserviço**: Componente de software independente, responsável por uma funcionalidade específica do sistema, que se comunica com outros componentes através de APIs.

## P

**Participante**: Perfil de usuário que pode se inscrever em eventos.

**Payload**: Dados enviados em uma requisição ou resposta HTTP.

**Promotor**: Perfil de usuário que pode criar e gerenciar eventos.

## R

**Rate Limiting**: Técnica para limitar o número de requisições que um cliente pode fazer em um determinado período de tempo.

**Refresh Token**: Token de longa duração utilizado para obter um novo token de acesso quando o atual expira.

## S

**Status de Evento**: Estado atual de um evento, podendo ser rascunho, ativo, esgotado ou inativo.

**Status de Inscrição**: Estado atual de uma inscrição, podendo ser ativo, cancelada, pendente ou expirada.

## T

**Token de Acesso**: Credencial temporária que permite acesso a recursos protegidos, geralmente implementado como JWT.

## U

**UUID (Universally Unique Identifier)**: Identificador único universal, utilizado como chave primária para entidades no sistema.

## V

**Vagas Restantes**: Número de inscrições ainda disponíveis em um evento (capacidade - inscrições ativas).