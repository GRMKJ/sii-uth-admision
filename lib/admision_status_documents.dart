import 'package:flutter/material.dart';

class DocumentosStatusScreen extends StatefulWidget {
  const DocumentosStatusScreen({super.key});

  @override
  State<DocumentosStatusScreen> createState() => _DocumentosStatusScreenState();
}

class _DocumentosStatusScreenState extends State<DocumentosStatusScreen> {
  bool _loading = true;
  bool _isValidated = false;

  @override
  void initState() {
    super.initState();
    _checkDocumentStatus();
  }

  Future<void> _checkDocumentStatus() async {
    await Future.delayed(const Duration(seconds: 5)); // Simulación de llamada API

    // Simular respuesta
    final response = {
      'validated': true,
    };

    setState(() {
      _isValidated = response['validated'] ?? false;
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
                                ? const Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(height: 16),
                                      Text('Validando tus documentos...'),
                                    ],
                                  )
                                : _isValidated
                                    ? Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.verified_user, size: 64, color: Colors.green),
                                          const SizedBox(height: 16),
                                          Text(
                                            '¡Documentos validados!',
                                            style: Theme.of(context).textTheme.headlineSmall,
                                          ),
                                          const SizedBox(height: 12),
                                          const Text(
                                            'Revisa tu correo electrónico. Si no recibiste información de seguimiento en las próximas horas:',
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 12),
                                          const Text('📧 Correo: aspirante@uth.edu.mx'),
                                          const Text('📞 Teléfonos:'),
                                          const Text('227 275 9311'),
                                          const Text('227 275 9313'),
                                        ],
                                      )
                                    : Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.hourglass_top_rounded, size: 64),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Tus documentos están en revisión',
                                            style: Theme.of(context).textTheme.headlineSmall,
                                          ),
                                          const SizedBox(height: 12),
                                          const Text(
                                            'Espera el correo con la confirmación. Si no lo recibes, contáctanos.',
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
