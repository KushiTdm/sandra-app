import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Pastille de matière : le picto dédié de `SubjectColor.iconAsset` sur fond
/// teinté, ou un repli Material discret pour `specialiste` (pas de picto —
/// créneau non modifiable, docs/prompts/claude_design_prompt.md).
class SubjectBadge extends StatelessWidget {
  const SubjectBadge({super.key, required this.subject, this.size = 40});

  final SubjectColor subject;
  final double size;

  @override
  Widget build(BuildContext context) {
    final asset = subject.iconAsset;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: subject.color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      alignment: Alignment.center,
      child: asset == null
          ? Icon(Icons.school_outlined, size: size * 0.5, color: subject.color)
          : ColorFiltered(
              colorFilter: ColorFilter.mode(subject.color, BlendMode.srcIn),
              child: Image.asset(asset, width: size * 0.56),
            ),
    );
  }
}
