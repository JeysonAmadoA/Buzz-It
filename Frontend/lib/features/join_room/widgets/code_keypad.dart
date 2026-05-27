import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';

/// Numeric-style keypad for entering the room code.
/// Demo keys: K / 7 / M / 9 + backspace (matches prototype).
class CodeKeypad extends StatelessWidget {
  const CodeKeypad({
    super.key,
    required this.onKey,
    required this.onDelete,
  });

  final ValueChanged<String> onKey;
  final VoidCallback onDelete;

  static const _keys = ['K', '7', 'M', '9'];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        ..._keys.map((k) => _Key(label: k, onTap: () => onKey(k))),
        _Key(label: '⌫', onTap: onDelete, isDelete: true),
      ],
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({
    required this.label,
    required this.onTap,
    this.isDelete = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.codeBg,
          border: Border.all(color: AppColors.goldDeep, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: isDelete
              ? AppTextStyles.hand(size: 20)
              : AppTextStyles.theater(size: 22),
        ),
      ),
    );
  }
}
