# Plantify SIH 26131 — Final Upgrade Checklist

## 1. Apply the database upgrade

Open Supabase Dashboard → SQL Editor.

Run the complete file:

`supabase/26131_upgrade.sql`

This creates the field, pest, expert, chat and report tables and the plant image bucket.

## 2. Deploy Edge Functions

From the project root:

```powershell
npx supabase link --project-ref ygsgpalzjlvzcfaouvlk

npx supabase functions deploy plant-detect --use-api
npx supabase functions deploy plantify-assistant --use-api
npx supabase functions deploy plant-assistant --use-api
```

Make sure these secrets exist server-side:

```powershell
npx supabase secrets set OPENROUTER_API_KEY="YOUR_KEY"
npx supabase secrets set PLANTIX_API_KEY="YOUR_KEY"
npx supabase secrets set PLANTIX_API_BASE_URL="https://api.plantix.net"
```

Do not put provider secrets in React source.

## 3. Run the web app

```powershell
npm install
npm run dev
```

## 4. Demo path for SIH

### Farmer flow

1. Sign in.
2. Open **Check with AI**.
3. Scan one affected leaf.
4. Show plant + diagnosis + confidence + severity.
5. Open **Plantify**.
6. Answer the three observation questions.
7. Show the refined assessment and care plan.
8. Save to **My Plants**.
9. Open the saved plant.
10. Show:
   - current health
   - confidence
   - management actions
   - watch-for items
   - health journey
   - expert validation
   - Plantify AI chat
11. Open **Alerts**.
12. Use **Risk & field intelligence**.
13. Add a field with crop, variety, crop stage, soil and location.
14. Load local weather.
15. Add a pest-trap/manual scouting observation.
16. Show the surveillance/report section.

## 5. What to say to judges

Plantify is a decision-support and surveillance prototype.

The scanner identifies visible symptoms early.
Plantify asks for farmer-observable context before refining the assessment.
The plant profile preserves the health journey.
The Risk Center combines weather and crop context for prioritization.
Field reports, pest observations and expert requests provide the foundation for
regional surveillance and feedback learning.

Do not claim that the prototype has a clinically/field-validated disease forecast.
Call the current weather calculation a prototype risk-prioritization signal.

## 6. If a feature says "table not found"

Run `supabase/26131_upgrade.sql` once.

The scanner itself does not depend on the new tables.
The new tables are for the SIH expansion around the stable scanner.
