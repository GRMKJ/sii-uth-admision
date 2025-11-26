import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:siiadmision/config/api_client.dart';
import 'package:siiadmision/config/session.dart';

class DocumentosStatusScreen extends StatefulWidget {
  const DocumentosStatusScreen({super.key});

  @override
  State<DocumentosStatusScreen> createState() => _DocumentosStatusScreenState();
}

class _DocumentosStatusScreenState extends State<DocumentosStatusScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _loading = true;
  bool _isValidated = false;
  bool _finalizing = false;
  String? _statusError;

  @override
  void initState() {
    super.initState();
    _checkDocumentStatus();
  }

  Future<void> _checkDocumentStatus() async {
    setState(() {
      _loading = true;
      _statusError = null;
    });

    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null || token.isEmpty) {
        throw Exception('Tu sesión expiró. Inicia sesión nuevamente.');
      }

      final response = await ApiClient.getJson('/documentos', token: token);
      final docs = (response['documentos'] as List?)?.cast<dynamic>() ?? const [];
      final validated = docs.isNotEmpty && docs.every((doc) {
        if (doc is Map<String, dynamic>) {
          final estado = doc['estado_validacion'];
          final value = estado is num ? estado.toInt() : int.tryParse('$estado');
          return (value ?? 0) >= 2;
        }
        return false;
      });

      if (!mounted) return;
      setState(() {
        _isValidated = validated;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusError = e.toString();
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No pudimos verificar tus documentos: $e')),
      );
    }
  }

  Future<void> _finalizeInscription() async {
    setState(() => _finalizing = true);
    String? token;
    try {
      token = await _storage.read(key: 'auth_token');
      if (token == null || token.isEmpty) {
        throw Exception('Tu sesión expiró. Inicia sesión nuevamente.');
      }

      await ApiClient.postJson('/aspirantes/finalize-documents', token: token);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tus documentos fueron validados. Revisar correo para tus accesos.'),
        ),
      );

      await _logoutAndRedirect(token);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No pudimos finalizar tu inscripción: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _finalizing = false);
      }
    }
  }

  Future<void> _logoutAndRedirect([String? token]) async {
    try {
      if (token != null && token.isNotEmpty) {
        await ApiClient.postJson('/auth/logout', token: token);
      }
    } catch (_) {
      // Ignorar errores al cerrar sesión en servidor.
    }

    final session = Session();
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'role');
    await session.clearPersistentIdentity();
    await session.clearPersistentRole();
    session.logout();

    if (!mounted) return;
    context.go('/');
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

    if (_statusError != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text('No pudimos obtener el estado de tus documentos', style: textTheme.headlineSmall, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(_statusError!, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _checkDocumentStatus,
            icon: const Icon(Icons.refresh),
            label: const Text('Intentar de nuevo'),
          ),
        ],
      );
    }

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
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _finalizing ? null : _finalizeInscription,
            icon: _finalizing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_circle_outline),
            label: Text(_finalizing ? 'Finalizando...' : 'Finalizar e ingresar como alumno'),
          ),
          const SizedBox(height: 12),
          Text(
            'Al continuar cerraremos tu sesión actual y recibirás un correo con tu matrícula y acceso al portal de alumnos.',
            textAlign: TextAlign.center,
          ),
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
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _checkDocumentStatus,
          icon: const Icon(Icons.refresh),
          label: const Text('Actualizar estado'),
        ),
      ],
    );
  }
}
