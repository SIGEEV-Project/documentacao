# Cronograma de Desenvolvimento SIGEEV

> Foco inicial: Módulo de Autenticação. Estrutura orientada a Épicos → Features → Histórias de Usuário. Cada história inclui critérios de aceite resumidos e dependências. O planejamento assume abordagem iterativa (sprints de 2 semanas) e prioriza valor incremental (MVP → expansão).

## 0. Premissas & Estratégia
- Metodologia: Scrum/Kanban híbrido (roadmap macro + fluxo contínuo por serviço)
- Sprint: 2 semanas (entregáveis potencialmente utilizáveis)
- Prioridade: Segurança / Base compartilhada > Domínio principal (Eventos/Inscrições) > Experiência (BFF/Frontend) > Observabilidade avançada
- Qualidade mínima: testes unitários (≥70% core), integração crítica para autenticação, eventos e inscrições
- Versionamento APIs: v1 estável inicial; mudanças breaking só após fase de Hardening
- Ambientes: dev (local compose), staging (integração), prod (após validação MVP)

## 1. Épicos
| Épico | Descrição | Objetivo de Negócio | Métrica de Sucesso (indicativa) |
|-------|-----------|---------------------|---------------------------------|
| E1 – Fundações & Infra | Repositórios, CI/CD, observabilidade básica, padrão de serviços | Base sustentável | Pipeline verde <5 min / cobertura inicial 50% |
| E2 – Autenticação & Segurança | Login, refresh, políticas de senha, recuperação | Acesso seguro unificado | p95 login <500ms, taxa falha <5% |
| E3 – Usuários & Perfis | Cadastro, perfil, promoção/rebaixamento, exclusão lógica | Gestão identidades | Tempo cadastro <3s, zero duplicidades |
| E4 – Eventos | CRUD + filtros + listagem pública + ciclo de vida | Oferta de eventos válida | p95 listagem <2s, precisão status 100% |
| E5 – Inscrições | Inscrição, cancelamento, listagens e consistência vagas | Conversão / engajamento | 0 inconsistências de vaga, p95 criar <2s |
| E6 – Notificações & Mensageria | Envio assíncrono de emails e eventos de domínio | Confirmação automática | 99% entrega eventos em ≤10s |
| E7 – BFF & Agregação | Orquestração segura e caching leve | UX simplificada | Redução 30% chamadas cliente ↔ backend |
| E8 – Frontend MVP | Tela autentic. + fluxo eventos/inscrição básico | Validação de mercado | Fluxo cadastro→inscrição <5 min |
| E9 – Observabilidade & Hardening | Logs estruturados, métricas, tracing, rate limit, auditoria | Confiabilidade | SLOs atendidos 95% tempo |
| E10 – Expansões Futuras | Pagamentos / lista espera / MFA / reativação conta | Monetização & robustez | Backlog groomado / prova conceito |

## 2. Fases (Macro Timeline)
| Fase | Sprints | Foco Principal | Épicos Dominantes |
|------|---------|----------------|-------------------|
| F1 – Kickoff & Base | S1 | Infra, padrões, autentic. esqueleto | E1,E2 |
| F2 – Autenticação Completa | S2 | Fluxos senha + proteção abuso | E2 |
| F3 – Usuários | S3 | Cadastro + gestão perfil | E3 |
| F4 – Eventos Inicial | S4 | CRUD básico eventos | E4 |
| F5 – Eventos Avançado + Inscrições Inicial | S5 | Filtros + inscrição criação | E4,E5 |
| F6 – Inscrições Completo + Notificações | S6 | Cancelamento + mensageria | E5,E6 |
| F7 – BFF + Frontend MVP | S7 | Orquestração + UI mínima | E7,E8 |
| F8 – Hardening Observabilidade | S8 | Logs, métricas, tracing completos | E9 |
| F9 – Ajustes & Expansões | S9 | Backlog futuro (priorizado) | E10 |

## 3. Detalhamento por Épico → Features → Histórias

### E1 – Fundações & Infra
**Objetivo:** Preparar terreno técnico reutilizável.

| Feature | Código | História | Descrição | Critérios de Aceite | Dependências |
|---------|--------|----------|-----------|---------------------|--------------|
| Repositórios & Estrutura | E1-F1 | E1-H1 | Criar mono ou multi-repo (serviços separados) + templates README | Repos criados; README inicial; licenças definidas | - |
| Pipeline CI inicial | E1-F2 | E1-H2 | Build + testes automáticos PR | Pipeline executa build/teste; status badge | E1-H1 |
| Docker Compose Dev | E1-F3 | E1-H3 | Ambiente local com DB + serviços stub | `docker compose up` inicia dependências | E1-H1 |
| Observabilidade básica | E1-F4 | E1-H4 | Logging estruturado + correlationId middleware | Requests logados c/ correlationId | E1-H3 |
| Segurança base config | E1-F5 | E1-H5 | Gestão de variáveis (.env), secrets e chaves JWT | Rotação chave documentada; .env.example | E1-H1 |

### E2 – Autenticação & Segurança
**Objetivo:** Fluxos completos de autenticação e proteção.

| Feature | Código | História | Descrição | Critérios | Dependências |
|---------|--------|----------|-----------|----------|--------------|
| Login básico | E2-F1 | E2-H1 | Endpoint /auth/login emitindo JWT + refresh | 200 em credenciais válidas; 401 inválidas | E1-H5 |
| Refresh token | E2-F2 | E2-H2 | /auth/refresh com invalidação anterior | 200 novo par; uso repetido 401 | E2-H1 |
| Política senha & troca | E2-F3 | E2-H3 | /auth/password/change com validações | Rejeita senha fraca; auditoria logada | E2-H1 |
| Recuperação senha | E2-F4 | E2-H4 | Solicitar + redefinir (token 1h) | Email disparado; token inválido após uso | E2-H3 |
| Rate limit login | E2-F5 | E2-H5 | 5 falhas → bloqueio 15 min (429) | Contador expira após sucesso | E2-H1 |
| Auditoria eventos auth | E2-F6 | E2-H6 | Logar login, falha, bloqueio, refresh | Logs contêm campos RNF | E2-H1 |
| Segurança JWT avançada | E2-F7 | E2-H7 | Claims (sub, roles, exp, iat, iss); RS256 | Tokens inválidos rejeitados | E2-H2 |

### E3 – Usuários & Perfis
| Feature | Código | História | Descrição | Critérios | Dependências |
|---------|--------|----------|-----------|----------|--------------|
| Cadastro usuário | E3-F1 | E3-H1 | POST /usuarios com validações CPF/email | 201 sucesso; 409 duplicados | E2-H7 |
| Consulta perfil | E3-F2 | E3-H2 | GET /usuarios/me (CPF mascarado) | 200 dados; 401 sem token | E3-H1 |
| Atualização perfil | E3-F3 | E3-H3 | PUT /usuarios/me sem alterar email/CPF | 200; tentativa alterar email→400 | E3-H2 |
| Promoção perfil | E3-F4 | E3-H4 | Admin promove usuário (promotor) | 200; 403 sem permissão | E3-H1 |
| Rebaixamento perfil | E3-F5 | E3-H5 | Admin rebaixa promotor → participante | 200; 409 se já participante | E3-H4 |
| Exclusão lógica conta | E3-F6 | E3-H6 | DELETE /usuarios/me com confirmação | Status excluido; não loga mais | E3-H3 |
| Auditoria usuários | E3-F7 | E3-H7 | Log promoções, rebaixos, exclusões | Logs completos (actor, alvo) | E3-H4/E3-H5 |

### E4 – Eventos
| Feature | Código | História | Descrição | Critérios | Dependências |
|---------|--------|----------|-----------|----------|--------------|
| Criar evento | E4-F1 | E4-H1 | POST /eventos (rascunho/ativo) | 201; validações EVT-RNF-001 | E3-H4 |
| Listagem pública | E4-F2 | E4-H2 | GET /eventos paginado | 200/204; ordenação dataInicio | E4-H1 |
| Filtro avançado | E4-F3 | E4-H3 | POST /eventos/filtrar | 200 filtros válidos; 400 inválidos | E4-H2 |
| Detalhes evento | E4-F4 | E4-H4 | GET /eventos/{id} + vagasRestantes | 200 válido; 404 inexistente | E4-H2 |
| Editar evento | E4-F5 | E4-H5 | PUT /eventos/{id} proprietário | 200; 403 não dono; 409 conflito cap | E4-H1 |
| Cancelar evento | E4-F6 | E4-H6 | DELETE /eventos/{id} sem inscrições ativas | 200; 409 se inscrições | E5-H2 |
| Meus eventos | E4-F7 | E4-H7 | GET /eventos/me | 200; 204 vazio | E4-H1 |
| Auditoria eventos | E4-F8 | E4-H8 | Log criação, edição, cancelamento | Logs conforme RNF | E4-H1..H6 |

### E5 – Inscrições
| Feature | Código | História | Descrição | Critérios | Dependências |
|---------|--------|----------|-----------|----------|--------------|
| Criar inscrição | E5-F1 | E5-H1 | POST /inscricoes (vagas) | 201; 409 esgotado/duplicado | E4-H4 |
| Minhas inscrições | E5-F2 | E5-H2 | GET /inscricoes/me | 200/204; ordena dataInicio | E5-H1 |
| Cancelar inscrição | E5-F3 | E5-H3 | DELETE /inscricoes/{id} | 200; 403 evento iniciado | E5-H1 |
| Inscrições evento | E5-F4 | E5-H4 | GET /eventos/{id}/inscricoes (promotor) | 200; 403 não dono | E4-H4 |
| Consistência vagas | E5-F5 | E5-H5 | Lock otimista / transação | Nenhuma vaga negativa | E5-H1 |
| Auditoria inscrições | E5-F6 | E5-H6 | Log criação / cancelamento / listagens | Logs RNF completos | E5-H1..H3 |

### E6 – Notificações & Mensageria
| Feature | Código | História | Descrição | Critérios | Dependências |
|---------|--------|----------|-----------|----------|--------------|
| Infra fila broker | E6-F1 | E6-H1 | Subir broker (ex: Rabbit/Kafka) | Broker acessível | E1-H3 |
| Publicar eventos domínio | E6-F2 | E6-H2 | Eventos: criação publicada, edição crítica, cancelamento, inscrição | Mensagens idempotentes | E4-H1,E4-H5,E4-H6,E5-H1 |
| Consumir emails | E6-F3 | E6-H3 | Serviço Notificações consome e envia email | 99% <10s | E6-H2 |
| Retry & DLQ | E6-F4 | E6-H4 | Reprocessamento + fila morta | Mensagens não perdidas | E6-H3 |
| Auditoria notificações | E6-F5 | E6-H5 | Log de envio e falhas | Logs completos | E6-H3 |

### E7 – BFF & Agregação
| Feature | Código | História | Descrição | Critérios | Dependências |
|---------|--------|----------|-----------|----------|--------------|
| Gateway/BFF setup | E7-F1 | E7-H1 | Serviço BFF valida JWT + correlationId | 100% chamadas com ID | E2-H7 |
| Orquestra login/cadastro | E7-F2 | E7-H2 | Fluxos combinados p/ frontend | Menos 2 roundtrips médios | E7-H1,E3-H1,E2-H1 |
| Agregar dados eventos | E7-F3 | E7-H3 | Endpoint consolidado detalhes + inscrição status | 1 chamada retorna tudo | E5-H1,E4-H4 |
| Cache camada BFF | E7-F4 | E7-H4 | Cache listagens (5m) / detalhes (2m) | Hit rate >40% | E7-H3 |
| Rate limit edge | E7-F5 | E7-H5 | Rate por IP (listagens / login proxy) | Requisições fora limite → 429 | E7-H1 |

### E8 – Frontend MVP
| Feature | Código | História | Descrição | Critérios | Dependências |
|---------|--------|----------|-----------|----------|--------------|
| UI Autenticação | E8-F1 | E8-H1 | Tela login + renovação silenciosa | Mantém sessão 1h renovável | E2-H1,E2-H2 |
| UI Cadastro | E8-F2 | E8-H2 | Tela registro + validações básicas | Erros campo exibidos | E3-H1 |
| UI Listagem eventos | E8-F3 | E8-H3 | Página com filtros básicos | Paginação funciona | E4-H2,E4-H3 |
| UI Detalhe + Inscrição | E8-F4 | E8-H4 | Página detalhe + botão inscrever/cancelar | Atualiza vagas em real-time (refetch) | E5-H1,E5-H3 |
| UI Perfil usuário | E8-F5 | E8-H5 | Exibir/editar perfil | Atualização otimista | E3-H3 |

### E9 – Observabilidade & Hardening
| Feature | Código | História | Descrição | Critérios | Dependências |
|---------|--------|----------|-----------|----------|--------------|
| Métricas Prometheus | E9-F1 | E9-H1 | Exportar métricas core | Latência p95 exposta | E1-H4 |
| Tracing distribuído | E9-F2 | E9-H2 | OpenTelemetry + correlationId | Trace 100% requests críticos | E9-H1 |
| Dashboards | E9-F3 | E9-H3 | Grafana (auth, eventos, inscrições) | Dashboards padronizados | E9-H1 |
| Alertas SLA | E9-F4 | E9-H4 | Alertas login, criação evento, inscrição | Alertas em canais definidos | E9-H3 |
| Hardening segurança | E9-F5 | E9-H5 | Headers, HSTS, body limit, audit refine | OWASP baseline aprovado | E2-H7,E7-H1 |

### E10 – Expansões Futuras (Backlog)
| Ideia | Código | Descrição | Pré-condição |
|-------|--------|-----------|--------------|
| MFA | E10-I1 | TOTP / WebAuthn | E2 completo |
| Lista de espera eventos | E10-I2 | Fila quando esgotado | E5-H1 |
| Pagamentos | E10-I3 | Status pendente/confirmada | E5 baseline |
| Reativar conta | E10-I4 | Endpoint reativação | E3-H6 |
| Exportação LGPD | E10-I5 | Dump dados pessoais | E3 completo |
| Webhooks parceiros | E10-I6 | Eventos push externos | E6 estável |

## 4. Sequenciamento de Entrega (Sprint View)

| Sprint | Objetos Prioritários | DoD Resumido |
|--------|----------------------|--------------|
| S1 | E1-H1..H5, E2-H1 (esqueleto login) | Build+test CI, login básico funcionando local |
| S2 | E2-H2..H7 | Fluxos auth completos, rate limit e auditoria |
| S3 | E3-H1..H4 | Cadastro + perfil + promoção fluxo admin |
| S4 | E4-H1,H2,H4 | CRUD evento base + listagem + detalhes |
| S5 | E4-H3,H5,H7 + E5-H1,H2 | Filtros, edição evento, inscrição criar/listar |
| S6 | E5-H3..H6 + E4-H6 + E6-H1,H2 | Cancelar inscrição, cancelar evento, mensageria básica |
| S7 | E6-H3..H5 + E7-H1..H4 + E8-H1,H2 | Notificações email, BFF orquestração, UI auth+cadastro |
| S8 | E7-H5 + E8-H3..H5 + E9-H1..H3 | UI eventos/inscrições + métricas & tracing |
| S9 | E9-H4,H5 + seleção backlog E10 | Alertas, hardening, início de expansão |

## 5. Critérios Gerais de Qualidade
- Code review obrigatório para merge
- Lint + testes unitários passam no CI
- Zero vulnerabilidades altas (scanner SAST/Dependabot)
- Logs sem dados sensíveis (hash de senha, tokens)
- Respostas em conformidade com envelope padrão

## 6. Gestão de Riscos (Resumo)
| Risco | Impacto | Mitigação |
|-------|---------|-----------|
| Acoplamento excessivo inicial | Alto | Definir contratos OpenAPI cedo |
| Falta de testes de concorrência (vagas/refresh) | Médio | Testes carga direcionados S5/S6 |
| Escalada complexidade mensageria | Médio | Introduzir broker apenas S6 |
| Deriva de requisitos | Médio | Revisão backlog a cada sprint |
| Latência consultas filtros | Médio | Índices planejados antes de S5 |

## 7. Definition of Done (por história)
- Código implementado e revisado
- Testes (unit + integração relevante) verdes
- Documentação endpoint atualizada (se aplicável)
- Logs e métricas instrumentados
- Critérios de aceite atendidos
- Sem regressões (smoke suite)

## 8. Próximos Passos Imediatos
1. Validar escolha mono-repo vs multi-repo (decisão arquitetural)  
2. Montar templates reutilizáveis (README, CONTRIBUTING, pull request)  
3. Criar backlog no board (Jira/GitHub Projects) importando tabela de histórias  
4. Iniciar Sprint 1 com foco em E1-H1..H5 + esqueleto E2-H1  

---
Documento gerado em 2025-08-30.
