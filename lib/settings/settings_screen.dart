import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:siiadmision/config/session.dart';
import 'package:siiadmision/config/theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final session = Session();
    final identity = session.identity;
    final displayName = session.displayName ?? 'Usuario';
    final identifierLabel = session.identifierLabel ?? 'Identificador';
    final identifierValue = session.identifier ?? 'No disponible';
    final roleLabel = _roleLabel(session.role);

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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: colors.primaryContainer,
                                  child: Icon(
                                    identity == null ? Icons.person_outline : Icons.verified_user_outlined,
                                    color: colors.onPrimaryContainer,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        displayName,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(roleLabel, style: Theme.of(context).textTheme.bodyMedium),
                                      Text('$identifierLabel: $identifierValue',
                                          style: Theme.of(context).textTheme.bodySmall),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              icon: const Icon(Icons.logout),
                              onPressed: () => _handleLogout(context),
                              style: FilledButton.styleFrom(
                                backgroundColor: colors.errorContainer,
                                foregroundColor: colors.onErrorContainer,
                              ),
                              label: const Text('Cerrar sesión'),
                            ),
                          ],
                        ),
                      ),
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

  String _roleLabel(String? role) {
    switch (role) {
      case 'aspirante':
        return 'Aspirante';
      case 'alumno':
        return 'Alumno';
      case 'admin':
      case 'administrativo':
        return 'Administrativo';
      default:
        return 'Sesión sin identificar';
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final storage = const FlutterSecureStorage();
    final session = Session();

    await storage.delete(key: 'auth_token');
    await storage.delete(key: 'role');
    await session.clearPersistentIdentity();
    await session.clearPersistentRole();
    session.logout();

    if (!context.mounted) return;
    context.go('/');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sesión cerrada correctamente')),
    );
  }
}
