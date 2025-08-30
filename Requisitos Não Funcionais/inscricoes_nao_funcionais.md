# 📄 Requisitos Não Funcionais — Inscrições

## **INS-RNF-001 — Consistência de Vagas**
Descrição: Operações de inscrição/cancelamento devem garantir que vagas não fiquem negativas ou ultrapassem capacidade (lock otimista ou transação).  
Critério: Teste concorrente não produz contagem inconsistente.

## **INS-RNF-002 — Validação de Entrada**
Descrição: Validar UUIDs (eventoId, inscricaoId) e impedir corpo com campos extras inesperados.  
Critério: Campos inválidos → 400.

## **INS-RNF-003 — Desempenho**
Descrição: Criar/cancelar inscrição p95 ≤ 2s; listagens p95 ≤ 1.5s sob carga normal.  
Critério: Métricas de performance atendem limites.

## **INS-RNF-004 — Auditoria**
Descrição: Logar criação, cancelamento e listagens sensíveis (por evento) com correlationId, usuário, evento, timestamp.  
Critério: Amostra de logs contém todos os campos.

## **INS-RNF-005 — Notificações Assíncronas**
Descrição: Enviar mensagens a serviço de notificações para confirmação/cancelamento (at-least-once, idempotente).  
Critério: Reenvios não duplicam email.

## **INS-RNF-006 — Segurança & Autorização**
Descrição: Garantir que somente dono veja/cancele suas inscrições; somente promotor dono ou admin vê inscrições de evento.  
Critério: Tentativa não autorizada → 403.

## **INS-RNF-007 — Rate Limiting**
Descrição: Limitar tentativas de inscrição por usuário/evento (ex: 5/min) para mitigar abuso.  
Critério: Excesso → 429.

## **INS-RNF-008 — Observabilidade**
Descrição: Métricas de inscrições criadas, canceladas, falhas, latência, contagem por status.  
Critério: Endpoint /metrics (interno) expõe contadores e histogramas.

## **INS-RNF-009 — Resiliência**
Descrição: Fila/retentativa para atualizações de vagas se serviço de eventos estiver momentaneamente indisponível; fallback recalcula posterior.  
Critério: Falha temporária não causa perda de consistência final.

## **INS-RNF-010 — Paginação Futuras**
Descrição: Preparar listagem por evento para paginação (parâmetros page/size) mesmo se primeira versão não implementar.  
Critério: Especificação aceita parâmetros sem erro.

## **INS-RNF-011 — Conformidade LGPD**
Descrição: Expor apenas dados mínimos de usuário (nome, email) em listagem de evento; nenhum dado sensível adicional.  
Critério: Revisão confirma ausência de campos extras.

## **INS-RNF-012 — Disponibilidade**
Descrição: Meta 99.5% mensal endpoints de criação/listagem.  
Critério: Monitoramento confirma uptime ≥ meta.

## **INS-RNF-013 — Integridade Transacional**
Descrição: Uso de transações para criação inscrição + decremento de vagas (ou marcação para recomputar).  
Critério: Crash no meio não deixa estado parcial.

## **INS-RNF-014 — Cache Leve**
Descrição: Opcional cache curto (≤30s) para listagem de inscrições por evento (apenas para promotor) invalidado em alterações.  
Critério: Após nova inscrição, cache invalidado.

## **INS-RNF-015 — Proteção Contra Repetição**
Descrição: Idempotência via chave (usuarioId+eventoId) impedindo duplicidade em reenvio.  
Critério: Repetição retorna 409 sem duplicar.
