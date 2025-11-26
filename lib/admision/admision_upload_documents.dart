import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:siiadmision/config/api_client.dart';
import 'package:siiadmision/config/aspirante_progress.dart';
import 'package:url_launcher/url_launcher.dart';

class UploadDocumentsScreen extends StatefulWidget {
  const UploadDocumentsScreen({super.key, this.sessionIdFromQuery, this.statusFromQuery});

  final String? sessionIdFromQuery;
  final String? statusFromQuery;

  @override
  State<UploadDocumentsScreen> createState() => _UploadDocumentsScreenState();
}

class _UploadDocumentsScreenState extends State<UploadDocumentsScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Map<String, bool> _uploadedStatus = {
    'Acta de Nacimiento': false,
    'CURP actualizado': false,
    'Certificado de Bachillerato o Constancia': false,
    'Foto Tamaño Infantil': false,
    'Comprobante de Número de Seguridad Social del IMSS': false,
    'Comprobante de Domicilio': false,
    'Pago de Inscripción y Orden de Cobro': false,
    'Pago de Seguro y Credencial': false,
  };

  // Estado de verificación por documento (muestra spinner mientras sube/verifica)
  final Map<String, bool> _verifyingStatus = {
    'Acta de Nacimiento': false,
    'CURP actualizado': false,
    'Certificado de Bachillerato o Constancia': false,
    'Foto Tamaño Infantil': false,
    'Comprobante de Número de Seguridad Social del IMSS': false,
    'Comprobante de Domicilio': false,
    'Pago de Inscripción y Orden de Cobro': false,
    'Pago de Seguro y Credencial': false,
  };

  bool get _allUploaded => _uploadedStatus.values.every((uploaded) => uploaded);
  String? _lastSessionId;
  bool _checkingStripeStatus = false;

  void _uploadDocument(String label) {
    setState(() {
      _uploadedStatus[label] = true;
    });
    // Sincroniza con el servidor por si hay más cambios
    _refreshStatuses();
  }


  @override
  void initState() {
    super.initState();
    _initializeFromQuery();
    // Traer estados desde el servidor al entrar a la vista
    _refreshStatuses();
  }

  @override
  void didUpdateWidget(covariant UploadDocumentsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sessionIdFromQuery != oldWidget.sessionIdFromQuery && (widget.sessionIdFromQuery ?? '').isNotEmpty) {
      _lastSessionId = widget.sessionIdFromQuery;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _refreshStripeStatus(widget.sessionIdFromQuery);
      });
    }
  }

  void _initializeFromQuery() {
    _lastSessionId = widget.sessionIdFromQuery;
    if ((_lastSessionId ?? '').isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _refreshStripeStatus(_lastSessionId);
      });
    }
  }

  Future<void> _refreshStatuses() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null || token.isEmpty) return;

      final res = await ApiClient.getJson('/documentos', token: token);
      if (res['success'] == true && res['documentos'] is List) {
        final docs = (res['documentos'] as List).cast<dynamic>();
        final uploadedNames = <String>{};
        for (final d in docs) {
          try {
            final m = d as Map<String, dynamic>;
            final nombre = (m['nombre'] ?? '').toString();
            final archivo = (m['archivo_pat'] ?? m['archivo_url'] ?? '').toString();
            final estadoRaw = m['estado_validacion'];
            int estado = 0;
            if (estadoRaw is int) {
              estado = estadoRaw;
            } else if (estadoRaw is double) {
              estado = estadoRaw.toInt();
            } else if (estadoRaw is String) {
              estado = int.tryParse(estadoRaw) ?? 0;
            }
            final bool validatedWithoutFile = estado >= 2;
            if (nombre.isNotEmpty && (archivo.isNotEmpty || validatedWithoutFile)) {
              uploadedNames.add(nombre);
            }
          } catch (_) {}
        }

        if (!mounted) return;
        setState(() {
          _uploadedStatus.updateAll((key, value) => uploadedNames.contains(key));
        });
      }
    } catch (_) {
      // opcional: mostrar snackBar o loguear
    }
  }

  Future<void> _refreshStripeStatus([String? sessionId]) async {
    final targetSession = sessionId ?? _lastSessionId;
    if (_checkingStripeStatus || targetSession == null || targetSession.isEmpty) {
      return;
    }

    setState(() => _checkingStripeStatus = true);
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null || token.isEmpty) {
        throw Exception('No autenticado');
      }

      final response = await ApiClient.getJson('/pagos/stripe/session/$targetSession', token: token);
      final data = _unwrapResponse(response);
      final nowPaid = _asInt(data['estado_validacion']) == 1;

      if (!mounted) return;
      setState(() {
        _lastSessionId = data['session_id'] as String? ?? targetSession;
      });

      if (nowPaid) {
        await _refreshStatuses();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pago de seguro confirmado.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo verificar el pago con Stripe: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _checkingStripeStatus = false);
      }
    }
  }

  Map<String, dynamic> _unwrapResponse(Map<String, dynamic> payload) {
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    return payload;
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final isMobile = screenWidth < 720;

            final card = Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow.withAlpha((0.1 * 255).round()),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: isMobile
                  ? _buildColumnLayout(context)
                  : _buildRowLayout(context),
            );

            return Column(
              children: [
                Expanded(
                  child: Center(
                    child: card,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 16, right: 16),
        child: FloatingActionButton(
          onPressed: () => _showHelpDialog(context),
          tooltip: 'Ayuda',
          child: const Icon(Icons.help_outline),
        ),
      ),
    );
  }

  Widget _buildRowLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              bottomLeft: Radius.circular(24),
            ),
            child: Image.asset(
              'assets/uth_fondo2.jpg',
              fit: BoxFit.cover,
              height: double.infinity,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: _buildInfoPanel(context),
        ),
      ],
    );
  }

  Widget _buildColumnLayout(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: Image.asset(
            'assets/uth_fondo2.jpg',
            fit: BoxFit.cover,
            height: 180,
            width: double.infinity,
          ),
        ),
        Expanded(child: _buildInfoPanel(context)),
      ],
    );
  }

  Widget _buildInfoPanel(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalDocs = _uploadedStatus.length;
        final uploadedCount = _uploadedStatus.values.where((uploaded) => uploaded).length;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admisión 2025',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Sube los documentos solicitados para completar tu inscripción:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                DocumentUploadForm(
                  uploadedStatus: _uploadedStatus,
                  verifyingStatus: _verifyingStatus,
                  onUpload: _uploadDocument,
                  onVerifying: (label, value) {
                    setState(() {
                      _verifyingStatus[label] = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    Text(
                      '$uploadedCount/$totalDocs documentos subidos',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    FilledButton(
                      onPressed: _allUploaded ? _showConfirmationDialog : null,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Siguiente'),
                          Icon(Icons.arrow_right),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.help_outline, size: 32),
            SizedBox(width: 8),
            Expanded(child: Text('¿Necesitas ayuda?', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Si tienes dudas sobre tu registro, puedes contactarnos:'),
            SizedBox(height: 12),
            Text('📧 Correo:'),
            SelectableText('aspirante@uth.edu.mx'),
            SizedBox(height: 8),
            Text('📞 Teléfonos:'),
            Text('227 275 9311'),
            Text('227 275 9313'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog() {
    bool accepted = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified_user_outlined, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Confirmar Envío de Documentos',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Estás por enviar tus documentos para revisión. '
                    'Verifica que todos los archivos subidos sean correctos, ya que no podrás hacer cambios posteriores.',
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Confirmo que los documentos son correctos'),
                    value: accepted,
                    onChanged: (val) => setState(() => accepted = val ?? false),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: accepted
                      ? () {
                          Navigator.pop(context);

                          // Aquí puedes enviar los datos o redirigir
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Documentos enviados para revisión')),
                          );
                          ProgressService.saveStep(5);

                          // Ejemplo: context.push('/siguiente-pantalla');
                        }
                      : null,
                  child: const Text('Confirmar Envío'),
                ),
              ],
            );
          },
        );
      },
    );
  }

}

class DocumentUploadForm extends StatefulWidget {
  final Map<String, bool> uploadedStatus;
  final Map<String, bool> verifyingStatus;
  final void Function(String) onUpload;
  final void Function(String, bool) onVerifying;

  const DocumentUploadForm({
    super.key,
    required this.uploadedStatus,
    required this.verifyingStatus,
    required this.onUpload,
    required this.onVerifying,
  });

  @override
  State<DocumentUploadForm> createState() => _DocumentUploadFormState();
}

class _DocumentUploadFormState extends State<DocumentUploadForm> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _photoDocumentLabel = 'Foto Tamaño Infantil';
  static const Set<String> _photoAllowedExtensions = {'jpg', 'jpeg'};
  static const int _photoMaxBytes = 5 * 1024 * 1024; // 5 MB
  static const int _seguroConfigId = 4;
  bool _launchingSeguroStripe = false;
  bool _checkingSeguroPayment = false;
  String? _seguroReference;
  String? _seguroStatusText;

  // Controlador para la referencia de pago de inscripción
  final Map<String, TextEditingController> _textControllers = {
    'Pago de Inscripción y Orden de Cobro': TextEditingController(),
  };

  Widget _uploadField(BuildContext context, String label, bool uploaded, bool isCompact) {
    final statusText = uploaded ? 'Cargado' : 'Pendiente';
    final statusColor = uploaded ? Colors.green : Colors.orange;
    final isVerifying = widget.verifyingStatus[label] == true;
    final isPhotoDocument = label == _photoDocumentLabel;

    Widget buildDocumentCard({required List<Widget> children}) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...children,
            ],
          ),
        ),
      );
    }

    if (label == 'Pago de Inscripción y Orden de Cobro') {
      final refController = _textControllers[label]!;

      final Widget statusChip = isVerifying
          ? Chip(
              avatar: SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                ),
              ),
              label: const Text('Verificando...'),
            )
          : uploaded
              ? Chip(
                  label: const Text('Cargado'),
                  backgroundColor: Colors.green.withAlpha((0.2 * 255).round()),
                  labelStyle: const TextStyle(color: Colors.green),
                  side: const BorderSide(color: Colors.green),
                )
              : Chip(
                  label: const Text('Pendiente'),
                  backgroundColor: Colors.orange.withAlpha((0.15 * 255).round()),
                  labelStyle: const TextStyle(color: Colors.orange),
                  side: const BorderSide(color: Colors.orange),
                );

      if (isCompact) {
        return buildDocumentCard(children: [
          TextField(
            controller: refController,
            enabled: !uploaded,
            decoration: const InputDecoration(
              hintText: 'Referencia / Folio',
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: (isVerifying || uploaded)
                  ? null
                  : () => _verifyInscripcion(label, refController.text.trim()),
              child: const Text('Verificar'),
            ),
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Estado de validación:'),
              const SizedBox(height: 4),
              statusChip,
            ],
          ),
        ]);
      }

      return buildDocumentCard(children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: refController,
                enabled: !uploaded,
                decoration: const InputDecoration(
                  hintText: 'Referencia / Folio',
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: (isVerifying || uploaded)
                  ? null
                  : () => _verifyInscripcion(label, refController.text.trim()),
              child: const Text('Verificar'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Estado de validación:'),
            const SizedBox(height: 4),
            statusChip,
          ],
        ),
      ]);
    }

    if (label == 'Pago de Seguro y Credencial') {
      final bool isConsulting = _checkingSeguroPayment;
      final bool isPaid = uploaded;
      final Color statusColor;
      if (isPaid) {
        statusColor = Colors.green;
      } else if ((_seguroStatusText ?? '').toLowerCase().contains('rechaz')) {
        statusColor = Colors.redAccent;
      } else {
        statusColor = Colors.orange;
      }

      final String statusLabel;
      if (isConsulting) {
        statusLabel = 'Consultando…';
      } else if (isPaid) {
        statusLabel = 'Validado';
      } else {
        statusLabel = _seguroStatusText ?? 'Pendiente';
      }

      final Widget statusChip = Chip(
        label: Text(statusLabel),
        backgroundColor: statusColor.withValues(alpha: statusLabel == 'Consultando…' ? 0.15 : 0.2),
        labelStyle: TextStyle(color: statusColor),
        side: BorderSide(color: statusColor),
      );

      Widget referenceBox() {
        if (_seguroReference == null) return const SizedBox.shrink();
        final theme = Theme.of(context);
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Último pago consultado', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              SelectableText('Referencia: ${_seguroReference!}'),
              if (_seguroStatusText != null)
                Text('Estado: $_seguroStatusText'),
            ],
          ),
        );
      }

      Widget actionsColumn(bool compact) {
        final stripeButton = FilledButton.icon(
          onPressed: _launchingSeguroStripe ? null : _startSeguroStripePayment,
          icon: _launchingSeguroStripe
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                )
              : const Icon(Icons.credit_card),
          label: Text(_launchingSeguroStripe ? 'Conectando…' : 'Pagar con Stripe'),
        );

        final validateButton = OutlinedButton.icon(
          onPressed: _checkingSeguroPayment ? null : () => _checkSeguroPaymentStatus(label),
          icon: _checkingSeguroPayment
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.verified_outlined),
          label: Text(_checkingSeguroPayment ? 'Buscando…' : 'Validar y obtener referencia'),
        );

        final widgets = [stripeButton, validateButton];

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: widgets
                .map((w) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: w,
                    ))
                .toList(),
          );
        }

        return Wrap(
          spacing: 12,
          runSpacing: 8,
          children: widgets
              .map((widgetButton) => SizedBox(
                    width: 260,
                    child: widgetButton,
                  ))
              .toList(),
        );
      }

      final Widget info = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Puedes pagar con tarjeta mediante Stripe y recibir la validación en minutos.'),
          const SizedBox(height: 6),
          const Text('También se puede pagar en efectivo directamente en la caja del edificio "A".'),
          const SizedBox(height: 8),
          actionsColumn(isCompact),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Estado de validación:'),
              const SizedBox(height: 4),
              statusChip,
            ],
          ),
          const SizedBox(height: 12),
          referenceBox(),
        ],
      );

      return buildDocumentCard(children: [info]);
    }

    final Widget statusChip = isVerifying
        ? Chip(
            avatar: SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
              ),
            ),
            label: const Text('Verificando...'),
          )
        : Chip(
            label: Text(statusText),
            backgroundColor: statusColor.withAlpha((0.2 * 255).round()),
            labelStyle: TextStyle(color: statusColor),
            side: BorderSide(color: statusColor),
          );

    final uploadButton = OutlinedButton.icon(
      onPressed: (isVerifying || uploaded)
          ? null
          : () => isPhotoDocument ? pickPhoto(label) : pickPdf(label),
      icon: Icon(isPhotoDocument ? Icons.photo_camera_outlined : Icons.upload_file),
      label: Text(
        isPhotoDocument ? 'Subir fotografía (JPG · máx 5 MB)' : 'Subir archivo PDF',
      ),
    );

    final content = <Widget>[
      SizedBox(width: double.infinity, child: uploadButton),
      const SizedBox(height: 12),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Estado de validación:'),
          const SizedBox(height: 4),
          statusChip,
        ],
      ),
    ];

    return buildDocumentCard(children: content);
  }

  Future<void> _verifyInscripcion(String label, String referencia) async {
    final scaffold = ScaffoldMessenger.of(context);
    if (referencia.isEmpty) {
      if (!mounted) return;
      scaffold.showSnackBar(const SnackBar(content: Text('Ingresa la referencia para verificar')));
      return;
    }

    try {
      widget.onVerifying(label, true);
      final token = await _storage.read(key: 'auth_token');
      if (token == null || token.isEmpty) {
        if (!mounted) return;
        scaffold.showSnackBar(const SnackBar(content: Text('No autenticado')));
        return;
      }

      // Ajusta el endpoint según tu backend real
      final res = await ApiClient.postJson(
        '/pagos/inscripcion/verify',
        body: {'reference': referencia},
        token: token,
      );

      final success = res['success'] == true;
      final msg = (res['message'] ?? (success ? 'Referencia verificada' : 'No verificado')).toString();

      if (success) {
        widget.onUpload(label);
      }

      if (!mounted) return;
      scaffold.showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (mounted) scaffold.showSnackBar(SnackBar(content: Text('Error al verificar: $e')));
    } finally {
      widget.onVerifying(label, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final docs = widget.uploadedStatus.keys.toList();
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 640;
        final cards = docs
            .map(
              (doc) => _uploadField(
                context,
                doc,
                widget.uploadedStatus[doc]!,
                isCompact,
              ),
            )
            .toList();

        late final Widget cardsLayout;
        if (isCompact) {
          cardsLayout = Column(children: cards);
        } else {
          const double horizontalSpacing = 16;
          const double totalCardMarginsPerRow = 32; // Each card already has 8px margin per side
          double cardWidth = (constraints.maxWidth - horizontalSpacing - totalCardMarginsPerRow) / 2;
          if (cardWidth <= 0) {
            cardWidth = constraints.maxWidth;
          }

          cardsLayout = Wrap(
            spacing: horizontalSpacing,
            runSpacing: 16,
            children: cards
                .map(
                  (card) => SizedBox(
                    width: cardWidth,
                    child: card,
                  ),
                )
                .toList(),
          );
        }

        return cardsLayout;
      },
    );
  }

  Future<void> pickPdf(String documentName) async {
    final scaffold = ScaffoldMessenger.of(context);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      final file = result.files.single;
      // En web, acceder a `path` lanza una excepción. Usa bytes si están disponibles.
      final bytes = file.bytes; // no-nulo en web
      final filename = file.name;
      final String? safePath = bytes != null ? null : file.path; // solo leer path si no hay bytes

      if (safePath == null && bytes == null) {
        return; // nothing to upload
      }
      // Subir el archivo al servidor y verificar
      widget.onVerifying(documentName, true);
      await uploadFile(
        scaffold,
        path: safePath,
        bytes: bytes,
        filename: filename,
        documentName: documentName,
      );
      widget.onVerifying(documentName, false);
    }
  }

  Future<void> pickPhoto(String documentName) async {
    final scaffold = ScaffoldMessenger.of(context);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _photoAllowedExtensions.toList(),
    );

    if (result == null) {
      return;
    }

    final file = result.files.single;
    final extension = _resolveExtension(file);
    if (!_photoAllowedExtensions.contains(extension)) {
      scaffold.showSnackBar(
        const SnackBar(content: Text('La fotografía debe estar en formato JPG.')),
      );
      return;
    }

    final int fileSize = file.bytes?.length ?? file.size;
    if (fileSize > _photoMaxBytes) {
      scaffold.showSnackBar(
        const SnackBar(content: Text('La fotografía debe pesar menos de 5 MB.')),
      );
      return;
    }

    final bytes = file.bytes;
    final filename = file.name;
    final String? safePath = bytes != null ? null : file.path;

    if (safePath == null && bytes == null) {
      scaffold.showSnackBar(
        const SnackBar(content: Text('No pudimos acceder al archivo seleccionado. Intenta nuevamente.')),
      );
      return;
    }

    widget.onVerifying(documentName, true);
    await uploadFile(
      scaffold,
      path: safePath,
      bytes: bytes,
      filename: filename,
      documentName: documentName,
    );
    widget.onVerifying(documentName, false);
  }

  String _resolveExtension(PlatformFile file) {
    final ext = file.extension?.toLowerCase();
    if (ext != null && ext.isNotEmpty) {
      return ext;
    }
    final name = file.name;
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex != -1 && dotIndex < name.length - 1) {
      return name.substring(dotIndex + 1).toLowerCase();
    }
    return '';
  }

  Future<void> uploadFile(
    ScaffoldMessengerState scaffold, {
    String? path,
    List<int>? bytes,
    required String filename,
    required String documentName,
  }) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null || token.isEmpty) {
        if (!mounted) return;
        scaffold.showSnackBar(const SnackBar(content: Text('No autenticado')));
        return;
      }

      // 1) Subir archivo
      final uploadRes = await ApiClient.postMultipart(
        '/documentos',
        fileField: 'archivo',
        filePath: path,
        fileBytes: bytes,
        fileName: filename,
        fields: {'documento': documentName},
        token: token,
      );

      if (uploadRes['success'] != true) {
        throw Exception(uploadRes['message'] ?? 'Error al subir el documento');
      }

      // 2) Verificar en servidor que exista el documento
      final verify = await ApiClient.getJson('/documentos', token: token);
      if (verify['success'] == true && verify['documentos'] is List) {
        final docs = (verify['documentos'] as List).cast<dynamic>();
        final found = docs.any((d) {
          try {
            final m = d as Map<String, dynamic>;
            final nombre = (m['nombre'] ?? '').toString();
            final archivo = (m['archivo_pat'] ?? '').toString();
            return nombre == documentName && archivo.isNotEmpty;
          } catch (_) {
            return false;
          }
        });

        if (found) {
          widget.onUpload(documentName);
          if (!mounted) return;
          scaffold.showSnackBar(SnackBar(content: Text('"$documentName" subido y verificado')));
        } else {
          throw Exception('El servidor no refleja el archivo subido aún');
        }
      } else {
        throw Exception('No se pudo verificar documentos');
      }
    } catch (e) {
      if (mounted) scaffold.showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      widget.onVerifying(documentName, false);
    }
 }

  Future<void> _startSeguroStripePayment() async {
    final scaffold = ScaffoldMessenger.of(context);
    try {
      setState(() => _launchingSeguroStripe = true);
      final token = await _storage.read(key: 'auth_token');
      if (token == null || token.isEmpty) {
        scaffold.showSnackBar(const SnackBar(content: Text('No autenticado')));
        return;
      }

      final response = await ApiClient.postJson(
        '/pagos/stripe/session',
        token: token,
        body: {'id_configuracion': _seguroConfigId},
      );
      final checkoutUrl = _extractCheckoutUrl(response);
      if (checkoutUrl == null) {
        throw Exception('No se recibió el enlace de Stripe.');
      }

      final launched = await launchUrl(
        Uri.parse(checkoutUrl),
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception('No se pudo abrir la ventana de pago.');
      }

      scaffold.showSnackBar(
        const SnackBar(
          content: Text('Stripe se abrió en otra ventana. Completa el pago y luego valida la referencia.'),
        ),
      );
    } catch (e) {
      scaffold.showSnackBar(SnackBar(content: Text('No se pudo iniciar el pago: $e')));
    } finally {
      if (mounted) {
        setState(() => _launchingSeguroStripe = false);
      }
    }
  }

  Future<void> _checkSeguroPaymentStatus(String label) async {
    final scaffold = ScaffoldMessenger.of(context);
    try {
      setState(() => _checkingSeguroPayment = true);
      final token = await _storage.read(key: 'auth_token');
      if (token == null || token.isEmpty) {
        scaffold.showSnackBar(const SnackBar(content: Text('No autenticado')));
        return;
      }

      final response = await ApiClient.getJson('/pagos?id_configuracion=$_seguroConfigId&per_page=5', token: token);
      final pagos = _extractPagos(response);
      if (pagos.isEmpty) {
        scaffold.showSnackBar(const SnackBar(content: Text('No encontramos pagos registrados para este concepto.')));
        return;
      }

      final pago = pagos.first;
      final referencia = (pago['referencia'] ?? pago['stripeSessionId'] ?? 'Sin referencia').toString();
      final estadoTexto = (pago['estadoValidacionTexto'] ?? pago['estado_validacion_texto'] ?? 'En proceso').toString();

      setState(() {
        _seguroReference = referencia;
        _seguroStatusText = estadoTexto;
      });

      final validado = _isPagoValidado(pago);
      if (validado) {
        widget.onUpload(label);
      }

      scaffold.showSnackBar(
        SnackBar(
          content: Text(validado
              ? 'Pago validado. Referencia: $referencia'
              : 'Último pago encontrado ($referencia): $estadoTexto'),
        ),
      );
    } catch (e) {
      scaffold.showSnackBar(SnackBar(content: Text('No se pudo validar: $e')));
    } finally {
      if (mounted) {
        setState(() => _checkingSeguroPayment = false);
      }
    }
  }

  List<Map<String, dynamic>> _extractPagos(Map<String, dynamic> payload) {
    final data = payload['data'];
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }
    if (data is Map<String, dynamic>) {
      final inner = data['data'];
      if (inner is List) {
        return inner.whereType<Map<String, dynamic>>().toList();
      }
    }
    return [];
  }

  bool _isPagoValidado(Map<String, dynamic> pago) {
    final estado = pago['estadoValidacion'] ?? pago['estado_validacion'];
    if (estado is num) {
      return estado.toInt() == 2;
    }
    final etiqueta = (pago['estadoValidacionTexto'] ?? pago['estado_validacion_texto'] ?? '').toString().toLowerCase();
    return etiqueta.contains('valid');
  }

  String? _extractCheckoutUrl(Map<String, dynamic> payload) {
    final candidates = <String?>[
      payload['checkout_url'] as String?,
      payload['url'] as String?,
      payload['redirect_url'] as String?,
      payload['checkoutUrl'] as String?,
    ];
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      candidates.addAll([
        data['checkout_url'] as String?,
        data['url'] as String?,
        data['redirect_url'] as String?,
        data['checkoutUrl'] as String?,
      ]);
    }
    for (final candidate in candidates) {
      if (candidate != null && candidate.isNotEmpty) {
        return candidate;
      }
    }
    return null;
  }

}