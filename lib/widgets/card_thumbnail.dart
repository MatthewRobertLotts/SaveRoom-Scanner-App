import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CardThumbnail extends StatefulWidget {
  const CardThumbnail({
    super.key,
    required this.imageUrls,
    this.cardName,
    this.width = 58,
    this.height = 82,
  });

  final List<String> imageUrls;
  final String? cardName;
  final double width;
  final double height;

  @override
  State<CardThumbnail> createState() => _CardThumbnailState();
}

class _CardThumbnailState extends State<CardThumbnail> {
  int _index = 0;
  String? _pendingFailedUrl;

  List<String> get _candidates => widget.imageUrls
      .map((url) => url.trim())
      .where((url) => url.isNotEmpty && url != '—')
      .toSet()
      .toList();

  @override
  void didUpdateWidget(covariant CardThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrls.join('|') != widget.imageUrls.join('|')) {
      _index = 0;
      _pendingFailedUrl = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final candidates = _candidates;
    final url = _index < candidates.length ? candidates[_index] : null;
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: url != null
            ? _imageContent(context, url)
            : _placeholder(context),
      ),
    );
  }

  Widget _imageContent(BuildContext context, String url) {
    return ExtendedImage.network(
      url,
      key: ValueKey(url),
      semanticLabel: widget.cardName == null
          ? 'Trading card thumbnail'
          : '${widget.cardName} card thumbnail',
      fit: BoxFit.contain,
      cache: true,
      retries: 1,
      timeLimit: const Duration(seconds: 4),
      loadStateChanged: (state) {
        if (state.extendedImageLoadState == LoadState.completed) return null;
        if (state.extendedImageLoadState == LoadState.failed) {
          _scheduleAdvance(url);
        }
        return _placeholder(context);
      },
    );
  }

  void _scheduleAdvance(String failedUrl) {
    if (_pendingFailedUrl == failedUrl) return;
    _pendingFailedUrl = failedUrl;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final candidates = _candidates;
      if (_index < candidates.length && candidates[_index] == failedUrl) {
        setState(() {
          _index += 1;
          _pendingFailedUrl = null;
        });
      } else {
        _pendingFailedUrl = null;
      }
    });
  }

  Widget _placeholder(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Icon(
          LucideIcons.image,
          size: 22,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
