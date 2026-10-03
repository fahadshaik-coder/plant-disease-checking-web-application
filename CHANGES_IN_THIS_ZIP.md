# Plantify V17 — Fixed Build Package

## Fixed in this package

1. **Blank white screen fixed**
   - `PlantDetails.tsx` had React hooks declared outside the component.
   - All chat/media state and refs are now inside `PlantDetails`.

2. **Plantify evidence toolbar removed from the investigation page**
   - Camera / Photo / Video / Voice are no longer shown as a separate row on the Plantify question screen.
   - Media controls now live inside the Plantify chat composer on the plant profile.

3. **Single unified Plantify chat composer**
   - Camera
   - Photo upload
   - Short video recording (maximum 10 seconds)
   - Voice input
   - Text input
   - Send button
   - Attachments stay inside the same chat card.

4. **Only one media mode is active at a time**
   - Camera stops video/voice.
   - Video stops camera/voice.
   - Voice stops camera/video.
   - Photo selection stops active capture.
   - Escape closes active media capture.

5. **Voice only listens after clicking the microphone**
   - No automatic microphone activation.
   - Clicking the microphone again stops listening.
   - Voice errors stay inside the chat UI instead of replacing the whole application.

6. **Voice response playback**
   - Assistant messages have a small speaker button to read the answer aloud.

7. **Chat image/video support**
   - Chat photos are uploaded to the `plant-images` Supabase bucket.
   - Videos are limited to short recordings and uploaded to the same bucket.
   - For a video, Plantify also extracts a first frame and sends that image to the vision model so the assistant can inspect visible plant evidence.

8. **Scanned images are now persisted correctly**
   - The old implementation stored a temporary browser `blob:` URL in the database.
   - The new implementation uploads the original scan image to `plant-images` before saving `plants` and `plant_scans`.
   - This makes images survive refresh/re-login and appear in My Plants and scan history.

9. **My Plants delete cleanup**
   - Deletes scan history, Plantify sessions, chat history, expert requests, the plant record, and stored plant/scan images when available.
   - Added required owner DELETE policies to the SQL migration.

10. **Confidence display fixed**
    - Supports both `0.85` and `85` database representations without showing `8500%`.

## Supabase step required

Run this file once in the Supabase SQL Editor:

`supabase/26131_upgrade.sql`

It creates/updates the `plant-images` storage bucket and the required owner policies.

## Local run

```powershell
cd "C:\Users\SAIF\Documents\Plantify-WEB-V17-STABLE-LEAF-AI"
npm install
npm run dev
```

Then open the localhost URL shown by Vite.

## Important

The package intentionally does not include `node_modules`. Run `npm install` after extracting the ZIP.


## Latest UI change
- Removed video upload/recording from the Plantify plant-profile assistant.
- Composer now provides only camera, photo upload, voice, text, and send.
- Voice remains click-to-listen only.
