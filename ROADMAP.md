# 🗺️ ROADMAP — Dia Organizado v1.0

> Fonte da verdade do projeto. Atualizado a cada entrega importante.
> Legenda: ✅ concluído · 🔜 próxima etapa · ⏳ depende do usuário · ⛔ requer app nativo (Android/iOS)

## 🛡️ Pilares invioláveis (nunca remover/quebrar)
Design **Sacred Order** · **Supabase** (Postgres + Auth + Realtime) · **comando de voz**
(Gemini + fallback por regras) · **conversa contínua hands-free** · **confirmação antes de
executar** · **prevenção de duplicidade** · **modo offline capturar + confirmar**.

---

## ✅ JÁ CONCLUÍDO
- App Flutter + design Sacred Order + navegação responsiva (menu lateral / barra inferior)
- Supabase (Postgres, RLS, tempo real) + modo local de reserva
- Cadastro, login e "lembrar e-mail e senha"
- Agenda, Tarefas, Notas, Versículo do dia
- Assistente de voz: Gemini grátis + fallback por regras, conversa contínua hands-free,
  estados visuais (🟢🔵🟣⚪), confirmação antes de executar, prevenção de duplicidade,
  modo offline "capturar + confirmar"
- Build release servida localmente (`tool/serve.dart`)

---

## 📌 ROADMAP OFICIAL (ordem de execução)

### ⏳ FASE 0 — Publicar na nuvem (PRIORIDADE ZERO)
- [ ] Verificar workflow `.github/workflows/deploy.yml`
- [ ] **Usuário:** GitHub → Settings → Pages → Source: GitHub Actions
- [ ] Validar em `https://eberdasilva147-design.github.io/DIA-ORGANIZADO/` (PC + celular)

### ✅ FASE 1 — Usabilidade e consistência (CONCLUÍDA)
- [x] Tarefas concluídas: excluir por item
- [x] Tarefas pendentes: botão "Reagendar"
- [x] Nova tarefa: campo Observação + Antecedência do lembrete (no horário/5/15/30min/1h/2h/1dia/personalizado)
- [x] Sincronização Home ↔ Tarefas ↔ Agenda (mesmos providers)
- [x] Home: "Próximos Compromissos" → "TODOS OS COMPROMISSOS"
- [x] Home: "Foco do Dia" → "Compromissos de Hoje"
- [x] Home: nova seção "ATIVIDADES DOS PRÓXIMOS 5 DIAS"
- [x] Home: ocultar compromisso/lembrete da Home
- [x] Notas: editar e excluir
- [x] Agenda: exclusão com confirmação + tempo real
- [x] Agenda: navegação por gestos (deslizar troca o mês)
- [x] Agenda: indicadores 🟢 confirmado / 🟡 pendente / 🔵 hoje / 🔴 atrasado + editar/reagendar/excluir nos cards
- [x] Home: destaque premium do botão "Nova Tarefa"

### ✅ FASE 2 — Tema e sistema de cores (CONCLUÍDA 2026-06-15)
- [x] Refatorar `AppColors` fixo → sistema dinâmico (`DiaColors` ThemeExtension)
- [x] Dark mode real (Sacred Order warm dark) — troca imediata via toggle em Configurações
- [x] Persistência do tema (SettingsProvider + shared_preferences)
- [x] Todas as telas, cards e modais respondem ao tema

### ✅ FASE 3 — Lixeira (CONCLUÍDA 2026-06-16)
- [x] Soft-delete em tarefas, compromissos e notas (deleted_at no Supabase)
- [x] Tela Lixeira no menu lateral (abaixo de Comando de Voz) com 3 abas
- [x] Restaurar e Excluir definitivamente por item
- [x] Esvaziar Lixeira (todos os itens de uma vez)
- [x] Contador de dias restantes (30 dias de retenção)
- [ ] Exportação de dados (CSV; depois PDF/Excel) — movida para backlog

### ✅ FASE 4 — Editar por voz (CONCLUÍDA 2026-06-15)
- [x] Editar tarefa por voz: mudar data/hora e prioridade ("editar tarefa X — amanhã às 10h")
- [x] Editar compromisso por voz: mudar data/hora e prioridade
- [x] Editar nota por voz: acrescentar conteúdo ("editar nota X — adicionar leite e ovos")
- [x] Restaurar da lixeira por voz: tarefas, compromissos e notas
- [x] Fallback inteligente: quando IA indisponível, interpreta intenção, datas, horários e prioridade
- [x] IA (Gemini): corrigida para soft-delete (lixeira) em vez de exclusão permanente
- [x] "Jogar X para amanhã" e outros comandos informais reconhecidos

### ✅ FASE 5 — Notificações/permissões (CONCLUÍDA 2026-06-17)
- [x] Som/vibração/modo silencioso/horário de silêncio/não perturbar (UI + prefs)
- [x] Orientação clara quando a permissão for negada

### ✅ FASE 6 — Idiomas (CONCLUÍDA 2026-06-17)
- [x] Infraestrutura i18n: ARB files PT/EN/ES + flutter gen-l10n + `context.l10n`
- [x] Seletor de idioma em Configurações (PT-BR · EN-US · ES-PY)
- [x] Todas as telas e widgets com strings via l10n
- [x] Extensões `priorityLabel`, `statusLabel`, `priorityBadge` contextuais
- [x] Formato de datas dinâmico (locale-aware em Agenda)

### ⛔ FASE 7 — Recursos nativos (Android/iOS)
- [ ] Widgets, tela de bloqueio, notificações persistentes, integração com o dispositivo

---

## 💡 BACKLOG OFICIAL (ideias futuras — nada é descartado)
> Capturado para não se perder. Será priorizado depois.
- Integração com o calendário do celular (Google Calendar / Apple)
- Dashboard semanal
- Estatísticas de produtividade
- IA avançada (mais capacidades no assistente)
- Widgets adicionais
- Relatórios
- Outras integrações futuras

---

## 🐞 CORREÇÕES E AJUSTES (bugs / problemas)
> Itens de correção, separados das funcionalidades.
- _(nenhum aberto no momento — registrar aqui quando surgir)_

---

## ⚙️ Como novos pedidos são tratados (governança)
Antes de implementar, cada pedido é classificado:
- **Tipo:** Roadmap / Backlog / Correção
- **Impacto:** baixo / médio / alto
- **Complexidade:** baixa / média / alta
- **Dependências:** partes do sistema afetadas
- **Ordem recomendada:** em qual fase entra
- **Anti-retrabalho:** já existe? já foi pedido? dá para reusar código?

A cada entrega importante: atualizar este `ROADMAP.md` (status) e o `CHANGELOG.md`.
