// Run: node --test supabase/functions/ai/logic_test.ts  (Node 22.18+ runs TypeScript directly)
import { test } from "node:test";
import assert from "node:assert/strict";
import { BadRequest, buildPrompt, chatBody, parseAnswer, parseRequest } from "./logic.ts";

test("a steps request is trimmed and checked", () => {
  const r = parseRequest({
    task: "steps",
    language: "ar",
    recipe: {
      title: "  Pancakes ",
      ingredients: [{ name: "flour", quantity: "200", unit: "g" }, { name: "  " }, { name: "eggs", quantity: "2" }],
      prepMinutes: 10,
      cookMinutes: -5,
      servings: 4,
      ownerEmail: "someone@example.com",
    },
  });
  assert.equal(r.task, "steps");
  if (r.task !== "steps") return;
  assert.equal(r.recipe.title, "Pancakes");
  assert.equal(r.recipe.ingredients.length, 2);
  assert.equal(r.recipe.cookMinutes, null);
  assert.ok(!JSON.stringify(r).includes("example.com"), "only recipe text goes to the AI");
});

test("unusable requests are refused before the AI", () => {
  assert.throws(() => parseRequest({ task: "steps", recipe: { title: "", ingredients: [{ name: "x" }] } }), BadRequest);
  assert.throws(() => parseRequest({ task: "steps", recipe: { title: "Soup", ingredients: [] } }), BadRequest);
  assert.throws(() => parseRequest({ task: "ideas", have: ["", " "] }), BadRequest);
  assert.throws(() => parseRequest({ task: "poem" }), BadRequest);
  assert.throws(() => parseRequest(null), BadRequest);
});

test("an unknown language falls back to English, and ideas lists are de-duplicated", () => {
  const r = parseRequest({ task: "ideas", language: "fr", have: ["eggs", "eggs", " rice "] });
  assert.deepEqual(r, { task: "ideas", language: "en", have: ["eggs", "rice"] });
});

test("the prompt asks for the app language and a strict JSON shape", () => {
  const req = parseRequest({ task: "ideas", language: "de", have: ["Eier"] });
  const p = buildPrompt(req);
  assert.match(p.system, /German/);
  assert.match(p.user, /- Eier/);
  const body = chatBody(req, "openai/gpt-oss-120b") as any;
  assert.equal(body.response_format.json_schema.strict, true);
  assert.equal(body.model, "openai/gpt-oss-120b");
  // Strict mode: every object lists all its fields as required and allows no others.
  const walk = (s: any) => {
    if (s?.type === "object") {
      assert.deepEqual([...s.required].sort(), Object.keys(s.properties).sort());
      assert.equal(s.additionalProperties, false);
      Object.values(s.properties).forEach(walk);
    }
    if (s?.type === "array") walk(s.items);
  };
  walk(p.schema);
  walk(buildPrompt(parseRequest({ task: "steps", recipe: { title: "a", ingredients: [{ name: "b" }] } })).schema);
});

test("steps come back clean", () => {
  const a = parseAnswer("steps", JSON.stringify({ steps: ["1. Whisk the eggs.", "Step 2: Fry.", "  ", "- Serve."] }));
  assert.deepEqual(a.steps, ["Whisk the eggs.", "Fry.", "Serve."]);
  assert.throws(() => parseAnswer("steps", JSON.stringify({ steps: [] })));
  assert.throws(() => parseAnswer("steps", "not json"));
});

test("meal ideas are checked and trimmed", () => {
  const a = parseAnswer("ideas", JSON.stringify({
    ideas: [
      {
        title: "Shakshuka", description: "Eggs in tomato sauce", prep_minutes: 10, cook_minutes: 20, servings: 2,
        ingredients: [{ name: "eggs", quantity: "4", unit: null, have: true }, { name: "feta", quantity: null, unit: null, have: false }],
        steps: ["Fry onions.", "Add eggs."],
      },
      { title: "", description: "", prep_minutes: 0, cook_minutes: 0, servings: 0, ingredients: [], steps: [] },
      {
        title: "Fried rice", description: "", prep_minutes: -1, cook_minutes: 1e9, servings: 0,
        ingredients: [{ name: "rice", quantity: "200", unit: "g", have: true }], steps: ["Fry."],
      },
    ],
  }));
  assert.equal(a.ideas.length, 2, "an empty meal is dropped");
  assert.equal(a.ideas[0].ingredients[1].have, false);
  assert.equal(a.ideas[1].prepMinutes, 10, "odd numbers get a sensible value");
  assert.equal(a.ideas[1].cookMinutes, 1440);
  assert.equal(a.ideas[1].servings, 2);
  assert.throws(() => parseAnswer("ideas", JSON.stringify({ ideas: [] })));
});
