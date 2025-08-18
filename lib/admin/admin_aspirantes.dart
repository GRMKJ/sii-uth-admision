import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:siiadmision/config/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:siiadmision/layout/header.dart';
import 'package:siiadmision/layout/side_navigation.dart';

class AspirantesAdminScreen extends StatefulWidget {
  const AspirantesAdminScreen({super.key});

  @override
  State<AspirantesAdminScreen> createState() => _AspirantesAdminScreenState();
}

class _AspirantesAdminScreenState extends State<AspirantesAdminScreen> {
  final storage = const FlutterSecureStorage();
  Map<String, dynamic>? data;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final token = await storage.read(key: 'auth_token');

    final response = await ApiClient.getJson("/admin/aspirantes", token: token);
    setState(() {
      data = response['data'];
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final tabs = [
      'Todos',
      'Con Pago',
      'Con Documentos',
      'Listos para Inscripción',
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: colors.surfaceContainerLowest,
        body: Row(
          children: [
            // 🔹 Menú lateral
            SideNavigationAdmin(
              selectedIndex: 1,
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
                  default:
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Modulo No Implementado')),
                    );
                }
              },
            ),

            // 🔹 Contenido principal
            Expanded(
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = constraints.maxWidth;
                    final contentWidth = screenWidth.clamp(320.0, 1280.0);

                    return Column(
                      children: [
                        UthHeader(maxWidth: contentWidth), // ✅ Header
                        const SizedBox(height: 16),
                        TabBar(
                          isScrollable: true,
                          indicatorColor: colors.primary,
                          labelColor: colors.primary,
                          unselectedLabelColor: colors.onSurfaceVariant,
                          tabs: tabs.map((t) => Tab(text: t)).toList(),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Container(
                            width: contentWidth,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.shadow.withOpacity(0.05),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: data == null
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : TabBarView(
                                    children: [
                                      _buildList(data!['todos']),
                                      _buildList(
                                        data!['con_pago'],
                                        buttonLabel: "Validar Pago",
                                        onPressed: (context, folio) {
                                          final pagos = data!['con_pago']
                                              .firstWhere(
                                                (a) =>
                                                    a['folio_examen'] == folio,
                                              )['pagos'];
                                          final ref = pagos.isNotEmpty
                                              ? pagos.first['referencia']
                                              : null;
                                          if (ref != null) {
                                            context.push("/admin/$ref/pago/");
                                          }
                                        },
                                      ),

                                      _buildList(
                                        data!['con_documentos'],
                                        buttonLabel: "Ver Documentos",
                                        onPressed: (context, folio) =>
                                            context.push(
                                              "/admin/aspirante/$folio/documentos",
                                            ),
                                      ),
                                      _buildList(
                                        data!['listos_inscripcion'],
                                        buttonLabel: "Autorizar e Inscribir",
                                        onPressed: (context, folio) => context.push(
                                          "/admin/aspirante/$folio/inscripcion",
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildList(
  List<dynamic> aspirantes, {
  String? buttonLabel,
  void Function(BuildContext, String)? onPressed,
}) {
  return ListView.separated(
    itemCount: aspirantes.length,
    separatorBuilder: (_, __) => const Divider(),
    itemBuilder: (context, index) {
      final asp = aspirantes[index];
      final folio = asp['folio_examen'] ?? 'SIN FOLIO';
      final nombre =
          "${asp['nombre']} ${asp['ap_paterno']} ${asp['ap_materno']}".trim();

      // 🔹 Manejo de pagos
      final pagos = asp['pagos'] as List<dynamic>? ?? [];
      final pago = pagos.isNotEmpty ? pagos.first : null;

      final pagoInfo = pago != null
          ? "Ref: ${pago['referencia']} - ${pago['estado_validacion']}"
          : "Sin pago";

      return ListTile(
        leading: const Icon(Icons.person_outline),
        title: Text(nombre),
        subtitle: Text("Folio: $folio\n$pagoInfo"),
        isThreeLine: true, // para que no se corte el texto
        trailing: buttonLabel != null
            ? ElevatedButton(
                onPressed: () => onPressed?.call(context, folio),
                child: Text(buttonLabel),
              )
            : null,
      );
    },
  );
}
