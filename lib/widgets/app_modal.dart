import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class AppModal extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final String confirmLabel;
  final VoidCallback onConfirm;

  const AppModal({
    super.key,
    required this.title,
    required this.children,
    this.confirmLabel = 'Salvar',
    required this.onConfirm,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required List<Widget> children,
    String confirmLabel = 'Salvar',
    required VoidCallback onConfirm,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AppModal(
        title: title,
        confirmLabel: confirmLabel,
        onConfirm: onConfirm,
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onConfirm,
              child: Text(confirmLabel),
            ),
          ],
        ),
      ),
    );
  }
}
