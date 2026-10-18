from app.matching import match_customer, match_item
from app.store import InMemoryRepository


def catalogue():
    repo = InMemoryRepository()
    shop = repo.create_shop("S", "O", "hi-Latn")
    return repo.list_items(shop.shop_id)


def test_fuzzy_item_names_resolve_to_catalogue():
    items = catalogue()
    assert match_item("parle ji", items).name == "Parle-G"
    assert match_item("Parle G 70g", items).name == "Parle-G"
    assert match_item("पारले जी", items).name == "Parle-G"
    assert match_item("maggie", items).name == "Maggi"
    assert match_item("tata namak", items).name == "Tata Salt"
    assert match_item("surf", items).name == "Surf Excel"
    assert match_item("good day biscuit", items).name == "Britannia Good Day"
    assert match_item("fortune tel", items).name == "Fortune Oil"


def test_unknown_item_returns_none():
    items = catalogue()
    assert match_item("zzqx widget", items) is None
    assert match_item("", items) is None


def test_customer_names_merge_only_when_close():
    known = ["Gupta ji", "Sharma aunty"]
    assert match_customer("gupta ji", known) == "Gupta ji"
    assert match_customer("Guptaji", known) == "Gupta ji"
    assert match_customer("Verma ji", known) == "Verma ji"
