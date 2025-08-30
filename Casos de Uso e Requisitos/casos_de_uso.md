 # 📘 Casos de Uso do Sistema SIGEEV

> Documento consolidado derivado dos Requisitos Funcionais (RF) e Não Funcionais (RNF). Objetivo: fornecer visão estruturada e homogênea dos fluxos de negócio.  
> Perfis: participante | promotor | administrador.

## Sumário
- [1. Autenticação](#1-autenticação)
- [2. Usuários](#2-usuários)
- [3. Eventos](#3-eventos)
- [4. Inscrições](#4-inscrições)
- [5. Rastreabilidade (Resumo)](#5-rastreabilidade-resumo)
- [6. Observações de Modelagem](#6-observações-de-modelagem)
- [7. Backlog Futuro](#7-backlog-futuro)

---
## 1. Autenticação

### UC-AUT-01 • Login de Usuário (AUT-RF-001)
**Objetivo**  
Autenticar usuário e emitir `accessToken` e `refreshToken`.

**Atores**  
- Primário: Usuário (qualquer perfil)  
- Secundários: Serviço de Autenticação, BFF, Serviço de Usuários, Serviço de Notificações (futuro alertas)  

**Pré-condições**  
- Usuário cadastrado e não excluído  
- Conta ativa e não bloqueada por tentativas  

**Pós-condições (sucesso)**  
- Par de tokens emitido  
- Contador de falhas zerado  
- Último login armazenado  

**Fluxo Principal**  
1. Receber email e senha  
2. Validar formato e existência do usuário  
3. Verificar status (ativo / bloqueio)  
4. Validar senha (hash)  
5. Gerar tokens (expiração ≤ 1h / 7d)  
6. Atualizar último login e registrar auditoria  
7. Retornar tokens e expirações  

**Fluxos Alternativos**  
- A1 Credenciais inválidas → incrementa falha; 401  
- A2 5ª falha → bloqueio 15 min; 429 (Retry-After)  
- A3 Conta inativa → 403  
- A4 Conta bloqueada → 429  

**Regras de Negócio** AUT-RF-001; AUT-RNF-001; AUT-RNF-003; AUT-RNF-005; AUT-RNF-007; AUT-RNF-008; AUT-RNF-013  
**RNF Relevantes** Desempenho p95 ≤ 500ms; Disponibilidade 99.7%  
**Endpoint** POST /auth/login

---
### UC-AUT-02 • Renovação de Token (AUT-RF-002)
**Objetivo** Gerar novo par de tokens via refresh token válido.

**Atores** Usuário; Serviço de Autenticação  
**Pré-condições** Refresh token existente, não expirado, não revogado  
**Pós-condições** Novo par emitido; anterior invalidado  
**Fluxo Principal** 1. Receber refreshToken 2. Validar integridade/expiração/revogação 3. Gerar novos tokens 4. Invalidar anterior 5. Retornar  
**Alternativos** A1 Expirado/revogado → 401 | A2 Formato inválido → 400  
**Regras** AUT-RF-002; AUT-RNF-005; AUT-RNF-006; AUT-RNF-015  
**RNF** Auditoria (AUT-RNF-008)  
**Endpoint** POST /auth/refresh

---
### UC-AUT-03 • Troca de Senha (AUT-RF-003)
**Objetivo** Alterar senha autenticado.

**Atores** Usuário autenticado  
**Pré-condições** JWT válido; senha atual correta  
**Pós-condições** Hash atualizado; notificação + auditoria  
**Fluxo Principal** 1. Receber senhaAtual/novaSenha 2. Validar senha atual 3. Validar política nova senha 4. Atualizar hash 5. Auditoria 6. Notificar 7. Retornar  
**Alternativos** A1 Senha atual incorreta → 401 | A2 Nova inválida → 400  
**Regras** AUT-RF-003; AUT-RNF-001; AUT-RNF-008; AUT-RNF-013  
**Endpoint** POST /auth/password/change

---
### UC-AUT-04 • Solicitar Recuperação de Senha (AUT-RF-004)
**Objetivo** Gerar token de recuperação (1h) e enviar email.

**Atores** Usuário; Serviço de Notificações  
**Pré-condições** Email cadastrado; dentro do rate limit  
**Pós-condições** Token persistido aguardando uso  
**Fluxo Principal** 1. Receber email 2. Validar existência 3. Verificar rate 4. Gerar token (TTL 1h) 5. Persistir 6. Enviar email 7. Auditoria  
**Alternativos** A1 Email não encontrado → 404 | A2 Limite excedido → 429  
**Regras** AUT-RF-004; AUT-RNF-004; AUT-RNF-009; AUT-RNF-008  
**Endpoint** POST /auth/password/recovery

---
### UC-AUT-05 • Redefinir Senha (AUT-RF-005)
**Objetivo** Redefinir senha via token de recuperação.

**Atores** Usuário  
**Pré-condições** Token válido (não usado/expirado)  
**Pós-condições** Senha atualizada; token e refresh antigos invalidos  
**Fluxo Principal** 1. Receber token+novaSenha 2. Validar token 3. Validar política senha 4. Atualizar hash 5. Invalidar token recuperação 6. Revogar refresh tokens 7. Notificar 8. Auditoria 9. Retornar  
**Alternativos** A1 Token inválido → 401 | A2 Nova senha inválida → 400  
**Regras** AUT-RF-005; AUT-RNF-001; AUT-RNF-005; AUT-RNF-006; AUT-RNF-008  
**Endpoint** POST /auth/password/reset

---
## 2. Usuários

### UC-USU-01 • Cadastro de Usuário (USU-RF-001)
**Objetivo** Criar usuário com dados pessoais + endereço.

**Atores** Novo usuário; Serviços: Autenticação, Notificações  
**Pré-condições** Email e CPF únicos; idade ≥ 18; campos obrigatórios  
**Pós-condições** Usuário persistido; token emitido; email confirmação; auditoria  
**Fluxo Principal** 1. Receber payload 2. Validar formatos/unicidade 3. Validar idade 4. Hash senha 5. Persistir 6. Gerar JWT 7. Notificar 8. Auditoria 9. Retornar  
**Alternativos** A1 CPF duplicado → 409 | A2 Email duplicado → 409 | A3 Inválido → 400  
**Regras** USU-RF-001; RNF-001..006,009; AUT-RNF-001  
**Endpoint** POST /usuarios

---
### UC-USU-02 • Consulta de Perfil (USU-RF-002)
**Objetivo** Retornar dados do próprio usuário.

**Atores** Usuário autenticado  
**Pré-condições** JWT válido; não excluído  
**Pós-condições** Auditoria registrada; CPF mascarado  
**Fluxo Principal** 1. Validar token 2. Carregar perfil 3. Mascarar CPF 4. Retornar  
**Alternativos** A1 Sem/ inválido → 401 | A2 Não encontrado → 404  
**Regras** USU-RF-002; RNF-002; RNF-007  
**Endpoint** GET /usuarios/me

---
### UC-USU-03 • Atualização de Perfil (USU-RF-003)
**Objetivo** Alterar dados (exceto email/CPF).

**Atores** Usuário autenticado  
**Pré-condições** JWT válido; ativo; payload válido  
**Pós-condições** Dados atualizados; auditoria; notificação  
**Fluxo Principal** 1. Receber dados 2. Validar formatos/idade 3. Atualizar 4. Persistir dataUltimaAtualizacao 5. Auditoria 6. Notificar 7. Retornar  
**Alternativos** A1 Dados inválidos → 400 | A2 Tentativa alterar email/CPF → 400 | A3 Não encontrado → 404  
**Regras** USU-RF-003; RNF-001..006; RNF-007  
**Endpoint** PUT /usuarios/me

---
### UC-USU-04 • Promoção de Perfil (USU-RF-004)
**Objetivo** Promover participante para promotor.

**Atores** Administrador; Usuário alvo  
**Pré-condições** Admin autenticado; usuário existe; não já promotor  
**Pós-condições** Perfil atualizado; auditoria; notificação  
**Fluxo Principal** 1. Validar permissão 2. Carregar usuário 3. Verificar perfil 4. Atualizar para promotor 5. Auditoria (adminId) 6. Notificar 7. Retornar  
**Alternativos** A1 Sem permissão → 403 | A2 Não encontrado → 404 | A3 Já promotor → 409  
**Regras** USU-RF-004; RNF-007; RNF-008  
**Endpoint** POST /usuarios/{id}/promover

---
### UC-USU-05 • Rebaixamento de Perfil (USU-RF-005)
**Objetivo** Rebaixar promotor para participante.

**Atores** Administrador; Usuário alvo  
**Pré-condições** Admin autenticado; perfil atual = promotor  
**Pós-condições** Perfil atualizado; auditoria; notificação  
**Fluxo Principal** 1. Validar permissão 2. Carregar usuário 3. Verificar perfil 4. Atualizar para participante 5. Auditoria 6. Notificar 7. Retornar  
**Alternativos** A1 Sem permissão → 403 | A2 Não encontrado → 404 | A3 Já participante → 409  
**Regras** USU-RF-005; RNF-007; RNF-008  
**Endpoint** POST /usuarios/{id}/rebaixar

---
### UC-USU-06 • Exclusão de Conta (USU-RF-006)
**Objetivo** Exclusão lógica da conta própria.

**Atores** Usuário autenticado  
**Pré-condições** JWT válido; confirmação explícita; não já excluída  
**Pós-condições** Status excluido; refresh tokens revogados; auditoria; notificação  
**Fluxo Principal** 1. Receber confirmação 2. Validar token 3. Marcar excluido 4. Revogar refresh tokens 5. Auditoria 6. Notificar 7. Retornar  
**Alternativos** A1 Não encontrado → 404 | A2 Já excluído → 409 | A3 Sem confirmação → 400  
**Regras** USU-RF-006; RNF-007; RNF-010; AUT-RNF-014  
**Endpoint** DELETE /usuarios/me

---
## 3. Eventos

### UC-EVT-01 • Criação de Evento (EVT-RF-001)
**Objetivo** Criar evento (ativo ou rascunho).

**Atores** Promotor; Serviços: Notificações  
**Pré-condições** Perfil promotor; payload válido; dentro rate limit  
**Pós-condições** Evento salvo; auditoria; (se ativo) notificação; caches invalidos  
**Fluxo Principal** 1. Receber dados + publicar 2. Validar campos 3. Determinar status 4. Persistir 5. Auditoria 6. Invalidar cache 7. Notificar se ativo 8. Retornar id/status  
**Alternativos** A1 Inválido → 400 | A2 Não promotor → 403 | A3 Rate excedido → 429  
**Regras** EVT-RF-001; EVT-RNF-001,002,004,005,007,008,009  
**Endpoint** POST /eventos

---
### UC-EVT-02 • Listagem Pública (EVT-RF-002)
**Objetivo** Listar eventos ativos/esgotados paginados.

**Atores** Usuário público  
**Pré-condições** —  
**Pós-condições** Acesso auditado; cache curto  
**Fluxo Principal** 1. Receber paginação 2. Aplicar ordenação padrão 3. Buscar eventos 4. Calcular vagas (ou cache) 5. Retornar  
**Alternativos** A1 Nenhum → 204  
**Regras** EVT-RF-002; EVT-RNF-004; EVT-RNF-005; EVT-RNF-003  
**Endpoint** GET /eventos

---
### UC-EVT-03 • Pesquisa Avançada (EVT-RF-003)
**Objetivo** Filtrar eventos com múltiplos critérios.

**Atores** Usuário público  
**Pré-condições** Filtros em formato válido  
**Pós-condições** Métricas atualizadas  
**Fluxo Principal** 1. Receber filtros 2. Validar 3. Aplicar filtros + paginação 4. Montar metadados 5. Retornar  
**Alternativos** A1 Inválidos → 400 | A2 Sem resultados → 204/Lista vazia  
**Regras** EVT-RF-003; EVT-RNF-006; EVT-RNF-005; EVT-RNF-003; EVT-RNF-013  
**Endpoint** POST /eventos/filtrar

---
### UC-EVT-04 • Meus Eventos (EVT-RF-004)
**Objetivo** Listar eventos do promotor (todos status).

**Atores** Promotor  
**Pré-condições** Perfil promotor  
**Pós-condições** Auditoria  
**Fluxo Principal** 1. Validar perfil 2. Buscar eventos do promotor 3. Ordenar dataCriacao DESC 4. Paginar 5. Retornar  
**Alternativos** A1 Sem eventos → 204 | A2 Não promotor → 403  
**Regras** EVT-RF-004; EVT-RNF-005; EVT-RNF-007  
**Endpoint** GET /eventos/me

---
### UC-EVT-05 • Detalhes de Evento (EVT-RF-005)
**Objetivo** Retornar detalhes completos.

**Atores** Usuário público; Serviço de Inscrições  
**Pré-condições** UUID válido; evento não inativo  
**Pós-condições** Acesso auditado; cache curto  
**Fluxo Principal** 1. Validar UUID 2. Buscar evento 3. Calcular vagas (ou fallback) 4. Retornar detalhes  
**Alternativos** A1 UUID inválido → 400 | A2 Inexistente/inativo → 404  
**Regras** EVT-RF-005; EVT-RNF-003; EVT-RNF-004; EVT-RNF-014  
**Endpoint** GET /eventos/{id}

---
### UC-EVT-06 • Edição de Evento (EVT-RF-006)
**Objetivo** Atualizar dados respeitando restrições.

**Atores** Promotor proprietário; Serviços: Inscrições, Notificações  
**Pré-condições** Proprietário; status ativo|esgotado; capacidade ≥ inscrições; dados válidos  
**Pós-condições** Evento atualizado; auditoria; notificação (campos críticos); cache limpo  
**Fluxo Principal** 1. Validar propriedade/status 2. Validar dados/versão 3. Aplicar lock otimista 4. Persistir e registrar dataUltimaAtualizacao 5. Invalidar cache 6. Notificar se crítico 7. Retornar  
**Alternativos** A1 Não encontrado → 404 | A2 Não proprietário → 403 | A3 Inválido → 400 | A4 Capacidade < inscrições → 409 | A5 Conflito versão → 409  
**Regras** EVT-RF-006; EVT-RNF-001,002,003,007,009,012,014  
**Endpoint** PUT /eventos/{id}

---
### UC-EVT-07 • Cancelamento de Evento (EVT-RF-007)
**Objetivo** Cancelar logicamente (inativo) sem inscrições ativas.

**Atores** Promotor proprietário; Serviços: Inscrições, Notificações  
**Pré-condições** Evento ativo|esgotado; zero inscrições ativas; proprietário  
**Pós-condições** Status inativo; auditoria; notificação; cache limpo  
**Fluxo Principal** 1. Validar existência/status 2. Validar propriedade 3. Verificar inscrições 4. Marcar inativo 5. Auditoria 6. Invalidar cache 7. Notificar 8. Retornar  
**Alternativos** A1 Inexistente/inativo → 404 | A2 Inscrições ativas → 409 | A3 Não proprietário → 403  
**Regras** EVT-RF-007; EVT-RNF-012; EVT-RNF-007; EVT-RNF-009; EVT-RNF-004  
**Endpoint** DELETE /eventos/{id}

---
## 4. Inscrições

### UC-INS-01 • Realizar Inscrição (INS-RF-001)
**Objetivo** Criar inscrição em evento com vagas.

**Atores** Usuário autenticado; Serviços: Eventos, Notificações  
**Pré-condições** Usuário ativo; evento ativo; vagas; não inscrito  
**Pós-condições** Inscrição ativa; auditoria; notificação; vagas atualizadas  
**Fluxo Principal** 1. Receber eventoId 2. Validar existência/status 3. Calcular vagas 4. Verificar duplicidade 5. Criar inscrição 6. Atualizar métricas 7. Auditoria 8. Notificar 9. Retornar  
**Alternativos** A1 Evento inexistente → 404 | A2 Inativo → 403 | A3 Esgotado → 409 | A4 Já inscrito → 409 | A5 Rate excedido → 429  
**Regras** INS-RF-001; INS-RNF-001,007,015; EVT-RNF-003; INS-RNF-004  
**Endpoint** POST /inscricoes

---
### UC-INS-02 • Minhas Inscrições (INS-RF-002)
**Objetivo** Listar inscrições do usuário.

**Atores** Usuário autenticado  
**Pré-condições** JWT válido  
**Pós-condições** Auditoria  
**Fluxo Principal** 1. Identificar usuário 2. Buscar inscrições 3. Agregar dados evento 4. Ordenar por dataInicio 5. Retornar  
**Alternativos** A1 Nenhuma inscrição → 204  
**Regras** INS-RF-002; INS-RNF-004; INS-RNF-008  
**Endpoint** GET /inscricoes/me

---
### UC-INS-03 • Cancelar Inscrição (INS-RF-003)
**Objetivo** Cancelar inscrição ativa antes do evento.

**Atores** Usuário autenticado; Serviços: Eventos, Notificações  
**Pré-condições** Inscrição do usuário; status ativo; evento não iniciado  
**Pós-condições** Status cancelada; vaga liberada; auditoria; notificação  
**Fluxo Principal** 1. Validar propriedade/status 2. Verificar início evento 3. Marcar cancelada 4. Atualizar vagas 5. Auditoria 6. Notificar 7. Retornar  
**Alternativos** A1 Inexistente → 404 | A2 Já cancelada → 409 | A3 Evento iniciado → 403  
**Regras** INS-RF-003; INS-RNF-001; INS-RNF-004; INS-RNF-009; INS-RNF-006  
**Endpoint** DELETE /inscricoes/{id}

---
### UC-INS-04 • Inscrições de Evento (Promotor) (INS-RF-004)
**Objetivo** Listar inscrições de um evento para o promotor.

**Atores** Promotor proprietário ou Admin  
**Pré-condições** Evento existe; caller autorizado  
**Pós-condições** Auditoria; dados mínimos expostos  
**Fluxo Principal** 1. Validar permissão/propriedade 2. Buscar inscrições 3. Ordenar dataInscricao DESC 4. Limitar campos 5. Retornar  
**Alternativos** A1 Evento inexistente/inativo → 404/403 | A2 Sem inscrições → 204 | A3 Não autorizado → 403  
**Regras** INS-RF-004; INS-RNF-006; INS-RNF-011; INS-RNF-004  
**Endpoint** GET /eventos/{id}/inscricoes

---
## 5. Rastreabilidade (Resumo)

| Caso de Uso | Requisitos Funcionais | Principais RNF |
|-------------|-----------------------|----------------|
| UC-AUT-01 | AUT-RF-001 | AUT-RNF-001,003,005,007,008,010,011 |
| UC-AUT-02 | AUT-RF-002 | AUT-RNF-005,006,015,008 |
| UC-AUT-03 | AUT-RF-003 | AUT-RNF-001,008,013 |
| UC-AUT-04 | AUT-RF-004 | AUT-RNF-004,009,008 |
| UC-AUT-05 | AUT-RF-005 | AUT-RNF-001,005,006,008,014 |
| UC-USU-01 | USU-RF-001 | RNF-001..006,009,007,008 |
| UC-USU-02 | USU-RF-002 | RNF-002,007 |
| UC-USU-03 | USU-RF-003 | RNF-001..006,007 |
| UC-USU-04 | USU-RF-004 | RNF-007,008 |
| UC-USU-05 | USU-RF-005 | RNF-007,008 |
| UC-USU-06 | USU-RF-006 | RNF-007,010, AUT-RNF-014 |
| UC-EVT-01 | EVT-RF-001 | EVT-RNF-001,002,004,005,007,008,009 |
| UC-EVT-02 | EVT-RF-002 | EVT-RNF-004,005,003 |
| UC-EVT-03 | EVT-RF-003 | EVT-RNF-006,005,003,013 |
| UC-EVT-04 | EVT-RF-004 | EVT-RNF-005,007 |
| UC-EVT-05 | EVT-RF-005 | EVT-RNF-003,004,014 |
| UC-EVT-06 | EVT-RF-006 | EVT-RNF-001,002,003,007,009,012,014 |
| UC-EVT-07 | EVT-RF-007 | EVT-RNF-012,007,009,004 |
| UC-INS-01 | INS-RF-001 | INS-RNF-001,007,015,004 |
| UC-INS-02 | INS-RF-002 | INS-RNF-004,008 |
| UC-INS-03 | INS-RF-003 | INS-RNF-001,004,009,006 |
| UC-INS-04 | INS-RF-004 | INS-RNF-006,011,004 |

---
## 6. Observações de Modelagem
1. Propagação de `correlationId` via BFF para rastreabilidade distribuída.  
2. Auditoria mínima: actorId, recurso, ação, timestamp, correlationId, resultado.  
3. Fallback vagas (detalhe evento): `vagasRestantes = null` + header `X-Degraded` (EVT-RNF-014).  
4. Rate limit deve informar cabeçalhos (restante / janela) quando aplicável.  
5. Mensageria at-least-once exige idempotência no consumidor (chave composta).  
6. Uso de 204 restrito a ausência semântica de conteúdo (listagens).  
7. Envelope de resposta padronizado conforme docs de API (exemplos omitidos aqui para evitar redundância).  

---
## 7. Backlog Futuro
- MFA e login de novo dispositivo (Autenticação)  
- Lista de espera / reservas (Eventos & Inscrições)  
- Pagamentos & estados adicionais (Inscrições)  
- Exportação de dados & reativação de conta  
- Webhooks / streaming em tempo real  
- Suporte a PATCH parcial (Usuários, Eventos)  

---
Documento atualizado em 2025-08-30.
