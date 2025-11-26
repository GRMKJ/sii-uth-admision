import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:siiadmision/config/api_client.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String token;
  final String role;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.token,
    required this.role,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _submitting = false;
  bool _obscure = true;

  @override
  void dispose() {
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final res = await ApiClient.postJson(
        '/auth/reset',
        body: {
          'email': widget.email,
          'token': widget.token,
          'role': widget.role,
          'password': _passCtrl.text,
          'password_confirmation': _confirmCtrl.text,
        },
      );

      if (!mounted) return;
      final scaffold = ScaffoldMessenger.of(context);
      if (res['success'] == true) {
        scaffold.showSnackBar(
          const SnackBar(content: Text('Contraseña restablecida. Inicia sesión.')),
        );
        context.go('/');
      } else {
        scaffold.showSnackBar(
          SnackBar(content: Text(res['message']?.toString() ?? 'No se pudo restablecer la contraseña')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final scaffold = ScaffoldMessenger.of(context);
      scaffold.showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final contentWidth = screenWidth.clamp(320.0, 1280.0);

            return Column(
              children: [
                Expanded(
                  child: Center(
                    child: Container(
                      width: contentWidth,
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
                          ? _buildResetColumn(context)
                          : _buildResetRow(context),
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

  Widget _buildResetRow(BuildContext context) {
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
            child: _buildResetForm(context),
          ),
        ),
      ],
    );
  }

  Widget _buildResetColumn(BuildContext context) {
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
            child: _buildResetForm(context),
          ),
        ),
      ],
    );
  }

  Widget _buildResetForm(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final roleLabel = const {
      'aspirante': 'Aspirante',
      'alumno': 'Alumno',
      'administrativo': 'Administrativo',
    }[widget.role] ?? widget.role;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Restablecer contraseña',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Estás restableciendo la contraseña para $roleLabel.',
            style: textTheme.labelMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _passCtrl,
            obscureText: _obscure,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Nueva contraseña',
              prefixIcon: const Icon(Icons.lock_outline),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Ingresa la nueva contraseña';
              if (v.length < 8) return 'Debe tener al menos 8 caracteres';
              if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Incluye al menos una mayúscula';
              if (!RegExp(r'[0-9]').hasMatch(v)) return 'Incluye al menos un número';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmCtrl,
            obscureText: _obscure,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) {
              if (!_submitting) {
                _submit();
              }
            },
            decoration: const InputDecoration(
              labelText: 'Confirmar contraseña',
              prefixIcon: Icon(Icons.lock_reset),
              border: OutlineInputBorder(),
            ),
            validator: (v) {
              if (v != _passCtrl.text) return 'Las contraseñas no coinciden';
              return null;
            },
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final stackButtons = constraints.maxWidth < 420;
              final submitButton = FilledButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Text(_submitting ? 'Guardando…' : 'Restablecer'),
              );

              if (stackButtons) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: _submitting ? null : () => context.go('/'),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    submitButton,
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _submitting ? null : () => context.go('/'),
                    child: const Text('Cancelar'),
                  ),
                  submitButton,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}