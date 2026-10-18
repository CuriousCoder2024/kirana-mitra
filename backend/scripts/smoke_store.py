"""One-shot Firestore smoke test: `uv run python scripts/smoke_store.py [--keep]`.

Creates a shop, applies one sale through the real service code (no Gemini),
undoes it, and prints the Firestore document paths touched. Uses the same env
as the server (GOOGLE_CLOUD_PROJECT, FIRESTORE_DATABASE, STORE); pass --root
to write under a different top-level collection than "shops". Deletes the shop
afterwards unless --keep is given.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from app.config import get_settings  # noqa: E402
from app.models import Entities, ExtractedItem, Extraction  # noqa: E402
from app.service import build_reply, undo  # noqa: E402
from app.store_firestore import FirestoreRepository  # noqa: E402


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", default="shops")
    ap.add_argument("--keep", action="store_true")
    args = ap.parse_args()
    settings = get_settings()
    print(f"project={settings.google_cloud_project} database={settings.firestore_database} root={args.root}")
    repo = FirestoreRepository(project=settings.google_cloud_project, database=settings.firestore_database,
                               root=args.root)

    shop = repo.create_shop("Smoke Test Store", "Smoke", "hi-Latn")
    print(f"created  {args.root}/{shop.shop_id}  ({len(repo.list_items(shop.shop_id))} seeded items)")
    parle = next(i for i in repo.list_items(shop.shop_id) if i.name == "Parle-G")
    print(f"item     {args.root}/{shop.shop_id}/items/{parle.item_id}  Parle-G quantity={parle.quantity:g}")

    extraction = Extraction(intent="sale", confidence=0.95, language="hi-Latn",
                            entities=Entities(items=[ExtractedItem(name="parle ji", quantity=5, unit="packet")]),
                            reply_text="Samjha: Parle-G, 5 packet bike.")
    reply = build_reply(repo, shop, extraction, threshold=settings.confirm_threshold)
    after = repo.get_item(shop.shop_id, parle.item_id)
    print(f"applied  {args.root}/{shop.shop_id}/messages/{reply.message_id}  "
          f"applied={reply.applied} Parle-G quantity={after.quantity:g}")
    print(f"         reply_text: {reply.reply_text}")

    text = undo(repo, shop, reply.message_id)
    restored = repo.get_item(shop.shop_id, parle.item_id)
    print(f"undone   {args.root}/{shop.shop_id}/messages/{reply.message_id}  "
          f"Parle-G quantity={restored.quantity:g}  ({text})")
    second = repo.pop_applied(shop.shop_id, reply.message_id)
    print(f"undo twice -> {'blocked' if second is None else 'NOT blocked (bug)'}")

    if not args.keep:
        db = repo._db
        shop_ref = db.collection(args.root).document(shop.shop_id)
        for sub in ("items", "ledger", "messages", "orders", "feedback"):
            for doc in shop_ref.collection(sub).stream():
                doc.reference.delete()
        shop_ref.delete()
        print(f"deleted  {args.root}/{shop.shop_id}")
    ok = restored.quantity == parle.quantity and after.quantity == parle.quantity - 5 and second is None
    print("RESULT", "OK" if ok else "FAILED")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
