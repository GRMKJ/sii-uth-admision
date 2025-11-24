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
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Validando tus documentos...'),
                        ],
                      )
                    : Center(child: _buildStatusContent(context)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusContent(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (_isValidated) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified, size: 64, color: Colors.green),
          const SizedBox(height: 16),
          Text(
            '¡Documentos validados!',
            style: textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Revisa tu correo electrónico. Si no recibes información de seguimiento en las próximas horas, contáctanos:',
            style: textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text('📧 aspirante@uth.edu.mx'),
          const Text('📞 227 275 9311'),
          const Text('📞 227 275 9313'),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.hourglass_top, size: 64),
        const SizedBox(height: 16),
        Text(
          'Tus documentos están en revisión',
          style: textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Espera el correo con la confirmación. Si no lo recibes en las próximas horas, comunícate con nosotros.',
          style: textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
