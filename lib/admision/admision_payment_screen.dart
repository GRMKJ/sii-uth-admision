import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:siiadmision/admision/models/bachillerato_form_data.dart';
import 'package:siiadmision/config/api_client.dart';
import 'package:siiadmision/config/aspirante_progress.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, this.formData});

  final BachilleratoFormData? formData;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _referenceController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  bool _submitting = false;

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final contentWidth = screenWidth.clamp(320.0, 1280.0);
                final isMobile = screenWidth < 640;

                return Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: Container(
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
                                      child: SingleChildScrollView(
                                        padding: const EdgeInsets.all(32),
                                        child: _formContent(context),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showHelpDialog,
        tooltip: 'Ayuda',
        child: const Icon(Icons.help_outline),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  Widget _formContent(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final data = widget.formData;
    final selectionMissing = data == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pago de examen',
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          'Confirma tus datos y captura la referencia del depósito para completar el registro.',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        selectionMissing ? _missingSelectionCard(context) : _selectionSummaryCard(context, data),
        const SizedBox(height: 24),
        _depositCard(context),
        const SizedBox(height: 24),
        TextField(
          controller: _referenceController,
          enabled: !selectionMissing && !_submitting,
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
            onPressed: selectionMissing
                ? () => context.go('/admision/bachillerato')
                : (_submitting ? null : _submitForm),
            child: Text(selectionMissing
                ? 'Capturar datos previos'
                : (_submitting ? 'Guardando…' : 'Siguiente')),
          ),
        ),
      ],
    );
  }

  Widget _missingSelectionCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.errorContainer,
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Falta información',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Antes de registrar tu pago debes elegir tu bachillerato de procedencia y la carrera a la que deseas aplicar.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _selectionSummaryCard(BuildContext context, BachilleratoFormData data) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen de selección',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.school),
              title: const Text('Bachillerato'),
              subtitle: Text(data.bachilleratoDescripcion ?? data.bachilleratoId),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.school_outlined),
              title: const Text('Carrera'),
              subtitle: Text(data.carreraNombre ?? data.carreraId),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.grade),
              title: const Text('Promedio general'),
              subtitle: Text(data.promedio),
            ),
          ],
        ),
      ),
    );
  }

  Widget _depositCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: colors.surfaceContainerHighest,
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance, size: 28),
                SizedBox(width: 8),
                Text(
                  'Datos de Depósito',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(height: 20, thickness: 1),
            Text('Banco: SANTANDER'),
            Text('Nombre: UNIVERSIDAD TECNOLÓGICA DE HUEJOTZINGO'),
            Text('Número de Cuenta: 6551 0840 686'),
            Text('CLABE: 0146 5065 5108 4068 63'),
            Text('Cantidad: 500.00'),
            SizedBox(height: 8),
            Text(
              'NOTA: Verifique y realice correctamente su pago ya que no aplica devolución o reembolso por cualquier motivo.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    final data = widget.formData;
    if (data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa primero tus datos de bachillerato.')),
      );
      return;
    }

    if (_referenceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa la referencia de pago.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final token = await _storage.read(key: 'auth_token');
      await ApiClient.postJson(
        '/aspirantes/pago',
        token: token,
        body: {
          'bachillerato_id': data.bachilleratoId,
          'promedio': data.promedio,
          'carrera_id': data.carreraId,
          'referencia': _referenceController.text.trim(),
        },
      );
      if (!mounted) return;
      _showConfirmationDialog();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
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
            Expanded(
              child: Text(
                '¿Necesitas ayuda?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
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
                    title: const Text(
                      'Acepto que los datos proporcionados son correctos',
                    ),
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
                            const SnackBar(
                              content: Text('Registro confirmado'),
                            ),
                          );
                          ProgressService.saveStep(3);
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
