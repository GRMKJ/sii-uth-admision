import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:siiadmision/config/api_client.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _identityCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _identityCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);
    final scaffold = ScaffoldMessenger.of(context);
    try {
      // El backend autoidentifica el tipo de cuenta a partir del identificador
      final res = await ApiClient.postJson(
        '/auth/forgot',
        body: {
          'identity': _identityCtrl.text.trim(),
        },
      );

      if (res['success'] == true) {
        scaffold.showSnackBar(
          const SnackBar(
            content: Text('Si la cuenta existe, se enviaron instrucciones.'),
          ),
        );
      } else {
        final msg = (res['message'] ?? 'No fue posible procesar la solicitud').toString();
        scaffold.showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      scaffold.showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final contentWidth = screenWidth.clamp(320.0, 1280.0);

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
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                                      BoxShadow(
                                        color: colors.shadow.withAlpha((0.1 * 255).round()),
                                        blurRadius: 12,
                                      ),
                        ],
                      ),
                      child: screenWidth < 640
                          ? _buildForgotColumn(context)
                          : _buildForgotRow(context),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildForgotRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: Image.asset(
              'assets/uth_building.jpg',
              fit: BoxFit.cover,
              height: double.infinity,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _buildForgotForm(context),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotColumn(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          child: Image.asset(
            'assets/uth_building.jpg',
            fit: BoxFit.cover,
            height: 180,
            width: double.infinity,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _buildForgotForm(context),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotForm(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Recuperar contraseña',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ingresa tu identificador (CURP / Matrícula / Núm. Empleado). Si la cuenta existe, te enviaremos instrucciones.',
          style: textTheme.labelMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _identityCtrl,
                decoration: const InputDecoration(
                  labelText: 'Identificador',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Ingresa tu identificador'
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _sending ? null : () => context.go('/'),
                    child: const Text('Volver al inicio de sesión'),
                  ),
                  FilledButton.icon(
                    onPressed: _sending ? null : _submit,
                    icon: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    label: Text(_sending ? 'Enviando…' : 'Enviar instrucciones'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
