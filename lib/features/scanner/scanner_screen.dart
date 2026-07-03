import 'package:flutter/material.dart';

import '../../app/app_routes.dart';
import '../../widgets/saveroom_shell.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SaveRoomShell(
      title: 'Scanner',
      children: [
        const Icon(Icons.document_scanner_outlined, size: 72),
        const SizedBox(height: 16),
        Text(
          'Scanner coming next',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text('Camera/OCR packages are deliberately not installed yet.'),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.mockScanResult),
          child: const Text('Use mock scan result'),
        ),
      ],
    );
  }
}
