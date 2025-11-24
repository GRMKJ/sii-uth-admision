import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:siiadmision/config/api_client.dart';
import 'package:siiadmision/config/aspirante_progress.dart';
import 'package:url_launcher/url_launcher.dart';

class UploadDocumentsScreen extends StatefulWidget {
  const UploadDocumentsScreen({super.key});

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
    // Traer estados desde el servidor al entrar a la vista
    _refreshStatuses();
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
            if (nombre.isNotEmpty && archivo.isNotEmpty) {
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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final contentWidth = screenWidth.clamp(320.0, 1280.0);
            final isMobile = screenWidth < 720;

            final card = Container(
              width: contentWidth,
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
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 0),
                      child: card,
                    ),
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
    return Padding(
      padding: const EdgeInsets.all(24),
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
          Expanded(
            child: SingleChildScrollView(
              child: DocumentUploadForm(
                uploadedStatus: _uploadedStatus,
                verifyingStatus: _verifyingStatus,
                onUpload: _uploadDocument,
                onVerifying: (label, value) {
                  setState(() {
                    _verifyingStatus[label] = value;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: _allUploaded ? _showConfirmationDialog : null,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Siguiente'),
                  Icon(Icons.arrow_right),
                ],
              ),
            ),
          ),
        ],
      ),
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
              contentPadding: const EdgeInsets.all(24),
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
  static final Uri _seguroPaymentUri = Uri.parse('https://pagos.uth.edu.mx/seguro-credencial');

  // Controlador para la referencia de pago de inscripción
  final Map<String, TextEditingController> _textControllers = {
    'Pago de Inscripción y Orden de Cobro': TextEditingController(),
  };

  Widget _uploadField(BuildContext context, String label, bool uploaded, bool isCompact) {
    final statusText = uploaded ? 'Cargado' : 'Pendiente';
    final statusColor = uploaded ? Colors.green : Colors.orange;
    final isVerifying = widget.verifyingStatus[label] == true;

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
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: refController,
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
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Estado de validación:', textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  statusChip,
                ],
              ),
            ],
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: refController,
                      decoration: const InputDecoration(
                        hintText: 'Referencia / Folio',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: (isVerifying || uploaded)
                        ? null
                        : () => _verifyInscripcion(label, refController.text.trim()),
                    child: const Text('Verificar'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Estado de validación:', textAlign: TextAlign.center),
                const SizedBox(height: 4),
                statusChip,
              ],
            ),
          ],
        ),
      );
    }

    if (label == 'Pago de Seguro y Credencial') {
      final Color statusColor = uploaded ? Colors.green : Colors.orange;
      final Widget statusChip = Chip(
        label: Text(uploaded ? 'Validado' : 'Pendiente'),
        backgroundColor: statusColor.withAlpha((0.2 * 255).round()),
        labelStyle: TextStyle(color: statusColor),
        side: BorderSide(color: statusColor),
      );

      final Widget info = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Realiza tu pago en línea o directamente en la caja del edificio "A".'),
          const SizedBox(height: 6),
          const Text('En cuanto registremos el pago este requisito quedará validado automáticamente.'),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _openSeguroPayment,
            icon: const Icon(Icons.payment),
            label: const Text('Pagar en línea'),
          ),
        ],
      );

      if (isCompact) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              info,
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Estado de validación:', textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  statusChip,
                ],
              ),
            ],
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            Expanded(
              flex: 4,
              child: info,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Estado de validación:', textAlign: TextAlign.center),
                const SizedBox(height: 4),
                statusChip,
              ],
            ),
          ],
        ),
      );
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
      onPressed: (isVerifying || uploaded) ? null : () => pickPdf(label),
      icon: const Icon(Icons.upload_file),
      label: const Text('Subir archivo PDF'),
    );

    if (isCompact) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(width: double.infinity, child: uploadButton),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Estado de validación:', textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  statusChip,
                ],
              ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 3,
            child: uploadButton,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Estado de validación:', textAlign: TextAlign.center),
              const SizedBox(height: 4),
              statusChip,
            ],
          ),
        ],
      ),
    );
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
        body: {'referencia': referencia},
        token: token,
      );

      if (res['success'] == true) {
        widget.onUpload(label);
        if (!mounted) return;
        scaffold.showSnackBar(const SnackBar(content: Text('Referencia verificada')));
      } else {
        final msg = (res['message'] ?? 'No verificado').toString();
        if (!mounted) return;
        scaffold.showSnackBar(SnackBar(content: Text(msg)));
      }
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
        return Column(
          children: docs
              .map(
                (doc) => _uploadField(
                  context,
                  doc,
                  widget.uploadedStatus[doc]!,
                  isCompact,
                ),
              )
              .toList(),
        );
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

  Future<void> _openSeguroPayment() async {
    final scaffold = ScaffoldMessenger.of(context);
    try {
      final launched = await launchUrl(
        _seguroPaymentUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        scaffold.showSnackBar(const SnackBar(content: Text('No se pudo abrir el portal de pago. Intenta más tarde.')));
      }
    } catch (_) {
      scaffold.showSnackBar(const SnackBar(content: Text('No se pudo abrir el portal de pago. Intenta más tarde.')));
    }
  }
}