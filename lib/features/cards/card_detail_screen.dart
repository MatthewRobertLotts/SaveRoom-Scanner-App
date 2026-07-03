import 'package:flutter/material.dart';

import '../../services/fixture_loader.dart';
import '../../widgets/info_tile.dart';
import '../../widgets/saveroom_shell.dart';

class CardDetailScreen extends StatelessWidget {
  const CardDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: const FixtureLoader().loadCardDetail(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return SaveRoomShell(title: 'Card detail', children: [Text('Fixture load failed: ${snapshot.error}')]);
        }
        if (!snapshot.hasData) {
          return const SaveRoomShell(title: 'Card detail', children: [LinearProgressIndicator()]);
        }
        return SaveRoomShell(title: 'Card detail', children: _content(snapshot.data!));
      },
    );
  }

  List<Widget> _content(Map<String, dynamic> fixture) {
    final data = asMap(fixture['data']);
    final card = asMap(data['card']);
    final set = asMap(data['set']);
    final pricing = asMap(data['pricing']);
    final images = asMap(data['images']);
    final commercial = asMap(data['commercial']);
    final metadata = asMap(fixture['metadata']);
    final setText = [textAt(set, 'name'), textAt(set, 'code'), textAt(card, 'number')]
        .where((value) => value != '—')
        .join(' / ');

    return [
      Text(textAt(card, 'name', 'Unknown card'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      InfoTile(label: 'Set / code / number', value: setText.isEmpty ? '—' : setText),
      InfoTile(label: 'Language', value: textAt(card, 'language')),
      InfoTile(label: 'Pricing summary', value: _pricingText(pricing)),
      InfoTile(label: 'Image URL/path', value: _firstImage(images)),
      InfoTile(label: 'Provenance / metadata', value: _metadataText(metadata, commercial)),
    ];
  }

  String _pricingText(Map<String, dynamic> pricing) {
    if (pricing.isEmpty) return '—';
    final parts = <String>[];
    for (final key in ['market_price', 'market_price_gbp', 'currency', 'price_label', 'source']) {
      final value = pricing[key];
      if (value != null) parts.add('$key: $value');
    }
    return parts.isEmpty ? pricing.toString() : parts.join(' · ');
  }

  String _firstImage(Map<String, dynamic> images) {
    for (final value in images.values) {
      if (value != null && value.toString().trim().isNotEmpty) return value.toString();
    }
    return '—';
  }

  String _metadataText(Map<String, dynamic> metadata, Map<String, dynamic> commercial) {
    final bits = <String>[];
    for (final key in ['api_version', 'contract', 'fixture', 'sanitized']) {
      if (metadata.containsKey(key)) bits.add('$key: ${metadata[key]}');
    }
    if (commercial.isNotEmpty) bits.add('commercial keys: ${commercial.keys.join(', ')}');
    return bits.isEmpty ? '—' : bits.join(' · ');
  }
}
