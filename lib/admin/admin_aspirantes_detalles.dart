import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:siiadmision/config/api_client.dart';


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
                    _infoLine(context, 'Duración', carrera['duracion'] ?? 'N/D'),
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
      final archivo = docMap['archivo_url'] ?? 'Sin archivo';
      return DataRow(cells: [
        DataCell(Text(docMap['nombre']?.toString() ?? 'Documento')),
        DataCell(Text(docMap['estado_validacion_texto']?.toString() ?? 'Pendiente')),
        DataCell(SizedBox(
          width: 220,
          child: Text(
            archivo.toString(),
            overflow: TextOverflow.ellipsis,
          ),
        )),
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
            DataColumn(label: Text('Archivo')),
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
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(doc['nombre']?.toString() ?? 'Documento'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoLine(dialogContext, 'Estado', doc['estado_validacion_texto']?.toString() ?? 'Pendiente'),
                _infoLine(dialogContext, 'Observaciones', doc['observaciones']?.toString() ?? 'Sin observaciones'),
                _infoLine(dialogContext, 'Archivo', doc['archivo_url']?.toString() ?? 'Sin archivo'),
                _infoLine(dialogContext, 'Fecha registro', doc['fecha_registro']?.toString() ?? 'N/D'),
                _infoLine(dialogContext, 'Fecha validación', doc['fecha_validacion']?.toString() ?? 'N/D'),
              ],
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

  Future<void> _showPagoDetails(BuildContext context, Map<String, dynamic> pago) async {
    final config = pago['configuracion'] as Map<String, dynamic>?;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Pago ${pago['referencia'] ?? ''}'.trim()),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
}
