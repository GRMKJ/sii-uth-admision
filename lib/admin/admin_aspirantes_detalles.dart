import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:siiadmision/config/api_client.dart';

class ValidarPagoScreen extends StatelessWidget {
  final String referencia;
  const ValidarPagoScreen({super.key, required this.referencia});

  @override
  Widget build(BuildContext context) {
    return _ScaffoldBase(
      title: 'Validar Pago de $referencia',
      children: [
        const Text('Referencia: 1234567890'),
        const Text('Monto: \$500'),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Pago validado para $referencia')),
            );
            Navigator.pop(context);
          },
          child: const Text('Validar Pago'),
        ),
      ],
    );
  }
}

class VerDocumentosScreen extends StatelessWidget {
  final String referencia;
  const VerDocumentosScreen({super.key, required this.referencia});

  @override
  Widget build(BuildContext context) {
    return _ScaffoldBase(
      title: 'Documentos de $referencia',
      children: [
        const _DocumentoItem(nombre: 'CURP.pdf'),
        const _DocumentoItem(nombre: 'ActaNacimiento.pdf'),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Documentos validados para $referencia')),
            );
            Navigator.pop(context);
          },
          child: const Text('Validar Todos'),
        ),
      ],
    );
  }
}

class AutorizarInscripcionScreen extends StatelessWidget {
  final String referencia;
  const AutorizarInscripcionScreen({super.key, required this.referencia});

  @override
  Widget build(BuildContext context) {
    return _ScaffoldBase(
      title: 'Autorizar Inscripción $referencia',
      children: [
        const Text(
          'Al autorizar se generará la matrícula y se enviará correo al aspirante.',
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Inscripción autorizada para $referencia'),
              ),
            );
            Navigator.pop(context);
          },
          child: const Text('Confirmar Inscripción'),
        ),
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
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _fetchDetalle();
  }

  Future<void> _fetchDetalle() async {
    final token = await const FlutterSecureStorage().read(key: 'auth_token');
    final response = await ApiClient.getJson(
      "/admin/pago/${widget.referencia}",
      token: token,
    );
    if (mounted) setState(() => data = response['data']);
  }

  Future<void> _validarYGenerarFolio() async {
    setState(() => _busy = true);
    try {
      // 1. Validar pago
      await ApiClient.postJson("/admin/pago/${widget.referencia}/validar");

      // 2. Generar folio
      final res = await ApiClient.postJson(
        "/admin/pago/${widget.referencia}/generar-folio",
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Pago validado y folio generado: ${res['folio']}")),
      );
      await _fetchDetalle();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _informarReferenciaInvalida() async {
    final motivoCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Marcar referencia inválida'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: motivoCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Motivo para el aspirante',
                hintText: 'Ej. El comprobante no corresponde al banco',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Escribe un motivo' : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.send),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(ctx, true);
                }
              },
              label: const Text('Enviar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() => _busy = true);
    try {
      // Endpoint para marcar/informar referencia inválida
      // Ajusta la ruta si tu backend usa otra
      await ApiClient.postJson(
        "/admin/pago/${widget.referencia}/invalidar",
        body: {"motivo": motivoCtrl.text.trim()},
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aspirante notificado: referencia inválida')),
      );
      await _fetchDetalle();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al notificar: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final aspirante = data!['aspirante'];
    final pago = data!['pago'];

    return Scaffold(
      appBar: AppBar(
        title: Text("Pago Ref: ${pago['referencia']}"),
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: AbsorbPointer(
          absorbing: _busy,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${aspirante['nombre']} ${aspirante['ap_paterno']} ${aspirante['ap_materno']}",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text("Carrera: ${aspirante['carrera']?['carrera'] ?? 'Sin carrera'}"),
              const Divider(),
              Text("Referencia: ${pago['referencia']}"),
              Text("Estado: ${pago['estado_texto'] ?? pago['estado_validacion']}"),
              const Spacer(),
              if (_busy) const LinearProgressIndicator(),
              const SizedBox(height: 12),
              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _busy ? null : _validarYGenerarFolio,
                      icon: const Icon(Icons.check_circle),
                      label: const Text("Validar Pago y Generar Folio"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _busy ? null : _informarReferenciaInvalida,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Theme.of(context).colorScheme.onError,
                      ),
                      icon: const Icon(Icons.report_gmailerrorred),
                      label: const Text("Marcar como Referencia inválida"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}