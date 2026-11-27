// Supabase Edge Function "ai": writes recipe steps and suggests meals for the Recipe App.
//
// The app calls it with the signed-in person's session. The function
//   1. counts the request against that person's daily allowance (use_ai in schema.sql),
//   2. asks the AI (Groq's free tier by default; any OpenAI-style chat API works),
//   3. checks the answer and returns it, or gives the request back if the AI failed.
//
// Secrets (Supabase dashboard -> Edge Functions -> Secrets):
//   GROQ_API_KEY  required: the key from console.groq.com
//   AI_MODEL      optional: defaults to openai/gpt-oss-120b
//   AI_BASE_URL   optional: another OpenAI-style endpoint, to switch provider without an app update
// SUPABASE_URL and SUPABASE_ANON_KEY are provided by Supabase automatically.

import { BadRequest, chatBody, parseAnswer, parseRequest } from "./logic.ts";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const reply = (status: number, body: unknown) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });

/** Calls a database function as the signed-in person, so auth.uid() is them. */
async function rpc(name: string, auth: string): Promise<Response> {
  const url = Deno.env.get("SUPABASE_URL")!;
  const key = Deno.env.get("SUPABASE_ANON_KEY") ?? Deno.env.get("SUPABASE_PUBLISHABLE_KEY") ?? "";
  return await fetch(`${url}/rest/v1/rpc/${name}`, {
    method: "POST",
    headers: { apikey: key, Authorization: auth, "Content-Type": "application/json" },
    body: "{}",
  });
}

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (request.method !== "POST") return reply(405, { error: "method" });

  let req;
  try {
    req = parseRequest(await request.json());
  } catch (e) {
    return reply(400, { error: "bad_request", message: e instanceof BadRequest ? e.message : "Send JSON." });
  }

  const auth = request.headers.get("Authorization") ?? "";
  const quota = await rpc("use_ai", auth);
  if (!quota.ok) {
    const err = await quota.json().catch(() => ({}));
    if (err.code === "54000") return reply(429, { error: "daily_limit" });
    if (String(err.message ?? "").includes("Confirm your email")) return reply(403, { error: "confirm_email" });
    return reply(401, { error: "sign_in" });
  }
  const remaining = Number(await quota.json());

  const apiKey = Deno.env.get("GROQ_API_KEY") ?? Deno.env.get("AI_API_KEY");
  if (!apiKey) {
    await rpc("refund_ai", auth);
    return reply(503, { error: "not_configured" });
  }

  try {
    const base = Deno.env.get("AI_BASE_URL") ?? "https://api.groq.com/openai/v1";
    const model = Deno.env.get("AI_MODEL") ?? "openai/gpt-oss-120b";
    const ai = await fetch(`${base}/chat/completions`, {
      method: "POST",
      headers: { Authorization: `Bearer ${apiKey}`, "Content-Type": "application/json" },
      body: JSON.stringify(chatBody(req, model)),
      signal: AbortSignal.timeout(55_000),
    });
    if (!ai.ok) {
      console.error("AI request failed", ai.status, (await ai.text()).slice(0, 500));
      await rpc("refund_ai", auth);
      // 429: the shared free allowance is used up for now.
      return reply(503, { error: ai.status === 429 ? "busy" : "failed" });
    }
    const data = await ai.json();
    const content = data?.choices?.[0]?.message?.content ?? "";
    const answer = parseAnswer(req.task as "steps", content);
    return reply(200, { ...answer, remaining });
  } catch (e) {
    console.error("AI answer unusable", e);
    await rpc("refund_ai", auth);
    return reply(502, { error: "failed" });
  }
});
