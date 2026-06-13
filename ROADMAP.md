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

### 🔜 FASE 1 — Usabilidade e consistência
- [ ] Tarefas concluídas: excluir por item
- [ ] Tarefas pendentes: botão "Reagendar"
- [ ] Nova tarefa: campo Observação + Antecedência do lembrete (no horário/5/15/30min/1h/2h/1dia/personalizado)
- [ ] Sincronização Home ↔ Tarefas ↔ Agenda (fonte única)
- [ ] Home: "Próximos Compromissos" → "TODOS OS COMPROMISSOS"
- [ ] Home: "Foco do Dia" → "Compromissos de Hoje"
- [ ] Home: nova seção "ATIVIDADES DOS PRÓXIMOS 5 DIAS"
- [ ] Home: ocultar compromisso/lembrete da Home
- [ ] Notas: editar e excluir
- [ ] Agenda: exclusão com confirmação + tempo real
- [ ] Agenda: navegação por gestos (deslizar troca o mês)
- [ ] Agenda: indicadores 🟢 confirmado / 🟡 pendente / 🔵 hoje / 🔴 atrasado + editar/reagendar/excluir nos cards
- [ ] Home: destaque premium do botão "Nova Tarefa"

### 🔜 FASE 2 — Tema e sistema de cores (fundacional)
- [ ] Refatorar `AppColors` fixo → sistema dinâmico
- [ ] Dark mode real + cores personalizáveis (dourado/azul/verde/vermelho/roxo/personalizado)
- [ ] Persistência + troca imediata em todas as telas

### 🔜 FASE 3 — Lixeira + exportação de dados
- [ ] Soft-delete (tarefa/compromisso/nota) → Lixeira, retenção 30 dias, restaurar/excluir definitivo
- [ ] Exportação de dados (CSV; depois PDF/Excel)

### 🔜 FASE 4 — Editar por voz (completar)
- [ ] Editar tarefa por voz + editar nota por voz (o resto já funciona — não reconstruir)

### 🔜 FASE 5 — Notificações/permissões (UI agora) + indicadores
- [ ] Som/vibração/modo silencioso/horário de silêncio/não perturbar (UI + prefs)
- [ ] Orientação clara quando a permissão for negada

### 🔜 FASE 6 — Idiomas
- [ ] i18n PT-BR / ES-PY / EN-US (menus, botões, mensagens, voz, configurações)

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
