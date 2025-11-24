import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:siiadmision/admision/models/bachillerato_form_data.dart';
import 'package:siiadmision/config/api_client.dart';
import 'package:url_launcher/url_launcher_string.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key, this.formData});
  final BachilleratoFormData? formData;
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _storage = const FlutterSecureStorage();
  bool _launchingStripe = false;
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 16, right: 16),
        child: FloatingActionButton(
          onPressed: _showHelpDialog,
          tooltip: 'Ayuda',
          child: const Icon(Icons.help_outline),
        ),
      ),
    );
  }

  Widget _formContent(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
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
          'Confirma tus datos y elige cómo realizar tu pago. Puedes iniciar un cobro seguro con Stripe o acudir a ventanilla.',
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        selectionMissing ? _missingSelectionCard(context) : _selectionSummaryCard(context, data),
        const SizedBox(height: 24),
        _paymentOptions(context),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.bottomRight,
          child: selectionMissing
              ? FilledButton(
                  onPressed: () => context.go('/admision/bachillerato'),
                  child: const Text('Capturar datos previos'),
                )
              : FilledButton.icon(
                  onPressed: _launchingStripe ? null : _startStripePayment,
                  icon: _launchingStripe
                      ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.onPrimary,
                        ),
                      )
                    : const Icon(Icons.credit_card),
                  label: Text(_launchingStripe ? 'Conectando…' : 'Pagar en Stripe (3.6 %)'),
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

  Widget _paymentOptions(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: colors.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.credit_card, size: 28, color: colors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Opción 1: Pago en línea (Stripe)",
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20, thickness: 1),
                const Text("Paga con tarjeta de crédito o débito mediante Stripe."),
                const SizedBox(height: 8),
                Text(
                  "Stripe aplica una comisión del 3.6 % sobre el monto de \$500.00, la cual se suma automáticamente antes de confirmar tu pago.",
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  "Después de completar el pago recibirás tu comprobante digital y podrás continuar con el registro sin acudir a la universidad.",
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.storefront, size: 28, color: colors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Opción 2: Pago en ventanilla",
                        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20, thickness: 1),
                const Text(
                  "Acude a la caja del edificio A de la Universidad Tecnológica de Huejotzingo para cubrir la cuota de \$500.00.",
                ),
                const SizedBox(height: 8),
                const Text("Lleva tu identificación y solicita registrar tu pago del examen de admisión."),
                const SizedBox(height: 8),
                const Text('Conserva tu comprobante sellado para seguimiento y validación en el sistema.'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _startStripePayment() async {
    final data = widget.formData;
    if (data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa primero tus datos de bachillerato.')),
      );
      context.go('/admision/bachillerato');
      return;
    }

    setState(() => _launchingStripe = true);
    try {
      final token = await _storage.read(key: 'auth_token');
      final response = await ApiClient.postJson(
        '/pagos/stripe/session',
        token: token,
        body: {
          'bachillerato_id': data.bachilleratoId,
          'promedio': data.promedio,
          'carrera_id': data.carreraId,
        },
      );
      final checkoutUrl = _extractCheckoutUrl(response);
      if (checkoutUrl == null) {
        throw Exception('No se recibió el enlace de Stripe.');
      }
      final launched = await launchUrlString(
        checkoutUrl,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw Exception('No se pudo abrir la ventana de pago.');
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stripe se abrió en otra ventana. Completa el pago y regresa para consultar el estado.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo iniciar el pago: $e')),
      );
    } finally {
      if (mounted) setState(() => _launchingStripe = false);
    }
  }

  String? _extractCheckoutUrl(Map<String, dynamic> payload) {
    final candidates = <String?>[
      payload['url'] as String?,
      payload['checkout_url'] as String?,
      payload['redirect_url'] as String?,
      payload['checkoutUrl'] as String?,
    ];
    final data = payload['data'];
    if (data is Map<String, dynamic>) {
      candidates.addAll([
        data['url'] as String?,
        data['checkout_url'] as String?,
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


}
