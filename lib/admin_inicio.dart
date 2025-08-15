import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:siiadmision/header.dart';
import 'package:siiadmision/side_navigation.dart';

class DashboardAdminScreen extends StatelessWidget {
  const DashboardAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      body: Row(
        children: [
          SideNavigationAdmin(
            selectedIndex: 0,
            onDestinationSelected: (index) {
              // Navegación simulada para ejemplo
              switch (index) {
                case 0:
                  context.go('/admin/inicio');
                  break;
                case 1:
                  context.go('/admin/aspirantes');
                  break;
                case 7:
                  context.go('/');
                  break;
              }
            },
          ),
          Expanded(
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = constraints.maxWidth;
                  final contentWidth = screenWidth.clamp(320.0, 1280.0);

                  return Column(
                    children: [
                      UthHeader(maxWidth: contentWidth),
                      const SizedBox(height: 24),
                      Expanded(
                        child: Center(
                          child: Container(
                            width: contentWidth,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.shadow.withOpacity(0.1),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Panel de Control Administrativo',
                                  style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 24),
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 16,
                                  children: const [
                                    _DashboardCard(
                                      title: 'Aspirantes registrados',
                                      count: 120,
                                      icon: Icons.person_outline,
                                    ),
                                    _DashboardCard(
                                      title: 'Por presentar examen diagnóstico',
                                      count: 80,
                                      icon: Icons.assignment,
                                    ),
                                    _DashboardCard(
                                      title: 'Pendientes de validar documentos',
                                      count: 35,
                                      icon: Icons.upload_file,
                                    ),
                                    _DashboardCard(
                                      title: 'Alumnos Insctritos',
                                      count: 50,
                                      icon: Icons.verified_user,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;

  const _DashboardCard({
    required this.title,
    required this.count,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 36, color: colors.onPrimaryContainer),
          const SizedBox(height: 12),
          Text(
            '$count',
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: textTheme.labelLarge?.copyWith(color: colors.onPrimaryContainer),
          ),
        ],
      ),
    );
  }
}
