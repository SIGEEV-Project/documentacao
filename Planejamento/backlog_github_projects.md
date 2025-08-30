# Backlog para Importação GitHub Projects

Arquivo CSV complementar: `backlog_github_projects.csv`

Campos principais:
- Title: Título da issue (inclui epic/identificador)
- Body: Descrição curta + critérios de aceite
- Labels: epics, feature, tipo, área, prioridade
- Milestone: Sprint alvo (S1..S9 ou Backlog)

## Legendas
- priority: P1 (crítico), P2 (alto), P3 (médio), Future (não priorizado)
- type: story (história), idea (ideia futura)
- epic: E1..E10 conforme cronograma

## Resumo por Sprint
| Sprint | Quantidade | Principais Focos |
|--------|-----------|------------------|
| S1 | 6 | Infra base + login básico |
| S2 | 6 | Fluxos completos auth + segurança |
| S3 | 7 | Usuários (cadastro, perfil, permissões) |
| S4 | 3 | CRUD e listagem primária de eventos |
| S5 | 6 | Filtros, edição eventos, inscrições básicas |
| S6 | 8 | Cancelamentos, mensageria inicial, consistência |
| S7 | 10 | Notificações, BFF, UI auth/cadastro |
| S8 | 9 | UI eventos/inscrições, métricas, tracing |
| S9 | 5 | Alertas, hardening, backlog grooming |
| Backlog | 6 | Expansões futuras |

## Métricas Potenciais
- Lead time médio por história (alvo < 7 dias)
- Throughput por sprint
- Taxa de spillover (alvo < 15%)

## Próximos Passos para Importar
1. Acesse GitHub Project (new experience)
2. Use opção de importar CSV (View → Table → ... → Import)
3. Verifique mapeamento: Title -> Title, Body -> Body, Labels -> Labels, Milestone -> Milestone
4. Após importação, criar views por Sprint e por Epic

## Dicas de Uso
- Criar automação: Ao mover para Done, exigir campo "QA Check" marcado
- Adicionar campo custom: Story Points (Fib: 1,2,3,5,8)
- Aplicar filtro semanal: is:open milestone:S(current)

---
Gerado automaticamente.
