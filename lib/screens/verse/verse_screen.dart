import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/verse_provider.dart';
import '../../utils/app_colors.dart';

class VerseScreen extends StatelessWidget {
  const VerseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VerseProvider>();
    final daily = provider.dailyVerse;
    final favorites = provider.favorites;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Versículo do Dia')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Daily verse card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.3),
                  AppColors.card,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome,
                        color: AppColors.accent, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Versículo de hoje',
                      style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    if (!provider.isFavorite(daily))
                      TextButton.icon(
                        onPressed: () => provider.addFavorite(daily),
                        icon: const Icon(Icons.bookmark_border,
                            size: 18, color: AppColors.accent),
                        label: const Text('Salvar',
                            style: TextStyle(
                                color: AppColors.accent, fontSize: 13)),
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                      )
                    else
                      const Row(
                        children: [
                          Icon(Icons.bookmark,
                              size: 18, color: AppColors.accent),
                          SizedBox(width: 4),
                          Text('Salvo',
                              style: TextStyle(
                                  color: AppColors.accent, fontSize: 13)),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '"${daily.versiculo}"',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '— ${daily.referencia}',
                  style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          if (favorites.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Favoritos',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ...favorites.map((v) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '"${v.versiculo}"',
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            height: 1.5),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '— ${v.referencia}',
                        style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}
