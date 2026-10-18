# Kirana Mitra demo video: storyboard

`kirana-mitra-demo.mp4`, 1280x720, H.264 + AAC, 221.3 s (3:41). Built by `tools/video/build.py`
(see `tools/video/README.md`). Live beats were recorded headless against the web app and shop `shp_FA718925476DAEF3` on Cloud Run on 2026-10-18;
long Gemini/BigQuery waits inside a beat are trimmed to about 3 s (the storyboard says where). Nothing is mocked.

| Start | Segment | Source | What it shows |
|---|---|---|---|
| 0:00 | The problem | animation (pages/opener.html) | Ramesh and his shop (real shelf photo from docs/design), cartons in, packets out, udhaar, the "Maggi khatam?" moment, Bolo ho jayega. |
| 0:20 | Onboarding in Hinglish | live recording (8.5-9.5s, 16.9-21.1s of the Playwright capture) | Shop name and owner typed, Hinglish selected, Shuru karo; POST /shops; the Namaste greeting. |
| 0:32 | Typed entry and Undo | live recording (21.1-28.0s, 53.2-61.0s of the Playwright capture) | Typed "Gupta ji ne 350 rupaye udhaar liya" with visible typing, the live Samjha card (+₹350, total ₹350), Undo and "Theek hai, hata diya". |
| 0:57 | Low confidence asks first | live recording (61.0-74.0s of the Playwright capture) | "Verma ji ko shayad 120 ka udhaar diya": confidence below 0.7, the Pakka nahi card, Haan add karo, then the Samjha card. |
| 1:12 | Voice note through the live API | animated card over the live POST /voice-note reply (8.35 s, pages/voicecard.html) | Synthesised voice note (cloud-tts hi-IN-Neural2-B) sent to POST /voice-note; Gemini transcript "कल पार्ले जी के तीन कार्टन आए", reply "Samjha: Parle-G, 3 carton stock mein add kiya. अब स्टॉक: Parle-G 114 packet (3 carton = 72 packet)." in 8.35 s. |
| 1:34 | Shelf photo through the live API | animated card over the live POST /shelf-scan + /confirm replies (4.21 s, pages/shelfcard.html) | Sample shelf shelf_02.jpg sent to POST /shelf-scan; counts Colgate 15, Harpic Toilet Cleaner 1, Lifebuoy 12, Dettol 8, Fortune Oil 4; Haan update karo = POST /confirm; "Stock update kiya: Colgate 15 piece, Harpic Toilet Cleaner 1 piece, Lifebuoy 12 piece, Dettol 8 piece, Fortune Oil 4 litre." (4.21 s). |
| 1:58 | Stock and Udhaar | live recording (87.0-88.0s, 91.2-108.4s of the Playwright capture) | Stock tab (low items first, Kam hai badges; Parle-G 114 after the voice note, scan counts applied) and the Udhaar bahi-khata with Verma ji. |
| 2:16 | Forecast, order sheet, WhatsApp | live recording (108.4-109.4s, 112.4-128.3s of the Playwright capture) | Forecast tab: 4 past + 4 forecast weeks, Dussehra and Diwali markers, Parle-G chip, reason band, Order banao, the Order taiyaar sheet, WhatsApp pe bhejo (wa.me link opened, nothing sent). |
| 2:40 | Evening hisaab | live recording (128.3-129.3s, 132.4-146.2s of the Playwright capture) | Chat menu > Aaj ka hisaab: sales, udhaar given/received, kul baaki, kam hai, next festival, Kal ka order banao. |
| 2:55 | How it works | animation (pages/howitworks.html) | Animated architecture: Flutter app > Cloud Run (FastAPI) > Gemini 3.8 Flash (JSON with response schema) > Firestore / BigQuery ML > reply with Undo. |
| 3:19 | Results and close | animation (pages/results.html) | Metric tiles (intent 96.2%, entities 100%, shelf 25/26, WAPE 11.0% vs 19.6%, p50 2.5 s) with the synthetic-data caveat, then the closing card with team and links. |

## Not captured live, and why

- **Hold-to-talk voice**: headless Chromium has no microphone, so the voice beat sends a Cloud TTS clip to the same `POST /voice-note` and shows the request and the live reply in an animated card labelled as such.
- **Shelf photo**: the app's Sample shelf sheet does not open under headless Chromium (the tap registers, the sheet never appears), so the same bundled photo is posted to `POST /shelf-scan` and `POST /confirm` for the recorded shop and shown in an animated card; the resulting counts are then visible live on the Stock tab.
- Gemini and BigQuery waits longer than about 4 s are trimmed inside a beat (typing dots stay on screen for the first seconds). Reply latency is printed on the API cards.
