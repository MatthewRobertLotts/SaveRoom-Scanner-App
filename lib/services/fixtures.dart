import 'dart:convert';

/// ponytail: inline fixture maps, one per card key.
/// Add more entries here when new demo cards are needed.
class Fixtures {
  static const _cardKeys = [
    'en:sv03-223',
    'en:sv04-234',
    'en:sv05-191',
    'en:sv07-201',
    'en:sv02-200',
  ];

  static List<String> get cardKeys => _cardKeys;

  static Map<String, dynamic> byKey(String cardKey) =>
      _all[cardKey] ?? _all[_cardKeys[0]]!;

  static Map<String, dynamic> get first => byKey(_cardKeys[0]);

  static final Map<String, Map<String, dynamic>> _all = {
    // --- Charizard ex (sv03-223) — the original fixture ---
    'en:sv03-223': {
      'data': {
        'card': {
          'card_key': 'en:sv03-223',
          'card_id': 'sv03-223',
          'name': 'Charizard ex',
          'language_code': 'en',
          'rarity': null,
          'collector_number': '223',
          'supertype': 'Pokémon',
        },
        'set': {
          'set_id': 'sv03',
          'set_code': 'sv03',
          'name': 'Obsidian Flames',
        },
        'images': {'has_local_image': false, 'display_image_url': null},
        'pricing': {
          'primary_price': null,
          'fallback_price': {
            'amount': 87.90,
            'currency': 'GBP',
            'source': 'rapidapi_ebay_average_selling_price',
          },
          'evidence_summary': {
            'total_evidence': 58,
            'uk_evidence': 0,
            'source': 'rapidapi',
          },
        },
        'commercial': {'default_sku_id': null, 'sellable_skus': []},
        'provider_status': {
          'cardmarket': 'ready',
          'justtcg': 'ready',
          'tcgplayer': 'ready',
        },
      },
      'metadata': {'contract': 'v1', 'api_version': 'v1', 'sanitized': 'true'},
    },

    // --- Miraidon ex (sv04-234) ---
    'en:sv04-234': {
      'data': {
        'card': {
          'card_key': 'en:sv04-234',
          'card_id': 'sv04-234',
          'name': 'Miraidon ex',
          'language_code': 'en',
          'rarity': 'Ultra Rare',
          'collector_number': '234',
          'supertype': 'Pokémon',
        },
        'set': {'set_id': 'sv04', 'set_code': 'sv04', 'name': 'Paradox Rift'},
        'images': {'has_local_image': false, 'display_image_url': null},
        'pricing': {
          'primary_price': null,
          'fallback_price': {
            'amount': 32.50,
            'currency': 'GBP',
            'source': 'rapidapi_ebay_average_selling_price',
          },
          'evidence_summary': {
            'total_evidence': 31,
            'uk_evidence': 0,
            'source': 'rapidapi',
          },
        },
        'commercial': {'default_sku_id': null, 'sellable_skus': []},
        'provider_status': {
          'cardmarket': 'ready',
          'justtcg': 'ready',
          'tcgplayer': 'ready',
        },
      },
      'metadata': {'contract': 'v1', 'api_version': 'v1', 'sanitized': 'true'},
    },

    // --- Iono (sv05-191) ---
    'en:sv05-191': {
      'data': {
        'card': {
          'card_key': 'en:sv05-191',
          'card_id': 'sv05-191',
          'name': 'Iono',
          'language_code': 'en',
          'rarity': 'Rare',
          'collector_number': '191',
          'supertype': 'Trainer',
        },
        'set': {
          'set_id': 'sv05',
          'set_code': 'sv05',
          'name': 'Temporal Forces',
        },
        'images': {'has_local_image': false, 'display_image_url': null},
        'pricing': {
          'primary_price': null,
          'fallback_price': {
            'amount': 8.20,
            'currency': 'GBP',
            'source': 'rapidapi_ebay_average_selling_price',
          },
          'evidence_summary': {
            'total_evidence': 27,
            'uk_evidence': 0,
            'source': 'rapidapi',
          },
        },
        'commercial': {'default_sku_id': null, 'sellable_skus': []},
        'provider_status': {
          'cardmarket': 'ready',
          'justtcg': 'ready',
          'tcgplayer': 'ready',
        },
      },
      'metadata': {'contract': 'v1', 'api_version': 'v1', 'sanitized': 'true'},
    },

    // --- Greninja ex (sv07-201) ---
    'en:sv07-201': {
      'data': {
        'card': {
          'card_key': 'en:sv07-201',
          'card_id': 'sv07-201',
          'name': 'Greninja ex',
          'language_code': 'en',
          'rarity': 'Double Rare',
          'collector_number': '201',
          'supertype': 'Pokémon',
        },
        'set': {'set_id': 'sv07', 'set_code': 'sv07', 'name': 'Stellar Crown'},
        'images': {'has_local_image': false, 'display_image_url': null},
        'pricing': {
          'primary_price': null,
          'fallback_price': {
            'amount': 14.30,
            'currency': 'GBP',
            'source': 'rapidapi_ebay_average_selling_price',
          },
          'evidence_summary': {
            'total_evidence': 43,
            'uk_evidence': 0,
            'source': 'rapidapi',
          },
        },
        'commercial': {'default_sku_id': null, 'sellable_skus': []},
        'provider_status': {
          'cardmarket': 'ready',
          'justtcg': 'ready',
          'tcgplayer': 'ready',
        },
      },
      'metadata': {'contract': 'v1', 'api_version': 'v1', 'sanitized': 'true'},
    },

    // --- Giratina V (sv02-200) ---
    'en:sv02-200': {
      'data': {
        'card': {
          'card_key': 'en:sv02-200',
          'card_id': 'sv02-200',
          'name': 'Giratina V',
          'language_code': 'en',
          'rarity': 'Ultra Rare',
          'collector_number': '200',
          'supertype': 'Pokémon',
        },
        'set': {'set_id': 'sv02', 'set_code': 'sv02', 'name': 'Paldea Evolved'},
        'images': {'has_local_image': false, 'display_image_url': null},
        'pricing': {
          'primary_price': null,
          'fallback_price': {
            'amount': 25.00,
            'currency': 'GBP',
            'source': 'rapidapi_ebay_average_selling_price',
          },
          'evidence_summary': {
            'total_evidence': 19,
            'uk_evidence': 0,
            'source': 'rapidapi',
          },
        },
        'commercial': {'default_sku_id': null, 'sellable_skus': []},
        'provider_status': {
          'cardmarket': 'ready',
          'justtcg': 'ready',
          'tcgplayer': 'ready',
        },
      },
      'metadata': {'contract': 'v1', 'api_version': 'v1', 'sanitized': 'true'},
    },
  };

  /// Return the full fixture JSON string for [cardKey], matching
  /// the format rootBundle.loadString would return.
  static String jsonString(String cardKey) => jsonEncode(byKey(cardKey));
}
