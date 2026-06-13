# 📓 CHANGELOG — Dia Organizado

Histórico das entregas importantes. Atualizado a cada marco.
Formato: data (AAAA-MM-DD) + resumo do que mudou.

## [Não lançado]
### Governança
- Adotada estrutura de governança: `ROADMAP.md` (roadmap oficial + backlog + correções)
  e `CHANGELOG.md`. Todo novo pedido é classificado antes de implementar; nada é descartado.

---

## 2026-06-13 — Assistente de voz (evolução completa)
- Integração com IA **Google Gemini** (free tier) via Edge Function `ai-voice` no Supabase,
  com fallback automático para o interpretador por regras quando a cota diária estoura.
- **Conversa contínua hands-free**: um toque inicia; o microfone reabre sozinho após cada
  resposta. Estados visuais 🟢 Ouvindo / 🔵 Processando / 🟣 Respondendo / ⚪ Encerrado.
- Encerramento por voz ("encerrar/parar/finalizar"), por inatividade ou pausa manual.
- **Respostas faladas** (TTS pt-BR) e **confirmação antes de executar** qualquer ação.
- **Prevenção de duplicidade** de tarefas/compromissos.
- **Modo offline "capturar + confirmar"**: toda fala vira uma proposta confirmável; frase
  fora dos padrões é capturada como tarefa (nunca se perde) — com opção de virar nota/compromisso.
- Modelo trocado para **Gemini Flash-Lite** com "thinking" desligado (respostas ~1s).

## 2026-06-13 — Migração de backend e publicação
- Backend migrado de Firebase para **Supabase** (Postgres + Auth + Realtime) com RLS.
- Modo local de reserva (shared_preferences) quando não há nuvem.
- Login por e-mail/senha + "lembrar e-mail e senha".
- Código no GitHub (`eberdasilva147-design/DIA-ORGANIZADO`); deploy via Railway e GitHub Pages
  configurados; servidor estático local (`tool/serve.dart`) para a build release.

## 2026-06-13 — Design e estrutura
- Aplicado o design **Sacred Order** (creme + dourado, tipografia Noto Serif / Plus Jakarta Sans).
- Menu lateral no desktop e barra inferior no mobile (navegação responsiva).
- Telas: Home, Tarefas, Agenda, Notas, Comando de Voz, Configurações, Versículo, Login/Cadastro.

## 2026-06-13 — Base do projeto
- App Flutter inicial, instalação do SDK, modelos (tarefa/compromisso/nota/versículo),
  providers, notificações locais e reconhecimento de voz.
