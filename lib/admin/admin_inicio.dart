import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:siiadmision/layout/header.dart';
import 'package:siiadmision/layout/side_navigation.dart';
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
    "aspirantes_registrados": 0,
    "pendientes_examen": 0,
    "pendientes_documentos": 0,
    "alumnos_inscritos": 0,
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
      if (token == null) throw Exception("Token no encontrado");
    debugPrint(token);
      final response = await ApiClient.getJson(
        "/admin/dashboard/stats",
        token: token,
      );

      
      if (response["success"] == true) {
        final data = response["data"] as Map<String, dynamic>;
        setState(() {
          stats = {
            "aspirantes_registrados": data["aspirantes_registrados"] ?? 0,
            "pendientes_examen": data["pendientes_examen"] ?? 0,
            "pendientes_documentos": data["pendientes_documentos"] ?? 0,
            "alumnos_inscritos": data["alumnos_inscritos"] ?? 0,
          };
          _loading = false;
        });
      } else {
        throw Exception(response["message"] ?? "Error en respuesta");
      }
    } catch (e) {
      setState(() => _loading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error cargando estadísticas: $e")),
        );
      }
    }
  }

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
                          child: _loading
                              ? const CircularProgressIndicator()
                              : Container(
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
                                            count: stats["aspirantes_registrados"]!,
                                            icon: Icons.person_outline,
                                          ),
                                          _DashboardCard(
                                            title: 'Por presentar examen diagnóstico',
                                            count: stats["pendientes_examen"]!,
                                            icon: Icons.assignment,
                                          ),
                                          _DashboardCard(
                                            title: 'Pendientes de validar documentos',
                                            count: stats["pendientes_documentos"]!,
                                            icon: Icons.upload_file,
                                          ),
                                          _DashboardCard(
                                            title: 'Alumnos Inscritos',
                                            count: stats["alumnos_inscritos"]!,
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
