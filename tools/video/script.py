"""The video's segments, in order: narration lines (one sentence each, captioned verbatim) and
the on-screen panel for live beats. Timings in the storyboard come from the recorded marks."""

SEGMENTS = [
    {"id": "opener", "kind": "anim", "page": "opener.html", "seconds": 20.0, "title": "The problem",
     "lines": [
         "Meet Ramesh Gupta. He runs Gupta General Store, a kirana.",
         "Stock arrives in cartons, sells by the packet, and half his customers buy on udhaar.",
         "Ramesh won't fill in forms. But he will talk.",
         "Kirana Mitra lets him just speak, in Hindi, Hinglish or English, and keeps the books.",
     ]},
    {"id": "onboarding", "kind": "live", "beat": "onboarding", "title": "Onboarding in Hinglish",
     "panel": {"title": "Two fields and a <span>language</span>", "step": "1 / 7",
               "bullets": ["Dukaan ka naam, aapka naam", "Hinglish, Hindi or English (24 Indian languages on the API)", "POST /shops creates the shop on Cloud Run"]},
     "lines": [
         "Two fields and a language. Ramesh picks Hinglish, so every reply comes back in Hinglish.",
         "The shop is created on Cloud Run, and the chat opens: Namaste Ramesh, bolo, kya aaya, kya bika.",
     ]},
    {"id": "typed", "kind": "live", "beat": "typed", "title": "Typed entry and Undo",
     "panel": {"title": "Typed entry, <span>Undo</span>", "step": "2 / 7",
               "bullets": ["Gemini 3.8 Flash returns structured JSON, not free text", "Written at once when confidence is 0.7 or higher", "Samjha card with the running total, and Undo"]},
     "lines": [
         "He types: Gupta ji ne 350 rupaye udhaar liya.",
         "Gemini 3.8 Flash returns structured data, not free text: intent, customer, amount, confidence.",
         "The entry is written at once, and Ramesh gets a card: Samjha, likh diya, Gupta ji, 350 rupees, total 350.",
         "Wrong? One tap on Undo and it is gone. Theek hai, hata diya.",
     ]},
    {"id": "confirm", "kind": "live", "beat": "confirm", "title": "Low confidence asks first",
     "panel": {"title": "Not sure? <span>Ask first</span>", "step": "3 / 7",
               "bullets": ["Shayad, lagta hai: confidence drops below 0.7", "Nothing is written; the app shows Pakka nahi", "Haan, add karo writes it; Nahi drops it"]},
     "lines": [
         "When Gemini is not sure, nothing is written.",
         "Verma ji ko shayad 120 ka udhaar diya: confidence 0.65, below the threshold, so the app asks: Pakka nahi, udhaar mein likhoon?",
         "Only Haan adds it.",
     ]},
    {"id": "voice", "kind": "card", "page": "voicecard.html", "seconds": 21.0, "title": "Voice note through the live API",
     "lines": [
         "Now by voice. Headless Chrome has no microphone, so this clip is synthesised and sent to the same live endpoint the app uses.",
         "The audio goes straight to Gemini; there is no separate speech-to-text step.",
         "It hears three cartons of Parle-G, converts them to seventy-two packets, and the stock total updates.",
     ]},
    {"id": "shelf", "kind": "card", "page": "shelfcard.html", "seconds": 24.0, "title": "Shelf photo through the live API",
     "lines": [
         "Or he just photographs the shelf. Gemini counts every pack it can match to the catalogue.",
         "Nothing changes until Ramesh says yes, and the photo is the truth, so stock is set to what it sees.",
         "Here Colgate and Lifebuoy are counted, and Lifebuoy is below its reorder level.",
     ]},
    {"id": "stock", "kind": "live", "beat": "stock+udhaar", "title": "Stock and Udhaar",
     "panel": {"title": "Stock and <span>Udhaar</span>", "step": "4 / 7",
               "bullets": ["Low items first, with Kam hai badges", "Parle-G 114 after the voice note, Lifebuoy 8 after the scan", "Udhaar is the bahi-khata: every customer, every balance"]},
     "lines": [
         "Stock shows what is low, first: the counts from the voice note and the shelf scan are already here.",
         "Udhaar is the bahi-khata: every customer and every balance, built from what Ramesh said.",
     ]},
    {"id": "forecast", "kind": "live", "beat": "forecast", "title": "Forecast, order sheet, WhatsApp",
     "panel": {"title": "Four weeks ahead, <span>Diwali included</span>", "step": "5 / 7",
               "bullets": ["BigQuery ML ARIMA_PLUS per item, times the festival uplift", "Parle-G: baseline about 148 packets, Diwali week 214", "Order banao builds the list; WhatsApp pe bhejo opens wa.me"]},
     "lines": [
         "Forecast looks four weeks ahead. BigQuery ML predicts demand per item, and we add a festival uplift.",
         "So Parle-G jumps in Diwali week, from a baseline of about 148 packets to 214.",
         "The band says why, and how much to order. One tap builds the order sheet, and one more opens it in WhatsApp for his distributor.",
         "Nothing is sent automatically.",
     ]},
    {"id": "hisaab", "kind": "live", "beat": "hisaab", "title": "Evening hisaab",
     "panel": {"title": "Aaj ka <span>hisaab</span>", "step": "6 / 7",
               "bullets": ["Sales, udhaar given and received, what is owed", "What is low, and the next festival", "Narrated by Gemini in the shop's language"]},
     "lines": [
         "At night, the whole day on one card: sales, udhaar given and received, what is owed, and what is low, in his language.",
     ]},
    {"id": "howitworks", "kind": "anim", "page": "howitworks.html", "seconds": 24.0, "title": "How it works",
     "lines": [
         "How it works. The Flutter app, on Android and the web, talks to a FastAPI service on Cloud Run in Mumbai.",
         "Every message, voice note or photo goes to Gemini 3.8 Flash on Vertex AI with a response schema, so the reply is always valid JSON.",
         "Shops, stock and udhaar live in Firestore. BigQuery ML does the forecast, and the reply comes back in the shopkeeper's language, with Undo.",
     ]},
    {"id": "results", "kind": "anim", "page": "results.html", "seconds": 19.0, "title": "Results and close",
     "lines": [
         "On our test sets: intent 96 percent, entities 100, shelf counts 25 of 26 exact, forecast error 11 percent against 19.6 without the festival uplift, and a typical reply in 2.5 seconds.",
         "Synthetic data and small samples, and we say so in the report.",
         "Kirana Mitra. Bolo, ho jayega.",
     ]},
]
