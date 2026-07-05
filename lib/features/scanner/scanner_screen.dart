import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../services/fixtures.dart';
import '../../widgets/saveroom_shell.dart';

/// ponytail: fixture-mode card picker in place of real scanner UI.
/// Replace with camera/OCR when that milestone arrives.
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  String _query = '';

  List<String> get _filteredKeys {
    if (_query.isEmpty) return Fixtures.cardKeys;
    final q = _query.toLowerCase();
    return Fixtures.cardKeys.where((key) {
      final card = Fixtures.byKey(key)['data']?['card'];
      final name = (card?['name'] ?? '').toString().toLowerCase();
      final code = (card?['card_key'] ?? '').toString().toLowerCase();
      return name.contains(q) || code.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SaveRoomShell(
      title: 'Choose a fixture card',
      children: [
        Text(
          'Fixture mode — camera/OCR not enabled yet',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            hintText: 'Search cards\u2026',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.3,
            ),
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
        const SizedBox(height: 8),
        Text(
          '${_filteredKeys.length} of ${Fixtures.cardKeys.length} cards',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        if (_filteredKeys.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Column(
              children: [
                Icon(
                  Icons.search_off_outlined,
                  size: 48,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'No fixture cards found',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Try another name or card key',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          )
        else
          // ponytail: shrinkWrap + NeverScrollableScrollPhysics because
          // SaveRoomShell already wraps children in a scrollable ListView.
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _filteredKeys.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final key = _filteredKeys[i];
              final card = Fixtures.byKey(key)['data']?['card'];
              final set = Fixtures.byKey(key)['data']?['set'];
              final name = card?['name'] ?? key;
              final setText =
                  '${set?['name'] ?? ''} / ${card?['collector_number'] ?? ''}';
              final rarity = card?['rarity'];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.style,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                title: Text(
                  name.toString(),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(setText, style: theme.textTheme.bodySmall),
                trailing: rarity != null
                    ? Chip(
                        label: Text(
                          rarity.toString(),
                          style: const TextStyle(fontSize: 10),
                        ),
                        visualDensity: VisualDensity.compact,
                      )
                    : null,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.cardDetail,
                  arguments: key,
                ),
              );
            },
          ),
      ],
    );
  }
}
