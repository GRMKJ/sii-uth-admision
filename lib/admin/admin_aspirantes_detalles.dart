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
                      await ApiClient.postJson("/admin/pago/${widget.referencia}/validar");
                      ScaffoldMessenger.of(context).showSnackBar(
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
                      final res = await ApiClient.postJson("/admin/pago/${widget.referencia}/generar-folio");
                      ScaffoldMessenger.of(context).showSnackBar(
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
