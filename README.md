# Recipe App

Your recipes and collections, on the web, Android and iOS, from one Flutter codebase.

## Free stack (€0 per month)

| Part | Service | Free tier |
| --- | --- | --- |
| Web app | [Vercel](https://vercel.com) Hobby | Personal, non-commercial use |
| Login and database | [Supabase](https://supabase.com) Free | 500 MB database; pauses after a week without activity (a daily GitHub Action keeps it awake) |
| Android / iOS store apps | Optional, later | Google Play $25 once, Apple $99 a year |

There is no backend server: the app talks to Supabase directly. Every user sees and
changes only their own recipes and groups; the database enforces this itself
(Row Level Security, see `supabase/schema.sql`).

## Friends and sharing

- **Friends:** Account → Friends. Send a request to an email address; the other person accepts it in their
  Friends list (a badge on the Account tab shows waiting requests). The app always answers "Request sent", so
  nobody can find out whether an address has an account. Requests are only shown in the app; no email is sent.
- **Sharing:** the Share button on your recipe or collection. Friends see your latest version, read-only, and can
  tap **Save a copy** to get their own editable recipe. A shared collection includes recipes you add to it later.
  Removing a friend stops all sharing between you.
- The database enforces all of this (`supabase/schema.sql`), and `supabase/tests/tests.sql` checks it: strangers
  see nothing, friends see only what was shared and can never change it.

## Project layout

- `lib/services/` – `auth_service.dart` (Supabase Auth), `recipe_service.dart`, `group_service.dart`, `errors.dart` (clear error messages)
- `lib/models/` – `Recipe`, `RecipeIngredient`, `GroupRecipes`, read from and written to the database
- `lib/screens/` – the 8 screens
- `supabase/schema.sql` – tables, access rules, the `save_recipe` function (saves a recipe and its ingredients in one step) and `ping`
- `supabase/tests/` – 162 database checks on a throwaway local Postgres: `bash supabase/tests/run.sh` (needs Postgres installed; nothing touches Supabase)
- `test/` – app tests: `flutter test` (109 tests). `screens_test.dart` opens every screen on the demo data at
  phone, tablet and laptop size, in dark mode and at 200% text, and checks layout, tap-target size, button labels
  and text contrast
- `assets/fonts/` – Fraunces and Inter (SIL Open Font License), bundled so nothing is fetched from Google
- `tool/generate_icons.dart` – draws the app icon for web, Android and iOS: `flutter test tool/generate_icons.dart`
- `lib/theme/` – colours, fonts and component styles; `lib/widgets/` – the navigation shell and shared pieces
- `vercel.json` – how Vercel builds and serves the web app
- `.github/workflows/keep-supabase-awake.yml` – the daily ping

## Try it without Supabase (demo mode)

```bash
flutter run -d chrome -t lib/demo/main_demo.dart
```

This runs the real app on made-up recipes kept in memory (`lib/demo/`), so you can try the
screens before setting anything up. Nothing is saved, and a reload starts over. Vercel never
builds it: it builds `lib/main.dart`.

## Set it up (once, about 30 minutes)

### 1. Create the Supabase project
1. Sign in at <https://supabase.com> (the same account as Word Buddy is fine: the free plan allows 2 projects).
2. **New project**, name `recipe-app`, region **Frankfurt** (or another in Europe). Save the database password somewhere safe.
3. **SQL Editor → New query**: paste all of `supabase/schema.sql` and click **Run**. (Run it again after each update; it keeps your data.)
4. Click **Connect** at the top and copy the **Project URL** (`https://<project-id>.supabase.co`).
5. **Project Settings → API Keys**: copy the **publishable key**. Never use the secret key in the app.

**Sharing a Supabase project with Word Buddy?** That works: the Recipe App's tables and functions have their own
names (`recipe_profiles`, `sync_recipe_profile`), so they never touch Word Buddy's. Keep in mind:
- Both apps then share the same accounts: one email and password signs in to both.
- Under **Authentication → URL Configuration**, add both apps' links to **Redirect URLs**.
- If `schema.sql` stops with "An earlier Recipe App setup replaced Word Buddy's sync_profile function", run
  `word-buddy/supabase/schema.sql` once to restore it, then run the Recipe `schema.sql` again.

### 2. Run it on your computer
```bash
cp supabase.example.json supabase.local.json
```
Put the URL and publishable key in `supabase.local.json` (it is not committed). Then:
```bash
flutter run -d chrome --dart-define-from-file=supabase.local.json
```
The same flag works for the iOS simulator and an Android emulator.

### 3. Put the code on GitHub
Create a **private** repository and push this folder to it.

### 4. Deploy on Vercel
1. At <https://vercel.com>: **Add New → Project**, import the repository.
2. Leave the framework as **Other**; `vercel.json` already has the build settings.
3. **Environment Variables**: add `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY` (same values as above).
4. **Deploy**. The first build takes about 3–5 minutes (Vercel downloads Flutter). You get a link such as `https://recipe-app-xyz.vercel.app`.

Every push to `main` deploys a new version.

### 5. Finish Supabase
**Authentication → URL Configuration**:
- **Site URL**: your Vercel link.
- **Redirect URLs**: add your Vercel link and `http://localhost:*` for testing.

Supabase's built-in email sends only a few emails per hour. For more sign-ups, add a free SMTP
service (Resend, Brevo) under **Authentication → Emails → SMTP Settings**.

### 6. Keep Supabase awake
In the GitHub repository: **Settings → Secrets and variables → Actions**, add `SUPABASE_URL` and
`SUPABASE_PUBLISHABLE_KEY`. Then **Actions → Keep Supabase awake → Run workflow** once to check it.
(GitHub pauses scheduled workflows in a repository with no commits for 60 days; it emails you first, and one click turns it back on.)

### 7. Install it on your phone
- **iPhone**: open the Vercel link in Safari → **Share → Add to Home Screen**.
- **Android**: open it in Chrome → menu → **Install app**.
