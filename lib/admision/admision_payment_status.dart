import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:siiadmision/config/api_client.dart';

class PaymentStatusScreen extends StatefulWidget {
  const PaymentStatusScreen({super.key});

  @override
  State<PaymentStatusScreen> createState() => _PaymentStatusScreenState();
}

class _PaymentStatusScreenState extends State<PaymentStatusScreen> {
  bool _loading = true;
  bool _isValidated = false;
  String? _folio;
  bool _hasValidatedPayment = false;
  bool _generatedNow = false;
  String? _errorMessage;

  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkPaymentStatus();
  }

  Future<void> _checkPaymentStatus() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
      _generatedNow = false;
    });

    try {
      final token = await storage.read(key: 'auth_token');
      if (token == null) {
        throw Exception("Token no encontrado");
      }

      final response = await ApiClient.postJson(
        "/aspirantes/folio/ensure",
        token: token,
      );

      final folio = response['folio'];
      final hasPayment = response['has_validated_payment'] == true;
      final generatedNow = response['generated_now'] == true;

      setState(() {
        if (folio is String && folio.isNotEmpty) {
          _isValidated = true;
          _folio = folio;
        } else {
          _isValidated = false;
          _folio = null;
        }
        _hasValidatedPayment = hasPayment;
        _generatedNow = generatedNow;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _isValidated = false;
        _folio = null;
        _hasValidatedPayment = false;
        _generatedNow = false;
        _errorMessage = e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error al consultar folio: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1300),
            child: SizedBox.expand(
              child: Container(
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
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                        ? _PendingMessage(
                            icon: Icons.error_outline,
                            title: 'No pudimos verificar tu folio',
                            message: _errorMessage!,
                            onRetry: _checkPaymentStatus,
                          )
                        : _isValidated
                            ? _SuccessView(
                                folio: _folio ?? '',
                                generatedNow: _generatedNow,
                                onRefresh: _checkPaymentStatus,
                              )
                            : _PendingStatusView(
                                hasValidatedPayment: _hasValidatedPayment,
                                onRetry: _checkPaymentStatus,
                              ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final String folio;
  final bool generatedNow;
  final VoidCallback onRefresh;

  const _SuccessView({
    required this.folio,
    required this.generatedNow,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.verified, size: 64, color: Colors.green),
        const SizedBox(height: 16),
        Text('¡Pago validado con éxito!', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 12),
        Text('Tu folio de examen es:', style: theme.textTheme.bodyLarge),
        const SizedBox(height: 8),
        SelectableText(
          folio,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        if (generatedNow) ...[
          const SizedBox(height: 8),
          const Text(
            'Lo acabamos de generar y lo enviamos también a tu correo.',
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh),
          label: const Text('Volver a verificar'),
        ),
      ],
    );
  }
}

class _PendingStatusView extends StatelessWidget {
  final bool hasValidatedPayment;
  final VoidCallback onRetry;

  const _PendingStatusView({
    required this.hasValidatedPayment,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final title = hasValidatedPayment
        ? 'Estamos generando tu folio'
        : 'Aún no encontramos tu pago';
    final message = hasValidatedPayment
        ? 'Tu pago ya fue validado. Estamos terminando la generación del folio '
            'y lo recibirás por correo en unos instantes.'
        : 'No detectamos un pago validado de examen de admisión. Si ya realizaste '
            'el pago, espera unos minutos y vuelve a intentar o comunícate con admisiones.';

    return _PendingMessage(
      icon: hasValidatedPayment ? Icons.hourglass_top : Icons.info_outline,
      title: title,
      message: message,
      onRetry: onRetry,
    );
  }
}

class _PendingMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback onRetry;

  const _PendingMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 64),
        const SizedBox(height: 16),
        Text(title, style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Volver a verificar'),
        ),
      ],
    );
  }
}
