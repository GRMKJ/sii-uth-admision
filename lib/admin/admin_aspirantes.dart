import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:siiadmision/admin/admin_aspirantes_detalles.dart';
import 'package:siiadmision/config/api_client.dart';
import 'package:siiadmision/layout/header.dart';
import 'package:siiadmision/widgets/sidebar.dart';

class AspirantesAdminScreen extends StatefulWidget {
  const AspirantesAdminScreen({super.key});

  @override
  State<AspirantesAdminScreen> createState() => _AspirantesAdminScreenState();
}

class _AspirantesAdminScreenState extends State<AspirantesAdminScreen> {
  static const List<String> _tabs = [
    'Todos',
    'Con Pago',
    'Con Documentos',
    'Listos para Inscripcion',
  ];

  final storage = const FlutterSecureStorage();
  Map<String, dynamic>? data;

  final TextEditingController _searchController = TextEditingController();
  String _stepFilter = 'todos';
  bool _soloConFolio = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchChanged);
    _fetchData();
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchChanged() => setState(() {});

  Future<void> _fetchData() async {
    final token = await storage.read(key: 'auth_token');
    final response = await ApiClient.getJson('/admin/aspirantes', token: token);
    setState(() => data = response['data']);
  }

  List<dynamic> _listForTab(int index) {
    if (data == null) return const [];
    switch (index) {
      case 1:
        return data!['con_pago'] as List<dynamic>? ?? const [];
      case 2:
        return data!['con_documentos'] as List<dynamic>? ?? const [];
      case 3:
        return data!['listos_inscripcion'] as List<dynamic>? ?? const [];
      default:
        return data!['todos'] as List<dynamic>? ?? const [];
    }
  }

  List<dynamic> _filteredAspirantes(int tabIndex) {
    final query = _searchController.text.trim().toLowerCase();
    final base = List<dynamic>.from(_listForTab(tabIndex));

    return base.where((raw) {
      final aspirante = raw as Map<String, dynamic>;
      final folio = (aspirante['folio_examen'] ?? '').toString().trim();
      final nombre =
          '${aspirante['nombre']} ${aspirante['ap_paterno']} ${aspirante['ap_materno']}'.toLowerCase();
      final matchesQuery = query.isEmpty ||
          folio.toLowerCase().contains(query) ||
          nombre.contains(query);

      final tieneFolio = folio.isNotEmpty && folio != 'SIN FOLIO';
      final folioOk = !_soloConFolio || tieneFolio;

      final step = (aspirante['progress_step'] ?? '').toString();
      final stepOk = _stepFilter == 'todos' || step == _stepFilter;

      return matchesQuery && folioOk && stepOk;
    }).toList();
  }

  String? _buttonLabelForTab(int index) {
    switch (index) {
      case 1:
        return 'Validar Pago';
      case 2:
        return 'Ver Documentos';
      case 3:
        return 'Autorizar e Inscribir';
      default:
        return null;
    }
  }

  void Function(BuildContext, Map<String, dynamic>)? _actionForTab(int index) {
    switch (index) {
      case 1:
        return (context, aspirante) {
          final pagos = aspirante['pagos'] as List<dynamic>? ?? [];
          final ref =
              pagos.isNotEmpty ? pagos.first['referencia']?.toString() : null;
          if (ref == null || ref.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Este aspirante no tiene pago registrado.')),
            );
            return;
          }
          context.push('/admin/$ref/pago/');
        };
      case 2:
        return (context, aspirante) {
          final folio = (aspirante['folio_examen'] ?? '').toString();
          if (folio.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('El aspirante no cuenta con folio.')),
            );
            return;
          }
          context.push('/admin/aspirante/$folio/documentos');
        };
      case 3:
        return (context, aspirante) {
          final folio = (aspirante['folio_examen'] ?? '').toString();
          if (folio.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('El aspirante no cuenta con folio.')),
            );
            return;
          }
          context.push('/admin/aspirante/$folio/inscripcion');
        };
      default:
        return null;
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
          context.go('/admin/ajustes');
          break;
      }
    }

    final content = SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final contentWidth = screenWidth.clamp(320.0, 1280.0);

          return Column(
            children: [
              UthHeader(maxWidth: contentWidth),
              const SizedBox(height: 16),
              TabBar(
                isScrollable: true,
                indicatorColor: colors.primary,
                labelColor: colors.primary,
                unselectedLabelColor: colors.onSurfaceVariant,
                tabs: _tabs.map((t) => Tab(text: t)).toList(),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _FiltersBar(
                  searchController: _searchController,
                  stepFilter: _stepFilter,
                  soloConFolio: _soloConFolio,
                  onStepChanged: (value) =>
                      setState(() => _stepFilter = value ?? 'todos'),
                  onToggleFolio: (value) =>
                      setState(() => _soloConFolio = value),
                ),
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
                        color: colors.shadow.withAlpha((0.05 * 255).round()),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: data == null
                      ? const Center(child: CircularProgressIndicator())
                      : TabBarView(
                          children: List.generate(_tabs.length, (index) {
                            final filtered = _filteredAspirantes(index);
                            return _buildList(
                              filtered,
                              buttonLabel: _buttonLabelForTab(index),
                              onPressed: _actionForTab(index),
                            );
                          }),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        backgroundColor: colors.surfaceContainerLowest,
        bottomNavigationBar: useRail
            ? null
            : NavigationBar(
                selectedIndex: 1,
                destinations: adminNavigationDestinations,
                onDestinationSelected: handleNavigation,
              ),
        body: useRail
            ? Row(
                children: [
                  SizedBox(
                    width: 96,
                    child: SideNavigationAdmin(
                      selectedIndex: 1,
                      onDestinationSelected: handleNavigation,
                    ),
                  ),
                  Expanded(child: content),
                ],
              )
            : content,
      ),
    );
  }
}

Widget _buildList(
  List<dynamic> aspirantes, {
  String? buttonLabel,
  void Function(BuildContext, Map<String, dynamic>)? onPressed,
}) {
  return ListView.separated(
    itemCount: aspirantes.length,
    separatorBuilder: (_, __) => const Divider(),
    itemBuilder: (context, index) {
      final asp = Map<String, dynamic>.from(aspirantes[index] as Map);
      final folio = (asp['folio_examen'] ?? 'SIN FOLIO').toString();
      final aspiranteId = (asp['id_aspirantes'] ?? '').toString();
      final hasId = aspiranteId.isNotEmpty;
      final nombre =
          '${asp['nombre']} ${asp['ap_paterno']} ${asp['ap_materno']}'.trim();

      final pagos = asp['pagos'] as List<dynamic>? ?? [];
      final pago = pagos.isNotEmpty ? pagos.first : null;
      final pagoInfo = pago != null
          ? 'Ref: ${pago['referencia']} - ${pago['estado_validacion']}'
          : 'Sin pago';

      return ListTile(
        leading: const Icon(Icons.person_outline),
        title: Text(nombre.isEmpty ? 'Sin nombre' : nombre),
        subtitle: Text('Folio: $folio\n$pagoInfo'),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (buttonLabel != null)
              ElevatedButton(
                onPressed:
                    onPressed != null ? () => onPressed(context, asp) : null,
                child: Text(buttonLabel),
              ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: hasId
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AspiranteDetalleScreen(
                            aspiranteId: aspiranteId,
                          ),
                        ),
                      );
                    }
                  : null,
              child: const Text('Ver Detalles'),
            ),
          ],
        ),
      );
    },
  );
}

class _FiltersBar extends StatelessWidget {
  final TextEditingController searchController;
  final String stepFilter;
  final bool soloConFolio;
  final ValueChanged<String?> onStepChanged;
  final ValueChanged<bool> onToggleFolio;

  const _FiltersBar({
    required this.searchController,
    required this.stepFilter,
    required this.soloConFolio,
    required this.onStepChanged,
    required this.onToggleFolio,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  labelText: 'Buscar por nombre o folio',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 220,
              child: DropdownMenu<String>(
                label: const Text('Paso'),
                initialSelection: stepFilter,
                dropdownMenuEntries: const [
                  DropdownMenuEntry(value: 'todos', label: 'Todos'),
                  DropdownMenuEntry(value: '1', label: 'Paso 1'),
                  DropdownMenuEntry(value: '2', label: 'Paso 2'),
                  DropdownMenuEntry(value: '3', label: 'Paso 3'),
                  DropdownMenuEntry(value: '4', label: 'Paso 4'),
                  DropdownMenuEntry(value: '5', label: 'Paso 5'),
                  DropdownMenuEntry(value: '6', label: 'Paso 6'),
                ],
                onSelected: onStepChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            FilterChip(
              label: const Text('Solo con folio asignado'),
              selected: soloConFolio,
              onSelected: onToggleFolio,
            ),
          ],
        ),
      ],
    );
  }
}
