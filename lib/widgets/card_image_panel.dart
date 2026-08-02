import 'dart:async';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
    this.showMetadata = true,
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
  final bool showMetadata;
  final double imageHeight;

  /// Construct from a raw fixture/API data map (the `data` field from
  /// card_detail_response.json).
  factory CardImagePanel.fromData(
    Map<String, dynamic> data, {
    double imageHeight = 200,
    bool showTitle = true,
    bool showMetadata = true,
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
      showMetadata: showMetadata,
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
                      : ExtendedImage.network(
                          candidates[_imageIndex],
                          key: ValueKey(candidates[_imageIndex]),
                          semanticLabel: '${widget.cardName} card image',
                          fit: BoxFit.contain,
                          cache: true,
                          retries: 1,
                          timeLimit: const Duration(seconds: 4),
                          loadStateChanged: (state) {
                            switch (state.extendedImageLoadState) {
                              case LoadState.completed:
                                _candidateTimer?.cancel();
                                return Semantics(
                                  button: true,
                                  label: 'Open ${widget.cardName} image viewer',
                                  child: GestureDetector(
                                    onTap: () => _openImageViewer(
                                      candidates[_imageIndex],
                                    ),
                                    child: state.completedWidget,
                                  ),
                                );
                              case LoadState.failed:
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  _advanceCandidate();
                                });
                                return _placeholderContent(
                                  theme,
                                  colorScheme,
                                  'Loading image',
                                  loading: true,
                                );
                              case LoadState.loading:
                                return _placeholderContent(
                                  theme,
                                  colorScheme,
                                  'Loading image',
                                  loading: true,
                                );
                            }
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
      if (widget.showMetadata) const SizedBox(height: 12),
      if (widget.showMetadata &&
          widget.setText != null &&
          widget.setText!.isNotEmpty &&
          widget.setText != '—')
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Icon(
                LucideIcons.layers,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(widget.setText!, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      if (widget.showMetadata &&
          widget.languageCode != null &&
          widget.languageCode != '—')
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Icon(
                LucideIcons.globe,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(widget.languageCode!, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      if (widget.showMetadata && widget.rarity != null && widget.rarity != '—')
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Icon(
                LucideIcons.star,
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
      icon: LucideIcons.sparkles,
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
              LucideIcons.image,
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

  Future<void> _openImageViewer(String url) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (dialogContext) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Positioned.fill(
              child: Semantics(
                image: true,
                label: '${widget.cardName} card image, zoomable',
                child: ExtendedImage.network(
                  url,
                  fit: BoxFit.contain,
                  cache: true,
                  mode: ExtendedImageMode.gesture,
                  initGestureConfigHandler: (_) => GestureConfig(
                    inPageView: false,
                    initialScale: 1,
                    maxScale: 4,
                    animationMaxScale: 4.5,
                    initialAlignment: InitialAlignment.center,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: SafeArea(
                child: IconButton.filledTonal(
                  tooltip: 'Close image viewer',
                  onPressed: () => Navigator.pop(dialogContext),
                  icon: const Icon(Icons.close),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Returns the map value as a trimmed nullable string, or null if empty/missing.
String? _nullableText(Map<String, dynamic> map, String key) {
  final value = map[key]?.toString().trim();
  return (value != null && value.isNotEmpty) ? value : null;
}
