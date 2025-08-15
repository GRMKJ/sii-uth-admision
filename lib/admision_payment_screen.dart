import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _referenceController = TextEditingController();
  String? _selectedCarrera;
  final List<String> _carreras = [
    'Ingeniería en Tecnologías de la Información',
    'Ingeniería en Mecatrónica',
    'Ingeniería en Energías Renovables',
    'Ingeniería en Logística',
    'Licenciatura en Innovación de Negocios',
    'Licenciatura en Gestión del Capital Humano',
  ];

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
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
                  final isMobile = screenWidth < 640;

                  return Column(
                    children: [
                      const SizedBox(height: 24),
                      Expanded(
                        child: Center(
                          child: Container(
                            width: contentWidth,
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
                            child: isMobile
                                ? Column(
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
                                      Expanded(
                                        child: SingleChildScrollView(
                                          padding: const EdgeInsets.all(24),
                                          child: _formContent(context),
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
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
                                          child: _formContent(context),
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
        onPressed: _showHelpDialog,
        tooltip: 'Ayuda',
        child: const Icon(Icons.help_outline),
      ),
    );
  }

  Widget _formContent(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Admisión 2025', style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const Text('Ahora necesitas pagar la Evaluacion Diagnostica'),
        const SizedBox(height: 8),
        const Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'Puedes pagar directamente en la '),
              TextSpan(text: 'Caja de la UTH', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text('o mediante transferencia a la sig. cuenta:'),
        const SizedBox(height: 12),
        const Text('Banco: SANTANDER'),
        const Text('Nombre: UNIVERSIDAD TECNOLÓGICA DE HUEJOTZINGO'),
        const Text('Num de Cuenta: 6551 0840 686'),
        const Text('CLABE: 0146 5065 5108 4068 63'),
        const SizedBox(height: 8),
        const Text(
          'NOTA: Verifique y realice correctamente su pago ya que no aplica devolución o reembolso por cualquier motivo.',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text('Selecciona la carrera a la que deseas aplicar:'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCarrera,
          items: _carreras
              .map((carrera) => DropdownMenuItem(
                    value: carrera,
                    child: Text(carrera),
                  ))
              .toList(),
          decoration: const InputDecoration(
            labelText: 'Carrera',
            prefixIcon: Icon(Icons.school),
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => setState(() => _selectedCarrera = value),
        ),
        const SizedBox(height: 16),
        const Text('Una vez realizado el pago, registra tu correo y tu referencia de pago'),
        const SizedBox(height: 16),
        TextField(
          controller: _referenceController,
          decoration: const InputDecoration(
            labelText: 'Referencia de Pago',
            prefixIcon: Icon(Icons.confirmation_number),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.bottomRight,
          child: FilledButton(
            onPressed: () {
              if (_referenceController.text.isNotEmpty && _selectedCarrera != null) {
                _showConfirmationDialog();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Completa todos los campos obligatorios')),
                );
              }
            },
            child: const Text('Siguiente'),
          ),
        ),
      ],
    );
  }

  void _showHelpDialog() {
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
                  const Icon(Icons.receipt_long_rounded, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Confirmación de Pago',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Como confirmación de este paso, 5 días hábiles posteriores debes recibir\ncorreo electrónico de confirmación de pre registro con\nla instrucción para registro al examen de admisión.\n\nDe lo contrario, comunícate a:',
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 8),
                  const SelectableText('aspirante@uth.edu.mx'),
                  const Text('Tels. 227 275 9311'),
                  const Text('Tels. 227 275 9313'),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Acepto que los datos proporcionados son correctos'),
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Registro confirmado')),
                          );
                          context.push('/admision/pagoexamen/status');
                        }
                      : null,
                  child: const Text('Acepto'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
