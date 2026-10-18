# Kirana Mitra · design v2.1 handoff for Flutter

Design board (annotated phone frames, tokens, components): https://claude.ai/artifact/Cv8J8Uh37PWCLuMfFFT1N2

Scope: visual and interaction redesign of the existing five screens plus five additions
(first-run welcome, recording sheet, per-customer history, evening hisaab card, empty and
error states). v2.1 adds the friendliness audit in section 8 and the Barni logo. The API contract in
`docs/api-contract.md` is unchanged; every screen below renders data that contract already
returns. Current implementation referenced throughout is `app/lib/` as of commit `a5369b8`.

Rules that apply everywhere:

- Primary actions are 56 dp tall or more and sit in the bottom 40 % of the screen.
- Body text 18 sp, captions 15 sp, nothing under 13 sp. Numbers that matter are 26 sp or larger.
- Every icon has a word next to it. Every colour signal has an icon or a word next to it.
- Red (`mirchi`) means only two things: stock is low, money is owed.
- Undo is always a labelled button, never only a snackbar or a chip.

---

## 1. Colour tokens

Replace `KmColors` in `app/lib/theme.dart` with the set below. Names are the tokens to use in
code; the Hinglish nickname is for the design board only.

| Token | Hex | Nickname | Use |
|---|---|---|---|
| `saffron` | `#C85A0E` | bhuna kesar | primary button fill, mic fill, selected chip, focused field border |
| `saffronBright` | `#F08A2C` | kesar glow | mic halo/shadow, forecast band, festival accents |
| `saffronTint` | `#FFE6CC` | kesar tint | user bubble, selected nav indicator, selected option card |
| `terracotta` | `#A83E12` | bahi-khata | udhaar ledger card, amounts owed, Undo border and text |
| `cream` | `#FBF1E2` | cream | scaffold background |
| `paper` | `#FFFCF7` | paper | cards, bubbles, app bar, nav bar, dock, text fields |
| `sand` | `#EBDAC1` | sand | borders, dividers, date chip background |
| `ink` | `#2A1A10` | ink | text, hisaab card header |
| `inkSoft` | `#6E5240` | ink soft | captions, labels, history line in chart |
| `inkFaint` | `#A58B77` | ink faint | hints, unselected radio, gesture bar |
| `leaf` | `#2F7A4B` | leaf | confirmed stripe, "Haan" button, paid amounts, sales total |
| `leafTint` | `#DDF0E2` | leaf tint | "Chukta" badge background |
| `mirchi` | `#B3261E` | mirchi | low-stock badge fill, low counts, "Kam hai" tile |
| `mirchiTint` | `#FBE1DE` | mirchi tint | low-stock band and tile background |
| `lowRowWash` | `#FFF7F3` | | background of a low-stock list row |
| `haldi` | `#E9A826` | haldi | low-confidence stripe, Diwali marker |
| `haldiTint` | `#FFF1CF` | haldi tint | low-confidence badge and forecast reason band |
| `haldiText` | `#8A5A00` | | text on haldi tint |
| `whatsapp` | `#1FA855` | | only on the button that opens WhatsApp |

Changes from current: `saffron` darkens from `#E8701A` to `#C85A0E` (white text now passes
4.2:1), `terracotta` from `#C1440E` to `#A83E12`, `brown` renamed `ink` and darkened to
`#2A1A10`, `alert` becomes `mirchi`, `userBubble` becomes `saffronTint`. New: `saffronBright`,
`paper`, `sand`, `inkFaint`, `leafTint`, `mirchiTint`, `lowRowWash`, `haldi*`, `whatsapp`.

Shadows: primary and leaf buttons carry a 2 dp hard bottom shadow in a darker shade
(`#8F3E07` under saffron, `#1F5533` under leaf, `#157A3C` under WhatsApp). The mic adds a
soft `saffron` glow (blur 18, alpha 0.35). Cards have no elevation; they use a 1 dp `sand` border.

Dark mode is out of scope for this pass. Keep `ThemeData` light only.

## 2. Typography

Add Google Fonts via the `google_fonts` package or bundle TTFs in `app/fonts/`:

- **Baloo 2** (weights 600, 700, 800) for display, titles, numbers and nav labels. It has
  native Devanagari, so Hindi titles use the same face.
- **Noto Sans** (400, 600, 700) and **Noto Sans Devanagari** (400, 600, 700) for everything
  read. Flutter needs both families in `fontFamilyFallback` so mixed Hinglish lines render.

| Role | Face | Size / weight / line height | Where |
|---|---|---|---|
| Display | Baloo 2 | 40 / 800 / 1.05 | onboarding wordmark, hisaab total |
| Ledger amount | Baloo 2 | 46 / 800 / 1.0, tabular | udhaar total card |
| Title | Baloo 2 | 28 / 700 / 1.15 | sheet titles ("Order taiyaar" at 24) |
| Heading | Baloo 2 | 22 / 700 / 1.2 | app bar title |
| Number L | Baloo 2 | 32 / 800 / 1.0, tabular | sales total in hisaab |
| Number M | Baloo 2 | 26 / 800 / 1.0, tabular | amounts in cards and rows |
| Number S | Baloo 2 | 24 / 800 / 1.1, tabular | shelf-scan counts, hisaab tiles |
| Timer | Baloo 2 | 34 / 800 / 1.0, tabular | recording sheet |
| Body | Noto Sans | 18 / 400 / 1.35 | bubbles, row titles (700), fields |
| Button | Noto Sans | 19 / 600 / 1.0 | all 56 dp buttons |
| Chip | Noto Sans | 17 / 600 / 1.0 | quick-action and filter chips |
| Caption | Noto Sans | 15 / 400 / 1.35, `inkSoft` | row captions, hints |
| Label | Noto Sans | 14 / 700, letter-spacing 0.02 em | badges, section labels (uppercase), nav labels (13) |
| Status | Noto Sans | 13 / 600 | field labels, app bar subtitle |

Use `FontFeature.tabularFigures()` on every number style.

## 3. Spacing, radius, targets

- Grid: 4 dp. Screen gutter 16. Card inner padding 16 (14 on the chart card). Gap between
  cards 12. Gap between sections 24. Chat bubble gap 10.
- Radius: cards and bubbles 20 (bubble corner on the sender side 6), buttons 18, small
  buttons 14, text fields and option cards 16, chips and badges full, mic full, bottom sheet 28 top.
- Tap targets: chips and list rows 48 minimum, buttons and dock buttons 56, mic FAB on tabs 60,
  hero mic in chat 80 (92 while recording), onboarding and forecast primary buttons 60.
- App bar 56 dp, bottom nav 72 dp, status bar as system. Mic dock 94 dp with the mic raised
  30 dp above the dock's top edge.

## 4. Components

### 4.1 Buttons (`KmButton`)
Variants: `primary` (saffron fill, white text), `leaf` (leaf fill, white), `whatsapp` (whatsapp
fill, white, send icon), `outline` (paper fill, 2 dp sand border, ink text), `undo` (paper fill,
2 dp terracotta border, terracotta text, undo icon), `ghost` (no fill, saffron text, 48 dp).
Height 56 (`small` variant 48, radius 14, 17 sp). Horizontal padding 22 (16 small). Icon 24 dp,
always leading, gap 10. Full-width variant `block`. One `primary` per screen at most.

Replaces: `FilledButton`/`OutlinedButton` theme entries; the Undo `ActionChip`.

### 4.2 Quick-action chip (`KmChip`)
48 dp, radius 24, paper fill, 2 dp saffron border, 17 sp semibold ink text, optional 20 dp
leading icon in saffron. `selected`: saffron fill, white text and icon. `quiet`: sand border
(used for unselected forecast item filters). Chips navigate (`open_stock`, `open_udhaar`,
`open_forecast`, `send_order`) or filter. They never carry `confirm` or `undo`; those actions
render as buttons inside the card (4.5, 4.6).

### 4.3 Badge (`KmBadge`)
Height 28 (24 inside list rows), radius full, 14 sp bold (12 in rows), 16 dp leading icon.
Variants: `low` (mirchi fill, white, arrow-down icon, text "Kam hai"), `ok` (leafTint fill,
leaf text, check icon, "Chukta"), `warn` (haldiTint, haldiText, warning icon, "Pakka nahi"),
`demo` (sand fill, inkSoft text, "Demo").

### 4.4 Bubbles (`MessageBubble`)
Max width 300. Padding 10 × 14. 18 sp body. User: saffronTint, top-right radius 6. Bot: paper,
1 dp sand border, top-left radius 6. Voice notes: the transcript from `ExtractionReply.transcript`
is the bubble text; beneath it a 14 sp meta row with a 16 dp mic icon, a 6–7 bar static waveform
(3 dp bars, saffron, heights 8–22) and the duration `m:ss`. Photo messages: the thumbnail
(200 × 130, radius 16) as the bubble.

Bot replies with `intent` in `stock_in | sale | udhaar_given | udhaar_paid` render as a card
(4.5 or 4.6) instead of a bubble. `question` and `unclear` stay bubbles.

### 4.5 Samjha card (`ConfirmCard`) — `applied: true`
Paper card, radius 20, 1 dp sand border, 6 dp leaf stripe on the left edge.
- Header row (padding 8 10 0 16): 22 dp check-circle icon in leaf + "Samjha · likh diya" 16 sp bold leaf,
  then a `SunoButton` (4.16) pushed to the right.
- Body (padding 6 16 10, gap 6): one or two key/value rows, then a 13 sp inkSoft caption
  "Likha {time} · {source} se" (source: voice / photo / likha). Row 1: subject (customer name or
  item name + pack) 18 sp left, delta right in Number M with sign ("+ ₹350", "+ 3 carton",
  "− ₹500"). Delta is terracotta for udhaar given and stock out, leaf for udhaar paid, ink for
  stock in. Row 2: caption "Udhaar · ab total" / "Stock · ab total" 15 sp inkSoft left, new total
  right in Number M ink.
- Footer (padding 0 16 10, gap 10): `KmButton.undo small` (not stretched) followed by the
  remaining `quick_actions` as `KmChip`s, the first stretched.
- Data: subject and delta from `entities`; the new total is parsed from `reply_text` until the
  contract carries it (the backend reply always ends with "Ab total X" / "Total ₹X"). If parsing
  fails, show `reply_text` as a bubble and still render the Undo button beneath it.

Replaces: plain-text reply + Undo chip.

### 4.6 Pakka nahi card (`AskCard`) — `applied: false`, confidence < 0.7
Same shell with a 6 dp haldi stripe.
- Header: 22 dp warning icon + "Pakka nahi" in haldiText, `SunoButton` at the right. The heard
  transcript is already the user bubble above, so the header does not repeat it.
- Body: subject/delta row as in 4.5, then the question line 15 sp inkSoft: "Stock mein add
  karoon?" / "Udhaar mein likhoon?" / "Bikri mein likhoon?" by intent.
- Footer: `KmButton.leaf small` with check icon and the `confirm` action's label ("Haan, add
  karo"), then `KmButton.outline small` "Nahi". Both stretch equally. "Nahi" posts nothing; it
  collapses the footer and appends a bot bubble "Theek hai, nahi likha."

Also used for `/shelf-scan` replies (header "Shelf dekha · N cheezein mili" with a camera icon
and a saffron stripe; body is the count list in 4.8; confirm label "Haan, update karo").

### 4.7 List row (`KmRow`)
Min height 72, padding 12 × 16, paper, 1 dp sand bottom border; rows live inside a radius-18
container with a sand border. Left: 44 dp tile (radius 12 for items with the first letter in
Baloo 2 20/800 on a tinted background cycling saffronTint, leafTint, haldiTint, sand; radius
full for customers with initials in white on terracotta/saffron/haldiText/inkSoft/leaf).
Middle: title 18/700, caption 15 inkSoft. Right: Number M (26/800 tabular) with a 14 sp unit or
state caption below.
Low-stock row: background `lowRowWash`, number in mirchi, `KmBadge.low` under the number.
Owed row: number in terracotta, caption "baaki". Settled row: `KmBadge.ok` "Chukta" instead of
a number.

### 4.8 Count list (shelf scan)
Inside the card body: one row per `items[]` entry, 8 dp vertical padding, sand dividers. Name
17/700 + "reorder at N" 14 caption; `KmBadge.low` when the item is in `low_stock[]`; count
Number S right-aligned (mirchi when low). No table header.

### 4.9 Ledger card (`KhataCard`)
Terracotta fill, white text, radius 22, padding 18. A 10 dp "stitched spine" strip on the left
edge: repeating 8 dp blocks of `#8E3310` and transparent. Label 14/600 uppercase letter-spacing
0.04 em at 90 % opacity, amount 46/800 tabular, then a 15 sp line of today's movement.

### 4.10 Forecast chart (`DemandChart`)
Plot area 264 × 136 dp inside a paper card. Grid lines sand at 0/40/80/120 (or a 4-step scale
derived from `max(upper)` rounded up to a multiple of 40). History: inkSoft 3 dp line with 3.5 dp
dots. Join history to forecast with a dashed saffron segment. Forecast: saffron 3 dp line, 4.5 dp
dots with paper stroke; the peak dot 6 dp with its value above it in Baloo 2 14/800. Band: polygon
upper→lower filled with a vertical gradient saffronBright 35 %→8 %. The forecast half of the plot
is washed `#FFF4E6` so past and future read without the legend. Festival: haldi 2 dp dashed
vertical line at the festival date with a 20 dp diya glyph above the plot. X labels every second
week ("21 Sep"), y labels left, 11 sp inkSoft. Legend beneath: Pichhle hafte · Anumaan · Range ·
Diwali, 13 sp.

### 4.11 Mic (`MicButton`, `MicDock`, `MicFab`)
- Hero mic in chat: 80 dp, linear gradient 150° from `saffronBright` to `saffron` (the only
  gradient in the app besides the logo and the FAB), white 40 dp mic icon, glow shadow, label "Dabake bolo"
  14/600 saffron beneath. Raised 30 dp above the dock.
- Dock: paper, 1 dp sand top border, padding 8 20 6. Left 56 dp outline circle with camera icon
  and label "Shelf photo" 13/600 inkSoft; right 56 dp with keyboard icon and label "Likho".
  Tapping "Likho" replaces the dock with the current text field + send row until sent or
  dismissed.
- Recording sheet (replaces the dock while pressed): mic grows to 92 dp terracotta with two rings
  (10 dp at 18 % and 22 dp at 8 % alpha), timer 34/800 terracotta, animated 13-bar waveform
  (5 dp bars, 10–38 dp), label "Sun raha hoon… chhodo toh bhejega" 16/600 inkSoft, hint row
  with back-arrow icon "Cancel ke liye ungli bahar le jao" 14/600. A 56 dp dashed circle with an
  X sits 90 dp left of the mic centre: when the finger is over it the mic turns `inkFaint`, the
  icon becomes X and the label "Chhod do, cancel ho gaya". The message list behind fades to 55 %.
  Respect `MediaQuery.disableAnimations` for the waveform.
- Mic FAB on Stock, Udhaar, Mangao: 60 dp, same gradient as the hero mic, bottom-right, 16 dp from the edge and
  32 dp above the nav bar. Same hold-to-talk; the reply shows as a floating `ConfirmCard` at the
  bottom for 6 s with its Undo, then the tab's list refreshes.

### 4.12 Language chip (`LangChip`)
36 dp, paper, 1.5 dp sand border, 18 dp globe icon saffron, label 14/700 in the current value
("हिंदी", "Hinglish", "English"). Sits at the right of every app bar. Tap opens a bottom sheet
with the three option cards from onboarding; selection updates `ShopPrefs.language` and the
locale immediately. (The contract's `POST /shops` is the only place language is sent; the app
stores it locally and the next `/chat` reply follows the user's mix anyway.)

### 4.13 Logo mark · the Barni (v2.1)
A kirana's glass barni jar with a sound wave inside it. SVG, 64 × 64 viewBox, in
`app/assets/logo.svg`; copy the `<symbol id="logo">` from the design board verbatim:

- Background: rounded square, radius 18/64 (28 %), linear gradient top-left `#F08A2C` to
  bottom-right `#BE520B`.
- Lid: `ink` rect 22 × 8 at (21, 11), radius 3. Neck: `paper` rect 16 × 5 at (24, 18).
- Jar body: `paper` rounded rect from (17, 22) to (47, 54), radius 8.
- Wave: three `saffron` bars 4.5 wide, radius 2.25, at x 23.5 / 29.75 / 36 with heights 10 / 22 / 16,
  vertically centred on y 39.

Sizes: 84 onboarding, 44 wordmark lockup, 36 app bar, 24 bot "Mitra" line and notifications.
Wordmark: Baloo 2 800 "Kirana Mitra" with "Mitra" in `saffron` (Devanagari: "किराना मित्र",
"मित्र" in saffron). Android adaptive icon: the gradient as background layer, jar as foreground.
The v2 awning-and-bubble mark is retired.

### 4.14 Bottom navigation
72 dp, paper, 1 dp sand top border. Four items: Baat (mic icon), Stock (box), Udhaar (wallet),
Mangao (trend). "Mangao" replaces "Forecast" (v2.1): the tab is named for the question it
answers, "kya mangao?". Icon 26 dp, label 13/600. Selected: terracotta icon and label with a
56 × 32 saffronTint pill behind the icon. Replaces Material `NavigationBar` indicator styling.

### 4.16 Suno button (`SunoButton`) — v2.1
32 dp pill, cream fill, 18 dp speaker icon + "Suno" 13/700 inkSoft, right-aligned in every bot
card header (`dark` variant on the hisaab header: 16 % paper fill, `#FFF4E6` text). Tap reads
`reply_text` aloud with `flutter_tts` in the reply's `language` (`hi-IN` for hi and hi-Latn,
`en-IN` for en). While speaking the icon animates and the label becomes "Ruko"; tapping again
stops. Also present on plain bot bubbles longer than one line as a trailing 32 dp icon-only
variant with semantics label "Suno".

### 4.17 Example chip (`ExampleChip`) — v2.1
Full-width `KmChip` variant: 52 dp min height, paper fill, sand border, left-aligned, 20 dp
leading icon in saffron, text wraps. Tapping sends the sentence through `/chat` as if typed.
Used in the first-run welcome and in every empty state.

### 4.18 Error card (`ErrorCard`) — v2.1
Floating card above the nav bar (14 dp side margins), paper, 1 dp sand border, 6 dp `ink` left
stripe (not red: nothing in the shop is wrong), 22 dp wifi-off icon, title 17/700, one line
15 inkSoft, `KmButton.outline small` "Phir try karo". Stays until resolved or dismissed by swipe.
Voice notes and photos that failed to send are queued locally and resent when connectivity
returns; the card then becomes a 3 s leaf toast "Bhej diya".

### 4.15 App bar
56 dp, cream (same as scaffold), no elevation, no solid saffron. Title in Baloo 2 22/700 ink,
subtitle 13 inkSoft beneath (shop name on chat, counts and freshness on tabs). Chat shows the
36 dp logo on the left; detail screens show a 44 dp back circle. `LangChip` on the right.
The "Demo" `KmBadge` sits left of the chip when the app is in mock mode.

---

## 5. Screens

### 5.1 Onboarding (`onboarding_screen.dart`)
Top to bottom, 16 dp gutter: 84 dp logo, "Kirana Mitra" 40/800, tagline "Bolo, ho jayega."
18/600 inkSoft, 14 dp gap, two `KmField`s (60 dp, radius 16, 2 dp sand border, leading icon
24 dp inkSoft, floating label 13 sp + value 18 sp; focused = saffron border), section label
"MITRA KIS BHASHA MEIN BOLE?" 15/700 inkSoft letter-spacing 0.04 em, three option cards
(64 dp, radius 16, 26 dp radio; selected = saffron border + `#FFF4E6` fill), spacer, 60 dp
`KmButton.primary block` "Shuru karo" with trailing arrow. Hinglish is preselected.
Each option shows its language name 18/700 and a sample greeting 15 inkSoft in that script.
Validation: empty fields get a saffron border and the caption "Yeh bharo" under the field; no
dialogs. Server failure keeps the current demo-mode fallback with the notice as a bot bubble on
the chat screen instead of text on this screen.

### 5.1b First run (v2.1, chat empty state)
Shown until the first voice note or chip is sent. Day chip, then a "Mitra" line (24 dp logo +
"Mitra" 13/700 inkSoft) above a bot bubble: "Namaste {name} ji! Main Mitra hoon. Dukaan mein jo
bhi hua, bas bol do. Main likh lunga, aur galti ho toh Undo hai." Then the label "AISE BOLO (tap
karke bhi bhej sakte ho)" 13/700 and three `ExampleChip`s (box icon "Aaj 2 carton Parle-G aaya",
wallet icon "Sharma ji ne 200 udhaar liya", rupee icon "Maggi kitni bachi hai?"). The hero mic
shows a pulsing 104 dp ring (`saffronBright`, 3 dp, scale 0.8→1.25, 1.6 s loop, off when
animations are disabled) and the label "Yahan dabao aur bolo". After the first send the ring
stops for good and the label returns to "Dabake bolo".

### 5.2 Chat home (`chat_screen.dart`)
App bar (logo, "Kirana Mitra", shop name, LangChip). Message list bottom-aligned, 14 dp side
padding, 10 dp gap, day chips ("Aaj · Sat 18 Oct") 13/600 on sand. Replies render per 4.4–4.6
with `SunoButton`. Mic dock per 4.11. Bottom nav per 4.14. Remove the always-visible text field;
"Likho" reveals it. Navigation chips (`open_*`, `send_order`) render as a chip row under the
latest reply only; older replies drop their chips so stale actions are never shown.
Festival day (v2.1): when `/forecast` lists a festival dated today, the first bot message of the
day is "Shubh {festival}, {name} ji! Aaj bheed hogi. Stock check kar lo?" with the chip "Stock
dekho", and the day chip shows a diya glyph instead of the dot for that week.

### 5.3 Recording state
Per 4.11. Triggered by pointer down on the hero mic or a tab FAB; ends on pointer up (send) or
on release over the cancel target. Max 60 s: at 55 s the timer turns mirchi; at 60 s the note is
sent automatically.

### 5.4 Shelf-scan result
Camera (v2.1): the capture screen shows a rounded-rectangle guide (16 dp inset, 2 dp paper at
70 %) with one line beneath it, "Shelf seedha, roshni mein", 16/600 on a 45 % ink scrim. If the
preview's sharpness score is low, the line becomes "Thoda aur paas, hilao mat" until it clears.
User photo bubble, then the `AskCard` variant from 4.6 with the count list from 4.8 and the
question "Stock yahi set kar doon?". After confirm, the card's footer swaps to a leaf "Samjha ·
stock update ho gaya" line with an Undo button. The chips row beneath keeps "Stock dekho" and
"Order banao" (`send_order`).

### 5.5 Stock (`stock_screen.dart`)
App bar: "Stock", subtitle "{count} cheezein · update {time}". Below: low-stock band (mirchiTint
fill, 1 dp `#EFC2BD` border, radius 18, 28 dp arrow-down icon in mirchi, "N cheezein kam hain"
18/700, the low item names 14 inkSoft, and a `KmButton.primary small` "Order banao" on the
right) shown only when `low_stock` count > 0; otherwise a leafTint band "Sab theek hai" with a
check icon. Then one `KmRow` list, sorted low-stock first then by name. Mic FAB.
Empty state (v2.1, same pattern on Udhaar and Mangao): centred column with an 84 dp tile
(radius 26, saffronTint, 44 dp tab icon in terracotta), title 24/700 Baloo, one 15 sp inkSoft
line, and one `ExampleChip` with a mic icon. Stock: "Stock abhi khaali hai" / "Jo aaya hai, bol
do. Mitra gin lega." / "Aaj 2 carton Parle-G aaya". Udhaar: "Abhi koi udhaar nahi" / "Kisi ne
udhaar liya? Bol do." / "Sharma ji ne 200 udhaar liya". Mangao: "Abhi anumaan nahi" / "2 hafte
ki bikri ke baad Mitra bata dega kya mangao." / no chip. App bar subtitle while empty: "Abhi
kuch nahi likha".

### 5.6 Udhaar (`udhaar_screen.dart`)
App bar: "Udhaar", subtitle "{n} log · bahi-khata". `KhataCard` with "KUL BAAKI",
`total_outstanding`, and "Aaj diya +₹X · Aaj aaya −₹Y" (from today's summary when available,
else omit the line). Rows per 4.7 sorted by balance descending, settled customers last with
"Chukta". Row caption: "{date} · +₹X" or "{date} · −₹Y aaya" from `last_entry_at` and the
last entry's sign (if the ledger endpoint lacks the sign, show the date only). Tap a row → 5.7.
Mic FAB.

### 5.7 Customer history (new, `customer_screen.dart`)
App bar: back circle, customer name, subtitle "Udhaar shuru {first date} · {n} entries".
`KhataCard` with "BAAKI", balance, "Last: {time}". Two 56 dp buttons side by side:
`KmButton.whatsapp` with bell icon "Yaad dilao" (opens `wa.me` with the reminder text below) and
`KmButton.leaf` with rupee icon "Paisa aaya" (opens the recording sheet with the prompt
"Kitna aaya? Bolo." so the entry goes through `/voice-note`). Section label "HISTORY". Rows at
64 dp: title "Udhaar liya" / "Paisa aaya", caption "{date} · voice|cash|photo", amount Number M
(terracotta "+₹" or leaf "−₹"). Entries still inside the undo window show a 40 dp
`KmButton.undo` at the right of the row.
Data: the contract has no per-customer history endpoint; the app keeps the last 50
`ExtractionReply`s per shop locally (message_id, intent, entities, applied, timestamp) and
builds this list from those with `customer_name` matching. Document this as a Phase 5 gap.
Reminder text: "Namaste {name} ji, Gupta General Store se. Aapka ₹{balance} baaki hai. Dhanyavaad!"

### 5.8 Mangao (`forecast_screen.dart`)
App bar: "Kya mangao?", subtitle "Agle 4 hafte ka anumaan · {festival} {date}" when a festival
falls in the horizon (else "Agle 4 hafte ka anumaan"). Horizontal `KmChip` row of items (selected = filled, others `quiet`). Chart card per
4.10 with the item name 18/700 and "{unit} / hafta" 14 inkSoft in the header. Reason band
(haldiTint fill, `#F3D98F` border, 28 dp diya icon in `#B07400`, `reorder_reason` 18/700,
"Stock mein {on_hand} · mangao {reorder_qty} {unit}" 14). 60 dp `KmButton.primary block`
"Order banao · {reorder_qty} {unit}". Bottom nav. No separate on-hand/suggested card.

### 5.9 Order sheet
Modal bottom sheet (radius 28, paper, 44 × 5 grab handle, 45 % ink scrim): header row with a
26 dp leaf check icon, "Order taiyaar" 24/700, "{n} cheezein" 14 inkSoft right-aligned; the
`text` from `/reorder` in a cream box (radius 14, 1 dp dashed sand border, 16 sp, selectable);
`KmButton.whatsapp block` "WhatsApp pe bhejo"; then "Copy" and "Share" as two equal
`KmButton.outline`s. Copy shows a 2 s toast "Copy ho gaya".

### 5.10 Evening hisaab (new, rendered in chat)
At the shop's closing time (default 21:30, local notification) the app fetches `/summary` and
appends a `HisaabCard` to the chat with the day chip "Dukaan band · 9:30 pm". Also reachable
from the chat app bar overflow as "Aaj ka hisaab".
Card: ink header (24 dp receipt icon in saffronBright, "Aaj ka hisaab" 18/700 Baloo, "{date} ·
{entries} entries" 13 at 85 %, `SunoButton.dark` at the right), body with "Aaj ki bikri" 16
inkSoft + `sales_total` Number L in leaf; beneath the label a `KmBadge.ok` "▲ kal se {pct}%"
(or `KmBadge.warn` "▼ kal se {pct}%") computed against the previous day's cached `/summary`,
omitted when there is none; 2 × 2 tiles (cream, radius 14, label 13/600 inkSoft, value Number S): "Udhaar diya" +₹ in
terracotta, "Udhaar aaya" ₹ in leaf, "Kul baaki" ink, "Kam hai" count in mirchi on mirchiTint;
then a 15 sp inkSoft line: "Shabash! " prefix when sales are up, then "Kal ke liye: {items}
mangao." and "{festival} {n} hafte door hai."; footer with
`KmButton.primary small` "Kal ka order banao" (→ 5.9 with all low items) above
`KmButton.outline small` "Ghar pe WhatsApp karo" (shares `reply_text`).

---

## 6. Copy strings

Add or change these keys in `app_en.arb` and `app_hi.arb`. The app currently carries Hinglish
inside the `en` file for `hi-Latn` shops; keep that convention: the `en` column below is the
Hinglish-leaning string the product speaks, `hi` is Devanagari. Where a plain-English variant
is needed for `language == en` shops, it is given in the third column; otherwise use `en` as is.

### 6.1 New keys

| Key | en (hi-Latn) | hi | en (plain), if different |
|---|---|---|---|
| `tagline` | Bolo, ho jayega. | बोलो, हो जाएगा। | Say it, it's done. |
| `languageQuestion` | Mitra kis bhasha mein bole? | मित्र किस भाषा में बोले? | Which language should Mitra reply in? |
| `langSampleHindi` | नमस्ते! आज क्या आया? | नमस्ते! आज क्या आया? | |
| `langSampleHinglish` | Namaste! Aaj kya aaya? | Namaste! Aaj kya aaya? | |
| `langSampleEnglish` | Hello! What came in today? | Hello! What came in today? | |
| `fieldRequired` | Yeh bharo | यह भरो | Fill this in |
| `dockPhoto` | Shelf photo | शेल्फ फोटो | |
| `dockType` | Likho | लिखो | Type |
| `micLabel` | Dabake bolo | दबाकर बोलो | Hold and speak |
| `recordingLabel` | Sun raha hoon… chhodo toh bhejega | सुन रहा हूँ… छोड़ो तो भेजेगा | Listening… release to send |
| `recordingCancelHint` | Cancel ke liye ungli bahar le jao | कैंसल के लिए उंगली बाहर ले जाओ | Slide out to cancel |
| `recordingCancelled` | Chhod do, cancel ho gaya | छोड़ दो, कैंसल हो गया | Released, cancelled |
| `confirmHeader` | Samjha · likh diya | समझा · लिख दिया | Got it · saved |
| `confirmTotalUdhaar` | Udhaar · ab total | उधार · अब कुल | Credit · new total |
| `confirmTotalStock` | Stock · ab total | स्टॉक · अब कुल | Stock · new total |
| `confirmTotalSale` | Bikri · aaj total | बिक्री · आज कुल | Sales · today's total |
| `askHeader` | Pakka nahi | पक्का नहीं | Not sure |
| `askHeard` | aapne kaha “{text}” | आपने कहा “{text}” | you said “{text}” |
| `askStock` | Stock mein add karoon? | स्टॉक में जोड़ूँ? | Add to stock? |
| `askUdhaar` | Udhaar mein likhoon? | उधार में लिखूँ? | Write it as credit? |
| `askSale` | Bikri mein likhoon? | बिक्री में लिखूँ? | Record as a sale? |
| `askNo` | Nahi | नहीं | No |
| `askDeclined` | Theek hai, nahi likha. | ठीक है, नहीं लिखा। | Okay, not saved. |
| `scanHeader` | Shelf dekha · {count} cheezein mili | शेल्फ देखा · {count} चीज़ें मिलीं | Shelf scanned · {count} items found |
| `scanQuestion` | Stock yahi set kar doon? | स्टॉक यही सेट कर दूँ? | Set stock to these counts? |
| `scanConfirmed` | Samjha · stock update ho gaya | समझा · स्टॉक अपडेट हो गया | Got it · stock updated |
| `stockSubtitle` | {count} cheezein · update {time} | {count} चीज़ें · अपडेट {time} | {count} items · updated {time} |
| `lowBandTitle` | {count, plural, =1{1 cheez kam hai} other{{count} cheezein kam hain}} | {count, plural, =1{1 चीज़ कम है} other{{count} चीज़ें कम हैं}} | {count, plural, =1{1 item is low} other{{count} items are low}} |
| `allGoodBand` | Sab theek hai | सब ठीक है | All good |
| `orderButton` | Order banao | ऑर्डर बनाओ | Build order |
| `orderButtonQty` | Order banao · {qty} {unit} | ऑर्डर बनाओ · {qty} {unit} | Build order · {qty} {unit} |
| `udhaarSubtitle` | {count} log · bahi-khata | {count} लोग · बही-खाता | {count} people · ledger |
| `totalOutstanding` | Kul baaki | कुल बाकी | Total outstanding |
| `balanceLabel` | Baaki | बाकी | Due |
| `todayGiven` | Aaj diya +₹{amount} | आज दिया +₹{amount} | Given today +₹{amount} |
| `todayReceived` | Aaj aaya −₹{amount} | आज आया −₹{amount} | Received today −₹{amount} |
| `owedCaption` | baaki | बाकी | due |
| `settledBadge` | Chukta | चुकता | Settled |
| `lastMovementGiven` | {date} · +₹{amount} | {date} · +₹{amount} | |
| `lastMovementPaid` | {date} · −₹{amount} aaya | {date} · −₹{amount} आया | {date} · −₹{amount} paid |
| `customerSubtitle` | Udhaar shuru {date} · {count} entries | उधार शुरू {date} · {count} एंट्री | Credit since {date} · {count} entries |
| `lastEntryAt` | Last: {time} | आखिरी: {time} | |
| `remindButton` | Yaad dilao | याद दिलाओ | Remind |
| `paidButton` | Paisa aaya | पैसा आया | Payment received |
| `paidPrompt` | Kitna aaya? Bolo. | कितना आया? बोलो। | How much came in? Speak. |
| `historyLabel` | History | हिस्ट्री | |
| `entryGiven` | Udhaar liya | उधार लिया | Took credit |
| `entryPaid` | Paisa aaya | पैसा आया | Paid |
| `entrySourceVoice` | voice | वॉइस | |
| `entrySourceCash` | cash | कैश | |
| `reminderText` | Namaste {name} ji, {shop} se. Aapka ₹{balance} baaki hai. Dhanyavaad! | नमस्ते {name} जी, {shop} से। आपका ₹{balance} बाकी है। धन्यवाद! | Hello {name}, this is {shop}. ₹{balance} is due. Thank you! |
| `forecastSubtitle` | Agle 4 hafte · {festival} {date} | अगले 4 हफ्ते · {festival} {date} | Next 4 weeks · {festival} {date} |
| `perWeek` | {unit} / hafta | {unit} / हफ्ता | {unit} / week |
| `legendHistory` | Pichhle hafte | पिछले हफ्ते | Past weeks |
| `legendForecast` | Anumaan | अनुमान | Forecast |
| `legendBand` | Range | दायरा | Likely range |
| `forecastFuture` | AAGE · forecast | आगे · अनुमान | AHEAD · forecast |
| `onHandReorder` | Stock mein {onHand} · mangao {qty} {unit} | स्टॉक में {onHand} · मंगाओ {qty} {unit} | On hand {onHand} · order {qty} {unit} |
| `orderReady` | Order taiyaar | ऑर्डर तैयार | Order ready |
| `orderItemCount` | {count} cheezein | {count} चीज़ें | {count} items |
| `shareWhatsapp` | WhatsApp pe bhejo | WhatsApp पर भेजो | Send on WhatsApp |
| `share` | Share | शेयर | |
| `copied` | Copy ho gaya | कॉपी हो गया | Copied |
| `hisaabTitle` | Aaj ka hisaab | आज का हिसाब | Today's summary |
| `hisaabSubtitle` | {date} · {count} entries | {date} · {count} एंट्री | |
| `hisaabDayChip` | Dukaan band · {time} | दुकान बंद · {time} | Shop closed · {time} |
| `hisaabSales` | Aaj ki bikri | आज की बिक्री | Today's sales |
| `hisaabGiven` | Udhaar diya | उधार दिया | Credit given |
| `hisaabReceived` | Udhaar aaya | उधार आया | Credit received |
| `hisaabOutstanding` | Kul baaki | कुल बाकी | Total due |
| `hisaabLow` | Kam hai | कम है | Low |
| `hisaabLowItems` | {items} kal mangao. | {items} कल मंगाओ। | Order {items} tomorrow. |
| `hisaabFestival` | {festival} {weeks} hafte door hai. | {festival} {weeks} हफ्ते दूर है। | {festival} is {weeks} weeks away. |
| `hisaabOrderButton` | Kal ka order banao | कल का ऑर्डर बनाओ | Build tomorrow's order |
| `hisaabShareButton` | Ghar pe WhatsApp karo | घर पर WhatsApp करो | WhatsApp it home |
| `todayChip` | Aaj · {date} | आज · {date} | Today · {date} |
| `demoNotice` | Server nahi mila. Demo mode mein shuru kar raha hoon. | सर्वर नहीं मिला। डेमो मोड में शुरू कर रहा हूँ। | Couldn't reach the server. Starting in demo mode. |

#### Added in v2.1

| Key | en (hi-Latn) | hi | en (plain), if different |
|---|---|---|---|
| `navForecast` | Mangao | मंगाओ | Order |
| `forecastTitle` | Kya mangao? | क्या मंगाओ? | What to order? |
| `forecastSubtitlePlain` | Agle 4 hafte ka anumaan | अगले 4 हफ्ते का अनुमान | Next 4 weeks' forecast |
| `forecastSubtitle` | Agle 4 hafte ka anumaan · {festival} {date} | अगले 4 हफ्ते का अनुमान · {festival} {date} | Next 4 weeks' forecast · {festival} {date} |
| `sunoButton` | Suno | सुनो | Listen |
| `sunoStop` | Ruko | रुको | Stop |
| `mitraName` | Mitra | मित्र | |
| `firstRunWelcome` | Namaste {name} ji! Main Mitra hoon. Dukaan mein jo bhi hua, bas bol do. Main likh lunga, aur galti ho toh Undo hai. | नमस्ते {name} जी! मैं मित्र हूँ। दुकान में जो भी हुआ, बस बोल दो। मैं लिख लूँगा, और गलती हो तो Undo है। | Hello {name}! I'm Mitra. Whatever happens in the shop, just say it. I'll write it down, and there's Undo if I get it wrong. |
| `exampleLabel` | Aise bolo (tap karke bhi bhej sakte ho) | ऐसे बोलो (टैप करके भी भेज सकते हो) | Try saying (or tap to send) |
| `exampleStock` | Aaj 2 carton Parle-G aaya | आज 2 कार्टन Parle-G आया | 2 cartons of Parle-G came today |
| `exampleUdhaar` | Sharma ji ne 200 udhaar liya | शर्मा जी ने 200 उधार लिया | Sharma ji took 200 on credit |
| `exampleQuestion` | Maggi kitni bachi hai? | Maggi कितनी बची है? | How much Maggi is left? |
| `micCoachLabel` | Yahan dabao aur bolo | यहाँ दबाओ और बोलो | Press here and speak |
| `emptySubtitle` | Abhi kuch nahi likha | अभी कुछ नहीं लिखा | Nothing written yet |
| `emptyStockTitle` | Stock abhi khaali hai | स्टॉक अभी खाली है | Stock is empty |
| `emptyStockLine` | Jo aaya hai, bol do. Mitra gin lega. | जो आया है, बोल दो। मित्र गिन लेगा। | Say what came in. Mitra will count it. |
| `emptyUdhaarTitle` | Abhi koi udhaar nahi | अभी कोई उधार नहीं | No credit yet |
| `emptyUdhaarLine` | Kisi ne udhaar liya? Bol do. | किसी ने उधार लिया? बोल दो। | Someone took credit? Say it. |
| `emptyForecastTitle` | Abhi anumaan nahi | अभी अनुमान नहीं | No forecast yet |
| `emptyForecastLine` | 2 hafte ki bikri ke baad Mitra bata dega kya mangao. | 2 हफ्ते की बिक्री के बाद मित्र बता देगा क्या मंगाओ। | After two weeks of sales Mitra will tell you what to order. |
| `errorOfflineTitle` | Net nahi chal raha | नेट नहीं चल रहा | No internet |
| `errorOfflineLine` | Aapka voice note save hai. Net aate hi bhej dunga. | आपका वॉइस नोट सेव है। नेट आते ही भेज दूँगा। | Your voice note is saved. I'll send it when the internet is back. |
| `errorRetry` | Phir try karo | फिर कोशिश करो | Try again |
| `errorSent` | Bhej diya | भेज दिया | Sent |
| `confirmWrittenAt` | Likha {time} · {source} se | लिखा {time} · {source} से | Written {time} · from {source} |
| `sourceVoice` / `sourcePhoto` / `sourceTyped` | voice / photo / likha | वॉइस / फोटो / लिखा | voice / photo / typed |
| `hisaabUpBadge` | ▲ kal se {pct}% | ▲ कल से {pct}% | ▲ {pct}% vs yesterday |
| `hisaabDownBadge` | ▼ kal se {pct}% | ▼ कल से {pct}% | ▼ {pct}% vs yesterday |
| `hisaabShabash` | Shabash! | शाबाश! | Well done! |
| `hisaabTomorrow` | Kal ke liye: {items} mangao. | कल के लिए: {items} मंगाओ। | For tomorrow: order {items}. |
| `festivalGreeting` | Shubh {festival}, {name} ji! Aaj bheed hogi. Stock check kar lo? | शुभ {festival}, {name} जी! आज भीड़ होगी। स्टॉक चेक कर लो? | Happy {festival}, {name}! It'll be busy today. Check stock? |
| `cameraGuide` | Shelf seedha, roshni mein | शेल्फ सीधा, रोशनी में | Shelf straight, in good light |
| `cameraCloser` | Thoda aur paas, hilao mat | थोड़ा और पास, हिलाओ मत | A bit closer, hold still |

### 6.2 Changed existing keys

| Key | Was (en) | Now en (hi-Latn) | Now hi |
|---|---|---|---|
| `onboardingTitle` | Set up your shop | (removed; tagline replaces it) | |
| `onboardingSubtitle` | Takes 20 seconds… | (removed) | |
| `shopNameLabel` | Shop name | Dukaan ka naam | दुकान का नाम |
| `ownerNameLabel` | Your name | Aapka naam | आपका नाम |
| `languageLabel` | Reply language | (replaced by `languageQuestion`) | |
| `startButton` | Start | Shuru karo | शुरू करें |
| `holdToTalk` | Hold to talk | (replaced by `micLabel`) | |
| `recording` | Listening… release to send | (replaced by `recordingLabel`) | |
| `slideToCancel` | Slide away to cancel | (replaced by `recordingCancelHint`) | |
| `recordingCancelled` | Cancelled | Chhod do, cancel ho gaya | छोड़ दो, कैंसल हो गया |
| `typeMessageHint` | Or type here… | Yahan likho… | यहाँ लिखो… |
| `pickPhoto` | Scan shelf photo | (replaced by `dockPhoto`) | |
| `scanColItem` / `scanColPack` / `scanColCount` | Item / Pack / Count | (removed; no table) | |
| `lowStockBadge` | Kam hai | Kam hai (unchanged) | कम है |
| `reorderAt` | Reorder at {level} | reorder at {level} (caption, lowercase) | {level} पर मंगाओ |
| `lowStockCount` | … items low | (replaced by `lowBandTitle` / `allGoodBand`) | |
| `emptyStock` | No stock yet. Tell me what came in. | Abhi stock nahi hai. Bolo kya aaya. | अभी स्टॉक नहीं है। बोलो क्या आया। |
| `emptyLedger` | No udhaar yet. Say "…" | Abhi koi udhaar nahi. Bolo "Gupta ji ko 350 ka udhaar diya". | अभी कोई उधार नहीं। बोलो "गुप्ता जी को 350 का उधार दिया"। |
| `customersCount` | {count} customers | (replaced by `udhaarSubtitle`) | |
| `lastEntry` | Last entry {date} | (replaced by `lastMovementGiven` / `lastMovementPaid`) | |
| `onHand` / `suggestedReorder` | On hand… / Suggested… | (replaced by `onHandReorder`) | |
| `reorderButton` | Reorder | (replaced by `orderButtonQty`) | |
| `copy` | Copy | Copy (unchanged) | कॉपी |
| `navChat` | Chat | Baat | बात |
| `navForecast` | Forecast | Mangao | मंगाओ |
| `forecastTitle` | Forecast | Kya mangao? | क्या मंगाओ? |

Unchanged keys keep their current values (`appTitle`, `welcomeMessage*`, `send`, `thinking`,
`networkError`, `comingSoon`, `scanFailed`, `imageTooLarge`, `micPermissionDenied`,
`voiceTooShort`, `navStock`, `navUdhaar`, `navForecast`, `demoMode`, `changeShop`, `retry`,
`loading`, `errorLoading`).

Number formatting: Indian grouping (`₹1,20,000`), no decimals for rupees, `NumberFormat('#,##,###', 'en_IN')`.
Dates: "Sat 18 Oct", times "7:41 pm", relative "Aaj" / "Kal" for today and yesterday.

---

## 7. What differs from the current app (review checklist)

1. **Mic dock replaces the input row.** Current: 72 dp mic, camera icon button and an always-
   visible text field in one row. New: 80 dp mic raised above a dock, camera and keyboard at
   56 dp, text field only on demand. Mic FAB added to Stock, Udhaar, Forecast.
2. **Samjha and Pakka nahi cards replace text replies.** Current: `reply_text` bubble plus
   quick-action chips including Undo. New: structured card with the change as a ledger line and
   Undo / Haan / Nahi as buttons; chips only for navigation.
3. **Recording sheet.** Current: colour change plus a 15 sp label. New: 92 dp mic with rings,
   34 sp timer, waveform, visible cancel target, dimmed chat.
4. **Cream app bar, Baloo 2 titles, language chip.** Current: solid saffron bar, Roboto. Language
   was set once at onboarding.
5. **Stock sorted low-first with a summary band** and solid mirchi badges; no "Reorder at" line
   in the row body.
6. **Udhaar ledger card and rows with last movement; new customer history screen** with
   Yaad dilao / Paisa aaya and row-level Undo.
7. **Shelf-scan counts as rows, not a table,** always behind a Haan/Nahi.
8. **Forecast: tinted future half, diya marker, reason band, quantity in the button;** order
   text in a bottom sheet with WhatsApp / Copy / Share.
9. **Evening hisaab card** (new) pushed into chat and reachable from the app bar.
10. **Palette deepened** (saffron `#C85A0E`, ink `#2A1A10`) and three semantic colours added.
11. **v2.1:** Barni logo, "Suno" read-aloud on every bot card, "Mangao" tab, first-run welcome
    with example chips and mic coach, designed empty states, persistent error card with offline
    queue, hisaab day-over-day badge, camera guide, festival greeting, 56 dp app bar, gradient
    on the mic and FAB.

---

## 8. UX audit (v2.1) — findings and where they land

| # | Finding | Fix | Where |
|---|---|---|---|
| 1 | Mitra never introduces itself; the first screen is an empty chat | First-run welcome in first person with the mark, three example chips, pulsing mic coach | 5.1b, 4.17 |
| 2 | Replies exist only as text; slow readers skip them | `SunoButton` on every bot card, TTS in the reply language | 4.16 |
| 3 | "Forecast" is jargon at a counter | Tab "Mangao", title "Kya mangao?" | 4.14, 5.8 |
| 4 | Confirmations carry no time, so they cannot be matched to memory | "Likha {time} · {source} se" caption; time and source on ledger rows | 4.5, 5.7 |
| 5 | Empty tabs show one line of text | Tile + title + one line + example chip on every empty state | 5.5 |
| 6 | Network errors are 4 s snackbars and the voice note is lost | Persistent `ErrorCard`, local queue, auto-resend | 4.18 |
| 7 | The hisaab has no context or warmth | "▲ kal se 12%" badge, "Shabash!" when up, low list as tomorrow's to-do | 5.10 |
| 8 | The camera gives no guidance; failures surface after the scan | Guide frame and one-line hint; sharpness nudge | 5.4 |
| 9 | Flat saffron and heavy ink feel stern | Gradient on mic, FAB and logo only; app bar 56 dp | 4.11, 4.15 |
| 10 | Festivals appear only in the chart | Festival-day greeting with a stock-check chip; diya in the day chip | 5.2 |
| 11 | The awning logo was three ideas and broke at 24 dp | Barni mark: one object, three UI colours, legible at 24 dp | 4.13 |

Not in this pass: dark mode, tablet layout, onboarding voice input, per-customer history
endpoint (needs a contract change; the local cache workaround is in 5.7), yesterday's sales in
`/summary` (the app caches the previous day's summary for the hisaab badge).
