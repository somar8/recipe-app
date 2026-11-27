# AI helper (Edge Function `ai`)

Writes recipe steps and suggests meals from what you have. The app never holds the AI
key: it calls this function, which checks the person's daily allowance (20 a day,
`use_ai` in `schema.sql`), asks the AI and checks the answer. Only recipe text is sent
to the AI, never names or emails.

Default AI: Groq's free tier with `openai/gpt-oss-120b` (no card needed).

## Set it up (about 10 minutes)

Do all of this for the **Recipe App** project `mevunepahqgdfecrsfzd`, not Word Buddy.

1. **Database**: in the SQL Editor of `mevunepahqgdfecrsfzd`, run all of
   `supabase/schema.sql` again (it adds `use_ai` and `refund_ai`).
2. **Groq key**: sign up at <https://console.groq.com>, open **API Keys**, create a key
   named "Recipe App" and copy it. Optional, for extra privacy: under
   **Settings -> Data Controls** turn on Zero Data Retention.
3. **Secret**: in Supabase, **Edge Functions -> Secrets**, add `GROQ_API_KEY` with that key.
4. **Deploy** from the RecipeApp folder (asks you to log in to Supabase the first time):

   ```bash
   npx supabase login
   npx supabase functions deploy ai --project-ref mevunepahqgdfecrsfzd
   ```

5. Open the app, go to **Cook**, add a few things and tap **Suggest meals**.

## Optional settings (Secrets)

| Name | Default | Use |
|---|---|---|
| `AI_MODEL` | `openai/gpt-oss-120b` | Another Groq model, e.g. `openai/gpt-oss-20b` (faster, simpler) |
| `AI_BASE_URL` | `https://api.groq.com/openai/v1` | Any OpenAI-style chat API, to switch provider without an app update |
| `AI_API_KEY` | | The key for that other provider (used when `GROQ_API_KEY` is not set) |

## When something goes wrong

The app shows a message and the request is not counted:

| App says | Cause |
|---|---|
| "The AI helper isn't set up yet." | The function isn't deployed, or `GROQ_API_KEY` is missing |
| "The free AI is busy right now." | Groq's shared free allowance is used up for the moment (429) |
| "You've used today's 20 AI requests." | That account's own daily limit |

Logs: Supabase **Edge Functions -> ai -> Logs**.

## Tests

```bash
node --test supabase/functions/ai/logic_test.ts
```
