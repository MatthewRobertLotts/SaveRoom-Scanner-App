import 'package:flutter/material.dart';

class CardThumbnail extends StatelessWidget {
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

  String? get _firstValidUrl {
    for (final url in imageUrls) {
      final String trimmed = url.trim();
      if (trimmed.isNotEmpty && trimmed != '—') return url;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final url = _firstValidUrl;
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: url != null ? _imageContent(context) : _placeholder(context),
      ),
    );
  }

  Widget _imageContent(BuildContext context) {
    return Image.network(
      _firstValidUrl!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(context),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _placeholder(context);
      },
    );
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
          Icons.style_outlined,
          size: 22,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}