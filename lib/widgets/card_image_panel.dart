import 'package:flutter/material.dart';

import '../services/fixture_loader.dart';
import 'section_card.dart';

/// A polished card-image placeholder that shows card metadata and an
/// "Image pending" visual treatment. Uses fixture/API data defensively.
///
/// ponytail: single widget, no image pipeline. Upgrade to real image loading
/// when a local/network image asset source is added.
class CardImagePanel extends StatelessWidget {
  const CardImagePanel({
    super.key,
    required this.cardName,
    this.setText,
    this.languageCode,
    this.rarity,
    this.imageUrl,
    this.hasLocalImage = false,
  });

  final String cardName;
  final String? setText;
  final String? languageCode;
  final String? rarity;
  final String? imageUrl;
  final bool hasLocalImage;

  /// Construct from a raw fixture/API data map (the `data` field from
  /// card_detail_response.json). Uses the same defensive helpers as
  /// the card detail screen.
  factory CardImagePanel.fromData(Map<String, dynamic> data) {
    final card = asMap(data['card']);
    final set = asMap(data['set']);
    final images = asMap(data['images']);
    return CardImagePanel(
      cardName: textAt(card, 'name', 'Unknown card'),
      setText: joinPresent([
        textAt(set, 'name'),
        textAt(set, 'set_code'),
        textAt(card, 'collector_number'),
      ]),
      languageCode: _nullableText(card, 'language_code'),
      rarity: _nullableText(card, 'rarity'),
      imageUrl: _nullableText(images, 'display_image_url'),
      hasLocalImage: images['has_local_image'] == true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final imagePlaceholder = Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_outlined,
              size: 52,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'Image pending',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );

    return SectionCard(
      title: cardName,
      icon: Icons.auto_awesome_outlined,
      children: [
        imagePlaceholder,
        const SizedBox(height: 12),
        if (setText != null && setText!.isNotEmpty && setText != '—')
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(
                  Icons.style_outlined,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(setText!, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        if (languageCode != null && languageCode != '—')
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(
                  Icons.language_outlined,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(languageCode!, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        if (rarity != null && rarity != '—')
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(
                  Icons.star_outline,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(rarity!, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
      ],
    );
  }
}

/// Returns the map value as a trimmed nullable string, or null if empty/missing.
String? _nullableText(Map<String, dynamic> map, String key) {
  final value = map[key]?.toString().trim();
  return (value != null && value.isNotEmpty) ? value : null;
}
