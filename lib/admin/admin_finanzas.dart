import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:siiadmision/config/api_client.dart';
import 'package:siiadmision/layout/header.dart';
import 'package:siiadmision/widgets/sidebar.dart';

class AdminFinanzasScreen extends StatefulWidget {
  const AdminFinanzasScreen({super.key});

  @override
  State<AdminFinanzasScreen> createState() => _AdminFinanzasScreenState();
}

class _AdminFinanzasScreenState extends State<AdminFinanzasScreen> {
  final storage = const FlutterSecureStorage();
  final Random _random = Random.secure();

  bool _loadingConceptos = true;
  bool _loadingAspirantes = true;
  bool _submitting = false;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _referenciaController = TextEditingController();

  List<Map<String, dynamic>> _conceptos = [];
  Map<String, dynamic>? _selectedConcepto;

  List<Map<String, dynamic>> _aspirantes = [];
  List<Map<String, dynamic>> _filteredAspirantes = [];
  Map<String, dynamic>? _selectedAspirante;

  String _stepFilter = 'todos';
  bool _soloConFolio = false;
  String _metodoPago = 'Efectivo ventanilla';
  DateTime _fechaPago = DateTime.now();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilters);
    _referenciaController.text = _generateReferencia();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _fetchConceptos(),
      _fetchAspirantes(),
    ]);
  }

  Future<void> _fetchConceptos() async {
    setState(() => _loadingConceptos = true);
    try {
      final token = await storage.read(key: 'auth_token');
      if (token == null) throw Exception('Token no encontrado');
      final response = await ApiClient.getJson('/configuracion-pagos?per_page=100&vigentes=1', token: token);
      final payload = response['data'] as Map<String, dynamic>?;
      final rows = payload?['data'] as List<dynamic>? ?? [];
      final conceptos = rows.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      setState(() {
        _conceptos = conceptos;
        _selectedConcepto ??= conceptos.isNotEmpty ? conceptos.first : null;
        _loadingConceptos = false;
      });
    } catch (e) {
      setState(() => _loadingConceptos = false);
      _showSnackBar('Error cargando conceptos: $e', isError: true);
    }
  }

  Future<void> _fetchAspirantes() async {
    setState(() => _loadingAspirantes = true);
    try {
      final token = await storage.read(key: 'auth_token');
      if (token == null) throw Exception('Token no encontrado');
      final response = await ApiClient.getJson('/admin/aspirantes', token: token);
      final payload = response['data'] as Map<String, dynamic>?;
      final todos = payload?['todos'] as List<dynamic>? ?? [];
      final aspirantes = todos.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      setState(() {
        _aspirantes = aspirantes;
        _filteredAspirantes = List.from(aspirantes);
        _loadingAspirantes = false;
      });
    } catch (e) {
      setState(() => _loadingAspirantes = false);
      _showSnackBar('Error cargando aspirantes: $e', isError: true);
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_applyFilters);
    _searchController.dispose();
    _referenciaController.dispose();
    super.dispose();
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

    final content = SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final contentWidth = screenWidth.clamp(320.0, 1400.0);
          final isWideLayout = contentWidth >= 1000;
          final horizontalPadding = screenWidth < 720 ? 16.0 : 24.0;

          Widget buildBody() {
            if (isWideLayout) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: min(420.0, contentWidth),
                    child: _buildRegistroCard(colors),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: _buildAspirantesCard(colors)),
                ],
              );
            }

            final minListHeight = max(420.0, MediaQuery.of(context).size.height * 0.5);

            return SingleChildScrollView(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildRegistroCard(colors, compact: true),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: minListHeight,
                    child: _buildAspirantesCard(colors),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              UthHeader(maxWidth: contentWidth),
              const SizedBox(height: 16),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: contentWidth),
                      child: buildBody(),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      bottomNavigationBar: useRail
          ? null
          : NavigationBar(
              selectedIndex: 2,
              destinations: adminNavigationDestinations,
              onDestinationSelected: handleNavigation,
            ),
      body: useRail
          ? Row(
              children: [
                SizedBox(
                  width: 96,
                  child: SideNavigationAdmin(
                    selectedIndex: 2,
                    onDestinationSelected: handleNavigation,
                  ),
                ),
                Expanded(child: content),
              ],
            )
          : content,
    );
  }

  Widget _buildRegistroCard(ColorScheme colors, {bool compact = false}) {
    final monto = _selectedConcepto != null ? _safeMonto(_selectedConcepto!['monto']) : null;
    final bottomSpacer = compact ? const SizedBox(height: 16) : const Spacer();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Registrar pago en ventanilla', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (_loadingConceptos)
              const Center(child: CircularProgressIndicator())
            else if (_conceptos.isEmpty)
              const Text('No hay conceptos configurados.')
            else ...[
              SizedBox(
                width: double.infinity,
                child: DropdownMenu<int>(
                  label: const Text('Concepto del pago'),
                  initialSelection: _selectedConcepto?['id'] as int?,
                  dropdownMenuEntries: _conceptos
                      .map(
                        (concepto) => DropdownMenuEntry<int>(
                          value: concepto['id'] as int,
                          label: concepto['concepto']?.toString() ?? 'Concepto',
                        ),
                      )
                      .toList(),
                  onSelected: (value) {
                    if (value == null) return;
                    final concept = _conceptos.firstWhere((element) => element['id'] == value);
                    setState(() => _selectedConcepto = concept);
                  },
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Monto', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: colors.onPrimaryContainer.withAlpha((0.8 * 255).round()))),
                    const SizedBox(height: 4),
                    Text(
                      monto != null ? _formatCurrency(monto) : 'Selecciona un concepto',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: colors.onPrimaryContainer, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: DropdownMenu<String>(
                  label: const Text('Método de pago'),
                  initialSelection: _metodoPago,
                  dropdownMenuEntries: const [
                    DropdownMenuEntry(value: 'Efectivo ventanilla', label: 'Efectivo ventanilla'),
                    DropdownMenuEntry(value: 'Tarjeta ventanilla', label: 'Tarjeta ventanilla'),
                  ],
                  onSelected: (value) => setState(() => _metodoPago = value ?? 'Efectivo ventanilla'),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fecha del pago'),
                subtitle: Text(_formatDate(_fechaPago)),
                trailing: TextButton.icon(
                  onPressed: _pickFechaPago,
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Cambiar'),
                ),
              ),
              TextFormField(
                controller: _referenciaController,
                readOnly: true,
                enableInteractiveSelection: false,
                decoration: InputDecoration(
                  labelText: 'Referencia (auto generada)',
                  prefixIcon: const Icon(Icons.tag),
                  suffixIcon: IconButton(
                    tooltip: 'Generar nuevo código',
                    icon: const Icon(Icons.refresh),
                    onPressed: _regenerarReferencia,
                  ),
                ),
              ),
              const Divider(height: 32),
              _buildAspiranteResumen(),
              bottomSpacer,
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _canSubmit ? _handleSubmitTap : null,
                  icon: _submitting
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.payments_outlined),
                  label: const Text('Registrar pago en ventanilla'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAspiranteResumen() {
    if (_selectedAspirante == null) {
      return Row(
        children: const [
          Icon(Icons.info_outline),
          SizedBox(width: 8),
          Expanded(child: Text('Selecciona un aspirante de la lista para continuar.')),
        ],
      );
    }

    final nombre = _nombreAspirante(_selectedAspirante!);
    final curp = _curpAspirante(_selectedAspirante!);
    final step = _stepLabel(_selectedAspirante!['progress_step']);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Aspirante seleccionado', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(nombre),
          Text('CURP: $curp · Paso: $step'),
        ],
      ),
    );
  }

  Widget _buildAspirantesCard(ColorScheme colors) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Buscar aspirante', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                IconButton(
                  tooltip: 'Actualizar listado',
                  onPressed: _loadingAspirantes ? null : _fetchAspirantes,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Buscar por nombre o folio',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 200,
                  child: DropdownMenu<String>(
                    label: const Text('Paso'),
                    initialSelection: _stepFilter,
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(value: 'todos', label: 'Todos'),
                      DropdownMenuEntry(value: '1', label: 'Paso 1'),
                      DropdownMenuEntry(value: '2', label: 'Paso 2'),
                      DropdownMenuEntry(value: '3', label: 'Paso 3'),
                      DropdownMenuEntry(value: '4', label: 'Paso 4'),
                      DropdownMenuEntry(value: '5', label: 'Paso 5'),
                      DropdownMenuEntry(value: '6', label: 'Paso 6'),
                    ],
                    onSelected: (value) {
                      setState(() => _stepFilter = value ?? 'todos');
                      _applyFilters();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('Solo con folio'),
                  selected: _soloConFolio,
                  onSelected: (value) {
                    setState(() => _soloConFolio = value);
                    _applyFilters();
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildAspiranteList(colors)),
          ],
        ),
      ),
    );
  }

  Widget _buildAspiranteList(ColorScheme colors) {
    if (_loadingAspirantes) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_filteredAspirantes.isEmpty) {
      return const Center(child: Text('No se encontraron aspirantes con los filtros seleccionados.'));
    }

    return ListView.separated(
      itemCount: _filteredAspirantes.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final aspirante = _filteredAspirantes[index];
        final isSelected = _selectedAspirante != null && _selectedAspirante!['id_aspirantes'] == aspirante['id_aspirantes'];
        final curp = _curpAspirante(aspirante);

        return ListTile(
          selected: isSelected,
          title: Text(_nombreAspirante(aspirante)),
          subtitle: Text('CURP: $curp · Paso ${aspirante['progress_step'] ?? '-'} · '),
          trailing: FilledButton.tonal(
            onPressed: () {
              setState(() => _selectedAspirante = aspirante);
            },
            child: Text(isSelected ? 'Seleccionado' : 'Elegir'),
          ),
          onTap: () => setState(() => _selectedAspirante = aspirante),
        );
      },
    );
  }

  void _applyFilters() {
    final term = _searchController.text.trim().toLowerCase();
    final step = _stepFilter;
    final soloConFolio = _soloConFolio;

    final filtered = _aspirantes.where((asp) {
      final nombre = _nombreAspirante(asp).toLowerCase();
      final folio = (asp['folio_examen'] ?? '').toString().toLowerCase();
      final matchesTerm = term.isEmpty || nombre.contains(term) || folio.contains(term);

      final paso = (asp['progress_step'] ?? '').toString();
      final matchesPaso = step == 'todos' || paso == step;

      final matchesFolio = !soloConFolio || (asp['folio_examen'] != null && asp['folio_examen'].toString().isNotEmpty);

      return matchesTerm && matchesPaso && matchesFolio;
    }).toList();

    setState(() => _filteredAspirantes = filtered);
  }

  String _nombreAspirante(Map<String, dynamic> aspirante) {
    return '${aspirante['nombre'] ?? ''} ${aspirante['ap_paterno'] ?? ''} ${aspirante['ap_materno'] ?? ''}'.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String _curpAspirante(Map<String, dynamic> aspirante) {
    final curp = aspirante['curp']?.toString().trim() ?? '';
    return curp.isEmpty ? 'N/D' : curp;
  }

  void _regenerarReferencia() {
    setState(() {
      _referenciaController.text = _generateReferencia();
    });
  }

  String _generateReferencia() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    return List.generate(15, (_) => chars[_random.nextInt(chars.length)]).join();
  }

  double? _safeMonto(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  String _formatCurrency(double value) => '\$${value.toStringAsFixed(2)} MXN';

  String _stepLabel(dynamic stepValue) {
    final step = stepValue is int ? stepValue : int.tryParse(stepValue?.toString() ?? '') ?? 0;
    switch (step) {
      case 1:
        return 'Registro';
      case 2:
        return 'Datos completos';
      case 3:
        return 'Pago validado';
      case 4:
        return 'Examen asignado';
      case 5:
        return 'Documentos';
      case 6:
        return 'Listo para inscripción';
      default:
        return 'Sin definir';
    }
  }

  Future<void> _pickFechaPago() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _fechaPago,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (selectedDate == null) return;
    if (!mounted) return;
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_fechaPago),
    );
    if (!mounted) return;
    setState(() {
      _fechaPago = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime?.hour ?? _fechaPago.hour,
        selectedTime?.minute ?? _fechaPago.minute,
      );
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  bool get _canSubmit => !_submitting && _selectedConcepto != null && _selectedAspirante != null;

  Future<void> _handleSubmitTap() async {
    if (!_canSubmit) return;
    final confirmed = await _showConfirmationDialog();
    if (confirmed == true) {
      await _submitPago();
    }
  }

  Future<void> _submitPago() async {
    if (!_canSubmit) return;
    setState(() => _submitting = true);
    try {
      final token = await storage.read(key: 'auth_token');
      if (token == null) throw Exception('Token no encontrado');

      final body = {
        'id_aspirantes': _selectedAspirante!['id_aspirantes'],
        'id_configuracion': _selectedConcepto!['id'],
        'tipo_pago': 'ventanilla',
        'metodo_pago': _metodoPago,
        'fecha_pago': _fechaPago.toIso8601String(),
        'referencia': _referenciaController.text.trim().isEmpty ? null : _referenciaController.text.trim(),
      }..removeWhere((key, value) => value == null);

      final response = await ApiClient.postJson('/pagos', body: body, token: token);
      if (response['success'] != true) {
        throw Exception(response['message'] ?? 'No se pudo registrar el pago');
      }

      if (!mounted) return;
      _showSnackBar('Pago registrado correctamente');
      setState(() {
        _submitting = false;
        _referenciaController.text = _generateReferencia();
        _selectedAspirante = null;
        _metodoPago = 'Efectivo ventanilla';
        _fechaPago = DateTime.now();
      });
      await _fetchAspirantes();
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        _showSnackBar('No se pudo registrar el pago: $e', isError: true);
      }
    }
  }

  Future<bool?> _showConfirmationDialog() {
    final aspirante = _selectedAspirante;
    final concepto = _selectedConcepto;
    final nombre = aspirante != null ? _nombreAspirante(aspirante) : 'Sin aspirante';
    final curp = aspirante != null ? _curpAspirante(aspirante) : 'N/D';
    final conceptoLabel = concepto?['concepto']?.toString() ?? 'Sin concepto';
    final monto = concepto != null ? _safeMonto(concepto['monto']) : null;
    final montoLabel = monto != null ? _formatCurrency(monto) : 'N/D';
    final metodo = _metodoPago;
    final fecha = _formatDate(_fechaPago);
    final referencia = _referenciaController.text.trim().isEmpty ? 'N/D' : _referenciaController.text.trim();

    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar registro de pago'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildConfirmationRow(dialogContext, 'Aspirante', nombre),
                _buildConfirmationRow(dialogContext, 'CURP', curp),
                const SizedBox(height: 12),
                _buildConfirmationRow(dialogContext, 'Concepto', conceptoLabel),
                _buildConfirmationRow(dialogContext, 'Monto', montoLabel),
                _buildConfirmationRow(dialogContext, 'Método de pago', metodo),
                _buildConfirmationRow(dialogContext, 'Fecha del pago', fecha),
                _buildConfirmationRow(dialogContext, 'Referencia', referencia),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Confirmar y registrar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildConfirmationRow(BuildContext context, String label, String value) {
    final labelStyle = Theme.of(context).textTheme.labelMedium;
    final valueStyle = Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(label, style: labelStyle),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 6,
            child: Text(value, style: valueStyle),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }
}
