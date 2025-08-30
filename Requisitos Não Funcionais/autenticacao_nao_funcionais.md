# 📄 Requisitos Não Funcionais — Autenticação

## **AUT-RNF-001 — Política de Senhas**
Descrição: Mínimo 8 caracteres, conter maiúscula, minúscula, dígito e caractere especial; rejeitar 3 últimas senhas (se histórico implementado futuramente).
Critério de Aceitação:
- Senha fora do padrão → 400.

## **AUT-RNF-002 — Hash & Armazenamento Seguro**
Descrição: Usar algoritmo forte (Argon2id preferencial ou bcrypt custo ≥ 12). Salts únicos por senha. Nunca armazenar em texto claro.
Critério de Aceitação:
- Auditoria verifica formato de hash e ausência de plaintext.

## **AUT-RNF-003 — Proteção Contra Brute Force**
Descrição: Máx 5 falhas consecutivas → bloqueio temporário 15 min; usar contador por email + IP; expurgar contador após sucesso.
Critério de Aceitação:
- 6ª tentativa no período retorna 429 com Retry-After.

## **AUT-RNF-004 — Rate Limiting Recuperação**
Descrição: Máx 3 solicitações de recuperação por email a cada 60 min.
Critério de Aceitação:
- 4ª tentativa retorna 429.

## **AUT-RNF-005 — Expiração de Tokens**
Descrição: tokenAcesso expira em ≤ 1h; refreshToken em ≤ 7d; suportar configuração via ambiente.
Critério de Aceitação:
- Tokens emitidos refletem tempos configurados.

## **AUT-RNF-006 — Revogação de Refresh Tokens**
Descrição: Refresh token antigo inválido após renovação; suportar revogação explícita em logout (futuro) e blacklist em comprometimento.
Critério de Aceitação:
- Uso de refresh revogado retorna 401.

## **AUT-RNF-007 — Segurança JWT**
Descrição: Assinatura RS256 (preferível) ou HS256 com chave robusta (>256 bits); incluir `aud`, `iss`, `iat`, `exp`, `sub`, `perfil`; clock skew tolerado ±60s.
Critério de Aceitação:
- Tokens inválidos ou com claims ausentes rejeitados com 401.

## **AUT-RNF-008 — Observabilidade & Auditoria**
Descrição: Logar login, falhas, bloqueios, refresh, troca/redefinição de senha (sem dados sensíveis). Incluir correlationId, IP, user-agent, resultado, tempo.
Critério de Aceitação:
- Amostra de logs contém todos os campos esperados.

## **AUT-RNF-009 — Notificações**
Descrição: Enviar email em troca de senha, redefinição e (futuro) login de novo dispositivo.
Critério de Aceitação:
- Eventos disparam mensagens para serviço de notificações.

## **AUT-RNF-010 — Desempenho**
Descrição: Login e refresh p95 ≤ 500ms; operações de recuperação/troca ≤ 800ms sob carga normal.
Critério de Aceitação:
- Testes de performance confirmam SLAs.

## **AUT-RNF-011 — Disponibilidade**
Descrição: Meta 99.7% mensal para endpoints de login e refresh.
Critério de Aceitação:
- Monitoramento confirma uptime ≥ meta.

## **AUT-RNF-012 — Resiliência**
Descrição: Requisições ao serviço de notificações usam retry exponencial (máx 3) e fallback log local se indisponível.
Critério de Aceitação:
- Indisponibilidade externa não impede fluxo principal.

## **AUT-RNF-013 — Proteção de Dados**
Descrição: Nunca incluir hash de senha, tokens ou segredos nos logs; mascarar emails parcialmente quando em erros (configurável).
Critério de Aceitação:
- Verificação manual mostra masking aplicado.

## **AUT-RNF-014 — Conformidade LGPD**
Descrição: Minimizar dados pessoais nos tokens; permitir invalidação e remoção de refresh tokens ao excluir conta.
Critério de Aceitação:
- Exclusão de usuário remove refresh tokens associados.

## **AUT-RNF-015 — Integridade & Concorrência**
Descrição: Uso de locks otimistas para revogação / renovação em ambientes distribuídos; impedir reutilização simultânea de mesmo refresh.
Critério de Aceitação:
- Teste de race usa mesmo refresh duas vezes: segunda retorna 401.

## **AUT-RNF-016 — Alertas de Segurança**
Descrição: Gatilhos para alertar (monitoramento) quando taxa de falha de login > limiar (ex: >20% em 5 min) ou muitos bloqueios.
Critério de Aceitação:
- Simulação gera evento de alerta.

## **AUT-RNF-017 — Hardening**
Descrição: Desabilitar listagem de verbos inseguros, usar HTTPS estrito (HSTS), cabeçalhos de segurança (no BFF), limitar corpo a 16KB.
Critério de Aceitação:
- Teste de segurança valida cabeçalhos e limites.

## **AUT-RNF-018 — Escalabilidade**
Descrição: Suporte horizontal (stateless) com storage central para refresh tokens (DB/Redis) e contador de falhas.
Critério de Aceitação:
- Escala linear demonstrada até alvo inicial.
