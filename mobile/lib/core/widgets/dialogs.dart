import 'package:flutter/material.dart';
import 'package:real_estate_crm/core/theme/app_theme.dart';

Future<bool> showConfirmDialog(BuildContext context,
    {required String title,
    required String content,
    String confirmLabel = 'Delete',
    Color confirmColor = AppColors.error}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title,
          style:
              const TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w600)),
      content: Text(content),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel')),
        TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: confirmColor),
            child: Text(confirmLabel)),
      ],
    ),
  );
  return result ?? false;
}
