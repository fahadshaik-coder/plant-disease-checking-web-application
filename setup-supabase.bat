@echo off
setlocal
set /p PLANTIX_KEY=Enter your NEW Plantix API key: 
set /p OPENROUTER_KEY=Enter your NEW OpenRouter API key: 
call npx supabase link --project-ref ygsgpalzjlvzcfaouvlk
call npx supabase secrets set PLANTIX_API_KEY="%PLANTIX_KEY%"
call npx supabase secrets set PLANTIX_API_BASE_URL="https://api.plantix.net"
call npx supabase secrets set OPENROUTER_API_KEY="%OPENROUTER_KEY%"
call npx supabase secrets set OPENROUTER_MODEL="google/gemini-2.5-pro"
call npx supabase functions deploy plant-detect --use-api
endlocal
