"""Extra seed items so a new shop starts with the full 40-item demo catalogue."""

from __future__ import annotations

# Generated from data/catalogue.csv (items itm_016..itm_040); the first 15 live in SEED_ITEMS.
# (name, pack_size, unit, opening qty, reorder level, aliases, units per carton, MRP rupees)
EXTRA_SEED_ITEMS: list[tuple[str, str | None, str, float, float, list[str], int, int]] = [
    ('Vim Dishwash Bar', '200g', 'piece', 48, 24, ['vim bar', 'विम', 'bartan sabun'], 12, 20),
    ('Clinic Plus Shampoo', '80ml', 'piece', 24, 12, ['clinic plus', 'क्लिनिक प्लस', 'shampoo'], 12, 55),
    ('Kurkure Masala Munch', '90g', 'packet', 60, 30, ['kurkure', 'कुरकुरे', 'kurkurey'], 12, 20),
    ('Lays Magic Masala', '52g', 'packet', 60, 30, ['lays', 'लेज़', 'chips'], 12, 20),
    ('Thums Up', '750ml', 'piece', 36, 18, ['thums up', 'थम्स अप', 'thumbs up', 'cold drink'], 12, 45),
    ('Frooti Mango', '160ml', 'piece', 72, 36, ['frooti', 'फ्रूटी', 'mango drink'], 12, 10),
    ('Cadbury Dairy Milk', '24g', 'piece', 96, 48, ['dairy milk', 'डेयरी मिल्क', 'chocolate'], 12, 10),
    ('Kissan Tomato Ketchup', '500g', 'piece', 12, 6, ['ketchup', 'किसान', 'tomato sauce'], 12, 120),
    ('MDH Garam Masala', '100g', 'packet', 16, 8, ['mdh', 'एमडीएच', 'garam masala'], 12, 85),
    ('Everest Chhole Masala', '100g', 'packet', 16, 8, ['everest', 'एवरेस्ट', 'chole masala'], 12, 72),
    ('Toor Dal', '1kg', 'kg', 30, 15, ['arhar dal', 'तूर दाल', 'toor daal'], 12, 160),
    ('India Gate Basmati Rice', '5kg', 'packet', 12, 6, ['basmati', 'बासमती', 'chawal'], 12, 520),
    ('Sugar', '1kg', 'kg', 40, 20, ['cheeni', 'चीनी', 'shakkar'], 12, 45),
    ('Rin Detergent Bar', '250g', 'piece', 48, 24, ['rin', 'रिन', 'rin sabun'], 12, 20),
    ('Harpic Toilet Cleaner', '500ml', 'piece', 12, 6, ['harpic', 'हार्पिक', 'toilet cleaner'], 12, 98),
    ('Good Knight Refill', '45ml', 'piece', 16, 8, ['good knight', 'गुड नाइट', 'machhar refill'], 12, 85),
    ('Dove Cream Beauty Bar', '100g', 'piece', 24, 12, ['dove', 'डव', 'dove sabun'], 12, 65),
    ('Pampers Baby Dry Pants M', '10 pcs', 'packet', 12, 6, ['pampers', 'पैंपर्स', 'diaper'], 12, 220),
    ('Whisper Ultra Clean XL', '7 pads', 'packet', 20, 10, ['whisper', 'व्हिस्पर', 'pads'], 12, 60),
    ('Bisleri Water', '1L', 'piece', 72, 36, ['bisleri', 'बिसलेरी', 'paani bottle'], 12, 20),
    ('Bournvita', '500g', 'piece', 12, 6, ['bournvita', 'बोर्नविटा', 'bornvita'], 12, 245),
    ('Horlicks Classic', '500g', 'piece', 12, 6, ['horlicks', 'हॉर्लिक्स', 'horlics'], 12, 285),
    ('Amul Cow Ghee', '500ml', 'piece', 16, 8, ['ghee', 'घी', 'amul ghee'], 12, 340),
    ('Besan', '500g', 'packet', 30, 15, ['besan', 'बेसन', 'gram flour'], 12, 45),
    ('Cycle Pure Agarbatti', '100 sticks', 'packet', 24, 12, ['agarbatti', 'अगरबत्ती', 'dhoop'], 12, 50),
]
