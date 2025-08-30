# 📄 Requisitos Não Funcionais — Eventos

## **EVT-RNF-001 — Validação de Campos**
Descrição:
Validar título (5–100), descrição (10–500), local (3–100; letras, números, espaços e hífens), capacidade (1–10.000), preço (0–9.999,99), URLs de banner (JPG/PNG/WebP), datas coerentes (início futuro >= +1h; fim > início).

Critérios de Aceitação:
- Payload inválido retorna 400 com lista de campos.
- Payload válido persiste evento corretamente.

---
## **EVT-RNF-002 — Consistência de Datas**
Descrição:
Garantir que dataInicio seja futura (≥ +1h) na criação; na edição, se evento já iniciado, não permitir alterar dataInicio para antes do horário atual; dataFim sempre > dataInicio.

Critérios de Aceitação:
- Violação retorna 400.

---
## **EVT-RNF-003 — Cálculo de Vagas**
Descrição:
Vagas restantes calculadas dinamicamente (capacidade - inscrições confirmadas) consultando serviço de inscrições; nunca valor negativo.

Critérios de Aceitação:
- Eventos esgotados exibem status "esgotado" e vagasRestantes = 0.

---
## **EVT-RNF-004 — Cache**
Descrição:
Listagem pública: cache 5 min (BFF). Detalhes do evento: cache 2 min. Invalidar cache em criação/edição/cancelamento.

Critérios de Aceitação:
- Após edição, nova consulta reflete alterações.

---
## **EVT-RNF-005 — Paginação & Ordenação**
Descrição:
Paginação obrigatória (padrão página=1, tamanho=20, máximo=20 público e 100 interno/meus-eventos). Ordenação default dataInicio ASC (listagem/filtrar) e dataCriacao DESC (meus eventos). Campos permitidos: dataInicio, titulo, preco, capacidade.

Critérios de Aceitação:
- Pedido com tamanho > limite ajustado ao máximo.

---
## **EVT-RNF-006 — Pesquisa & Filtros**
Descrição:
Filtros opcionais combináveis: intervalo de datas, local (contains case-insensitive), palavra-chave em título/descrição, faixa de preço, status (ativo, esgotado), ordenação configurável.

Critérios de Aceitação:
- Filtros inválidos → 400; ausência de filtros → retorna todos ativos/esgotados.

---
## **EVT-RNF-007 — Segurança & Auditoria**
Descrição:
Registrar logs de criação, edição, cancelamento, acesso a detalhes e listagens (para métricas agregadas). Cada log com timestamp, promotorId (quando aplicável), eventoId, ação, correlationId. Impedir exposição de dados sensíveis do promotor. Implementar dupla confirmação opcional para cancelamento.

Critérios de Aceitação:
- Logs presentes para todas as operações críticas.

---
## **EVT-RNF-008 — Rate Limiting**
Descrição:
Limitar criação a 10 eventos por promotor por hora (janela deslizante). Retornar 429 quando excedido com Retry-After.

Critérios de Aceitação:
- 11ª tentativa dentro da janela → 429.

---
## **EVT-RNF-009 — Integrações Assíncronas**
Descrição:
Publicar eventos em fila / broker para serviço de notificações (criação publicada, edição relevante, cancelamento). Garantir pelo menos uma entrega (at-least-once) com idempotência consumidora.

Critérios de Aceitação:
- Mensagem publicada por ação; duplicados ignorados no consumidor.

---
## **EVT-RNF-010 — Desempenho**
Descrição:
Tempo resposta sob carga normal: criação/edição ≤ 3s; listagens e detalhes ≤ 2s (p95). Filtros avançados ≤ 3s (p95) com índice adequado.

Critérios de Aceitação:
- Testes de performance confirmam SLAs (p95) dentro dos limites.

---
## **EVT-RNF-011 — Escalabilidade**
Descrição:
Estrutura preparada para horizontal scaling: leitura intensiva servida por cache e índices; filtros com paginação eficiente e índices compostos (dataInicio, status, local). Suporte a sharding futuro.

Critérios de Aceitação:
- Teste de carga demonstra escala linear até limite definido inicial.

---
## **EVT-RNF-012 — Confiabilidade & Integridade**
Descrição:
Transações ACID para criação/edição/cancelamento. Evitar race em edição de capacidade com lock otimista (versão). Capacidade nunca inferior a inscrições confirmadas.

Critérios de Aceitação:
- Conflito de versão → 409.

---
## **EVT-RNF-013 — Observabilidade**
Descrição:
Expor métricas (latência, contagem por status, erros, hit ratio cache) e traces distribuídos com correlationId propagado.

Critérios de Aceitação:
- Métricas acessíveis no endpoint /metrics (interno) ou sistema APM.

---
## **EVT-RNF-014 — Resiliência**
Descrição:
Circuit breakers e retry exponencial para chamadas ao serviço de inscrições / notificações. Fallback: se serviço de inscrições indisponível, retornar vagasRestantes como null e indicar degradação em header `X-Degraded: inscriptions`.

Critérios de Aceitação:
- Falha externa não causa erro 500 geral; resposta degrade controlada.

---
## **EVT-RNF-015 — Conformidade & LGPD**
Descrição:
Dados pessoais do promotor limitados a nome e email público; logs não armazenam informações sensíveis além do necessário para auditoria.

Critérios de Aceitação:
- Revisão confirma ausência de dados sensíveis indevidos.

---
## **EVT-RNF-016 — Disponibilidade**
Descrição:
Meta de disponibilidade 99.5% mensal para leitura (listagem/detalhes); operações de escrita podem ter janelas de manutenção comunicadas.

Critérios de Aceitação:
- Monitoramento registra uptime dentro do alvo.

---
## **EVT-RNF-017 — Internacionalização Futuras**
Descrição:
Estrutura de mensagens com chaves para futura localização (pt-BR default). Não hardcode de textos de erro no domínio.

Critérios de Aceitação:
- Mensagens retiradas de catálogo central.

---
## **EVT-RNF-018 — Segurança de API**
Descrição:
Validar JWT, aplicar princípio de menor privilégio, limitar campos no output, sanitizar entrada (evitar XSS via campos texto), usar HTTPS obrigatório.

Critérios de Aceitação:
- Testes de segurança aprovados (lint OWASP top inputs).

---
