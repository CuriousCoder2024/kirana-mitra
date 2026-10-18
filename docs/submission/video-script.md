# Kirana Mitra: 3 min 30 s screen-recording script

Rule: 3 to 4 minutes, over 4 is penalised. This script targets **3:35** at a relaxed pace (about 450 spoken words); if you
run long, drop the second sentence of beats 5 and 7 first. Beats are timestamped from the start of the recording.
Reply strings come from the code and evals (see `docs/submission/demo-script.md`, which has fallbacks and sources). With
live Gemini the first sentence of a reply can differ slightly; the totals after it are fixed by the backend.

Lines tagged **[confirm after deploy]** depend on Firestore or Firebase Hosting being live.

## Recording setup

- **Browser:** Chrome at 1280x720 for the whole recording. For the app, use a phone-size window (about 390x844) centred in the
  frame, or Chrome DevTools device mode; keep the browser chrome and bookmarks bar hidden.
- **URL:** `https://kirana-mitra-app.web.app` **[confirm after deploy]**; until then
  `https://storage.googleapis.com/kirana-mitra-app-web/index.html`. API: `https://kirana-mitra-api-396621755403.asia-south1.run.app`.
- **Mic test:** allow the microphone for the site, speak one throwaway voice note before recording, and check the level
  and that no "Demo" badge shows in the app bar (it means the app fell back to the offline mock).
- **Fresh shop:** onboard on camera. Do not redeploy Cloud Run before recording. Until Firestore is live the store is in
  memory, so a restart wipes shops. Warm up first: open the Forecast tab once (BigQuery is cached for 10 minutes) and send one
  throwaway typed message in a different shop.
- **Files ready:** `backend/tests/eval/shelf/images/shelf_01_easy.jpg` (known result: Maggi 6, Parle-G 12, Tata Salt 3) or the
  app's **Sample shelf** picker (licensed photos; their counts are not measured, so rehearse and read the result off the screen).
- **Date check:** record on or after 26 Oct if you want the order sheet's reason to say Diwali; before that the reason band and
  subtitle say Dussehra (the chart still shows the Diwali marker). See `demo-script.md`, step 5.
- **Fallback line if Gemini takes more than 10 s:** "Gemini is reading it; typing dots mean it is working." Keep talking over the
  dots and do not cut. If nothing arrives by about 15 s, stop, retake from the start of that beat; text entry has a p50 of
  2.5 s but a tail above 40 s (`docs/submission/performance-report.md`). Never splice a mock-mode reply in without saying so.

## Beats

### 0:00 to 0:20. The problem
- **Screen:** the onboarding screen (logo, "Kirana Mitra", "Bolo, ho jayega."), not yet touched.
- **Say:** "Meet Ramesh Gupta. He runs Gupta General Store, a kirana. Stock arrives in cartons, sells by the packet, and half his
  customers buy on udhaar. Ramesh won't fill in forms, but he will talk. Kirana Mitra means he just speaks, in Hindi, Hinglish
  or English, and it keeps the books."

### 0:20 to 0:40. Onboarding
- **Screen:** onboarding form, then the chat.
- **Do:** type `Gupta General Store` in "Dukaan ka naam", `Ramesh Gupta` in "Aapka naam"; Hinglish is preselected under
  "Mitra kis bhasha mein bole?"; tap "Shuru karo".
- **Say:** "Two fields and a language. Ramesh picks Hinglish, so every reply will come back in Hinglish."
- **Appears:** "Namaste Ramesh! Bolo: kya aaya, kya bika, kisko udhaar diya. Mic dabake rakho aur bolo."

### 0:40 to 1:30. Typed entry, Undo, then a voice stock entry
- **Screen:** chat tab.
- **0:40 Do:** tap "Likho", type `Gupta ji ne 350 rupaye udhaar liya`, send.
  **Appears:** the green "Samjha · likh diya" card: Gupta ji, "+ ₹350", "Udhaar · ab total ₹350"; the reply is
  `Samjha: Gupta ji, ₹350 udhaar. Total ₹350.`
  **Say:** "Typed: 'Gupta ji ne 350 rupaye udhaar liya'. Gemini returns structured data, not free text; the entry is written
  and Ramesh gets a card and an Undo button."
- **0:55 Do:** tap **Undo**. **Appears:** `Theek hai, hata diya. Gupta ji ₹350 → Total ₹0.`
  **Say:** "Wrong? One tap and it is gone."
- **1:05 Do:** hold the big mic ("Dabake bolo") and say "Kal Parle-G ke 3 carton aaye", release.
  **Appears:** the voice-note bubble, then
  `Samjha: Parle-G, 3 carton stock mein add kiya. Ab total: Parle-G 114 packet (3 carton = 72 packet).` with **Undo** and
  **Stock dekho**. (114 = the demo shop's 42 packets plus 3 cartons of 24. By the app code this reply may show as a plain bubble
  with Undo instead of the green card, because the stock total is not parsed; if so, say "and here is the reply and Undo".)
  **Say:** "Now by voice. Ramesh says 'Kal Parle-G ke 3 carton aaye'. The audio goes straight to Gemini 3.8 Flash. It
  understands three cartons, and converts them to seventy-two packets."

### 1:30 to 2:10. Shelf photo scan, with confirm
- **Screen:** chat; tap "Shelf photo" in the dock.
- **Do:** pick `shelf_01_easy.jpg` (or the Sample shelf). Wait for the card, then tap **Haan, update karo**.
  **Appears:** "Shelf dekha · 3 cheezein mili" with Maggi 6, Parle-G 12, Tata Salt 3 and "Kam hai" badges, the question
  "Stock yahi set kar doon?", then "Samjha · stock update ho gaya" and
  `Stock update kiya: Maggi 6 packet, Parle-G 12 packet, Tata Salt 3 packet.`
- **Say:** "Or he just photographs the shelf. Gemini counts every pack. Nothing changes until Ramesh says yes, and the photo
  is the truth, so stock is set to what it sees. Three items are below their reorder level." If the scan is slow: "Counting a
  shelf takes a few seconds longer than a sentence; this is the slowest step."

### 2:10 to 2:50. Stock, Forecast with the Diwali bump, order sheet
- **Screen:** Stock tab (low items first, "Kam hai" badges) for about 5 s, then Forecast tab.
- **Do:** tap **Forecast**, tap the **Parle-G** chip, point at the saffron line and the festival marker, tap
  **Order banao · N packet**, then **WhatsApp pe bhejo** (stop at the link opening; do not send).
  **Appears:** chart with 4 past weeks, 4 forecast weeks with a range band and a festival marker; the reason band
  (for example `Diwali week demand ~1.8x`); the sheet "Order taiyaar" with `Gupta General Store ke liye order:`,
  `- Parle-G 70g: ... packet`, ending `Please kal tak bhej dein. Dhanyavaad!`
- **Say:** "Stock shows what is low. Forecast looks four weeks ahead. BigQuery ML predicts demand per item, and we add a festival
  uplift, so Parle-G jumps in Diwali week, from a baseline of about 148 packets to 214. One tap builds the order, and one more opens
  it in WhatsApp for his distributor." (Numbers: `data/bqml/results.md`, week of 2 Nov: baseline 148, forecast 214.)

### 2:50 to 3:05. Evening hisaab
- **Screen:** back to chat, three-dot menu, **Aaj ka hisaab**.
- **Appears:** the card "Aaj ka hisaab" with "Aaj ki bikri", tiles "Udhaar diya", "Udhaar aaya", "Kul baaki", "Kam hai", and
  buttons "Kal ka order banao" and "Ghar pe WhatsApp karo".
- **Say:** "At night, the whole day on one card: sales, udhaar given and received, what is owed, and what is low, in his language."

### 3:05 to 3:20. Architecture in one breath
- **Screen:** the architecture diagram from the deck (`docs/submission/Kirana-Mitra-AI-Builder-Cup-Submission.pptx`) or the
  Mermaid diagram in `README.md`.
- **Say:** "The Flutter web app is served from Firebase Hosting **[confirm after deploy]**; it talks to a FastAPI service on Cloud
  Run with one warm instance, which calls Gemini 3.8 Flash on Vertex AI and keeps shops, stock and orders in Firestore
  **[confirm after deploy]**; BigQuery ML does the forecast."

### 3:20 to 3:30. Results
- **Screen:** the results slide.
- **Say:** "On our test sets: shelf counts, 25 of 26 exactly right; entry extraction, 96 percent intent accuracy; forecast error
  11 percent against 19.6 percent without the festival uplift. These are synthetic data and small samples, and we say so in the
  report." (Sources: `backend/tests/eval/shelf/results.csv`, `backend/tests/eval/results.csv`, `data/bqml/results.md`.)

### 3:30 to 3:35. Close
- **Screen:** logo and the URL.
- **Say:** "Kirana Mitra. Bolo, ho jayega."

## Do not say

- Do not call the evaluation sets real shop data; shelf images and sales history are synthetic.
- Do not say the evening summary is sent automatically (it is opened from the menu), that the order is sent automatically
  (it opens a WhatsApp link), or that Firebase Auth exists (it is on the roadmap).
- Do not claim the Firestore or Firebase Hosting lines until the **[confirm after deploy]** markers have been verified.
