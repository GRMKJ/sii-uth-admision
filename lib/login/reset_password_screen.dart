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
    final scaffold = ScaffoldMessenger.of(context);
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
      scaffold.showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              elevation: 4,
              margin: const EdgeInsets.all(24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    shrinkWrap: true,
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
                        'Estás restableciendo la contraseña para ${{'aspirante':'Aspirante','alumno':'Alumno','administrativo':'Administrativo'}[widget.role] ?? widget.role}.',
                        style: textTheme.labelMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        enabled: false,
                        initialValue: widget.email,
                        decoration: const InputDecoration(
                          labelText: 'Correo',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure,
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
                      Row(
                        children: [
                          TextButton(
                            onPressed: _submitting ? null : () => context.go('/'),
                            child: const Text('Cancelar'),
                          ),
                          const Spacer(),
                          FilledButton.icon(
                            onPressed: _submitting ? null : _submit,
                            icon: _submitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.check),
                            label: Text(_submitting ? 'Guardando…' : 'Restablecer'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}