import 'package:flutter/material.dart';
import '../../avatar/widgets/avatar_painter.dart';

class ZamuAvatarWidget extends StatelessWidget {
  final double size;
  final int zamuLevel;

  const ZamuAvatarWidget({
    super.key,
    this.size = 80,
    required this.zamuLevel,
  });

  @override
  Widget build(BuildContext context) {
    final aura = zamuLevel >= 5 ? 2 : zamuLevel >= 3 ? 1 : 0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AvatarWidget(
          avatarId: 'innovator',
          size: size,
          auraLevel: aura,
        ),
        const SizedBox(height: 4),
        const Text(
          'Zamu',
          style: TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}
