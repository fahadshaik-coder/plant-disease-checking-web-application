# Plantify Web V17 — Stable Leaf Diagnosis

Plantify is a camera-first plant-health web application. This version focuses on one job: **capture a leaf, identify the plant, diagnose the most likely visible health problem, and explain what to do next without crashing the browser or silently losing the AI response.**

## Scanner architecture

```text
Camera / Gallery
      ↓
Single resize + JPEG compression (≤1024px, target ≤1 MB)
      ↓
FormData Blob upload
      ↓
Supabase Edge Function
      ↓
OpenRouter Vision
      ↓
Gemini 2.5 Pro by default
      ↓
JSON Schema constrained diagnosis
      ↓
Plantify result UI
```

The browser never receives the OpenRouter secret.

## What changed in V17

- Removed the camera path's second JPEG compression pass.
- Camera captures directly at the final scanner dimensions.
- Upload is kept as a Blob/FormData flow in the browser.
- Added a hard duplicate-request lock.
- Camera tracks, object URLs, canvas memory, and pending requests are released aggressively.
- Increased request timeout to 45 seconds.
- OpenRouter now uses **structured JSON output with a JSON Schema** instead of hoping that free-form text parses as JSON.
- Default model is `Random`; override it with `OPENROUTER_MODEL` if desired.
- Increased output ceiling to 1400 tokens, while keeping the schema compact.
- The model is explicitly instructed to identify the plant and give the best supported disease/pest/deficiency/stress/healthy diagnosis.
- `possible` is used for suggestive evidence; `insufficient_evidence` is reserved for genuinely unusable images; missing disease output is never automatically treated as healthy.
- If a provider still returns malformed/truncated content, the actual response is shown rather than replaced with a generic parsing error.
- Technical details expose provider status, finish reason, request ID, and model without exposing secrets.

## Supabase secrets

Set these server-side:

```bat
npx supabase secrets set OPENROUTER_API_KEY="YOUR_KEY"
npx supabase secrets set OPENROUTER_MODEL="Random Ai"
```

## Run locally

```bat
npm install
npm run dev
```

## Deploy

```bat
npx supabase link --project-ref ygsgpalzjlvzcfaouvlk
npx supabase functions deploy plant-detect --use-api
```

## Important testing rule

Test repeated scans. The intended lifecycle is:

```text
one capture → one request → one response → cleanup
```

Do not add scan history, plant passports, alerts, community mapping, or other large features until this scanner remains stable across repeated scans.

## AI limitations

A single photograph cannot guarantee a field diagnosis. The application should communicate uncertainty and recommend better photos or local agricultural confirmation when evidence is weak. Do not use the AI result as the sole basis for high-risk chemical treatment decisions.

## Plantix + Gemini scanner architecture

The scanner now uses Plantix as the agriculture-specific image-analysis signal and Gemini/OpenRouter as the final reasoning and farmer-facing explanation layer. Plantix is called server-side from the `plant-detect` Edge Function; its API key is never sent to the browser. Plantix can reject blurry, too-distant, non-plant, or ornamental images before the expensive vision explanation step. When Plantix is unavailable, the scanner gracefully falls back to Gemini.

### Supabase secrets

Set these server-side secrets only:

```bat
npx supabase secrets set PLANTIX_API_KEY="YOUR_NEW_PLANTIX_KEY"
npx supabase secrets set PLANTIX_API_BASE_URL="https://api.plantix.net"
npx supabase secrets set OPENROUTER_API_KEY="YOUR_NEW_OPENROUTER_KEY"
npx supabase secrets set OPENROUTER_MODEL="google/gemini-2.5-pro"
npx supabase functions deploy plant-detect --use-api
```

The included `setup-supabase.bat` performs this setup interactively. Do not put provider secrets in `.env`, frontend code, Git, or this ZIP.

### OAuth

Google OAuth is wired through the existing Supabase project. In the Supabase dashboard, Google must be enabled under Authentication → Providers, and the deployed site's origin must be present in Authentication → URL Configuration / Redirect URLs.

### Scanner stability rules

- Browser sends a compressed multipart image, never a giant base64 string.
- Camera tracks are stopped immediately after capture.
- The diagnosis screen does not keep rendering the captured image after analysis.
- Plantix receives the same temporary image on the server and returns compact structured evidence.
- Gemini receives the image plus compact Plantix evidence and produces the final diagnosis.
- No provider API key is exposed to the browser.


# SIH 26131 V18 Upgrade — Crop Health Intelligence

The scanner remains the stable core. V18 expands Plantify around the SIH 26131 problem statement:

```text
Leaf image
  ↓
Plantix + Vision AI
  ↓
Plant diagnosis + confidence + severity
  ↓
Plantify follow-up questions
  ↓
Refined assessment + care plan
  ↓
My Plants health profile
  ├── scan history
  ├── Plantify assessment history
  ├── management actions
  ├── expert validation request
  └── contextual Plantify AI chat
  ↓
Risk Center
  ├── local weather signal
  ├── crop / field context
  ├── field reports
  └── future geospatial hotspot aggregation
```

## New frontend modules

- `src/PlantDetails.tsx` — individual plant health profile and timeline.
- `src/RiskCenter.tsx` — crop-context, weather-risk and surveillance interface.
- `src/MyPlants.tsx` — redesigned plant records.
- `src/PlantifyAssistant.tsx` — scan follow-up and refined assessment.
- `src/main.tsx` — connects the profile and risk-center routes.

## New AI function

`supabase/functions/plant-assistant/index.ts`

This is a contextual assistant. It receives the selected plant, latest scan, latest Plantify assessment and recent conversation. It does not expose the OpenRouter key to the browser.

## SIH database upgrade

Run:

```text
supabase/26131_upgrade.sql
```

once in the Supabase SQL Editor.

It adds:

- `crop_fields`
- `field_reports`
- `pest_observations`
- `expert_requests`
- `plant_chat_messages`
- `plants.field_id`
- `plant-images` storage bucket and authenticated storage policies

The UI degrades gracefully if the optional field/chat tables have not been created yet, but the full SIH demo should run the migration.

## Deploy

```bat
npx supabase link --project-ref ygsgpalzjlvzcfaouvlk

npx supabase functions deploy plant-detect --use-api
npx supabase functions deploy plantify-assistant --use-api
npx supabase functions deploy plant-assistant --use-api
```

The existing server-side secrets are still required:

```bat
npx supabase secrets set OPENROUTER_API_KEY="YOUR_KEY"
npx supabase secrets set PLANTIX_API_KEY="YOUR_KEY"
npx supabase secrets set PLANTIX_API_BASE_URL="https://api.plantix.net"
```

Do not put provider secrets into frontend source.

## What this prototype covers from SIH 26131

| SIH requirement | Plantify implementation |
|---|---|
| Image symptom identification | Plantix + OpenRouter vision scanner |
| Crop-health diagnosis | Structured diagnosis, confidence and severity |
| Actionable management | Plantify care plan |
| Follow-up monitoring | My Plants scan/assessment timeline |
| Weather-based risk | Risk Center local weather signal |
| Crop stage / variety / soil context | Crop field profile |
| Pest-trap / sensor input | `pest_observations` data model ready |
| Geospatial hotspot mapping | `field_reports` location data + surveillance UI foundation |
| Expert validation | Expert request workflow |
| Multilingual advisories | UI/AI architecture can be extended with locale-aware responses |
| Official dashboard | Surveillance data model is prepared; official role dashboard is the next expansion |
| Learning from confirmations | Expert confirmation and field-report tables provide the feedback foundation |

## Important scope note

The weather/risk panel is intentionally labelled a **prototype risk signal**. It must not be presented as a validated disease-forecasting model. The final SIH demo should describe it as a multi-factor prioritization layer and show how validated field confirmations would improve future risk models.
