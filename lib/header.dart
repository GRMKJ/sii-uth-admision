import 'package:flutter/material.dart';

class UthHeader extends StatelessWidget {
  final double maxWidth;

  const UthHeader({super.key, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Container(
        width: maxWidth,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 16),
            Image.asset(
              'assets/logo_uth.png',
              height: 50,
            ),
            const SizedBox(width: 12),
            // 📌 Este Flexible permite al texto usar el espacio restante
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Universidad Tecnológica de Huejotzingo',
                    style: textTheme.labelLarge?.copyWith(
                      color: colors.onPrimary,
                    ),
                    overflow: TextOverflow.visible,
                    softWrap: true,
                  ),
                  Text(
                    'Sistema Integral de Información',
                    style: textTheme.titleMedium?.copyWith(
                      color: colors.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.visible,
                    softWrap: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
