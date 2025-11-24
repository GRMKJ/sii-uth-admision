import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DocumentosScreen extends StatelessWidget {
  const DocumentosScreen({super.key});

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
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 0),
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
        padding: const EdgeInsets.only(top: 8, right: 16),
        child: FloatingActionButton(
          onPressed: () => _showHelpDialog(context),
          tooltip: 'Ayuda',
          child: const Icon(Icons.help_outline),
        ),
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
            'Bienvenido @Nombre, Fuiste aceptado en la UTH, el siguiente paso es ayudarnos con estos, documentos para tu inscripción:',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: const DocumentosTable(),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () {
                context.push('/admision/documentos/subida');
              },
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
}



class DocumentosTable extends StatelessWidget {
  const DocumentosTable({super.key});

  static const List<Map<String, String>> _documents = [
    {
      'doc': 'Acta de Nacimiento',
      'format': 'Formato PDF',
      'obs': 'Si en el reverso tiene cualquier información en texto o gráfico debes incluirlo.',
    },
    {
      'doc': 'CURP actualizado',
      'format': 'Formato PDF',
      'obs': 'La puedes descargar de https://www.gob.mx/curp/.',
    },
    {
      'doc': 'Certificado de Bachillerato o Constancia',
      'format': 'Formato PDF',
      'obs': 'En caso de no contar aún con el certificado deberás subir una constancia reciente emitida por tu escuela con firma y sello del director.',
    },
    {
      'doc': 'Foto Tamaño Infantil',
      'format': 'Formato JPG',
      'obs': 'Fondo blanco, reciente, vestimenta formal y preferentemente a color.',
    },
    {
      'doc': 'Comprobante de Número de Seguridad Social del IMSS',
      'format': 'Formato PDF',
      'obs': 'Es el comprobante que emite el IMSS con tu número de seguridad social. Puedes solicitarlo en http://www.imss.gob.mx/.',
    },
    {
      'doc': 'Comprobante de Domicilio',
      'format': 'Formato PDF',
      'obs': 'Recibo de luz, teléfono, agua o predial con antigüedad máxima de 2 meses (no importa a qué nombre esté).',
    },
    {
      'doc': 'Pago de Inscripción y Orden de Cobro',
      'format': 'Referencia de Pago',
      'obs': 'Adjunta la referencia u orden de cobro pagada para la cuota de inscripción/reinscripción; debe coincidir con el beneficiario y el monto emitido.',
    },
    {
      'doc': 'Pago de Seguro y Credencial',
      'format': 'Referencia de Pago',
      'obs': 'Realiza el pago en línea o en la caja del edificio "A" y conserva el comprobante; al registrarse se validará automáticamente.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final headerStyle = Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold);
    final cellStyle = Theme.of(context).textTheme.bodyMedium;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 720;
        if (isCompact) {
          return Column(
            children: _documents
                .map(
                  (doc) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Card(
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(doc['doc']!, style: headerStyle),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.insert_drive_file_outlined, size: 18),
                                const SizedBox(width: 6),
                                Expanded(child: Text('Formato: ${doc['format']}', style: cellStyle)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(doc['obs']!, style: cellStyle),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          );
        }

        TableRow row(Map<String, String> doc) => TableRow(
              children: [
                Padding(padding: const EdgeInsets.all(8), child: Text(doc['doc']!, style: cellStyle, softWrap: true)),
                Padding(padding: const EdgeInsets.all(8), child: Text(doc['format']!, style: cellStyle)),
                Padding(padding: const EdgeInsets.all(8), child: Text(doc['obs']!, style: cellStyle, softWrap: true)),
              ],
            );

        return Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(6),
          },
          border: TableBorder.all(color: Colors.black26),
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.black12),
              children: [
                Padding(padding: const EdgeInsets.all(8), child: Text('Documento', style: headerStyle)),
                Padding(padding: const EdgeInsets.all(8), child: Text('Formato', style: headerStyle)),
                Padding(padding: const EdgeInsets.all(8), child: Text('Observaciones', style: headerStyle)),
              ],
            ),
            ..._documents.map(row),
          ],
        );
      },
    );
  }
}