import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
  int _currentIndex = 0;
  bool _failed = false;

  @override
  void didUpdateWidget(covariant CardThumbnail old) {
    super.didUpdateWidget(old);
    if (old.imageUrls != widget.imageUrls) {
      setState(() {
        _currentIndex = 0;
        _failed = false;
      });
    }
  }

  List<String> get _validUrls => widget.imageUrls
      .where((url) => url.trim().isNotEmpty && url != '—')
      .toSet()
      .toList();

  void _tryNext() {
    if (_currentIndex + 1 < _validUrls.length) {
      setState(() => _currentIndex++);
    } else {
      setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final validUrls = _validUrls;
    if (validUrls.isEmpty || _failed) {
      return _placeholder(context);
    }

    final currentUrl = validUrls[_currentIndex];
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          currentUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) { _tryNext(); return _placeholder(context); },
        ),
      ),
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