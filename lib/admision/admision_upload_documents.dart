import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:siiadmision/config/aspirante_progress.dart';

class UploadDocumentsScreen extends StatefulWidget {
  const UploadDocumentsScreen({super.key});

  @override
  State<UploadDocumentsScreen> createState() => _UploadDocumentsScreenState();
}

class _UploadDocumentsScreenState extends State<UploadDocumentsScreen> {
  final Map<String, bool> _uploadedStatus = {
    'Acta de Nacimiento': true,
    'CURP actualizado': true,
    'Certificado de Bachillerato o Constancia': true,
    'Foto Tamaño Infantil': true,
    'Comprobante de Número de Seguridad Social del IMSS': true,
    'Comprobante de Domicilio': true,
    'Pago de Inscripción y Orden de Cobro': true,
    'Pago de Seguro y Credencial': true,
  };

  bool get _allUploaded => _uploadedStatus.values.every((uploaded) => uploaded);

  void _uploadDocument(String label) {
    setState(() {
      _uploadedStatus[label] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      body: Row(
        children: [
          Expanded(
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = constraints.maxWidth;
                  final contentWidth = screenWidth.clamp(320.0, 1000.0);

                  return Column(
                    children: [
                      const SizedBox(height: 24),
                      Expanded(
                        child: Center(
                          child: Container(
                            width: contentWidth,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
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
                            child: Row(
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
                                  child: Padding(
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
                                              onUpload: _uploadDocument,
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
                                  ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showHelpDialog(context),
        tooltip: 'Ayuda',
        child: const Icon(Icons.help_outline),
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

class DocumentUploadForm extends StatelessWidget {
  final Map<String, bool> uploadedStatus;
  final void Function(String) onUpload;

  const DocumentUploadForm({super.key, required this.uploadedStatus, required this.onUpload});

  Widget _uploadField(BuildContext context, String label, bool uploaded) {
    final statusText = uploaded ? 'Cargado' : 'Pendiente';
    final statusColor = uploaded ? Colors.green : Colors.orange;

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
            child: OutlinedButton.icon(
              onPressed: () => pickPdf(label),
              icon: const Icon(Icons.upload_file),
              label: const Text('Subir archivo PDF'),
            ),
          ),
          const SizedBox(width: 8),
          Chip(
            label: Text(statusText),
            backgroundColor: statusColor.withOpacity(0.2),
            labelStyle: TextStyle(color: statusColor),
            side: BorderSide(color: statusColor),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final docs = uploadedStatus.keys.toList();
    return Column(
      children: docs.map((doc) => _uploadField(context, doc, uploadedStatus[doc]!)).toList(),
    );
  }

    Future<void> pickPdf(String documentName) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      final file = result.files.single;

      // Aquí puedes enviar el archivo al servidor
      await uploadFile(file.path!, documentName);
    }
  }

  Future<void> uploadFile(String path, String documentName) async {
  final uri = Uri.parse('https://127.0.0.1:8000/api/subir-documento');

  final request = http.MultipartRequest('POST', uri)
    ..fields['documento'] = documentName
    ..files.add(await http.MultipartFile.fromPath('archivo', path));

  final response = await request.send();

  if (response.statusCode == 200) {
    // Éxito
    print('Documento subido correctamente');
  } else {
    // Error
    print('Error al subir el documento');
  }
}

}
