# Brief description of what we built

Hackathon form field: "Brief description of what you have built". Two versions below. State verified on 18 Oct 2026: Firestore live on Cloud Run revision 00006; web app at https://storage.googleapis.com/kirana-mitra-app-web/index.html.

## Full version (about 215 words)

Kirana Mitra is a voice- and photo-first assistant for small Indian grocery shops. A shopkeeper speaks or types in Hindi, Hinglish or English ("Kal Parle-G ke 3 carton aaye", "Gupta ji ne 350 rupaye udhaar liya") or photographs a shelf. The app turns it into a stock or udhaar (credit) entry, always with a confirmation and an Undo button, and answers in the shopkeeper's own language.

**Gemini.** Gemini 3.8 Flash on Vertex AI counts units in shelf photos, extracts intent, items, customer and amount from voice notes and text using structured JSON output, and writes the replies and the evening summary in the shopkeeper's language.

**Cloud Run.** One FastAPI service makes every Gemini call, serves the app's API and exposes the scheduler endpoint for automatic restock; it runs with one warm instance.

**Firestore.** Shops, items, stock, messages, orders and feedback are stored in Firestore (Native mode, asia-south1), verified live on Cloud Run revision 00006 on 18 Oct 2026.

**Firebase.** kirana-mitra-app is a Firebase project (Hosting site configured, Firestore as the database); the Flutter web app is published at https://storage.googleapis.com/kirana-mitra-app-web/index.html with Firebase Hosting as the next publish target. Firebase Auth for shop sign-in is on the roadmap.

**BigQuery ML.** An `ARIMA_PLUS` model forecasts four weeks of demand per item, with a festival uplift for Dussehra and Diwali, and drives a one-tap WhatsApp reorder. On a 14-day holdout of synthetic sales, the festival-adjusted forecast had 11.0% volume-weighted error against 19.6% for plain ARIMA.

## Short version (60 words)

Kirana Mitra lets a kirana owner speak, type or photograph a shelf in Hindi, Hinglish or English. Gemini 3.8 Flash on Vertex AI turns it into stock and udhaar entries with Undo. Cloud Run hosts the API, Firestore stores shops, stock and orders, Firebase Hosting serves the web app, BigQuery ML forecasts festival demand.

## Sources for the numbers and claims

- 11.0% vs 19.6%: `data/bqml/results.md` (40 items, 14-day holdout, synthetic sales; the uplift table is shared with the data generator, see `docs/submission/performance-report.md`).
- Gemini jobs and structured output: `backend/app/gemini.py`. Scheduler endpoint and v1.1 shapes: `docs/api-contract.md`.
- One warm instance: `infra/deploy.sh` (min 1 / max 1). Firestore: `infra/README.md`, `infra/setup.sh`.
- Word counts: full version 217, short version 60 (counted on the text above, with the confirm markers and bold labels included).
