import 'package:flutter/material.dart';

class PaymentStatusScreen extends StatefulWidget {
  const PaymentStatusScreen({super.key});

  @override
  State<PaymentStatusScreen> createState() => _PaymentStatusScreenState();
}

class _PaymentStatusScreenState extends State<PaymentStatusScreen> {
  bool _loading = true;
  bool _isValidated = false;
  String? _folio;

  @override
  void initState() {
    super.initState();
    _checkPaymentStatus();
  }

  Future<void> _checkPaymentStatus() async {
    await Future.delayed(const Duration(seconds: 5)); // Simular delay de API

    // Simular respuesta
    final response = {
      'validated': true,
      'folio': 'EX123456'
    };

    setState(() {
      _isValidated = response['validated'] as bool? ?? false;
      _folio = response['folio'] as String?;
      _loading = false;
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
                  //final isMobile = screenWidth < 640;

                  return Column(
                    children: [
                      const SizedBox(height: 24),
                      Expanded(
                        child: Center(
                          child: Container(
                            width: contentWidth,
                            padding: const EdgeInsets.all(24),
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
                            child: _loading
                                ? const CircularProgressIndicator()
                                : _isValidated
                                    ? Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.verified, size: 64, color: Colors.green),
                                          const SizedBox(height: 16),
                                          Text(
                                            '¡Pago validado con éxito!',
                                            style: Theme.of(context).textTheme.headlineSmall,
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Tu folio de examen es:',
                                            style: Theme.of(context).textTheme.bodyLarge,
                                          ),
                                          const SizedBox(height: 8),
                                          SelectableText(
                                            _folio ?? '',
                                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.hourglass_top, size: 64),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Aún estamos validando tu pago',
                                            style: Theme.of(context).textTheme.headlineSmall,
                                          ),
                                          const SizedBox(height: 12),
                                          const Text(
                                            'Por favor espera hasta recibir confirmación por correo.',
                                            textAlign: TextAlign.center,
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
    );
  }
}
