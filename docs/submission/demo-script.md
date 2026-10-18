# Kirana Mitra: two-minute judge demo

Persona: Ramesh Gupta, owner of Gupta General Store. Language: Hinglish. Run against the live Cloud Run API
(`<CLOUD_RUN_URL>`) from the web demo (`<WEB_DEMO_URL>`) or an Android phone.

How to read the "App replies" lines: text in quotes is copied from the code (`backend/app/service.py`,
`backend/app/gemini.py`, `app/lib/l10n/app_en.arb`) or from a local run of the backend in mock mode on 2026-10-18.
With live Gemini the first sentence of a reply is written by the model, following the few-shot examples in
`backend/app/gemini.py`, so its wording can differ slightly. Everything after it (running totals, "Total ₹350.",
"Ab total: ...", the shelf "kam hai" list) is added by the backend and is deterministic.

| Step | Clock | What it shows |
|---|---|---|
| 0. Pre-flight | before | warm-up, one clean shop |
| 1. Onboarding in Hinglish | 0:00 to 0:20 | no forms, language choice |
| 2. Voice note: Parle-G cartons | 0:20 to 0:40 | voice to a stock entry, carton to packet |
| 3. Typed udhaar and Undo | 0:40 to 1:00 | structured entry, confirmation, undo |
| 4. Shelf photo scan | 1:00 to 1:25 | vision count, confirm before write |
| 5. Forecast and reorder | 1:25 to 1:50 | festival-aware forecast, WhatsApp order |
| 6. Evening hisaab | 1:50 to 2:00 | the day in one card |

## 0. Pre-flight (do this 5 minutes before, not on stage)

1. `curl <CLOUD_RUN_URL>/health` returns `{"ok":true,"model":"gemini-3.8-flash"}`. Cloud Run runs with
   `--min-instances 0`, so the first request after idle is a cold start.
2. The store is in memory (`InMemoryRepository`): shops are lost whenever the instance restarts. Onboard the
   demo shop after the last restart, not before.
3. Warm Gemini with one throwaway typed message in a separate shop, and open the Forecast tab once: the first
   BigQuery `ML.FORECAST` call is slower and the result is then cached for 10 minutes (`backend/app/forecast.py`).
   The 6 s first-call figure is from a hand-over note, not measured in the repo.
4. Have `backend/tests/eval/shelf/images/shelf_01_easy.jpg` ready to pick (web opens a file picker; Android
   opens the camera, so photograph a printed copy or a real shelf instead).
5. Allow the microphone in the browser or phone.
6. Make sure the app is not in demo mode: there must be no "Demo" badge in the app bar. (If the app was built
   with the `/healthz` health check, the Cloud Run URL makes it fall back to the mock; see the README's "Known
   issue".) Keep a second tab or phone built with `--dart-define USE_MOCK=true` as the safety net.

## 1. Onboarding in Hinglish (0:00 to 0:20)

- **Say:** "Ramesh ji ki dukaan. Koi form nahi, sirf naam aur bhasha, aur bol ke kaam."
- **Tap:** type `Gupta General Store` in "Dukaan ka naam", `Ramesh Gupta` in "Aapka naam". "Hinglish" is
  already selected under "Mitra kis bhasha mein bole?" (the other choices are हिंदी and English). Tap
  "Shuru karo".
- **App replies:** the chat opens with the welcome bubble
  "Namaste Ramesh! Bolo: kya aaya, kya bika, kisko udhaar diya. Mic dabake rakho aur bolo."
  Behind the scenes `POST /shops` created the shop with language `hi-Latn`, so every reply follows that mix.
- **If Gemini or the server is slow:** onboarding does not call Gemini. If `POST /shops` fails the app switches
  to demo mode on its own and shows "Server nahi mila. Demo mode mein shuru kar raha hoon."; say so and carry on.

## 2. Voice note: "Kal Parle-G ke 3 carton aaye" (0:20 to 0:40)

- **Say (holding the mic):** "Kal Parle-G ke 3 carton aaye."
- **Tap:** press and hold the big mic ("Dabake bolo"), speak, release to send. (Slide your finger out to cancel.)
- **App replies:** a voice-note bubble from you, then (typing dots while Gemini works):
  `Samjha: Parle-G, 3 carton stock mein add kiya. Ab total: Parle-G 114 packet (3 carton = 72 packet).`
  with buttons **Undo** and **Stock dekho**. The 114 is the demo shop's seed stock of 42 packets plus 3 cartons
  at 24 packets per carton (`SEED_ITEMS` in `backend/app/store.py`; the same sum is asserted in
  `backend/tests/test_api.py`).
  The audio went to Gemini as inline bytes; there is no separate speech-to-text step. The API also returns the
  `transcript` Gemini heard.
  *What to expect on screen:* the Samjha card needs a total it can parse from the reply. For stock entries the
  app's current parser (`_parseTotal` in `app/lib/widgets/reply_card.dart`) does not recognise the
  "Ab total: Parle-G 114 packet" wording, so by the code you should see the reply as a plain bubble with the Undo
  button beneath it (the documented fallback), not the green "Samjha · likh diya" card. This was read from the
  code, not run; udhaar entries (step 3) do parse.
- **If Gemini is slow:** keep talking over the typing dots; the app keeps working and the call has a 40 s cap
  plus one retry on the server. After about 10 s, switch to the typed path: tap **Likho** and type
  `Kal Parle-G ke 3 carton aaye` (same Gemini call, so use it only if the mic failed). If the bubble
  "Couldn't reach the server. Try again." appears, tap the mic again. Last resort is the mock tab: its voice
  note is a random pick from five canned transcripts (`MockApiClient.voiceNote`), so say the Parle-G line anyway
  and, if it picks something else, narrate that entry instead. Say plainly that you switched to offline demo mode.

## 3. Typed: "Gupta ji ne 350 rupaye udhaar liya", then Undo (0:40 to 1:00)

- **Say:** "Ab typing bhi chalti hai: Gupta ji ne teen sau pachaas ka udhaar liya."
- **Tap:** **Likho** (keyboard), type `Gupta ji ne 350 rupaye udhaar liya`, send. Then tap **Undo** on the reply.
- **App replies:** the Samjha card ("Samjha · likh diya") with `Gupta ji`, `+ ₹350`, and
  "Udhaar · ab total ₹350", built from the reply
  `Samjha: Gupta ji, ₹350 udhaar. Total ₹350.`
  (first sentence from Gemini, `Total ₹350.` appended by the backend; it is the customer's running balance, so
  it is ₹350 only if Gupta ji had no earlier entry). Buttons: **Undo**, **Udhaar dekho**.
  After **Undo** a new bubble says
  `Theek hai, hata diya. Gupta ji ₹350 → Total ₹0.` and the card is greyed out.
- **Point out:** entry was written immediately because confidence was at least 0.7 (`CONFIRM_THRESHOLD`);
  below that the app shows "Pakka nahi" with "Haan, add karo" and "Nahi" instead of writing. To show it on demand,
  type `shayad 5 maggi aaye, ya 6`; it is one of the 26 eval samples (`amb-01`) and is expected to be held.
- **If Gemini is slow:** typed messages are the fastest path (eval p50 2.5 s, but with a tail above 40 s; see
  `docs/submission/performance-report.md`). If it hangs, wait for the error bubble and resend; the entry is only
  written when a reply comes back, so a retry cannot double-write. In the mock tab the same sentence gives an
  equivalent Samjha reply ("Samjha: Gupta ji ko ₹350 udhaar diya. Ab unka total ₹350." in the app mock).

## 4. Shelf photo scan with confirm (1:00 to 1:25)

- **Say:** "Ab dukaan ki shelf ki photo. Gin ke batayega, aur main haan bolunga tabhi stock badlega."
- **Tap:** the **Shelf photo** button in the dock, pick `shelf_01_easy.jpg` (or take a photo on a phone).
  Wait for the scan card, then tap **Haan, update karo**.
- **App replies:** your photo as a bubble, then a card headed "Shelf dekha · 3 cheezein mili" listing
  Maggi 6, Parle-G 12, Tata Salt 3 with "Kam hai" badges, the question "Stock yahi set kar doon?", and buttons
  **Haan, update karo** / **Nahi**. The underlying reply is
  `Shelf pe dikha: Maggi 6, Parle-G 12, Tata Salt 3. Maggi kam hai (reorder 12); Parle-G kam hai (reorder 24); Tata Salt kam hai (reorder 10). Update karoon?`
  (the first sentence is Gemini's; the "kam hai (reorder N)" list is added by the backend from each item's
  reorder level). The counts are the labelled truth for that image in `backend/tests/eval/shelf/labels.json`.
  After **Haan, update karo**: "Samjha · stock update ho gaya", reply
  `Stock update kiya: Maggi 6 packet, Parle-G 12 packet, Tata Salt 3 packet.` with **Undo**.
- **Presenter note:** the scan sets stock to the counted number (an absolute set, not an add), so Parle-G goes
  from 114 (step 2) to 12. That is by design (the photo is the truth) and it makes the next step's reorder
  big; say so if asked.
- **If Gemini is slow:** this is the slowest call (eval p50 9 s, and a tail of 113 s on 5 images; the server
  allows 90 s). Narrate the typing dots ("Gemini counts every packet"), keep the card open once it arrives.
  If it passes about 20 s, press on with the next step and come back, or use the mock tab, whose scan always
  returns the same Maggi 6, Parle-G 12, Tata Salt 3 (`MockApiClient.shelfScan`; the backend with `MOCK_GEMINI=1`
  also returns that for any image).

## 5. Forecast: the Diwali bump and the reorder WhatsApp link (1:25 to 1:50)

- **Say:** "Aage ke chaar hafte. Diwali 8 November ko hai, aur saffron line yahan ooper jaati hai."
- **Tap:** the **Forecast** tab, tap the **Parle-G** chip, point at the chart, tap the saffron
  **Order banao · N packet** button, then **WhatsApp pe bhejo** in the sheet.
- **App replies:** the chart shows 4 past weeks (brown line), 4 forecast weeks (saffron line with a range band) and a
  dashed festival marker with a diya at the Diwali date. Items come back sorted by reorder quantity. The band
  under the chart reads the item's `reorder_reason`, for example `Diwali week demand ~1.8x`, and
  "Stock mein 12 · mangao N packet". The sheet "Order taiyaar" shows the text from `POST /reorder`:
  `Gupta General Store ke liye order:` then one line per item such as `- Parle-G 70g: 288 packet`, ending
  `Please kal tak bhej dein. Dhanyavaad!`, and the button opens a `wa.me` link with that text. Nothing is sent
  automatically.
- **Numbers to quote (BigQuery ML, `data/bqml/results.md`, 4 weeks from 2026-10-19):** Parle-G baseline 142,
  145, 148, 150 units per week; with festival uplift 156, 145, **214** (Diwali x1.8), 180. Aashirvaad atta 12 to
  **20** in the Diwali week. The measured holdout error is 11.0% volume-weighted with the uplift against 19.6%
  without it (14 days, 40 items, synthetic sales; see the performance report for the caveat).
- **Date-dependent behaviour (read before recording):** the chart always includes the Diwali marker while 8 Nov
  is inside the 4-week window (until about 8 Nov). The reorder reason and the quantity only look at the first
  2 weeks (`REORDER_COVER_WEEKS = 2`), and the app-bar subtitle names the first festival in the window. On
  18 to 25 Oct that is Dussehra (20 Oct): the band will read `Dussehra week demand ~1.3x` and the subtitle
  "Agle 4 hafte · Dussehra 20 Oct". From 26 Oct the first two weeks reach the Diwali ramp and the band
  names Diwali. Record on or after 26 Oct, or say "Dussehra abhi, aur Diwali chart mein aage dikh raha hai".
  Exact live quantities (for example 288 packets) depend on the day and on the stock left after step 4.
- **If BigQuery or Gemini is slow:** the forecast does not use Gemini. Open the tab during pre-flight so it is
  cached for 10 minutes. If the call fails the tab shows "Couldn't load. Pull down to retry." In the mock tab the
  fixture forecast always shows Diwali (`Diwali week demand ~2x`, forecast 44, 52, 90, 48) and the order text
  starts "Order for Gupta General Store (Diwali week):".

## 6. Evening hisaab (1:50 to 2:00)

- **Say:** "Raat ko ek card mein poora din: bikri, udhaar, aur kya kam hai."
- **Tap:** back to the chat tab, open the three-dot menu in the app bar, tap **Aaj ka hisaab**.
- **App replies:** the hisaab card: "Aaj ka hisaab", date and entry count, "Aaj ki bikri" with the sales total,
  tiles "Udhaar diya", "Udhaar aaya", "Kul baaki", "Kam hai" (count of low items), a line such as
  "... kal mangao.", and buttons **Kal ka order banao** and **Ghar pe WhatsApp karo**. The `reply_text` Gemini writes for
  the same numbers (**Ghar pe WhatsApp karo** passes it to the phone's share sheet) looks like this fixed
  template, which is what you get whenever Gemini fails:
  `Aaj ka hisaab: bikri ₹70, 4 entries. Udhaar diya ₹350, wapas aaya ₹0; total baaki ₹350. Kam stock: Parle-G (12 packet), Maggi (6 packet), Tata Salt (3 packet).`
  (from a local mock-mode run of steps 2 to 4 plus a 5-packet Maggi sale; your figures follow what you entered.
  A message you undid is not counted, so the step-3 udhaar disappears from the totals.)
- **Close with one line:** "Bolo, ho jayega: voice, photo, forecast, hisaab, sab Hinglish mein."
- **If Gemini is slow:** `/summary` has a 20 s cap on the narration and then falls back to the fixed template,
  so it never fails; the card itself is built from the numbers, not from Gemini's text.

## What the demo does not claim

- Sales history behind the forecast is synthetic, and only the demo shop has history; a new shop sees the demo
  series scaled to its own stock.
- The evening summary is opened from the menu; there is no scheduled 21:30 notification yet.
- Stock and udhaar are held in memory on the server (Cloud SQL is deferred), so a restart clears them.
