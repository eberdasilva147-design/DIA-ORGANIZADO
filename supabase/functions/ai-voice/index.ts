// Edge Function "ai-voice" — interpreta comandos de voz com o Gemini (free tier).
// A chave GEMINI_API_KEY fica em secret no Supabase; o app nunca a vê.
// Requer usuário autenticado (JWT do Supabase).

import { createClient } from "npm:@supabase/supabase-js@2";

const GEMINI_URL =
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const SYSTEM_PROMPT = `Você é o assistente de voz do app "Dia Organizado", um app de organização pessoal em português do Brasil.

Você recebe o que o usuário FALOU (transcrito), o contexto atual (data de hoje, tarefas pendentes e compromissos com seus IDs) e o histórico da conversa.

Sua resposta DEVE seguir o JSON schema fornecido:
- "reply": resposta curta e natural em pt-BR, pois será FALADA em voz alta (1-2 frases, sem emojis, sem markdown, sem listas longas).
- "actions": lista de ações a executar no app (pode ser vazia se for só conversa/pergunta).

Tipos de ação e seus parâmetros:
- create_task: nome, data (dd/MM/yyyy), horario (HH:mm), prioridade ("h"|"m"|"l"), lembrete (boolean)
- complete_task: id (use o ID exato do contexto)
- delete_task: id
- reschedule_task: id, data, horario
- create_appointment: titulo, data (dd/MM/yyyy), horario (HH:mm), local (pode ser vazio)
- delete_appointment: id
- create_note: titulo, corpo

Regras:
- Datas sempre dd/MM/yyyy. Resolva "amanhã", "sexta", "dia 20" usando a data de hoje do contexto.
- Horário padrão 08:00 se não informado. Prioridade padrão "m". Lembrete padrão true.
- Para concluir/excluir/reagendar, encontre a tarefa/compromisso no contexto pelo nome aproximado e use o ID. Se não encontrar, não execute ação e explique no reply.
- Para perguntas ("quais minhas tarefas?"), responda no reply usando o contexto, sem ações.
- Use o histórico para entender referências ("muda pra sexta" = o último item mencionado).
- Seja proativo e simpático, mas breve.`;

const RESPONSE_SCHEMA = {
  type: "OBJECT",
  properties: {
    reply: { type: "STRING" },
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
  required: ["reply", "actions"],
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
