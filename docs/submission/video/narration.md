# Kirana Mitra demo video: narration

Spoken by Google Cloud Text-to-Speech (cloud-tts en-IN-Neural2-B), one call per sentence; the same sentences are burned in as captions.
Hinglish lines are spoken as written. Total narration about 187 s inside a 221 s video.

## 0:00 · The problem

- Meet Ramesh Gupta. He runs Gupta General Store, a kirana.
- Stock arrives in cartons, sells by the packet, and half his customers buy on udhaar.
- Ramesh won't fill in forms. But he will talk.
- Kirana Mitra lets him just speak, in Hindi, Hinglish or English, and keeps the books.

## 0:20 · Onboarding in Hinglish

- Two fields and a language. Ramesh picks Hinglish, so every reply comes back in Hinglish.
- The shop is created on Cloud Run, and the chat opens: Namaste Ramesh, bolo, kya aaya, kya bika.

## 0:32 · Typed entry and Undo

- He types: Gupta ji ne 350 rupaye udhaar liya.
- Gemini 3.8 Flash returns structured data, not free text: intent, customer, amount, confidence.
- The entry is written at once, and Ramesh gets a card: Samjha, likh diya, Gupta ji, 350 rupees, total 350.
- Wrong? One tap on Undo and it is gone. Theek hai, hata diya.

## 0:57 · Low confidence asks first

- When Gemini is not sure, nothing is written.
- Verma ji ko shayad 120 ka udhaar diya: confidence 0.65, below the threshold, so the app asks: Pakka nahi, udhaar mein likhoon?
- Only Haan adds it.

## 1:12 · Voice note through the live API

- Now by voice. Headless Chrome has no microphone, so this clip is synthesised and sent to the same live endpoint the app uses.
- The audio goes straight to Gemini; there is no separate speech-to-text step.
- It hears three cartons of Parle-G, converts them to seventy-two packets, and the stock total updates.

## 1:34 · Shelf photo through the live API

- Or he just photographs the shelf. Gemini counts every pack it can match to the catalogue.
- Nothing changes until Ramesh says yes, and the photo is the truth, so stock is set to what it sees.
- Here Colgate and Lifebuoy are counted, and Lifebuoy is below its reorder level.

## 1:58 · Stock and Udhaar

- Stock shows what is low, first: the counts from the voice note and the shelf scan are already here.
- Udhaar is the bahi-khata: every customer and every balance, built from what Ramesh said.

## 2:16 · Forecast, order sheet, WhatsApp

- Forecast looks four weeks ahead. BigQuery ML predicts demand per item, and we add a festival uplift.
- So Parle-G jumps in Diwali week, from a baseline of about 148 packets to 214.
- The band says why, and how much to order. One tap builds the order sheet, and one more opens it in WhatsApp for his distributor.
- Nothing is sent automatically.

## 2:40 · Evening hisaab

- At night, the whole day on one card: sales, udhaar given and received, what is owed, and what is low, in his language.

## 2:55 · How it works

- How it works. The Flutter app, on Android and the web, talks to a FastAPI service on Cloud Run in Mumbai.
- Every message, voice note or photo goes to Gemini 3.8 Flash on Vertex AI with a response schema, so the reply is always valid JSON.
- Shops, stock and udhaar live in Firestore. BigQuery ML does the forecast, and the reply comes back in the shopkeeper's language, with Undo.

## 3:19 · Results and close

- On our test sets: intent 96 percent, entities 100, shelf counts 25 of 26 exact, forecast error 11 percent against 19.6 without the festival uplift, and a typical reply in 2.5 seconds.
- Synthetic data and small samples, and we say so in the report.
- Kirana Mitra. Bolo, ho jayega.
