import 'dart:async';

import 'package:flutter/material.dart';

import '../services/fixture_loader.dart';
import '../services/saveroom_api_client.dart';
import 'section_card.dart';

/// A polished card-image panel that shows either a real image (when image URLs
/// are available) or a placeholder with card metadata.
class CardImagePanel extends StatefulWidget {
  const CardImagePanel({
    super.key,
    required this.cardName,
    this.setText,
    this.languageCode,
    this.rarity,
    this.imageUrl,
    this.imageUrls = const [],
    this.hasLocalImage = false,
    this.showTitle = true,
    this.imageHeight = 200,
  });

  final String cardName;
  final String? setText;
  final String? languageCode;
  final String? rarity;
  final String? imageUrl;
  final List<String> imageUrls;
  final bool hasLocalImage;
  final bool showTitle;
  final double imageHeight;

  /// Construct from a raw fixture/API data map (the `data` field from
  /// card_detail_response.json).
  factory CardImagePanel.fromData(
    Map<String, dynamic> data, {
    double imageHeight = 200,
    bool showTitle = true,
  }) {
    final card = asMap(data['card']);
    final set = asMap(data['set']);
    final images = asMap(data['images']);
    final rawCandidates = images['image_url_candidates'];
    final candidates = rawCandidates is List
        ? rawCandidates
              .map((v) => v.toString())
              .where((v) => v.isNotEmpty)
              .toList()
        : CardImageResolver.candidatesFromDetailData(data);
    final legacyUrl =
        _nullableText(images, 'resolved_image_url') ??
        _nullableText(images, 'primary_image_url') ??
        _nullableText(images, 'display_image_url');
    final urls = <String>[...candidates, ?legacyUrl];
    return CardImagePanel(
      cardName: textAt(card, 'name', 'Unknown card'),
      setText: joinPresent([
        textAt(set, 'name'),
        textAt(set, 'set_code'),
        textAt(card, 'collector_number', textAt(card, 'number')),
      ]),
      languageCode: _nullableText(card, 'language_code'),
      rarity: _nullableText(card, 'rarity'),
      imageUrl: urls.isNotEmpty ? urls.first : null,
      imageUrls: urls.toSet().toList(),
      hasLocalImage: images['has_local_image'] == true,
      imageHeight: imageHeight,
      showTitle: showTitle,
    );
  }

  @override
  State<CardImagePanel> createState() => _CardImagePanelState();
}

class _CardImagePanelState extends State<CardImagePanel> {
  late int _imageIndex;
  Timer? _candidateTimer;
  bool _attemptStarted = false;

  @override
  void initState() {
    super.initState();
    _imageIndex = 0;
    _startCandidateAfterFirstFrame();
  }

  @override
  void didUpdateWidget(covariant CardImagePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrls.join('|') != widget.imageUrls.join('|') ||
        oldWidget.imageUrl != widget.imageUrl) {
      _imageIndex = 0;
      _attemptStarted = false;
      _startCandidateAfterFirstFrame();
    }
  }

  @override
  void dispose() {
    _candidateTimer?.cancel();
    super.dispose();
  }

  void _advanceCandidate() {
    if (!mounted) return;
    final candidates = _candidates;
    if (_imageIndex < candidates.length) {
      setState(() {
        _imageIndex += 1;
        _attemptStarted = false;
      });
      _startCandidateAfterFirstFrame();
    }
  }

  void _startCandidateAfterFirstFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _imageIndex >= _candidates.length) return;
      setState(() => _attemptStarted = true);
      _scheduleCandidateTimeout();
    });
  }

  void _scheduleCandidateTimeout() {
    _candidateTimer?.cancel();
    final candidates = _candidates;
    if (_imageIndex >= candidates.length) return;
    final expected = candidates[_imageIndex];
    _candidateTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      final current = _candidates;
      if (_imageIndex < current.length && current[_imageIndex] == expected) {
        _advanceCandidate();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final candidates = _candidates;
    final hasImage = _imageIndex < candidates.length;
    final imagePlaceholder = Center(
      child: SizedBox(
        height: widget.imageHeight,
        child: AspectRatio(
          // ponytail: standard Pokémon cards are 2.5" x 3.5" (5:7); scale evenly.
          aspectRatio: 5 / 7,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: hasImage
                ? !_attemptStarted
                      ? _placeholderContent(
                          theme,
                          colorScheme,
                          'Loading image',
                          loading: true,
                        )
                      : Image.network(
                          candidates[_imageIndex],
                          key: ValueKey(candidates[_imageIndex]),
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _advanceCandidate();
                            });
                            return _placeholderContent(
                              theme,
                              colorScheme,
                              'Loading image',
                              loading: true,
                            );
                          },
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) {
                              _candidateTimer?.cancel();
                              return child;
                            }
                            return _placeholderContent(
                              theme,
                              colorScheme,
                              'Loading image',
                              loading: true,
                            );
                          },
                        )
                : DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.4,
                      ),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: _placeholderContent(
                      theme,
                      colorScheme,
                      'Image pending',
                    ),
                  ),
          ),
        ),
      ),
    );

    final children = [
      imagePlaceholder,
      const SizedBox(height: 12),
      if (widget.setText != null &&
          widget.setText!.isNotEmpty &&
          widget.setText != '—')
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
              Text(widget.setText!, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      if (widget.languageCode != null && widget.languageCode != '—')
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
              Text(widget.languageCode!, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      if (widget.rarity != null && widget.rarity != '—')
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
              Text(widget.rarity!, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
    ];

    if (!widget.showTitle) return Column(children: children);
    return SectionCard(
      title: widget.cardName,
      icon: Icons.auto_awesome_outlined,
      children: children,
    );
  }

  List<String> get _candidates {
    final urls = <String>[
      ...widget.imageUrls,
      if (widget.imageUrl != null) widget.imageUrl!,
    ];
    return urls
        .where((url) => url.trim().isNotEmpty && url != '—')
        .toSet()
        .toList();
  }

  Widget _placeholderContent(
    ThemeData theme,
    ColorScheme colorScheme,
    String label, {
    bool loading = false,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (loading)
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Icon(
              Icons.image_outlined,
              size: 52,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

/// Returns the map value as a trimmed nullable string, or null if empty/missing.
String? _nullableText(Map<String, dynamic> map, String key) {
  final value = map[key]?.toString().trim();
  return (value != null && value.isNotEmpty) ? value : null;
}
