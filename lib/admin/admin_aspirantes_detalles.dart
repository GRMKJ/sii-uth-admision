import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:siiadmision/config/api_client.dart';
import 'package:url_launcher/url_launcher.dart';


class ValidarPagoScreen extends StatelessWidget {
  final String folio;
  const ValidarPagoScreen({super.key, required this.folio});

  @override
  Widget build(BuildContext context) {
    return _ScaffoldBase(
      title: 'Validar Pago de $folio',
      children: [
        const Text('Referencia: 1234567890'),
        const Text('Monto: \$500'),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Pago validado para $folio')),
            );
            Navigator.pop(context);
          },
          child: const Text('Validar Pago'),
        )
      ],
    );
  }
}

class VerDocumentosScreen extends StatelessWidget {
  final String folio;
  const VerDocumentosScreen({super.key, required this.folio});

  @override
  Widget build(BuildContext context) {
    return _ScaffoldBase(
      title: 'Documentos de $folio',
      children: [
        const _DocumentoItem(nombre: 'CURP.pdf'),
        const _DocumentoItem(nombre: 'ActaNacimiento.pdf'),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Documentos validados para $folio')),
            );
            Navigator.pop(context);
          },
          child: const Text('Validar Todos'),
        )
      ],
    );
  }
}

class AutorizarInscripcionScreen extends StatelessWidget {
  final String folio;
  const AutorizarInscripcionScreen({super.key, required this.folio});

  @override
  Widget build(BuildContext context) {
    return _ScaffoldBase(
      title: 'Autorizar Inscripción $folio',
      children: [
        const Text('Al autorizar se generará la matrícula y se enviará correo al aspirante.'),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Inscripción autorizada para $folio')),
            );
            Navigator.pop(context);
          },
          child: const Text('Confirmar Inscripción'),
        )
      ],
    );
  }
}

class _ScaffoldBase extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ScaffoldBase({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    //final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

class _DocumentoItem extends StatelessWidget {
  final String nombre;
  const _DocumentoItem({required this.nombre});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.picture_as_pdf_outlined),
      title: Text(nombre),
      trailing: IconButton(
        icon: const Icon(Icons.check_circle_outline),
        onPressed: () {},
        tooltip: 'Validar',
      ),
    );
  }
}

class PagoDetalleScreen extends StatefulWidget {
  final String referencia;
  const PagoDetalleScreen({super.key, required this.referencia});

  @override
  State<PagoDetalleScreen> createState() => _PagoDetalleScreenState();
}

class _PagoDetalleScreenState extends State<PagoDetalleScreen> {
  Map<String, dynamic>? data;

  @override
  void initState() {
    super.initState();
    _fetchDetalle();
  }

  Future<void> _fetchDetalle() async {
    final token = await const FlutterSecureStorage().read(key: 'auth_token');
    final response = await ApiClient.getJson("/admin/pago/${widget.referencia}", token: token);
    setState(() => data = response['data']);
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final aspirante = data!['aspirante'];
    final pago = data!['pago'];

    return Scaffold(
      appBar: AppBar(title: Text("Pago Ref: ${pago['referencia']}")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${aspirante['nombre']} ${aspirante['ap_paterno']} ${aspirante['ap_materno']}",
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text("Carrera: ${aspirante['carrera']?['carrera'] ?? 'Sin carrera'}"),
            Text("Teléfono: ${aspirante['telefono']}"),
            const Divider(),
            Text("Referencia: ${pago['referencia']}"),
            Text("Estado: ${pago['estado_validacion']}"),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final scaffold = ScaffoldMessenger.of(context);
                      await ApiClient.postJson("/admin/pago/${widget.referencia}/validar");
                      if (!mounted) return;
                      scaffold.showSnackBar(
                        const SnackBar(content: Text("Pago validado")),
                      );
                      _fetchDetalle();
                    },
                    icon: const Icon(Icons.check),
                    label: const Text("Validar Pago"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final scaffold = ScaffoldMessenger.of(context);
                      final res = await ApiClient.postJson("/admin/pago/${widget.referencia}/generar-folio");
                      if (!mounted) return;
                      scaffold.showSnackBar(
                        SnackBar(content: Text("Folio generado: ${res['folio']}")),
                      );
                      _fetchDetalle();
                    },
                    icon: const Icon(Icons.assignment),
                    label: const Text("Generar Folio"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class AspiranteDetalleScreen extends StatefulWidget {
  final String aspiranteId;
  const AspiranteDetalleScreen({super.key, required this.aspiranteId});

  @override
  State<AspiranteDetalleScreen> createState() => _AspiranteDetalleScreenState();
}

class _AspiranteDetalleScreenState extends State<AspiranteDetalleScreen> {
  Map<String, dynamic>? data;

  @override
  void initState() {
    super.initState();
    _fetchDetalle();
  }

  Future<void> _fetchDetalle() async {
    final token = await const FlutterSecureStorage().read(key: 'auth_token');
    final res = await ApiClient.getJson('/aspirantes/${widget.aspiranteId}', token: token);
    setState(() => data = res['data']);
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final asp = data!;
    final nombre = "${asp['nombre'] ?? ''} ${asp['ap_paterno'] ?? ''} ${asp['ap_materno'] ?? ''}".trim();
    final carrera = asp['carrera'] as Map<String, dynamic>?;
    final bachillerato = asp['bachillerato'] as Map<String, dynamic>?;
    final documentos = (asp['documentos'] as List?) ?? const [];
    final pagos = (asp['pagos'] as List?) ?? const [];
    final displayTitle = nombre.isNotEmpty ? nombre : 'Detalles del aspirante';
    final genero = _genderFromCurp(asp['curp'] as String?);

    return Scaffold(
      appBar: AppBar(title: Text(displayTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SelectionArea(
          child: ListView(
            children: [
              _buildGeneralSection(context, asp, genero),
              if (carrera != null)
                _buildSection(
                  context,
                  'Carrera elegida',
                  [
                    _infoLine(context, 'Programa', carrera['carrera'] ?? 'N/D'),
                    if ((carrera['descripcion'] ?? '').toString().isNotEmpty)
                      _infoLine(context, 'Descripción', carrera['descripcion']),
                  ],
                ),
              if (bachillerato != null)
                _buildSection(
                  context,
                  'Bachillerato de procedencia',
                  [
                    _infoLine(context, 'Nombre', bachillerato['nombre'] ?? 'N/D'),
                    _infoLine(context, 'Municipio', bachillerato['municipio'] ?? 'N/D'),
                    _infoLine(context, 'Estado', bachillerato['estado'] ?? 'N/D'),
                  ],
                ),
              _buildDocumentsSection(context, documentos),
              _buildPagosSection(context, pagos),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralSection(BuildContext context, Map<String, dynamic> asp, String genero) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Datos generales', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _infoLine(context, 'Folio de examen', asp['folio_examen'] ?? 'No asignado'),
                  _infoLine(context, 'CURP', asp['curp'] ?? 'No proporcionada'),
                  _infoLine(context, 'Género', genero),
                  _infoLine(context, 'Correo', asp['email'] ?? 'No proporcionado'),
                  _infoLine(context, 'Teléfono', asp['telefono'] ?? 'No proporcionado'),
                  _infoLine(context, 'Promedio general', (asp['promedio_general'] ?? 'N/D').toString()),
                  _infoLine(context, 'Paso actual', '${asp['progress_step'] ?? '-'}'),
                  _infoLine(context, 'Fecha de registro', asp['fecha_registro'] ?? 'N/D'),
                ],
              ),
            ),
            const SizedBox(width: 24),
            _buildProfilePlaceholder(context, genero),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _infoLine(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SelectableText.rich(
        TextSpan(
          children: [
            TextSpan(text: '$label: ', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            TextSpan(text: value, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsSection(BuildContext context, List documentos) {
    if (documentos.isEmpty) {
      return _buildSection(context, 'Documentos cargados', [
        _infoLine(context, 'Estado', 'El aspirante aún no carga documentos'),
      ]);
    }

    final docList = documentos.map((doc) => Map<String, dynamic>.from(doc as Map)).toList();
    final rows = docList.map((docMap) {
      return DataRow(cells: [
        DataCell(Text(docMap['nombre']?.toString() ?? 'Documento')),
        DataCell(Text(docMap['estado_validacion_texto']?.toString() ?? 'Pendiente')),
        DataCell(Text(docMap['fecha_registro']?.toString() ?? 'N/D')),
        DataCell(
          TextButton.icon(
            onPressed: () => _showDocumentDetails(context, docMap),
            icon: const Icon(Icons.visibility_outlined, size: 18),
            label: const Text('Detalles'),
          ),
        ),
      ]);
    }).toList();

    return _buildSection(context, 'Documentos cargados', [
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Nombre')),
            DataColumn(label: Text('Estado')),
            DataColumn(label: Text('Fecha registro')),
            DataColumn(label: Text('Acciones')),
          ],
          rows: rows,
          dataRowMinHeight: 48,
          dataRowMaxHeight: 64,
        ),
      ),
    ]);
  }

  Widget _buildPagosSection(BuildContext context, List pagos) {
    if (pagos.isEmpty) {
      return _buildSection(context, 'Pagos realizados', [
        _infoLine(context, 'Estado', 'Sin pagos registrados'),
      ]);
    }

    final pagoList = pagos.map((pago) => Map<String, dynamic>.from(pago as Map)).toList();
    final rows = pagoList.map((pagoMap) {
      return DataRow(cells: [
        DataCell(Text(pagoMap['referencia']?.toString() ?? 'N/D')),
        DataCell(Text(pagoMap['tipo_pago']?.toString() ?? 'N/D')),
        DataCell(Text(pagoMap['estado_validacion_texto']?.toString() ?? 'N/D')),
        DataCell(Text(pagoMap['fecha_pago']?.toString() ?? 'N/D')),
        DataCell(
          TextButton.icon(
            onPressed: () => _showPagoDetails(context, pagoMap),
            icon: const Icon(Icons.visibility_outlined, size: 18),
            label: const Text('Detalles'),
          ),
        ),
      ]);
    }).toList();

    return _buildSection(context, 'Pagos realizados', [
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Referencia')),
            DataColumn(label: Text('Tipo')),
            DataColumn(label: Text('Estado')),
            DataColumn(label: Text('Fecha')),
            DataColumn(label: Text('Acciones')),
          ],
          rows: rows,
          dataRowMinHeight: 48,
          dataRowMaxHeight: 64,
        ),
      ),
    ]);
  }

  Widget _buildProfilePlaceholder(BuildContext context, String genero) {
    const size = 140.0;
    final color = _placeholderColor(genero);
    final asset = _placeholderAssetForGender(genero);
    final borderRadius = BorderRadius.circular(size / 6);

    Widget fallbackIcon() {
      final icon = switch (genero) {
        'Hombre' => Icons.man_3_outlined,
        'Mujer' => Icons.woman_2_outlined,
        'No binario' => Icons.transgender,
        _ => Icons.person_outline,
      };
      return Align(
        alignment: Alignment.center,
        child: Icon(icon, size: 56, color: Colors.white.withValues(alpha: 0.9)),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(color: color, width: 2),
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withAlpha((0.25 * 255).round()),
                    color.withAlpha((0.6 * 255).round()),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            if (asset != null)
              Image.asset(
                asset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => fallbackIcon(),
              )
            else
              fallbackIcon(),
            if (asset != null)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.35),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _placeholderColor(String genero) {
    switch (genero) {
      case 'Mujer':
        return Colors.pinkAccent;
      case 'No binario':
        return Colors.deepPurple;
      default:
        return Colors.blueGrey;
    }
  }

  Future<void> _showDocumentDetails(BuildContext context, Map<String, dynamic> doc) async {
    bool originalFisico = false;
    bool copiaFisico = false;
    bool savingPosesion = false;
    bool requestingReplacement = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final archivoUrl = (doc['archivo_url'] ?? '').toString();
        final hasArchivo = archivoUrl.isNotEmpty;
        final estadoLabel = doc['estado_validacion_texto']?.toString() ?? 'Pendiente';
        final validatorName = _documentValidatorName(doc);
        final ocrNotes = _extractOcrObservations(doc);

        return StatefulBuilder(
          builder: (innerContext, setStateDialog) {
            return AlertDialog(
              title: Text(doc['nombre']?.toString() ?? 'Documento'),
              content: SizedBox(
                width: 520,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 460),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatusBadge(dialogContext, estadoLabel),
                        const SizedBox(height: 12),
                        _infoLine(dialogContext, 'Validado por', validatorName),
                        _infoLine(dialogContext, 'Observaciones (OCR)', ocrNotes),
                        if (!hasArchivo)
                          _infoLine(dialogContext, 'Archivo', 'Sin archivo'),
                        _infoLine(dialogContext, 'Fecha registro', doc['fecha_registro']?.toString() ?? 'N/D'),
                        _infoLine(dialogContext, 'Fecha validación', doc['fecha_validacion']?.toString() ?? 'N/D'),
                        const SizedBox(height: 12),
                        Text(
                          'Documento físico en posesión',
                          style: Theme.of(dialogContext)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: CheckboxListTile(
                                value: originalFisico,
                                onChanged: (value) => setStateDialog(() => originalFisico = value ?? false),
                                title: const Text('Original'),
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: CheckboxListTile(
                                value: copiaFisico,
                                onChanged: (value) => setStateDialog(() => copiaFisico = value ?? false),
                                title: const Text('Copia'),
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: savingPosesion
                              ? null
                              : () async {
                                  if (!dialogContext.mounted) return;
                                  setStateDialog(() => savingPosesion = true);
                                  await _saveDocumentPossession(
                                    context,
                                    doc,
                                    originalFisico,
                                    copiaFisico,
                                  );
                                  if (!dialogContext.mounted) return;
                                  setStateDialog(() => savingPosesion = false);
                                },
                          icon: savingPosesion
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.save_outlined),
                          label: Text(savingPosesion ? 'Guardando cambios…' : 'Registrar posesión'),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: hasArchivo
                                    ? () => _openExternalDocument(dialogContext, archivoUrl)
                                    : null,
                                icon: const Icon(Icons.open_in_new_outlined),
                                label: const Text('Ver documento'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final comentario = await _promptManualValidationComment(context, doc);
                                  if (comentario == null) return;
                                  _manualValidateDocument(
                                    context,
                                    doc,
                                    originalFisico,
                                    copiaFisico,
                                    comentario,
                                  );
                                },
                                icon: const Icon(Icons.verified_user_outlined),
                                label: const Text('Validación manual'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: requestingReplacement
                                    ? null
                                    : () async {
                                        final comment = await _promptReplacementComment(context, doc);
                                        if (comment == null || !dialogContext.mounted) {
                                          return;
                                        }
                                        setStateDialog(() => requestingReplacement = true);
                                        await _requestNewDocumentUpload(context, doc, comment);
                                        if (!dialogContext.mounted) return;
                                        setStateDialog(() => requestingReplacement = false);
                                      },
                                icon: requestingReplacement
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.autorenew_outlined),
                                label: Text(
                                  requestingReplacement ? 'Solicitando…' : 'Solicitar nuevamente',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cerrar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showPagoDetails(BuildContext context, Map<String, dynamic> pago) async {
    final config = pago['configuracion'] as Map<String, dynamic>?;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Pago ${pago['referencia'] ?? ''}'.trim()),
          content: SizedBox(
            width: 520,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 420),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoLine(dialogContext, 'Tipo', pago['tipo_pago']?.toString() ?? 'N/D'),
                    _infoLine(dialogContext, 'Método', pago['metodo_pago']?.toString() ?? 'N/D'),
                    _infoLine(dialogContext, 'Estado', pago['estado_validacion_texto']?.toString() ?? 'N/D'),
                    _infoLine(dialogContext, 'Fecha', pago['fecha_pago']?.toString() ?? 'N/D'),
                    _infoLine(dialogContext, 'Comprobante', pago['comprobante_url']?.toString() ?? 'Sin archivo'),
                    if (config != null)
                      _infoLine(
                        dialogContext,
                        'Configuración',
                        '${config['concepto'] ?? 'N/D'} - ${config['monto'] ?? ''}',
                      ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusBadge(BuildContext context, String estado) {
    final scheme = Theme.of(context).colorScheme;
    final color = _statusColorForLabel(estado, scheme);
    final textStyle = Theme.of(context).textTheme.labelLarge?.copyWith(color: color);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(estado, style: textStyle),
        ],
      ),
    );
  }

  String _documentValidatorName(Map<String, dynamic> doc) {
    final validador = doc['validador'];
    if (validador is Map<String, dynamic>) {
      final formatted = [
        validador['nombre'],
        validador['ap_paterno'],
        validador['ap_materno'],
      ].whereType<String>().map((e) => e.trim()).where((e) => e.isNotEmpty).join(' ');
      if (formatted.isNotEmpty) {
        return formatted;
      }
    }

    final origen = doc['validacion_origen']?.toString();
    if (origen != null && origen.trim().isNotEmpty) {
      return origen.trim();
    }

    final estado = (doc['estado_validacion_texto']?.toString() ?? '').toLowerCase();
    if (estado.contains('autom')) {
      return 'Agente automatizado';
    }
    if (estado.contains('pendiente')) {
      return 'Pendiente de validación';
    }
    return 'Sin registro';
  }

  String _extractOcrObservations(Map<String, dynamic> doc) {
    const candidateKeys = [
      'ocr_observaciones',
      'ocr_resultado',
      'ocr_texto',
      'ocr_data',
      'ocr',
      'observaciones',
    ];

    for (final key in candidateKeys) {
      final value = doc[key];
      if (value == null) continue;
      final text = value.toString().trim();
      if (text.isNotEmpty) {
        return text;
      }
    }
    return 'Sin datos capturados por OCR.';
  }

  Color _statusColorForLabel(String estado, ColorScheme scheme) {
    final normalized = estado.toLowerCase();
    if (normalized.contains('autom')) {
      return scheme.tertiary;
    }
    if (normalized.contains('pendiente')) {
      return scheme.secondary;
    }
    if (normalized.contains('manual')) {
      return scheme.primary;
    }
    return scheme.outline;
  }

  String? _placeholderAssetForGender(String genero) {
    switch (genero) {
      case 'Hombre':
        return 'assets/maleph.png';
      case 'Mujer':
        return 'assets/femaleph.png';
      case 'No binario':
        return 'assets/nbph.png';
      default:
        return null;
    }
  }

  String _genderFromCurp(String? curp) {
    if (curp == null || curp.length < 11) {
      return 'No determinado';
    }
    final indicator = curp[10].toUpperCase();
    switch (indicator) {
      case 'H':
        return 'Hombre';
      case 'M':
        return 'Mujer';
      case 'X':
        return 'No binario';
      default:
        return 'No determinado';
    }
  }

  Future<void> _openExternalDocument(BuildContext context, String url) async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.tryParse(url);
    if (uri == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('URL del documento no válida.')),
      );
      return;
    }
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el documento.')),
      );
    }
  }

  void _manualValidateDocument(
    BuildContext hostContext,
    Map<String, dynamic> doc,
    bool originalFisico,
    bool copiaFisico,
    String comentario,
  ) {
    final messenger = ScaffoldMessenger.of(hostContext);
    final nombreDoc = doc['nombre']?.toString() ?? 'Documento';
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Validación manual registrada para $nombreDoc · Original: ${originalFisico ? 'Sí' : 'No'}, Copia: ${copiaFisico ? 'Sí' : 'No'} · Comentario: $comentario',
        ),
      ),
    );
  }

  Future<String?> _promptManualValidationComment(
    BuildContext context,
    Map<String, dynamic> doc,
  ) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Validación manual - ${doc['nombre'] ?? 'Documento'}'),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Comentario de validación',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Agrega un comentario antes de validar.')),
                  );
                  return;
                }
                Navigator.of(dialogContext).pop(text);
              },
              child: const Text('Confirmar validación'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    return result;
  }

  Future<void> _saveDocumentPossession(
    BuildContext context,
    Map<String, dynamic> doc,
    bool originalFisico,
    bool copiaFisico,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final docId = _resolveDocumentId(doc);
    if (docId == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No se pudo identificar el documento.')),
      );
      return;
    }
    try {
      final token = await const FlutterSecureStorage().read(key: 'auth_token');
      await ApiClient.postJson(
        '/admin/documentos/$docId/posesion',
        token: token,
        body: {
          'original_fisico': originalFisico,
          'copia_fisico': copiaFisico,
        },
      );
      messenger.showSnackBar(
        const SnackBar(content: Text('Registro de documento físico actualizado.')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error al registrar posesión: $e')),
      );
    }
  }

  Future<String?> _promptReplacementComment(
    BuildContext context,
    Map<String, dynamic> doc,
  ) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Solicitud para ${doc['nombre'] ?? 'documento'}'),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Comentario para el aspirante',
              hintText: 'Describe qué debe corregir o adjuntar…',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Agrega un comentario para continuar.')),
                  );
                  return;
                }
                Navigator.of(dialogContext).pop(text);
              },
              child: const Text('Enviar solicitud'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    return result;
  }

  Future<void> _requestNewDocumentUpload(
    BuildContext context,
    Map<String, dynamic> doc,
    String comentario,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final docId = _resolveDocumentId(doc);
    if (docId == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No se pudo identificar el documento.')),
      );
      return;
    }
    try {
      final token = await const FlutterSecureStorage().read(key: 'auth_token');
      await ApiClient.postJson(
        '/admin/documentos/$docId/solicitar-reenvio',
        token: token,
        body: {
          'comentario': comentario,
        },
      );
      messenger.showSnackBar(
        const SnackBar(content: Text('Solicitud enviada al aspirante.')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error al solicitar nuevo documento: $e')),
      );
    }
  }

  String? _resolveDocumentId(Map<String, dynamic> doc) {
    const candidates = [
      'id',
      'documento_id',
      'id_documento',
      'uuid',
    ];
    for (final key in candidates) {
      final value = doc[key];
      if (value == null) continue;
      final text = value.toString();
      if (text.isNotEmpty) {
        return text;
      }
    }
    return null;
  }
}
