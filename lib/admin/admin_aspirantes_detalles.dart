import 'package:flutter/material.dart';

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
