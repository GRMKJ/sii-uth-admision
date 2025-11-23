import 'package:flutter/material.dart';
import 'package:siiadmision/config/theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final contentWidth = screenWidth.clamp(320.0, 900.0);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Container(
                width: contentWidth,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: colors.shadow.withAlpha((0.08 * 255).round()),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ajustes',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Configura la apariencia de la aplicación según tus preferencias.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    Card(
                      elevation: 0,
                      color: colors.surfaceContainerHighest,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: AnimatedBuilder(
                          animation: themeController,
                          builder: (context, _) {
                            final dropdown = ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 260),
                              child: DropdownMenu<ThemeMode>(
                                initialSelection: themeController.mode,
                                dropdownMenuEntries: const [
                                  DropdownMenuEntry(
                                    value: ThemeMode.system,
                                    label: 'Sistema (predeterminado)',
                                  ),
                                  DropdownMenuEntry(
                                    value: ThemeMode.light,
                                    label: 'Claro',
                                  ),
                                  DropdownMenuEntry(
                                    value: ThemeMode.dark,
                                    label: 'Oscuro',
                                  ),
                                ],
                                onSelected: (mode) {
                                  if (mode != null) {
                                    themeController.updateMode(mode);
                                  }
                                },
                              ),
                            );

                            final description = Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Tema de la Aplicación',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Elige entre tema claro, oscuro o sigue la configuración del sistema.',
                                ),
                              ],
                            );

                            return LayoutBuilder(
                              builder: (context, innerConstraints) {
                                final isNarrow = innerConstraints.maxWidth < 520;
                                if (isNarrow) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      description,
                                      const SizedBox(height: 16),
                                      dropdown,
                                    ],
                                  );
                                }
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: description),
                                    const SizedBox(width: 24),
                                    dropdown,
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
