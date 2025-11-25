import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:siiadmision/layout/header.dart';
import 'package:siiadmision/widgets/sidebar.dart';
import 'package:siiadmision/config/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DashboardAdminScreen extends StatefulWidget {
  const DashboardAdminScreen({super.key});

  @override
  State<DashboardAdminScreen> createState() => _DashboardAdminScreenState();
}

class _DashboardAdminScreenState extends State<DashboardAdminScreen> {
  bool _loading = true;
  Map<String, int> stats = {
    'aspirantes_registrados': 0,
    'pendientes_examen': 0,
    'pendientes_documentos': 0,
    'alumnos_inscritos': 0,
  };

  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final token = await storage.read(key: 'auth_token');
      if (token == null) throw Exception('Token no encontrado');
      final response = await ApiClient.getJson(
        '/admin/dashboard/stats',
        token: token,
      );

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        setState(() {
          stats = {
            'aspirantes_registrados': data['aspirantes_registrados'] ?? 0,
            'pendientes_examen': data['pendientes_examen'] ?? 0,
            'pendientes_documentos': data['pendientes_documentos'] ?? 0,
            'alumnos_inscritos': data['alumnos_inscritos'] ?? 0,
          };
          _loading = false;
        });
      } else {
        throw Exception(response['message'] ?? 'Error en respuesta');
      }
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cargando estad�sticas: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final useRail = useNavigationRailLayout(context);

    void handleNavigation(int index) {
      switch (index) {
        case 0:
          context.go('/admin/inicio');
          break;
        case 1:
          context.go('/admin/aspirantes');
          break;
        case 2:
          context.go('/admin/finanzas');
          break;
        case 3:
          context.go('/ajustes');
          break;
      }
    }

    final content = _DashboardBody(
      loading: _loading,
      stats: stats,
      onRefresh: _fetchStats,
    );

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      bottomNavigationBar: useRail
          ? null
          : NavigationBar(
              selectedIndex: 0,
              destinations: adminNavigationDestinations,
              onDestinationSelected: handleNavigation,
            ),
      body: useRail
          ? Row(
              children: [
                SizedBox(
                  width: 96,
                  child: SideNavigationAdmin(
                    selectedIndex: 0,
                    onDestinationSelected: handleNavigation,
                  ),
                ),
                Expanded(child: content),
              ],
            )
          : content,
    );
  }
}

class _DashboardBody extends StatelessWidget {
  final bool loading;
  final Map<String, int> stats;
  final Future<void> Function() onRefresh;

  const _DashboardBody({
    required this.loading,
    required this.stats,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
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
                  child: loading
                      ? const CircularProgressIndicator()
                      : RefreshIndicator(
                          onRefresh: onRefresh,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Container(
                              width: contentWidth,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: colors.shadow
                                        .withAlpha((0.1 * 255).round()),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Panel de Control Administrativo',
                                    style: textTheme.headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 24),
                                  Wrap(
                                    spacing: 16,
                                    runSpacing: 16,
                                    children: [
                                      _DashboardCard(
                                        title: 'Aspirantes registrados',
                                        count: stats['aspirantes_registrados']!,
                                        icon: Icons.person_outline,
                                      ),
                                      _DashboardCard(
                                        title: 'Por presentar examen diagn�stico',
                                        count: stats['pendientes_examen']!,
                                        icon: Icons.assignment,
                                      ),
                                      _DashboardCard(
                                        title: 'Pendientes de validar documentos',
                                        count: stats['pendientes_documentos']!,
                                        icon: Icons.upload_file,
                                      ),
                                      _DashboardCard(
                                        title: 'Alumnos Inscritos',
                                        count: stats['alumnos_inscritos']!,
                                        icon: Icons.verified_user,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ],
          );
        },
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
            color: colors.shadow.withAlpha((0.05 * 255).round()),
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
            style: textTheme.labelLarge?.copyWith(
              color: colors.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
