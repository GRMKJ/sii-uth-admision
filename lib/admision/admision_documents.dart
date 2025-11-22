import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DocumentosScreen extends StatelessWidget {
  const DocumentosScreen({super.key});

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
                                        color: colors.shadow.withAlpha((0.1 * 255).round()),
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
                                          'Bienvenido @Nombre, Fuiste aceptado en la UTH, el siguiente paso es ayudarnos con estos, documentos para tu inscripción:',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        const SizedBox(height: 16),
                                        const Expanded(
                                          child: SingleChildScrollView(
                                            child: DocumentosTable(),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: FilledButton(
                                            onPressed: () {
                                                context.push('/admision/documentos/subida'); // Navegar a la pantalla de carga de documentos
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
}



class DocumentosTable extends StatelessWidget {
  const DocumentosTable({super.key});

  @override
  Widget build(BuildContext context) {
    final headerStyle = Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold);
    final cellStyle = Theme.of(context).textTheme.bodyMedium;

    TableRow row(String doc, String formato, String obs) => TableRow(
          children: [
            Padding(padding: const EdgeInsets.all(8), child: Text(doc, style: cellStyle, softWrap: true)),
            Padding(padding: const EdgeInsets.all(8), child: Text(formato, style: cellStyle)),
            Padding(padding: const EdgeInsets.all(8), child: Text(obs, style: cellStyle, softWrap: true)),
          ],
        );

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: IntrinsicColumnWidth(),
        2: FlexColumnWidth(5),
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
        row('Acta de Nacimiento', 'Formato PDF', 'Si en el reverso tiene cualquier información en texto o gráfico debes incluirlo'),
        row('CURP actualizado', 'Formato PDF', 'La puedes descargar de https://www.gob.mx/curp/'),
        row('Certificado de Bachillerato', 'Formato PDF', 'Si en el reverso tiene cualquier información en texto o gráfico debes incluirlo\nEn caso de no contar en el momento de la inscripción con el CERTIFICADO de estudios, deberá presentar una constancia de estudios expedida con fecha reciente por la institución de la que egresa, en la cual se especifique la situación actual de sus estudios, la fecha, el promedio, historial académico, en caso de ser egresado el periodo de acreditación de todas las asignaturas, firmada y sellada por el Director de la Escuela.\nEste documento no exime de la presentación del certificado de terminación de estudios.'),
        row('Foto Tamaño Infantil', 'Formato PDF', 'Fondo blanco, reciente, vestimenta formal y preferentemente a color'),
        row('Comprobante de Número de Seguridad Social del IMSS', 'Formato PDF', 'Es para aplicar tu derecho como estudiante de registro ante el Seguro Facultativo ante el Instituto Mexicano del Seguro Social.\nSe puede tramitar en http://www.imss.gob.mx/\nSi no requieres que te registremos en este servicio, es porque cuentas con otro servicio de Seguridad Social (Seguro del Bienestar, ISSSTE, ISSSTEP, PEMEX, etc.) y de igual forma debes contar con el comprobante de tal servicio'),
        row('Comprobante de tu Domicilio', 'Formato PDF', 'Es un recibo de servicios tal como luz, teléfono, predial; con una antigüedad máxima de 2 meses (no importa a qué nombre esté)'),
        row('Comprobante de Pago Realizado de Inscripción y Orden de Cobro', 'Formato PDF', 'Por el concepto UTHUEJOTZINGO POR CUOTA DE INSCRIPCIÓN Y/O REINSCRIPCIÓN POR CUATRIMESTRE\nAmbos documentos en un mismo archivo PDF\nPuedes generar la orden de pago en el portal https://rl.puebla.gob.mx/tramites/703\nSi su pago lo realizó en línea con "PAGO CON TARJETA DE CRÉDITO" no hay Orden de Cobro\nSigue la instrucción, pues en caso de cometer algún error no será posible realizar devolución o reembolso de cualquiera de estos pagos.'),
        row('Comprobante de Pago Realizado de Seguro y Credencial', 'Formato PDF', 'Este pago se realiza en efectivo en la caja de la UTH ubicada en el edificio "A".\nSolo debe proporcionar nombre completo y Clave de Aspirante (se encuentra en el correo de "Bienvenido a la UTH...")\nAntes de digitalizar el documento en PDF colocar Clave de Aspirante y nombre completo.\nSigue la instrucción, pues en caso de cometer algún error no será posible realizar devolución o reembolso de cualquiera de estos pagos.'),
      ],
    );
  }
}