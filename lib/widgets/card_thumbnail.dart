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

  @override
  Widget build(BuildContext context) {
    final validUrls = imageUrls
        .where((url) => url.trim().isNotEmpty && url != '—')
        .toSet()
        .toList();

    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: validUrls.isEmpty
            ? _placeholder(context)
            : Image.network(
                validUrls.first,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _placeholder(context),
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : _placeholder(context, loading: true),
              ),
      ),
    );
  }

  Widget _placeholder(BuildContext context, {bool loading = false}) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Center(
        child: loading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              )
            : Icon(
                Icons.style_outlined,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.5,
                ),
              ),
      ),
    );
  }
}
