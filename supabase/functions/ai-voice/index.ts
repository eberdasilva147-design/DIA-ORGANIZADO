// Edge Function "ai-voice" — interpreta comandos de voz com o Gemini (free tier).
// A chave GEMINI_API_KEY fica em secret no Supabase; o app nunca a vê.
// Requer usuário autenticado (JWT do Supabase).

import { createClient } from "npm:@supabase/supabase-js@2";

// Flash-Lite: o mais rápido do free tier (~1000 comandos/dia) e sem
// "thinking" demorado — ideal para interpretar comandos de voz.
const GEMINI_URL =
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const SYSTEM_PROMPT = `Você é o assistente de voz do app "Dia Organizado", um app de organização pessoal em português do Brasil.

Estilo Gemini Live: rápido, natural e MUITO conciso — UMA frase curta por resposta, sem emojis, sem markdown, sem listas longas.

Você recebe o que o usuário falou, o CONTEXTO (data de hoje, tarefas pendentes e compromissos com IDs) e o histórico da conversa.

REGRAS DE OURO:
1. Respostas curtíssimas, faladas em voz alta. Uma frase.
2. NUNCA execute ações (deixe "actions" vazio) até o usuário CONFIRMAR explicitamente ("sim", "pode", "confirma", "ok", "isso", "claro").
3. Se faltar informação, faça UMA pergunta curta por vez. Ex.: usuário "agende uma reunião amanhã às 8" → você "Com quem é a reunião?".
4. Quando tiver os dados, apresente um resumo curto e peça confirmação, com "actions" vazio e conversation_done=false. Ex.: "Reunião com Bio Durango amanhã às 8h. Confirmo?".
5. Só DEPOIS que o usuário confirmar, emita as actions e responda algo curto ("Pronto, agendado.") com conversation_done=true.
6. ANTES de propor criar um compromisso, verifique no CONTEXTO:
   - DUPLICIDADE: mesmo título + mesma data + mesmo horário → avise "Já existe um compromisso parecido nesse horário. Crio mesmo assim?" e NÃO proponha criação até o usuário decidir.
   - CONFLITO: outro compromisso na mesma data e horário → avise e pergunte se mantém os dois, reagenda ou substitui.
7. CONFIANÇA: se não entendeu o pedido (<70%), pergunte. Se há ambiguidade (70-95%), peça só o esclarecimento que falta. Só apresente resumo+confirmação quando estiver seguro (>95%).
8. Datas relativas ("amanhã", "sexta", "dia 20") resolvidas pela data de hoje do contexto. Formato data dd/MM/yyyy, horário HH:mm. Horário padrão 08:00, prioridade padrão "m", lembrete padrão true.
9. Perguntas simples ("o que tenho hoje?") → responda curto pelo contexto, sem ações, conversation_done=true.
10. Use o histórico para juntar complementos ("com o pessoal da Bio Durango" completa a reunião em andamento).

CAMPOS DE CONTROLE:
- conversation_done = true quando você CONCLUIU (executou ação confirmada, ou respondeu uma pergunta e nada mais está pendente). false quando está perguntando algo ou aguardando confirmação.

Tipos de ação (só quando confirmado):
- create_task: nome, data, horario, prioridade ("h"|"m"|"l"), lembrete
- complete_task: id | delete_task: id | reschedule_task: id, data, horario
- create_appointment: titulo, data, horario, local
- delete_appointment: id | create_note: titulo, corpo`;

const RESPONSE_SCHEMA = {
  type: "OBJECT",
  properties: {
    reply: { type: "STRING" },
    conversation_done: { type: "BOOLEAN" },
    actions: {
      type: "ARRAY",
      items: {
        type: "OBJECT",
        properties: {
          type: {
            type: "STRING",
            enum: [
              "create_task",
              "complete_task",
              "delete_task",
              "reschedule_task",
              "create_appointment",
              "delete_appointment",
              "create_note",
              "none",
            ],
          },
          id: { type: "STRING" },
          nome: { type: "STRING" },
          titulo: { type: "STRING" },
          corpo: { type: "STRING" },
          data: { type: "STRING" },
          horario: { type: "STRING" },
          prioridade: { type: "STRING" },
          local: { type: "STRING" },
          lembrete: { type: "BOOLEAN" },
        },
        required: ["type"],
      },
    },
  },
  required: ["reply", "actions", "conversation_done"],
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // ── Autenticação: só usuários logados ────────────────────────────
    const authHeader = req.headers.get("Authorization") ?? "";
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } },
    );
    const { data: userData, error: authError } = await supabase.auth.getUser();
    if (authError || !userData?.user) {
      return json({ error: "unauthorized" }, 401);
    }

    const { message, history = [], context = "" } = await req.json();
    if (!message || typeof message !== "string") {
      return json({ error: "message obrigatório" }, 400);
    }

    // ── Monta a conversa para o Gemini ───────────────────────────────
    const contents = [
      ...history.map((h: { role: string; text: string }) => ({
        role: h.role === "user" ? "user" : "model",
        parts: [{ text: h.text }],
      })),
      {
        role: "user",
        parts: [{ text: `CONTEXTO ATUAL:\n${context}\n\nUSUÁRIO DISSE: ${message}` }],
      },
    ];

    const geminiKey = Deno.env.get("GEMINI_API_KEY");
    if (!geminiKey) return json({ error: "GEMINI_API_KEY não configurada" }, 500);

    const geminiRes = await fetch(`${GEMINI_URL}?key=${geminiKey}`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        system_instruction: { parts: [{ text: SYSTEM_PROMPT }] },
        contents,
        generationConfig: {
          responseMimeType: "application/json",
          responseSchema: RESPONSE_SCHEMA,
          temperature: 0.3,
          // Desliga o "modo pensar" — resposta em ~1s em vez de vários segundos
          thinkingConfig: { thinkingBudget: 0 },
        },
      }),
    });

    // Limite diário do free tier estourado → o app cai no modo básico
    if (geminiRes.status === 429) {
      return json({ error: "quota_exceeded" }, 429);
    }
    if (!geminiRes.ok) {
      const detail = await geminiRes.text();
      console.error("Gemini error:", geminiRes.status, detail);
      return json({ error: "ai_unavailable" }, 502);
    }

    const result = await geminiRes.json();
    const text: string | undefined =
      result?.candidates?.[0]?.content?.parts?.[0]?.text;
    if (!text) return json({ error: "ai_unavailable" }, 502);

    // O schema garante JSON válido com {reply, actions}
    return new Response(text, {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (e) {
    console.error("ai-voice error:", e);
    return json({ error: "ai_unavailable" }, 502);
  }
});

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}
