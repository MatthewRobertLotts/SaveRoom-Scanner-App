import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../widgets/section_card.dart';
import '../../widgets/saveroom_shell.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SaveRoomShell(
      title: 'Scanner',
      children: [
        const _ScanFrame(),
        const SizedBox(height: 18),
        Text(
          'Camera scanner coming later',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 6),
        const Text(
          'No camera/OCR package, permissions, or native scanner config has been added yet.',
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.mockScanResult),
          icon: const Icon(Icons.science_outlined),
          label: const Text('Use mock scan result'),
        ),
        const SectionCard(
          title: 'Planned scanner backend',
          icon: Icons.pending_actions_outlined,
          children: [
            Text(
              'Scan candidate response shape and collection-safe endpoints are planned for v12.4.',
            ),
          ],
        ),
      ],
    );
  }
}

class _ScanFrame extends StatelessWidget {
  const _ScanFrame();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return AspectRatio(
      aspectRatio: 1.45,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: color, width: 2),
          gradient: LinearGradient(
            colors: [color.withValues(alpha: .20), Colors.transparent],
          ),
        ),
        child: const Center(
          child: Icon(Icons.document_scanner_outlined, size: 70),
        ),
      ),
    );
  }
}
