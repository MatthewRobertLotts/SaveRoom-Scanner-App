import 'package:flutter/material.dart';

import 'status_pill.dart';

class FixtureBadge extends StatelessWidget {
  const FixtureBadge({super.key});

  @override
  Widget build(BuildContext context) =>
      const StatusPill('Fixture result', icon: Icons.science_outlined);
}
